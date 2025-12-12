# Act 1 Validation Checklist

Use this checklist to verify Act 1 is working correctly before moving to Act 2.

---

## ✅ Database Setup Validation

### Step 1: Database Created
```sql
-- Run this query in Snowsight
SHOW DATABASES LIKE 'PREDICTIVE_MAINTENANCE';
```
**Expected:** 1 row returned with database name

### Step 2: Schemas Created
```sql
USE DATABASE PREDICTIVE_MAINTENANCE;
SHOW SCHEMAS;
```
**Expected:** See schemas: `RAW_DATA`, `ANALYTICS`, `OPERATIONS`, `PUBLIC`, `INFORMATION_SCHEMA`

### Step 3: Tables Created
```sql
SHOW TABLES IN SCHEMA RAW_DATA;
```
**Expected:** 5 tables
- DEVICE_INVENTORY
- SCREEN_TELEMETRY
- MAINTENANCE_HISTORY
- DEVICE_MODELS_REFERENCE
- (Plus views: V_LATEST_TELEMETRY, V_DEVICE_HEALTH_SUMMARY)

---

## ✅ Data Validation

### Step 4: Device Inventory
```sql
SELECT COUNT(*) AS DEVICE_COUNT FROM DEVICE_INVENTORY;
```
**Expected:** 100 devices

```sql
SELECT 
    COUNT(*) AS TOTAL,
    COUNT(CASE WHEN OPERATIONAL_STATUS = 'Active' THEN 1 END) AS ACTIVE
FROM DEVICE_INVENTORY;
```
**Expected:** 100 total, 100 active

### Step 5: Telemetry Data
```sql
SELECT COUNT(*) AS TELEMETRY_RECORDS FROM SCREEN_TELEMETRY;
```
**Expected:** ~864,000 records (exactly 864,000 if 100 devices × 8,640 intervals)

```sql
SELECT 
    MIN(TIMESTAMP) AS EARLIEST,
    MAX(TIMESTAMP) AS LATEST,
    DATEDIFF('day', MIN(TIMESTAMP), MAX(TIMESTAMP)) AS DAYS_SPAN
FROM SCREEN_TELEMETRY;
```
**Expected:** Approximately 30 days span

### Step 6: Maintenance History
```sql
SELECT COUNT(*) AS MAINTENANCE_RECORDS FROM MAINTENANCE_HISTORY;
```
**Expected:** 150 records

### Step 7: Device Models Reference
```sql
SELECT MODEL_NAME, MANUFACTURER FROM DEVICE_MODELS_REFERENCE;
```
**Expected:** 4 models (Samsung, LG, NEC, Philips)

---

## ✅ Device #4532 Validation (Problem Device)

### Step 8: Device Exists
```sql
SELECT * FROM DEVICE_INVENTORY WHERE DEVICE_ID = '4532';
```
**Expected:** 1 row
- DEVICE_MODEL: Samsung DM55E
- FACILITY_CITY: Should show a city
- ENVIRONMENT_TYPE: Lobby
- FIRMWARE_VERSION: v2.3.8

### Step 9: Latest Telemetry Shows Degradation
```sql
SELECT 
    DEVICE_ID,
    TEMPERATURE_F,
    POWER_CONSUMPTION_W,
    ERROR_COUNT,
    TIMESTAMP
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID = '4532'
ORDER BY TIMESTAMP DESC
LIMIT 10;
```
**Expected:**
- TEMPERATURE_F: Between 80-85°F (elevated)
- POWER_CONSUMPTION_W: Between 200-230W (elevated, possibly with spikes)
- ERROR_COUNT: Between 10-15 (elevated)

### Step 10: Health Status Shows Warning/Critical
```sql
SELECT 
    DEVICE_ID,
    TEMP_STATUS,
    POWER_STATUS,
    TEMPERATURE_F,
    POWER_CONSUMPTION_W
FROM V_DEVICE_HEALTH_SUMMARY
WHERE DEVICE_ID = '4532';
```
**Expected:**
- TEMP_STATUS: 'WARNING' or 'CRITICAL'
- POWER_STATUS: 'CRITICAL'

### Step 11: Historical Pattern Shows Degradation
```sql
SELECT 
    DATE_TRUNC('day', TIMESTAMP) AS DAY,
    AVG(TEMPERATURE_F) AS AVG_TEMP,
    AVG(POWER_CONSUMPTION_W) AS AVG_POWER,
    AVG(ERROR_COUNT) AS AVG_ERRORS
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID = '4532'
GROUP BY DAY
ORDER BY DAY DESC
LIMIT 10;
```
**Expected:** Clear upward trend in last 7 days:
- AVG_TEMP: Should increase from ~65°F to ~80°F
- AVG_POWER: Should increase from ~100W to ~210W
- AVG_ERRORS: Should increase from ~1 to ~12

---

## ✅ Comparison: Healthy Device Validation

