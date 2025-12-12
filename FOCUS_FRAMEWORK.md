## Focus Framework (PatientPoint Predictive Maintenance): Challenge → Action → Result

This repo is organized to support a **credible executive narrative** while still showing the “how” (governed data + AI tooling) inside Snowflake.

### Challenges (what hurts the business)
- **Lost advertising revenue**: Screen downtime directly reduces impressions and partner revenue.
- **High operational costs**: Reactive maintenance drives expensive field dispatches and emergency parts replacement.
- **Unexpected downtime**: Break/fix operations cause unpredictable outages, SLA risk, and reputational impact.

### Actions (what we do in Snowflake)
- **Predictive analytics (demo simulation)**
  - Anomaly scoring + ranked watchlist (baseline 14d vs scoring 1d)
  - 24–48h failure predictions + demo evaluation metrics
  - Note: These are **simulated (no training pipeline)** but are explainable and reproducible.
- **AI Agent implementation (Snowflake Intelligence)**
  - **Cortex Analyst** over native **semantic views** for structured questions
  - **Cortex Search** over a maintenance KB for “similar incidents” retrieval
  - **Cortex Agent** orchestrates these tools with governed instructions
- **Automated remote resolution (simulation)**
  - **Work order generation** (ops queue) from watchlist/predictions
  - **Remote runbooks + execution outcomes** (simulated) with escalation guidance

### Results (what you can show, credibly)
- **Observed (from data)**
  - Downtime and revenue impact history from `RAW_DATA.MAINTENANCE_HISTORY`
  - Remote success rates by failure type from `ANALYTICS.V_REMOTE_RESOLUTION_RATES`
- **Estimated (assumption-driven)**
  - Executive KPI estimates (downtime avoided, revenue protected, field cost avoided) are calculated using **explicit inputs** in `OPERATIONS.DEMO_ASSUMPTIONS`.
  - This prevents “fudging metrics” and makes assumptions editable per customer.

---

## What’s implemented in the repo (inventory)

### Data foundation
- **Schemas/tables/views**: `sql/00_setup.sql`
- **Synthetic data (telemetry + history)**: `sql/01_generate_sample_data.sql`
  - Includes deterministic `DEMO-*` incidents for scenario devices (supports eval + demo repeatability)

### Snowflake Intelligence enablement (Semantic layer + Search + Agent)
- Curated analytics views: `sql/10_curated_analytics_views.sql`
- Cortex Search KB + service: `sql/12_cortex_search_kb.sql`
- Split semantic views (fleet/telemetry/incidents/remote rates/baseline): `sql/11_semantic_views.sql`
- Cortex Agent (orchestration=auto, APP_WH): `sql/70_cortex_agent.sql`

### Ops Center (watchlist → predictions → work orders → remediation)
- Anomaly watchlist + scoring procedure: `sql/20_anomaly_watchlist.sql`
- Watchlist semantic view: `sql/21_semantic_view_anomaly_watchlist.sql`
- Failure predictions + demo evaluation: `sql/30_failure_predictions.sql`
- Prediction semantic views: `sql/31_semantic_views_predictions.sql`
- Work orders + queue: `sql/40_work_orders.sql` + `sql/41_semantic_view_work_orders.sql`
- Remote remediation runbooks/executions: `sql/50_remote_remediation.sql` + `sql/51_semantic_view_remote_remediation.sql`

### Executive dashboard KPIs
- KPI view + assumptions: `sql/60_executive_kpis.sql`
- Exec KPI semantic view: `sql/61_semantic_view_executive_kpis.sql`

---

## 4 Interfaces (how to demo it)

### 1) Executive Dashboard (C‑Suite)
- **KPIs**: query `ANALYTICS.V_EXEC_KPIS` (or semantic view `ANALYTICS.SV_EXEC_KPIS`)
- **Narrative**: “observed outcomes” + “transparent estimates” (assumption table)

### 2) Operations Center (IT/Facilities)
- **Watchlist**: `OPERATIONS.WATCHLIST_CURRENT` / `ANALYTICS.SV_ANOMALY_WATCHLIST`
- **Predictions**: `ANALYTICS.SV_FAILURE_PREDICTIONS`
- **Queue / work orders**: `ANALYTICS.SV_WORK_ORDERS`

### 3) Field Technician interface (mobile-optimized)
- Supported as a data product in this repo (work orders + runbook steps).
- Demo via queries / agent responses:
  - `OPERATIONS.WORK_ORDERS`
  - `OPERATIONS.REMOTE_RUNBOOK_STEPS`

### 4) AI Agent Chat Interface
- `OPERATIONS.MAINTENANCE_OPS_AGENT` uses Analyst tools + Search tool:
  - Watchlist, predictions, work orders, remote outcomes, exec KPIs, fleet/telemetry/incidents, and KB search.


