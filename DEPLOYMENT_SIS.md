# 🚀 Streamlit in Snowflake Deployment Guide

This project is designed for **Streamlit in Snowflake (SiS)** deployment, providing a native, secure, and scalable solution entirely within your Snowflake account.

## 🎯 Why Streamlit in Snowflake?

### Advantages

✅ **Zero External Infrastructure**: Everything runs in Snowflake  
✅ **Automatic Authentication**: Uses Snowflake login  
✅ **Enterprise Security**: Data never leaves your account  
✅ **RBAC Integration**: Governed by Snowflake roles  
✅ **No Secrets Management**: Native connection handling  
✅ **Instant Deployment**: No Docker, no cloud services  
✅ **Cost Effective**: Only pay for compute used  

### Use Cases

- **Operations Centers**: 24/7 monitoring dashboards
- **Executive Dashboards**: Real-time KPIs for leadership
- **Field Service Tools**: Mobile-accessible repair guidance
- **Data Science Demos**: Showcase ML models to stakeholders

---

## 📋 Prerequisites

1. **Snowflake Account** with:
   - Cortex AI features enabled (contact your account team)
   - ACCOUNTADMIN or equivalent role
   - A warehouse (e.g., `COMPUTE_WH`)

2. **SnowSQL** (optional, for file uploads)
   - Download: https://docs.snowflake.com/en/user-guide/snowsql.html

---

## 🚀 Step-by-Step Deployment

### Step 1: Backend Setup (5 minutes)

1. Open Snowflake (Snowsight UI)
2. Navigate to **Worksheets**
3. Create a new SQL worksheet
4. Copy entire contents of `setup_backend.sql`
5. Execute the script (takes ~2-3 minutes)

**Verification**:
```sql
-- Should return 500
SELECT COUNT(*) FROM PATIENTPOINT_OPS.DEVICE_ANALYTICS.FLEET_HEALTH_SCORED;

-- Should return summary metrics
SELECT * FROM PATIENTPOINT_OPS.DEVICE_ANALYTICS.VW_FLEET_HEALTH_METRICS;

-- Should list the search service
SHOW CORTEX SEARCH SERVICES IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS;
```

---

### Step 2: Create Stage for Streamlit Files (2 minutes)

```sql
-- Create stage to hold application files
CREATE OR REPLACE STAGE PATIENTPOINT_OPS.DEVICE_ANALYTICS.STREAMLIT_STAGE
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage for PatientPoint Command Center Streamlit app';

-- Verify stage created
SHOW STAGES IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS;
```

---

### Step 3: Upload Files to Stage (3 minutes)

You need to upload **2 files**: `dashboard_app.py` and `semantic_model.yaml`

#### Option A: Using Snowsight UI (Recommended)

1. In Snowsight, navigate to:
   - **Data** → **Databases** → **PATIENTPOINT_OPS** → **DEVICE_ANALYTICS** → **Stages**
2. Click on **STREAMLIT_STAGE**
3. Click **"+ Files"** button in top right
4. Upload these files:
   - `dashboard_app.py`
   - `semantic_model.yaml`
5. Verify files appear in the stage

#### Option B: Using SnowSQL

```bash
# Connect to Snowflake
snowsql -a <your_account> -u <your_username>

# Switch to the correct context
USE DATABASE PATIENTPOINT_OPS;
USE SCHEMA DEVICE_ANALYTICS;

# Upload files (run from your project directory)
PUT file://dashboard_app.py @STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file://semantic_model.yaml @STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

# Verify upload
LIST @STREAMLIT_STAGE;
```

---

### Step 4: Create Streamlit App (2 minutes)

```sql
-- Create the Streamlit in Snowflake application
CREATE OR REPLACE STREAMLIT PATIENTPOINT_OPS.DEVICE_ANALYTICS.COMMAND_CENTER
  ROOT_LOCATION = '@PATIENTPOINT_OPS.DEVICE_ANALYTICS.STREAMLIT_STAGE'
  MAIN_FILE = 'dashboard_app.py'
  QUERY_WAREHOUSE = COMPUTE_WH
  TITLE = 'PatientPoint Command Center'
  COMMENT = 'Predictive maintenance dashboard for medical device fleet management';

-- Grant access to your role (adjust as needed)
GRANT USAGE ON STREAMLIT PATIENTPOINT_OPS.DEVICE_ANALYTICS.COMMAND_CENTER TO ROLE ACCOUNTADMIN;
```

**Verification**:
```sql
-- Should show your new app
SHOW STREAMLITS IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS;
```

---

### Step 5: Launch Dashboard (1 minute)

1. In Snowsight, click **Streamlit** in the left navigation menu
2. You should see **COMMAND_CENTER** listed
3. Click on it to launch
4. Dashboard opens—ready to use! 🎉

**Expected View**:
- Top row: 4 KPI metrics
- Middle: Interactive geospatial map with 500 devices
- Bottom: Charts and AI agent interface

---