### Step 12: Check Healthy Device (e.g., 4501)
```sql
SELECT 
    DEVICE_ID,
    TEMP_STATUS,
    POWER_STATUS,
    TEMPERATURE_F,
    POWER_CONSUMPTION_W,
    ERROR_COUNT
FROM V_DEVICE_HEALTH_SUMMARY
WHERE DEVICE_ID = '4501';
```
**Expected:**
- TEMP_STATUS: 'NORMAL'
- POWER_STATUS: 'NORMAL'
- TEMPERATURE_F: 60-70°F range
- POWER_CONSUMPTION_W: 90-110W range
- ERROR_COUNT: 0-2

### Step 13: Compare Statistics
```sql
SELECT 
    DEVICE_ID,
    AVG(TEMPERATURE_F) AS AVG_TEMP,
    STDDEV(TEMPERATURE_F) AS TEMP_STDDEV,
    MAX(TEMPERATURE_F) AS MAX_TEMP,
    AVG(POWER_CONSUMPTION_W) AS AVG_POWER,
    MAX(POWER_CONSUMPTION_W) AS MAX_POWER
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID IN ('4532', '4501')
  AND TIMESTAMP >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY DEVICE_ID;
```
**Expected:**
- Device 4532: Higher averages, higher max values, more variation
- Device 4501: Normal averages, normal max values, low variation

---

## ✅ Streamlit Dashboard Validation

### Step 14: Dashboard Loads
**Action:** Open Streamlit app in Snowsight

**Expected:**
- ✅ No error messages
- ✅ Page loads within 5 seconds
- ✅ Title shows "PatientPoint Fleet Monitoring"

### Step 15: Fleet Overview Metrics
**Location:** Top of dashboard

