# Project Directory Structure

```
ai_agent_predictive_maintenance/
│
├── sql/                                    # SQL scripts (run in Snowsight)
│   ├── 01_setup_database.sql              ✅ ACT 1: Database schema and tables
│   └── 02_generate_sample_data.sql        ✅ ACT 1: Synthetic data generation
│
├── streamlit/                              # Streamlit applications
│   └── 01_Fleet_Monitoring.py             ✅ ACT 1: Monitoring dashboard
│
├── python/                                 # Python utilities (future)
│   └── (empty - will add in later acts)
│
├── notebooks/                              # Jupyter notebooks (future)
│   └── (empty - will add in Act 3 for ML model training)
│
├── docs/                                   # Documentation
│   ├── README.md                          ✅ Main project overview
│   ├── QUICKSTART.md                      ✅ 5-minute setup guide
│   ├── ACT1_TECHNICAL.md                  ✅ Act 1 technical details
│   └── ACT1_SUMMARY.md                    ✅ Act 1 completion summary
│
└── PROJECT_STRUCTURE.md                    ✅ This file
```

---

## 📋 Act-by-Act File Plan

### ✅ Act 1: Foundation & Monitoring (COMPLETE)
```
sql/
├── 01_setup_database.sql
└── 02_generate_sample_data.sql

streamlit/
└── 01_Fleet_Monitoring.py
```

### 🔲 Act 2: Anomaly Detection (NEXT)
```
sql/
├── 03_anomaly_detection.sql               # Cortex ML anomaly detection
└── 04_create_watchlist.sql                # Watch list table

streamlit/
└── 02_Anomaly_Detection.py                # Enhanced dashboard with ML alerts
```

### 🔲 Act 3: Predictive Model
```
sql/
├── 05_feature_engineering.sql             # ML features
├── 06_training_data.sql                   # Labeled training data
└── 07_predictions_table.sql               # Prediction results

python/
├── train_model.py                         # Model training script
└── predict.py                             # Scoring script

notebooks/
└── model_training.ipynb                   # Interactive model development

streamlit/
└── 03_Predictions.py                      # Prediction dashboard
```

### 🔲 Act 4: Knowledge Base
```
sql/
├── 08_maintenance_history.sql             # Enhanced history
└── 09_create_cortex_search.sql            # Cortex Search service

python/
├── search_similar_cases.py                # Search utilities
└── calculate_success_rates.py             # Success rate analysis

streamlit/
└── 04_Knowledge_Base.py                   # Decision support view
```

### 🔲 Act 5: Automated Remediation
```
sql/
├── 10_remediation_workflows.sql           # Workflow definitions
└── 11_execution_log.sql                   # Audit trail

python/
├── remediation_engine.py                  # Execution engine
└── device_simulator.py                    # Simulate device responses

streamlit/
└── 05_Remediation.py                      # Remediation control center
```

### 🔲 Act 6: Business Metrics
```
sql/
├── 12_business_metrics.sql                # Cost tracking
└── 13_roi_calculations.sql                # ROI calculations

python/
└── metrics_calculator.py                  # Business logic

streamlit/
└── 06_Executive_Dashboard.py              # C-level view
```

### 🔲 Act 7: Natural Language Interface
```
sql/
└── 14_cortex_analyst_setup.sql            # Semantic model

python/
└── analyst_interface.py                   # Cortex Analyst wrapper

streamlit/
└── 07_Ask_Questions.py                    # Chat interface
```

### 🔲 Act 8: Polish & Advanced
```
python/
├── llm_summaries.py                       # Cortex Complete integration
└── demo_scenarios.py                      # Demo helpers

streamlit/
├── 08_Demo_Controls.py                    # Presenter mode
├── 09_Model_Performance.py                # ML monitoring
└── 10_Fleet_Map.py                        # Geographic view
```

---

## 📊 Current Status