## 🔧 Configuration & Customization

### Changing the Warehouse

```sql
-- Use a different warehouse for compute
ALTER STREAMLIT PATIENTPOINT_OPS.DEVICE_ANALYTICS.COMMAND_CENTER 
  SET QUERY_WAREHOUSE = MY_OTHER_WAREHOUSE;
```

### Updating the App

After making changes to `dashboard_app.py`:

```sql
-- Re-upload the file (using SnowSQL or Snowsight UI)
PUT file://dashboard_app.py @PATIENTPOINT_OPS.DEVICE_ANALYTICS.STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- The app will automatically reload on next access
-- Or manually refresh in browser
```

### Updating the Semantic Model

After editing `semantic_model.yaml`:

```sql
-- Re-upload
PUT file://semantic_model.yaml @PATIENTPOINT_OPS.DEVICE_ANALYTICS.STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- Refresh the Streamlit app in browser
```

---

## 🔐 Security & Access Control

### Grant Access to Users

```sql
-- Create a read-only role for dashboard users
CREATE ROLE IF NOT EXISTS DASHBOARD_READER;

-- Grant database and schema access
GRANT USAGE ON DATABASE PATIENTPOINT_OPS TO ROLE DASHBOARD_READER;
GRANT USAGE ON SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DASHBOARD_READER;

-- Grant read access to tables and views
GRANT SELECT ON ALL TABLES IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DASHBOARD_READER;
GRANT SELECT ON ALL VIEWS IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DASHBOARD_READER;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DASHBOARD_READER;

-- Grant Cortex Search access
GRANT USAGE ON CORTEX SEARCH SERVICE PATIENTPOINT_OPS.DEVICE_ANALYTICS.RUNBOOK_SEARCH_SERVICE TO ROLE DASHBOARD_READER;

-- Grant Streamlit app access
GRANT USAGE ON STREAMLIT PATIENTPOINT_OPS.DEVICE_ANALYTICS.COMMAND_CENTER TO ROLE DASHBOARD_READER;

-- Assign role to users
GRANT ROLE DASHBOARD_READER TO USER alice;
GRANT ROLE DASHBOARD_READER TO USER bob;
```

### Restrict Access by IP

```sql
-- Create network policy (optional)
CREATE NETWORK POLICY dashboard_access_policy
  ALLOWED_IP_LIST = ('192.168.1.0/24', '10.0.0.0/8')
  COMMENT = 'Restrict dashboard access to corporate network';

-- Apply to role
ALTER USER alice SET NETWORK_POLICY = dashboard_access_policy;
```

---

## 📊 Monitoring & Maintenance

### Monitor App Usage

```sql
-- View who's using the app
SELECT 
    user_name,
    role_name,
    query_text,
    start_time,
    total_elapsed_time / 1000 AS elapsed_seconds,
    warehouse_name
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%FLEET_HEALTH_SCORED%'
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 100;
```

### Monitor Warehouse Costs

```sql
-- Compute costs for the dashboard warehouse
SELECT 
    warehouse_name,
    SUM(credits_used) AS total_credits,
    SUM(credits_used) * 3 AS estimated_cost_usd  -- Adjust multiplier for your pricing
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name = 'COMPUTE_WH'
  AND start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY warehouse_name;
```

### Refresh ML Scores (Optional)

If you want to simulate real-time ML inference updates:

```sql
-- Create a task to periodically update scores
CREATE OR REPLACE TASK PATIENTPOINT_OPS.DEVICE_ANALYTICS.REFRESH_DEVICE_SCORES
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 * * * * UTC'  -- Every hour
AS
    UPDATE PATIENTPOINT_OPS.DEVICE_ANALYTICS.FLEET_HEALTH_SCORED
    SET 
        failure_probability = LEAST(0.99, GREATEST(0.01, 
            failure_probability + UNIFORM(-0.05, 0.05, RANDOM()))),
        last_ping = CURRENT_TIMESTAMP(),
        cpu_load = ROUND(UNIFORM(10.0, 95.0, RANDOM()), 2),
        temperature = ROUND(UNIFORM(35.0, 85.0, RANDOM()), 2);

-- Enable the task
ALTER TASK PATIENTPOINT_OPS.DEVICE_ANALYTICS.REFRESH_DEVICE_SCORES RESUME;

-- To stop
ALTER TASK PATIENTPOINT_OPS.DEVICE_ANALYTICS.REFRESH_DEVICE_SCORES SUSPEND;
```

---

## 💰 Cost Optimization

### Estimated Monthly Costs

| Component | Configuration | Estimated Cost |
|-----------|--------------|----------------|
| Warehouse (X-Small, 4 hrs/day) | Auto-suspend after 5 min | $60/month |
| Storage (1GB) | Data + Streamlit files | $2/month |
| **Total** | | **~$62/month** |

### Best Practices

1. **Enable Auto-Suspend**:
```sql
ALTER WAREHOUSE COMPUTE_WH SET 
  AUTO_SUSPEND = 300  -- 5 minutes
  AUTO_RESUME = TRUE;
```