**Expected:**
- Total devices: 100
- Healthy devices: 88-92 (most devices)
- Warning devices: 4-8 (minor anomalies)
- Critical devices: 2-4 (includes #4532)
- Fleet avg temperature: ~65-68°F
- Fleet avg power: ~100-105W

### Step 16: Device Priority Queue
**Location:** Middle section

**Expected:**
- ✅ Device #4532 appears in list
- ✅ Status shows 🔴 CRITICAL or 🟡 WARNING
- ✅ Temperature shows 80-85°F
- ✅ Power shows 200-220W
- ✅ Can sort by clicking columns

### Step 17: Device Deep Dive - Select Device
**Action:** Select Device #4532 from dropdown

**Expected:**
- ✅ Device info loads
- ✅ Shows: Samsung DM55E, Chicago location, Lobby environment
- ✅ Firmware: v2.3.8
- ✅ Warranty: Expired
- ✅ Temp Status: 🔴 or 🟡
- ✅ Power Status: 🔴

### Step 18: Temperature Chart
**Action:** Click "🌡️ Temperature" tab

**Expected:**
- ✅ Line chart shows 30 days of data
- ✅ First 23 days: stable around 65°F
- ✅ Last 7 days: climbing trend to 80-85°F
- ✅ Orange dashed line (warning threshold) visible
- ✅ Red dashed line (critical threshold) visible
- ✅ Current temperature crosses critical line
- ✅ Metrics below chart show: Current, Average, Max, Min

### Step 19: Power Chart
**Action:** Click "⚡ Power" tab

**Expected:**
- ✅ Line chart shows 30 days of data
- ✅ First 23 days: stable around 100W
- ✅ Last 7 days: climbing with spikes to 200-220W
- ✅ Warning and critical threshold lines visible
- ✅ Current power exceeds critical threshold
- ✅ Visible spikes in last week

### Step 20: Error Chart
**Action:** Click "⚠️ Errors" tab

**Expected:**
- ✅ Bar chart shows error counts
- ✅ First 23 days: 0-2 errors per hour
- ✅ Last 7 days: increasing to 10-15 errors per hour
- ✅ Total errors show significant increase

### Step 21: System Charts
**Action:** Click "💻 System" tab

**Expected:**
- ✅ CPU usage chart shows data
- ✅ Network latency chart shows data
- ✅ Both display 30 days of history

### Step 22: Switch to Healthy Device
**Action:** Select Device #4501 (or any non-4532 device)

**Expected:**
- ✅ Device info loads
- ✅ Status shows 🟢 HEALTHY
- ✅ Temperature chart: stable around 65°F, no climbing trend
- ✅ Power chart: stable around 100W, no spikes
- ✅ Error chart: consistently low (0-2 per hour)

### Step 23: Filters Work
**Action:** Use sidebar filters

**Expected:**
- ✅ Can filter by state
- ✅ Can filter by device model
- ✅ Can filter by health status
- ✅ Device count updates when filters applied

---

## ✅ Performance Validation

### Step 24: Query Performance
```sql
-- Should run in < 2 seconds
SELECT * FROM V_DEVICE_HEALTH_SUMMARY LIMIT 100;
```

```sql
-- Should run in < 5 seconds (uses clustering)
SELECT * FROM SCREEN_TELEMETRY 
WHERE DEVICE_ID = '4532' 
ORDER BY TIMESTAMP DESC 
LIMIT 8640;
```

**Expected:** Queries complete quickly due to clustering

---

## ✅ Data Quality Checks

### Step 25: No Nulls in Critical Fields
```sql
SELECT 
    COUNT(*) AS TOTAL_TELEMETRY,
    COUNT(DEVICE_ID) AS HAS_DEVICE_ID,
    COUNT(TIMESTAMP) AS HAS_TIMESTAMP,
    COUNT(TEMPERATURE_F) AS HAS_TEMP,
    COUNT(POWER_CONSUMPTION_W) AS HAS_POWER
FROM SCREEN_TELEMETRY;
```
**Expected:** All counts should be equal (no nulls)

### Step 26: Timestamps Are Recent
```sql
SELECT 
    MAX(TIMESTAMP) AS MOST_RECENT,
    DATEDIFF('hour', MAX(TIMESTAMP), CURRENT_TIMESTAMP()) AS HOURS_AGO
FROM SCREEN_TELEMETRY;
```
**Expected:** MOST_RECENT within a few minutes of current time

### Step 27: Telemetry Intervals
```sql
SELECT 
    DEVICE_ID,
    MIN(DATEDIFF('minute', LAG(TIMESTAMP) OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP), TIMESTAMP)) AS MIN_INTERVAL,
    MAX(DATEDIFF('minute', LAG(TIMESTAMP) OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP), TIMESTAMP)) AS MAX_INTERVAL
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID = '4532'
GROUP BY DEVICE_ID;
```
**Expected:** MIN_INTERVAL = 5, MAX_INTERVAL = 5 (consistent 5-minute intervals)

---

## ✅ Final Validation

### Step 28: Run Complete Health Check
```sql
SELECT 
    'Devices' AS CHECK_ITEM,
    COUNT(*) AS VALUE,
    100 AS EXPECTED,
    CASE WHEN COUNT(*) = 100 THEN '✅' ELSE '❌' END AS STATUS
FROM DEVICE_INVENTORY

UNION ALL

SELECT 
    'Telemetry Records',
    COUNT(*),
    864000,
    CASE WHEN COUNT(*) >= 860000 THEN '✅' ELSE '❌' END
FROM SCREEN_TELEMETRY

UNION ALL

SELECT 
    'Maintenance Records',
    COUNT(*),
    150,
    CASE WHEN COUNT(*) = 150 THEN '✅' ELSE '❌' END
FROM MAINTENANCE_HISTORY

UNION ALL

SELECT 
    'Device Models',
    COUNT(*),
    4,
    CASE WHEN COUNT(*) = 4 THEN '✅' ELSE '❌' END
FROM DEVICE_MODELS_REFERENCE

UNION ALL

SELECT 
    'Critical Devices',
    COUNT(*),
    2,  -- At least 1, likely 2-4
    CASE WHEN COUNT(*) >= 1 THEN '✅' ELSE '❌' END
FROM V_DEVICE_HEALTH_SUMMARY
WHERE TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL';
```

**Expected:** All rows show ✅ in STATUS column

---

## 📋 Summary Checklist

Quick checklist - mark each as you validate:

**Database:**
- [ ] Database PREDICTIVE_MAINTENANCE exists
- [ ] All tables created (5 tables)
- [ ] All views created (2 views)

**Data:**
- [ ] 100 devices in DEVICE_INVENTORY
- [ ] ~864,000 records in SCREEN_TELEMETRY
- [ ] 150 records in MAINTENANCE_HISTORY
- [ ] 4 models in DEVICE_MODELS_REFERENCE

**Device #4532:**
- [ ] Device exists and is Samsung DM55E
- [ ] Latest temperature 80-85°F
- [ ] Latest power 200-220W
- [ ] Error count 10-15
- [ ] Status shows WARNING or CRITICAL
- [ ] Historical chart shows climbing trend

**Dashboard:**
- [ ] Streamlit app loads without errors
- [ ] Fleet overview shows 100 devices
- [ ] Device #4532 appears in priority queue
- [ ] Can select Device #4532 and view details
- [ ] Temperature chart shows degradation
- [ ] Power chart shows spikes
- [ ] Error chart shows increase
- [ ] Can select healthy device for comparison
- [ ] Filters work correctly

**Performance:**
- [ ] Queries complete in < 5 seconds
- [ ] Dashboard loads in < 10 seconds
- [ ] Charts render smoothly

---

## ✅ All Checks Passed?

If all validation steps pass, you're ready for **Act 2: Anomaly Detection**!

If any checks fail, see troubleshooting section in `QUICKSTART.md` or `README.md`.

---

## 🚀 Next Steps

1. **Document any issues** encountered during validation
2. **Take screenshots** of Device #4532 charts for reference
3. **Practice demo script** with Device #4532 → healthy device comparison
4. **Request Act 2** when ready to add ML-based anomaly detection

---

**Act 1 Validation Complete!** ✅