| Act | Status | Files | Lines of Code | Demoable |
|-----|--------|-------|---------------|----------|
| 1 | ✅ Complete | 7 | ~1,200 | Yes |
| 2 | 🔲 Ready to build | - | ~400 (est.) | - |
| 3 | 🔲 Planned | - | ~800 (est.) | - |
| 4 | 🔲 Planned | - | ~500 (est.) | - |
| 5 | 🔲 Planned | - | ~700 (est.) | - |
| 6 | 🔲 Planned | - | ~400 (est.) | - |
| 7 | 🔲 Planned | - | ~300 (est.) | - |
| 8 | 🔲 Planned | - | ~600 (est.) | - |

**Total estimated:** ~5,000 lines of code across 30+ files

---

## 🗂️ File Naming Conventions

### SQL Files
- Numbered sequentially: `01_`, `02_`, `03_`, etc.
- Descriptive names: `setup_database.sql`, `anomaly_detection.sql`
- Run in order (each may depend on previous)

### Python Files
- Lowercase with underscores: `train_model.py`
- Grouped by function: data generation, ML, remediation, utilities

### Streamlit Files
- Numbered by act: `01_`, `02_`, `03_`, etc.
- Title case with underscores: `Fleet_Monitoring.py`
- Each act can be standalone or build on previous

### Documentation
- UPPERCASE for main docs: `README.md`, `QUICKSTART.md`
- Act-specific with prefix: `ACT1_TECHNICAL.md`, `ACT2_GUIDE.md`

---

## 📁 Where to Find What

### "I want to set up the database"
→ `sql/01_setup_database.sql`

### "I want to generate test data"
→ `sql/02_generate_sample_data.sql`

### "I want to run the monitoring dashboard"
→ `streamlit/01_Fleet_Monitoring.py`

### "I want quick setup instructions"
→ `QUICKSTART.md`

### "I want to understand the technical details"
→ `ACT1_TECHNICAL.md`

### "I want the full project vision"
→ `README.md`

### "I want to see what's been built"
→ `ACT1_SUMMARY.md`

---

## 🎯 How to Navigate This Project

### For Developers
1. Start with `QUICKSTART.md` for setup
2. Reference `ACT1_TECHNICAL.md` for implementation details
3. Run SQL scripts in order
4. Deploy Streamlit app
5. Request next act when ready

### For Stakeholders
1. Start with `README.md` for vision and business case
2. Review `ACT1_SUMMARY.md` for current state
3. Request demo walkthrough
4. Discuss timeline for remaining acts

### For Technical Reviewers
1. Review `sql/` scripts for data modeling
2. Review `streamlit/` for UI/UX patterns
3. Check `ACT1_TECHNICAL.md` for architecture decisions
4. Provide feedback before Act 2

---

## 🚀 Incremental Build Approach

Each act adds new capabilities:

```
Act 1  →  Act 2  →  Act 3  →  Act 4  →  Act 5  →  Act 6  →  Act 7  →  Act 8
   ↓         ↓         ↓         ↓         ↓         ↓         ↓         ↓
Monitor   Detect   Predict   Advise   Execute   Measure   Query   Polish
```

**Each act is independently demoable** - you don't need to complete all 8 to show value.

### Minimum Viable Demo
- **Acts 1-3:** Show predictive maintenance working (detection → prediction)
- **Time:** 1-2 days

### Full MVP
- **Acts 1-5:** Show complete automation (detection → prediction → recommendation → execution)
- **Time:** 1 week

### Production-Ready
- **Acts 1-8:** Show enterprise-grade solution with all features
- **Time:** 2 weeks

---

## 📝 Notes

- All SQL runs in Snowflake (Snowsight worksheets)
- All Streamlit runs in Snowflake (Streamlit in Snowflake)
- Python utilities can run locally or in Snowpark
- Notebooks for ML model development (optional, can do in SQL)

---

**Current status:** Act 1 complete, ready for Act 2  
**Next step:** Request Act 2 files when validated

