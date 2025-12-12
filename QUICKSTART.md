# Act 1 Quick Start Guide

## ⚡ 5-Minute Setup

### Prerequisites
- Snowflake account with Streamlit enabled
- Warehouse with MEDIUM or larger size (for data generation performance)

---

## Step 1: Database Setup (2 minutes)

1. **Open Snowsight** → Go to **Worksheets**
2. **Create new SQL worksheet**
3. **Copy and paste** contents of `sql/01_setup_database.sql`
4. **Click "Run All"** (or select all and run)
5. **Wait for completion** - should see success message

**✅ Checkpoint:** You should see message: "Act 1 Database Setup Complete!"

---

## Step 2: Generate Data (1 minute)

1. **In same or new worksheet**
2. **Copy and paste** contents of `sql/02_generate_sample_data.sql`
3. **Click "Run All"**
4. **Wait 30-60 seconds** for data generation

**✅ Checkpoint:** 
- Success message: "Act 1 Data Generation Complete!"
- Verification queries show:
  - 100 devices
  - ~864,000 telemetry records
  - Device 4532 showing CRITICAL or WARNING status

---

## Step 3: Launch Dashboard (2 minutes)

1. **In Snowsight** → Go to **Projects** → **Streamlit**
2. **Click "+ Streamlit App"**
3. **Configure:**
   - Name: `PatientPoint Fleet Monitoring`
   - Database: `PREDICTIVE_MAINTENANCE`
   - Warehouse: (select your warehouse)
4. **Delete default code**
5. **Copy and paste** all contents from `streamlit/01_Fleet_Monitoring.py`
6. **Click "Run"**

**✅ Checkpoint:** Dashboard loads showing fleet overview

---

## Step 4: Validate (2 minutes)

### Test 1: Fleet Overview
- See 100 total devices
- Most showing "Healthy" status
- ~2-10 showing "Warning" or "Critical"

### Test 2: Problem Device
1. In "Device Deep Dive" dropdown, select **Device #4532**
2. Click **"🌡️ Temperature"** tab
   - Should see temperature climbing from ~65°F to 82°F+ in last 7 days
3. Click **"⚡ Power"** tab  
   - Should see power climbing from ~100W to 215W+ with spikes
4. Click **"⚠️ Errors"** tab
   - Should see errors increasing in last week

### Test 3: Healthy Device Comparison
1. Select **Device #4501** (or any other device)
2. Should see stable, normal metrics with small variation

**✅ All tests passed?** Act 1 is complete! 🎉

---

## 🎬 Quick Demo Script

> "This dashboard monitors 100 digital screens across 15 US cities. 
> 
> Most devices are healthy, but Device #4532 in Chicago is showing warning signs. [Select device]
> 
> Temperature has climbed from 65 to 82 degrees over the past week. Power consumption is spiking erratically up to 215 watts - normally it's stable at 100.
>
> This is a classic power supply degradation pattern. Without predictive maintenance, we'd only know about this when the device fails during business hours - that's lost revenue and an emergency $500 tech dispatch.
>
> Right now, an operator would need to manually check all 100 devices to spot this. In Act 2, we'll add machine learning to automatically detect these anomalies."

---

## 🐛 Quick Troubleshooting

**Dashboard shows "No data"**
```sql
-- Check data exists
USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA RAW_DATA;
SELECT COUNT(*) FROM DEVICE_INVENTORY;  -- Should be 100
```

**Device #4532 looks normal**
```sql
-- Check recent telemetry
SELECT TEMPERATURE_F, POWER_CONSUMPTION_W, TIMESTAMP
FROM SCREEN_TELEMETRY 
WHERE DEVICE_ID = '4532'
ORDER BY TIMESTAMP DESC
LIMIT 10;
-- Temperature should be 80-85°F, Power 200-220W
```

**Charts load slowly**
- Use a MEDIUM or LARGE warehouse
- Check that SCREEN_TELEMETRY is clustered by DEVICE_ID

---

## ✅ Success Criteria

You're ready for Act 2 when:
- ✅ Dashboard loads without errors
- ✅ Fleet shows 100 devices
- ✅ Device #4532 shows clear degradation in charts
- ✅ Can switch between devices smoothly
- ✅ Understand the data patterns

---

## 🚀 Next: Act 2

When ready, request Act 2 files for:
- Automatic anomaly detection using Cortex ML
- Watch list for flagged devices  
- Comparison of ML detection vs. manual thresholds

**Estimated time for Act 2:** 2-3 hours

