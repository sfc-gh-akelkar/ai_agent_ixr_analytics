# Act 1: Foundation & Monitoring - Technical Overview

## 🎯 What We Built

A foundational monitoring system that ingests device telemetry and provides visibility into fleet health.

**This is NOT yet using ML** - just threshold-based rules and visualization.

---

## 📊 Data Architecture

```
PREDICTIVE_MAINTENANCE (Database)
│
├── RAW_DATA (Schema)
│   ├── DEVICE_INVENTORY
│   │   └── 100 devices across 15 US cities
│   │       - Device metadata (model, location, age)
│   │       - Installation and maintenance dates
│   │       - Warranty status
│   │
│   ├── SCREEN_TELEMETRY
│   │   └── ~864,000 time-series records
│   │       - Temperature, power, errors (every 5 min)
│   │       - CPU, memory, network metrics
│   │       - 30 days of history per device
│   │       - Clustered by (DEVICE_ID, TIMESTAMP)
│   │
│   ├── MAINTENANCE_HISTORY
│   │   └── 150 historical repair records
│   │       - Past failures and resolutions
│   │       - Remote fix success rates by type
│   │       - Costs and downtime tracking
│   │
│   └── DEVICE_MODELS_REFERENCE
│       └── Threshold definitions per model
│           - Normal operating ranges
│           - Warning and critical thresholds
│
├── ANALYTICS (Schema)
│   └── [Empty - will hold ML features in Act 3]
│
└── OPERATIONS (Schema)
    └── [Empty - will hold alerts/workflows in Act 5]
```

---

## 🔍 What Makes Device #4532 "Sick"

### Normal Device Pattern (e.g., Device #4501)
```
Temperature:  65°F ± 3°F (stable)
Power:        100W ± 10W (stable)
Errors:       0-2 per hour (minimal)
```

### Device #4532 Pattern (Power Supply Degradation)

**Days 1-23:** Normal operation
```
Temperature:  65°F ± 3°F
Power:        100W ± 10W  
Errors:       0-2 per hour
```

**Days 24-30:** Progressive degradation
```
Temperature:  65°F → 82°F (climbing linearly)
Power:        100W → 215W (climbing + random spikes)
Errors:       0-2 → 12-15 per hour (increasing)
```

**Underlying simulation logic:**
- Temperature increases by 0.003°F per 5-minute interval = ~25°F over 7 days
- Power increases by 0.014W per interval = ~120W increase + 20-50W random spikes
- Error count correlates with temperature rise

**Why this pattern?**
- Mimics real power supply capacitor degradation
- Temperature rises due to inefficient power conversion
- Power spikes from voltage regulation failures
- Errors logged from voltage monitoring systems

---

## 📈 Dashboard Features (Act 1)

### 1. Fleet Overview
- **Metrics:** Total devices, health status breakdown
- **Detection:** Threshold-based (compares to model reference data)
- **Limitation:** Requires manual threshold tuning per device model

### 2. Device Priority Queue
- **Sorting:** Critical → Warning → Healthy
- **Filters:** State, model, health status
- **Limitation:** No predictive ranking (just current state)

### 3. Device Deep Dive
- **Charts:** 30 days of telemetry history
- **Thresholds:** Visual warning/critical lines
- **Analysis:** Visual pattern detection by human operator
- **Limitation:** Operator must manually inspect each device

---

## 🎨 Data Realism Features

### Seasonal Patterns
- Ambient temperature varies sinusoidally (mimics seasons)
- Brightness adjusts for business hours vs. night

### Correlations
- Temperature ↑ correlates with Power ↑ (physics-based)
- CPU usage higher during business hours
- Network latency has occasional spikes (5% of time)

### Device Diversity
- 4 device models with different baselines
- Older devices (2-4 years) more likely to fail
- Lobby environments see more stress than exam rooms

### Minor Anomalies (8 devices)
- Devices 4505, 4512, 4523, 4534, 4545, 4556, 4567, 4578
- Slightly elevated metrics but not critical
- Used in Act 2 to test false positive rates

---

## 🔧 Technical Implementation Details

### SQL Performance Optimizations
```sql
-- Clustering for time-series queries
ALTER TABLE SCREEN_TELEMETRY 
  CLUSTER BY (DEVICE_ID, TIMESTAMP);

-- View with latest telemetry (avoids repeated window functions)
CREATE VIEW V_LATEST_TELEMETRY AS
SELECT t.*, d.DEVICE_MODEL, d.FACILITY_NAME
FROM SCREEN_TELEMETRY t
INNER JOIN (
    SELECT DEVICE_ID, MAX(TIMESTAMP) AS MAX_TIMESTAMP
    FROM SCREEN_TELEMETRY GROUP BY DEVICE_ID
) latest ON t.DEVICE_ID = latest.DEVICE_ID 
        AND t.TIMESTAMP = latest.MAX_TIMESTAMP
LEFT JOIN DEVICE_INVENTORY d ON t.DEVICE_ID = d.DEVICE_ID;
```

