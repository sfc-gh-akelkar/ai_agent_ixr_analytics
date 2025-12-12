## Project Structure

This repo is organized as a **single, rehearsable demo** with a **numbered SQL run sequence**.

```
ai_agent_predictive_maintenance/
├── sql/                      # Run in Snowsight, in numeric order
│   ├── 00_setup.sql
│   ├── 01_generate_sample_data.sql
│   ├── 10_curated_analytics_views.sql
│   ├── 11_semantic_views.sql
│   ├── 12_cortex_search_kb.sql
│   ├── 20_anomaly_watchlist.sql
│   ├── 21_semantic_view_anomaly_watchlist.sql
│   ├── 30_failure_predictions.sql
│   ├── 31_semantic_views_predictions.sql
│   ├── 40_work_orders.sql
│   ├── 41_semantic_view_work_orders.sql
│   ├── 50_remote_remediation.sql
│   ├── 51_semantic_view_remote_remediation.sql
│   ├── 60_executive_kpis.sql
│   ├── 61_semantic_view_executive_kpis.sql
│   └── 70_cortex_agent.sql
├── streamlit/
│   └── fleet_monitoring.py   # Optional dashboard UI
├── README.md                 # Overview
├── START_HERE.md             # Exact run order
├── FOCUS_FRAMEWORK.md        # Challenge → Action → Result mapping
└── DEMO_GUIDE.md             # Rehearsal talk track + agent questions
```


