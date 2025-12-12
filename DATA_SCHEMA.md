# Data Schema Documentation

This document describes the data structures used in the PatientPoint Command Center.

## Table of Contents

1. [FLEET_HEALTH_SCORED](#fleet_health_scored)
2. [MAINTENANCE_LOGS](#maintenance_logs)
3. [RUNBOOK_DOCS](#runbook_docs)
4. [Views](#views)
5. [Sample Queries](#sample-queries)

---

## FLEET_HEALTH_SCORED

**Purpose**: Real-time device health metrics and ML failure predictions

**Update Frequency**: Every hour (via ML inference pipeline)

**Row Count**: 500 (one per device)

### Schema

| Column Name | Data Type | Description | Example Values |
|------------|-----------|-------------|----------------|
| `device_id` | VARCHAR(50) | Unique device identifier | PP-00001, PP-00245 |
| `region` | VARCHAR(50) | US State where deployed | New York, California, Texas |
| `hospital_name` | VARCHAR(200) | Hospital facility name | Mount Sinai Hospital, UCLA Medical Center |
| `last_ping` | TIMESTAMP_LTZ | Last check-in time | 2025-12-12 14:30:22 |
| `cpu_load` | FLOAT | CPU utilization (0-100%) | 45.23, 87.91 |
| `voltage` | FLOAT | Power supply voltage (volts) | 118.45, 122.31 |
| `memory_usage` | FLOAT | RAM utilization (0-100%) | 62.14, 89.33 |
| `temperature` | FLOAT | Operating temperature (Celsius) | 58.2, 76.8 |
| `uptime_hours` | INTEGER | Hours since last service | 2453, 7834 |
| `failure_probability` | FLOAT | ML predicted failure probability (0-1) | 0.12, 0.89, 0.95 |
| `predicted_failure_type` | VARCHAR(100) | Most likely failure mode | Overheating, Memory Leak |
| `latitude` | FLOAT | Geographic latitude | 40.7903, 34.0754 |
| `longitude` | FLOAT | Geographic longitude | -73.9522, -118.3774 |
| `created_at` | TIMESTAMP_LTZ | Record creation time | 2025-12-12 15:00:00 |

### Primary Key
- `device_id`

### Indexes/Clustering
```sql
ALTER TABLE FLEET_HEALTH_SCORED CLUSTER BY (region, failure_probability);
```

### Data Distribution

**Failure Probability Distribution** (by design):
- Critical (>0.85): ~20 devices (4%)
- High (0.70-0.85): ~30 devices (6%)
- Medium (0.50-0.70): ~70 devices (14%)
- Low (<0.50): ~380 devices (76%)

**Regional Distribution**:
Devices spread across 30 major US hospital systems in 15+ states.

### Sample Query

```sql
-- Find all critical devices
SELECT 
    device_id,
    hospital_name,
    region,
    failure_probability,
    predicted_failure_type,
    temperature,
    cpu_load
FROM FLEET_HEALTH_SCORED
WHERE failure_probability > 0.85
ORDER BY failure_probability DESC;
```

---

## MAINTENANCE_LOGS

**Purpose**: Historical maintenance records for cost analysis and ROI calculations

**Update Frequency**: Real-time (as maintenance occurs)

**Row Count**: ~200 historical records (2 years of data)

### Schema

| Column Name | Data Type | Description | Example Values |
|------------|-----------|-------------|----------------|
| `log_id` | INTEGER | Auto-incrementing primary key | 1, 2, 3... |
| `device_id` | VARCHAR(50) | Device that was serviced | PP-00123 |
| `maintenance_date` | TIMESTAMP_LTZ | Date/time of maintenance | 2024-06-15 10:30:00 |
| `failure_type` | VARCHAR(100) | Type of failure addressed | Overheating, CPU Exhaustion |
| `downtime_hours` | FLOAT | Duration of outage | 2.5, 12.0 |
| `repair_cost` | FLOAT | Total cost (parts + labor) | 1250.00, 8500.50 |
| `parts_replaced` | VARCHAR(500) | Components that were replaced | Cooling fan, thermal paste |
| `technician_notes` | VARCHAR(2000) | Service notes | Routine maintenance completed... |
| `preventive` | BOOLEAN | Proactive vs reactive | TRUE, FALSE |
| `created_at` | TIMESTAMP_LTZ | Log entry timestamp | 2024-06-15 14:00:00 |

### Primary Key
- `log_id`

### Foreign Keys
- `device_id` → FLEET_HEALTH_SCORED.device_id

### Indexes
```sql
ALTER TABLE MAINTENANCE_LOGS CLUSTER BY (maintenance_date, device_id);
```

### Sample Query

```sql
-- Calculate average cost by failure type
SELECT 
    failure_type,
    COUNT(*) AS incident_count,
    ROUND(AVG(downtime_hours), 2) AS avg_downtime_hrs,
    ROUND(AVG(repair_cost), 2) AS avg_repair_cost,
    ROUND(SUM(repair_cost), 2) AS total_cost,
    SUM(IFF(preventive, 1, 0)) AS preventive_count,
    SUM(IFF(NOT preventive, 1, 0)) AS reactive_count
FROM MAINTENANCE_LOGS
GROUP BY failure_type
ORDER BY total_cost DESC;
```

---

## RUNBOOK_DOCS

**Purpose**: Repair manuals and troubleshooting procedures for Cortex Search

**Update Frequency**: As needed (documentation updates)

**Row Count**: 6 comprehensive repair guides

### Schema

| Column Name | Data Type | Description | Example Values |
|------------|-----------|-------------|----------------|
| `doc_id` | INTEGER | Auto-incrementing primary key | 1, 2, 3... |
| `title` | VARCHAR(500) | Document title | Overheating Component Diagnostic... |
| `failure_category` | VARCHAR(100) | Failure type this addresses | Overheating, Memory Leak |
| `content` | TEXT | Full repair procedure (3000+ words) | SYMPTOMS: Device temperature... |
| `severity` | VARCHAR(20) | Issue severity | Critical, High, Medium, Low |
| `estimated_repair_time` | VARCHAR(50) | Expected duration | 2-4 hours, 30 minutes - 2 hours |
| `required_tools` | VARCHAR(500) | Tools needed | Phillips screwdriver, multimeter |
| `safety_notes` | VARCHAR(1000) | Safety precautions | CRITICAL: Allow device to cool... |
| `created_at` | TIMESTAMP_LTZ | Document creation time | 2025-12-12 10:00:00 |

### Primary Key
- `doc_id`

### Full-Text Search
Indexed by Cortex Search Service on the `content` column for semantic search.

### Available Repair Guides

1. **Overheating Component Diagnostic and Repair Procedure**
   - Category: Overheating
   - Severity: High
   - Time: 2-4 hours

2. **Memory Leak Resolution and RAM Module Replacement**
   - Category: Memory Leak
   - Severity: Medium
   - Time: 1-3 hours

3. **CPU Exhaustion and Process Management**
   - Category: CPU Exhaustion
   - Severity: High
   - Time: 30 minutes - 2 hours

4. **Power Supply Failure and Voltage Stabilization**
   - Category: Power Supply Failure
   - Severity: Critical
   - Time: 2-4 hours

5. **Component Degradation and Preventive Maintenance Schedule**
   - Category: Component Degradation
   - Severity: Medium
   - Time: Ongoing

6. **System Instability and Software Corruption Recovery**
   - Category: System Instability
   - Severity: Variable
   - Time: 30 minutes - 8 hours

### Sample Query

```sql
-- Search for overheating repair procedures
SELECT
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PATIENTPOINT_OPS.DEVICE_ANALYTICS.RUNBOOK_SEARCH_SERVICE',
    '{
      "query": "How do I fix an overheating device?",
      "columns": ["title", "content", "severity", "estimated_repair_time"],
      "limit": 3
    }'
  ) AS search_results;
```

---

## Views

### VW_FLEET_HEALTH_METRICS

**Purpose**: Aggregated KPIs for dashboard top-line metrics

```sql
CREATE OR REPLACE VIEW VW_FLEET_HEALTH_METRICS AS
SELECT 
    COUNT(*) AS total_devices,
    SUM(CASE WHEN failure_probability > 0.85 THEN 1 ELSE 0 END) AS critical_devices,
    SUM(CASE WHEN failure_probability > 0.70 THEN 1 ELSE 0 END) AS high_risk_devices,
    ROUND(AVG(failure_probability), 3) AS avg_failure_probability,
    SUM(CASE WHEN failure_probability > 0.80 THEN 50 * 24 ELSE 0 END) AS revenue_at_risk_usd,
    SUM(CASE WHEN DATEDIFF(MINUTE, last_ping, CURRENT_TIMESTAMP()) > 60 THEN 1 ELSE 0 END) AS offline_devices
FROM FLEET_HEALTH_SCORED;
```

**Output Example**:

| total_devices | critical_devices | high_risk_devices | avg_failure_probability | revenue_at_risk_usd | offline_devices |
|--------------|------------------|-------------------|------------------------|-------------------|-----------------|
| 500 | 18 | 52 | 0.384 | 21600.00 | 3 |

### VW_REGIONAL_HEALTH

**Purpose**: Regional breakdown for geographic analysis

```sql
CREATE OR REPLACE VIEW VW_REGIONAL_HEALTH AS
SELECT 
    region,
    COUNT(*) AS total_devices,
    SUM(CASE WHEN failure_probability > 0.85 THEN 1 ELSE 0 END) AS critical_count,
    ROUND(AVG(failure_probability), 3) AS avg_failure_prob,
    SUM(CASE WHEN failure_probability > 0.80 THEN 50 * 24 ELSE 0 END) AS revenue_at_risk
FROM FLEET_HEALTH_SCORED
GROUP BY region
ORDER BY critical_count DESC;
```

**Output Example**:

| region | total_devices | critical_count | avg_failure_prob | revenue_at_risk |
|--------|--------------|----------------|-----------------|-----------------|
| California | 68 | 5 | 0.412 | 6000.00 |
| New York | 52 | 4 | 0.389 | 4800.00 |
| Texas | 45 | 3 | 0.354 | 3600.00 |

### VW_FAILURE_TYPE_ANALYSIS

**Purpose**: Analyze at-risk devices by failure type

```sql
CREATE OR REPLACE VIEW VW_FAILURE_TYPE_ANALYSIS AS
SELECT 
    predicted_failure_type,
    COUNT(*) AS device_count,
    ROUND(AVG(failure_probability), 3) AS avg_probability,
    ROUND(AVG(cpu_load), 2) AS avg_cpu_load,
    ROUND(AVG(memory_usage), 2) AS avg_memory_usage,
    ROUND(AVG(temperature), 2) AS avg_temperature
FROM FLEET_HEALTH_SCORED
WHERE failure_probability > 0.70
GROUP BY predicted_failure_type
ORDER BY device_count DESC;
```

**Output Example**:

| predicted_failure_type | device_count | avg_probability | avg_cpu_load | avg_memory_usage | avg_temperature |
|----------------------|-------------|----------------|-------------|-----------------|----------------|
| Overheating | 15 | 0.823 | 72.45 | 68.23 | 78.9 |
| Memory Leak | 12 | 0.791 | 65.32 | 91.45 | 62.1 |
| CPU Exhaustion | 10 | 0.785 | 89.67 | 73.12 | 64.5 |

---

## Sample Queries

### 1. Find Critical Devices Requiring Immediate Attention

```sql
SELECT 
    device_id,
    hospital_name,
    region,
    failure_probability,
    predicted_failure_type,
    DATEDIFF(MINUTE, last_ping, CURRENT_TIMESTAMP()) AS minutes_since_last_ping,
    temperature,
    cpu_load,
    memory_usage
FROM FLEET_HEALTH_SCORED
WHERE failure_probability > 0.85
ORDER BY failure_probability DESC
LIMIT 20;
```

### 2. Calculate Total Revenue at Risk by Region

```sql
SELECT 
    region,
    SUM(CASE WHEN failure_probability > 0.80 THEN 1 ELSE 0 END) AS critical_devices,
    SUM(CASE WHEN failure_probability > 0.80 THEN 50 * 24 ELSE 0 END) AS revenue_at_risk_24h,
    SUM(CASE WHEN failure_probability > 0.80 THEN 50 * 24 * 7 ELSE 0 END) AS revenue_at_risk_7d
FROM FLEET_HEALTH_SCORED
GROUP BY region
HAVING critical_devices > 0
ORDER BY revenue_at_risk_24h DESC;
```

### 3. Preventive vs Reactive Maintenance ROI

```sql
SELECT 
    preventive,
    COUNT(*) AS maintenance_count,
    ROUND(AVG(downtime_hours), 2) AS avg_downtime,
    ROUND(AVG(repair_cost), 2) AS avg_cost,
    ROUND(SUM(repair_cost), 2) AS total_cost,
    ROUND(AVG(downtime_hours * 50), 2) AS avg_revenue_loss
FROM MAINTENANCE_LOGS
GROUP BY preventive
ORDER BY preventive DESC;
```

**Expected Result**:
```
| preventive | maintenance_count | avg_downtime | avg_cost | total_cost | avg_revenue_loss |
|------------|------------------|--------------|----------|------------|------------------|
| TRUE       | 60               | 1.8          | 2500.00  | 150000.00  | 90.00            |
| FALSE      | 140              | 8.5          | 6800.00  | 952000.00  | 425.00           |
```

**Insight**: Preventive maintenance costs 63% less and causes 79% less downtime!

### 4. Find Devices with Multiple Failure Indicators

```sql
SELECT 
    device_id,
    hospital_name,
    region,
    failure_probability,
    predicted_failure_type,
    CASE WHEN temperature > 75 THEN 1 ELSE 0 END AS high_temp_flag,
    CASE WHEN cpu_load > 85 THEN 1 ELSE 0 END AS high_cpu_flag,
    CASE WHEN memory_usage > 85 THEN 1 ELSE 0 END AS high_memory_flag,
    CASE WHEN voltage < 115 OR voltage > 125 THEN 1 ELSE 0 END AS voltage_issue_flag
FROM FLEET_HEALTH_SCORED
WHERE (temperature > 75 OR cpu_load > 85 OR memory_usage > 85 OR voltage < 115 OR voltage > 125)
  AND failure_probability > 0.70
ORDER BY failure_probability DESC;
```

### 5. Time-Based Device Health Trends (Requires Historical Data)

```sql
-- Note: This assumes FLEET_HEALTH_SCORED_HISTORY table with hourly snapshots
SELECT 
    DATE_TRUNC('day', created_at) AS date,
    COUNT(DISTINCT device_id) AS total_devices,
    AVG(failure_probability) AS avg_failure_prob,
    SUM(CASE WHEN failure_probability > 0.85 THEN 1 ELSE 0 END) AS critical_count
FROM FLEET_HEALTH_SCORED_HISTORY
WHERE created_at >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY date;
```

### 6. Search Repair Documentation (Cortex Search)

```sql
-- Find all documentation related to power issues
SELECT
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PATIENTPOINT_OPS.DEVICE_ANALYTICS.RUNBOOK_SEARCH_SERVICE',
    '{
      "query": "power supply voltage failure repair",
      "columns": ["title", "failure_category", "severity", "estimated_repair_time", "safety_notes"],
      "filter": {"@eq": {"severity": "Critical"}},
      "limit": 5
    }'
  ) AS search_results;
```

### 7. Device Age and Failure Correlation

```sql
SELECT 
    CASE 
        WHEN uptime_hours < 8760 THEN '0-1 year'
        WHEN uptime_hours < 17520 THEN '1-2 years'
        WHEN uptime_hours < 26280 THEN '2-3 years'
        WHEN uptime_hours < 43800 THEN '3-5 years'
        ELSE '5+ years'
    END AS device_age_category,
    COUNT(*) AS device_count,
    ROUND(AVG(failure_probability), 3) AS avg_failure_prob,
    SUM(CASE WHEN failure_probability > 0.85 THEN 1 ELSE 0 END) AS critical_count
FROM FLEET_HEALTH_SCORED
GROUP BY device_age_category
ORDER BY MIN(uptime_hours);
```

---

## Data Refresh Schedule

| Component | Refresh Frequency | Method |
|-----------|------------------|--------|
| FLEET_HEALTH_SCORED | Hourly | ML inference job (XGBoost) |
| MAINTENANCE_LOGS | Real-time | Inserted as maintenance occurs |
| RUNBOOK_DOCS | As needed | Manual documentation updates |
| Cortex Search Index | 1 hour lag | Automatic (TARGET_LAG setting) |
| Dashboard Cache | 5 minutes | Streamlit @cache_data(ttl=300) |

---

## Data Retention Policy

| Table/Object | Retention Period | Backup Frequency |
|-------------|-----------------|------------------|
| FLEET_HEALTH_SCORED (current) | 7 days | Daily |
| FLEET_HEALTH_SCORED_HISTORY | 2 years | Weekly |
| MAINTENANCE_LOGS | 5 years | Weekly |
| RUNBOOK_DOCS | Permanent | Monthly |

---

## Security and Access Control

```sql
-- Read-only access for dashboard
GRANT USAGE ON DATABASE PATIENTPOINT_OPS TO ROLE DASHBOARD_READER;
GRANT USAGE ON SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DASHBOARD_READER;
GRANT SELECT ON ALL TABLES IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DASHBOARD_READER;
GRANT SELECT ON ALL VIEWS IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DASHBOARD_READER;
GRANT USAGE ON CORTEX SEARCH SERVICE RUNBOOK_SEARCH_SERVICE TO ROLE DASHBOARD_READER;

-- Write access for ML pipeline
GRANT INSERT, UPDATE ON TABLE FLEET_HEALTH_SCORED TO ROLE ML_PIPELINE;

-- Admin access for maintenance
GRANT ALL PRIVILEGES ON SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE DATA_ENGINEER;
```

---

## Notes

- All timestamps are stored in `TIMESTAMP_LTZ` (with local timezone) for proper handling across regions
- Device IDs follow format: `PP-XXXXX` (e.g., PP-00001 to PP-00500)
- Failure probability is a continuous value from 0.0 to 1.0 (0% to 100%)
- Revenue calculation uses $50/hour as the baseline device revenue
- Geographic coordinates are synthetic for demo purposes (clustered around actual hospital locations)

---

**Last Updated**: 2025-12-12  
**Maintained By**: Data Engineering Team