### Data Generation Efficiency
- Uses `TABLE(GENERATOR(ROWCOUNT => N))` for bulk generation
- Cross join to create intervals × devices
- Single INSERT generates all 864K records in 30-60 seconds

### Streamlit Design Patterns
- Session caching for repeated queries
- Altair for interactive charts (client-side interactivity)
- Tabs to organize multiple metric views
- Color coding: 🟢 Green = Healthy, 🟡 Yellow = Warning, 🔴 Red = Critical

---

## 🚫 What's NOT in Act 1 (Coming Later)

| Feature | Act |
|---------|-----|
| Anomaly detection (ML-based) | Act 2 |
| Failure prediction (48h advance warning) | Act 3 |
| Similar case search (Cortex Search) | Act 4 |
| Automated remediation workflows | Act 5 |
| ROI calculations and cost tracking | Act 6 |
| Natural language queries (Cortex Analyst) | Act 7 |
| LLM-generated diagnostics | Act 8 |

---

## 📊 Sample Queries for Validation

### Check Device #4532 Latest Metrics
```sql
SELECT 
    DEVICE_ID,
    TEMPERATURE_F,
    POWER_CONSUMPTION_W,
    ERROR_COUNT,
    TEMP_STATUS,
    POWER_STATUS
FROM V_DEVICE_HEALTH_SUMMARY
WHERE DEVICE_ID = '4532';
```

**Expected:** 
- TEMPERATURE_F: 80-85°F
- POWER_CONSUMPTION_W: 200-220W
- ERROR_COUNT: 10-15
- TEMP_STATUS: WARNING or CRITICAL
- POWER_STATUS: CRITICAL

### View Telemetry Trend
```sql
SELECT 
    DATE_TRUNC('day', TIMESTAMP) AS DAY,
    AVG(TEMPERATURE_F) AS AVG_TEMP,
    AVG(POWER_CONSUMPTION_W) AS AVG_POWER
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID = '4532'
GROUP BY DAY
ORDER BY DAY;
```

**Expected:** Should see clear upward trend in last 7 days

### Compare Healthy vs. Sick Device
```sql
SELECT 
    DEVICE_ID,
    AVG(TEMPERATURE_F) AS AVG_TEMP,
    STDDEV(TEMPERATURE_F) AS TEMP_VARIATION,
    MAX(POWER_CONSUMPTION_W) AS MAX_POWER
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID IN ('4532', '4501')
  AND TIMESTAMP >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY DEVICE_ID;
```

**Expected:**
- Device 4532: Higher avg temp, higher variation, much higher max power
- Device 4501: Stable metrics, low variation

---

## 🎓 Learning Outcomes

After Act 1, you understand:

1. **Time-series data modeling** for IoT telemetry
2. **Threshold-based monitoring** (the old way)
3. **Why manual monitoring doesn't scale** (100 devices × 10 metrics = too much)
4. **What "normal" vs "degrading" looks like** in telemetry
5. **Snowflake fundamentals**: Tables, views, clustering, Streamlit integration

---

## 🎯 Success Criteria

Act 1 is complete when:

✅ Database contains realistic device fleet data  
✅ Dashboard shows clear health status differentiation  
✅ Device #4532 visually shows degradation pattern  
✅ Can compare healthy vs. unhealthy devices  
✅ Understand why threshold-based rules are insufficient  

**Key insight for stakeholders:**
> "With 100 devices and 10 metrics each, an operator would need to check 1,000 charts daily. That's why we need machine learning to automate pattern detection - that's Act 2."

---

## 🚀 Ready for Act 2?

**Act 2 Preview:**
- Replace manual threshold rules with Cortex ML anomaly detection
- Automatically flag Device #4532 based on pattern deviation
- Create "Watch List" with ML-detected anomalies
- Compare: Threshold detection (Act 1) vs. ML detection (Act 2)

**Key demo point:**
> "In Act 1, Device #4532 triggered alerts because it crossed 75°F threshold. But what if a device normally runs at 70°F and jumps to 73°F? Threshold rules miss it. ML learns each device's baseline and detects relative changes, not just absolute thresholds."

---

## 📁 Act 1 Files Reference

```
sql/
├── 01_setup_database.sql       # Schema definition (5 tables, 2 views)
└── 02_generate_sample_data.sql # Data generation (stored procedure)

streamlit/
└── 01_Fleet_Monitoring.py      # Dashboard (450 lines)

docs/
├── README.md                    # Full project overview
├── QUICKSTART.md                # 5-minute setup guide
└── ACT1_TECHNICAL.md            # This file
```

Total lines of code: ~1,200 (SQL + Python)  
Data generated: 864K telemetry records + 100 devices + 150 maintenance records

---

**Next:** Request Act 2 when ready to add ML-based anomaly detection!

