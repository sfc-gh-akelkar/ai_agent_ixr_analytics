## PatientPoint Predictive Maintenance Demo (Snowflake Intelligence)

This repo is an end-to-end demo showing how Snowflake can help PatientPoint **protect advertising revenue**, **reduce field-service costs**, and **reduce downtime risk** for in-office digital screens.

### What you can demo
- **Early warning**: anomaly watchlist (baseline 14d vs scoring 1d) with explainable signals
- **24–48 hour predictions**: simulated failure predictions + demo evaluation metrics
- **Ops execution**: auto-generated work orders (remote vs field guidance)
- **Automated remote remediation (simulated)**: runbooks + execution outcomes + escalation
- **Executive KPIs**: observed downtime/revenue impact + transparent assumption-driven estimates
- **AI Agent chat**: Cortex Analyst (semantic views) + Cortex Search (KB) orchestrated by a Cortex Agent

### Where to start
- **Run order + setup**: `START_HERE.md`
- **Rehearsal talk track**: `DEMO_GUIDE.md`
- **Challenge → Action → Result mapping**: `FOCUS_FRAMEWORK.md`

### Optional UI
There is an optional Streamlit dashboard at `streamlit/fleet_monitoring.py`. The Intelligence + Agent demo works without Streamlit.