2. **Use Smaller Warehouse for Light Usage**:
```sql
ALTER STREAMLIT COMMAND_CENTER SET QUERY_WAREHOUSE = COMPUTE_XS_WH;
```

3. **Leverage Query Result Cache**: Identical queries within 24 hours are free

4. **Monitor and Optimize**: Review `QUERY_HISTORY` regularly for slow queries

---

## 🚨 Troubleshooting

### Issue: "Streamlit not found in navigation"

**Solution**: Ensure Streamlit feature is enabled in your account. Contact Snowflake support to enable.

### Issue: "Permission denied" on app launch

**Solution**:
```sql
-- Grant usage to your role
GRANT USAGE ON STREAMLIT COMMAND_CENTER TO ROLE YOUR_ROLE;

-- Grant necessary data permissions
GRANT SELECT ON ALL TABLES IN SCHEMA DEVICE_ANALYTICS TO ROLE YOUR_ROLE;
```

### Issue: "Warehouse not running"

**Solution**:
```sql
-- Check warehouse status
SHOW WAREHOUSES LIKE 'COMPUTE_WH';

-- Resume if suspended
ALTER WAREHOUSE COMPUTE_WH RESUME;

-- Or enable auto-resume
ALTER WAREHOUSE COMPUTE_WH SET AUTO_RESUME = TRUE;
```

### Issue: Map not rendering devices

**Solution**: Check browser console for errors. Ensure PyDeck is supported (modern browsers). Try refreshing the page.

### Issue: AI Agent not responding

**Solution**:
```sql
-- Verify Cortex Search Service exists
SHOW CORTEX SEARCH SERVICES IN SCHEMA DEVICE_ANALYTICS;

-- Grant usage permission
GRANT USAGE ON CORTEX SEARCH SERVICE RUNBOOK_SEARCH_SERVICE TO ROLE YOUR_ROLE;
```

---

## 🔄 Updating the App

### Making Code Changes

1. Edit `dashboard_app.py` locally
2. Upload to stage (overwrite existing):
```sql
PUT file://dashboard_app.py @STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
```
3. Refresh browser—changes take effect immediately

### Rolling Back

```sql
-- List file versions in stage
LIST @STREAMLIT_STAGE;

-- Restore previous version if needed
GET @STREAMLIT_STAGE/dashboard_app.py file://./dashboard_app_backup.py;
```

---

## 📱 Mobile Access

Streamlit in Snowflake apps are automatically mobile-responsive. Users can access via:

- **Mobile browser**: Navigate to Snowflake Snowsight, tap Streamlit → COMMAND_CENTER
- **Tablets**: Full functionality on iPad/Android tablets
- **Responsive design**: Layout adapts to screen size

---

## 🎓 Training Your Team

### For Executives
- Focus on **Section A (KPIs)** and **Section B (Map)**
- Key message: "18 devices need attention, $21,600 at risk"

### For Operations Managers
- Teach **AI Agent queries**: structured, unstructured, composite
- Show how to filter by region/hospital
- Demonstrate critical device table

### For Field Technicians
- Focus on **AI Agent → Search**: "How do I fix X?"
- Show repair manual search
- Explain safety notes in documentation

---

## 📚 Additional Resources

- **[README.md](README.md)**: Quick start and overview
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)**: Executive summary and ROI
- **[DATA_SCHEMA.md](DATA_SCHEMA.md)**: Database structure and queries
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Visual diagrams

### Snowflake Documentation
- [Streamlit in Snowflake Docs](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
- [Cortex AI Overview](https://docs.snowflake.com/en/user-guide/ml-powered-functions)
- [Security Best Practices](https://docs.snowflake.com/en/user-guide/security)

---

## ✅ Deployment Checklist

- [ ] Run `setup_backend.sql` successfully
- [ ] Create `STREAMLIT_STAGE` in correct schema
- [ ] Upload `dashboard_app.py` to stage
- [ ] Upload `semantic_model.yaml` to stage
- [ ] Create Streamlit app with correct parameters
- [ ] Grant permissions to user roles
- [ ] Test app launch in Snowsight
- [ ] Verify all 3 sections render correctly
- [ ] Test AI Agent queries (all 3 types)
- [ ] Configure warehouse auto-suspend
- [ ] Set up monitoring queries
- [ ] Train users on dashboard usage

---

## 🙏 Support

For issues or questions:

1. **Check troubleshooting section** above
2. **Review logs** in Snowflake query history
3. **Open issue** on [GitHub](https://github.com/sfc-gh-akelkar/ai_agent_predictive_maintenance/issues)
4. **Contact** your Snowflake account team

---

**Deployment Time**: ~15 minutes  
**Skill Level Required**: Intermediate SQL knowledge  
**Maintenance**: Minimal (Snowflake managed)  

**🎉 You're all set! Enjoy your PatientPoint Command Center!**

