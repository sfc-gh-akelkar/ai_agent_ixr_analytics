# 🏥 PatientPoint AI Agent Demos

**AI Agents for Healthcare Digital Health Operations**

Two Snowflake Cortex Agent demos for **Snowflake Intelligence** showcasing AI-powered analytics for PatientPoint's digital health platform.

---

## 📋 Use Cases Overview

| Use Case | Focus | Business Value |
|----------|-------|----------------|
| [**01: Predictive Maintenance**](use_cases/01_predictive_maintenance/) | IoT device health & automated fixes | $96M annual savings |
| [**02: Patient Engagement**](use_cases/02_patient_engagement/) | Engagement analytics & churn prediction | Revenue protection |

---

## 🔧 Use Case 1: Predictive Device Maintenance

**AI-powered IoT device maintenance for 500,000 HealthScreen displays**

### The Challenge
| Pain Point | Impact |
|------------|--------|
| **High Costs** | Field technician dispatches cost $150-300+ per visit |
| **Lost Revenue** | Device downtime = lost advertising impressions |
| **Reactive Model** | Issues discovered after failure, not before |

### The Solution
- **Predictive Failure Detection** - 24-48 hour advance warning
- **Automated Remote Remediation** - 60%+ issues fixed without dispatch
- **AI-Powered Triage** - Intelligent routing to remote fix vs. field dispatch

### Business Impact
| Metric | Value |
|--------|-------|
| Annual Cost Baseline | $185M |
| Projected Savings | $96M (52% reduction) |
| Remote Fix Rate | 60%+ |
| Prediction Accuracy | >85% |

📁 **[View Use Case 1 →](use_cases/01_predictive_maintenance/)**

---

## 📊 Use Case 2: Patient Engagement Analytics

**Validate that patient engagement drives retention and outcomes**

### The Three Hypotheses
| Hypothesis | Question | Business Impact |
|------------|----------|-----------------|
| **H1: Patient Retention** | Do engaged patients stay with providers? | Prove value to providers |
| **H2: Patient Outcomes** | Does engagement improve health metrics? | Prove value to pharma |
| **H3: Provider Retention** | Does patient engagement predict provider retention? | Protect PatientPoint revenue |

### The Solution
- **Churn Prediction** - Identify at-risk providers before they leave
- **Correlation Analysis** - Statistically validate engagement-outcome links
- **Best Practices Search** - AI-powered intervention recommendations

### Business Impact
| Metric | Value |
|--------|-------|
| Revenue at Risk | Identified proactively |
| Churn Prediction | >85% accuracy |
| Intervention Time | Seconds vs weeks |

📁 **[View Use Case 2 →](use_cases/02_patient_engagement/)**

---

## 📁 Project Structure

```
ai_agent_device_maintenance/
├── use_cases/
│   ├── 01_predictive_maintenance/
│   │   ├── setup/
│   │   │   ├── 01_create_database_and_data.sql
│   │   │   ├── 02_create_semantic_views.sql
│   │   │   ├── 03_create_cortex_search.sql
│   │   │   ├── 04_create_agent.sql
│   │   │   └── 05_predictive_simulation.sql
│   │   ├── DEMO_SCRIPT.md
│   │   └── README.md
│   │
│   └── 02_patient_engagement/
│       ├── setup/
│       │   ├── 01_create_database_and_data.sql
│       │   ├── 02_create_semantic_views.sql
│       │   ├── 03_create_cortex_search.sql
│       │   └── 04_create_agent.sql
│       ├── DEMO_SCRIPT.md
│       └── README.md
│
└── README.md                 # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Snowflake account with **Cortex** access
- ACCOUNTADMIN role (for initial setup)
- The demos use the `SF_INTELLIGENCE_DEMO` role (created automatically)

### Setup Steps

**For Use Case 1 (Predictive Maintenance):**
```bash
cd use_cases/01_predictive_maintenance/setup/
# Run scripts 01-05 in order
```

**For Use Case 2 (Patient Engagement):**
```bash
cd use_cases/02_patient_engagement/setup/
# Run scripts 01-04 in order
```

### Access the Agents

1. Navigate to **AI & ML → Snowflake Intelligence**
2. Select the agent:
   - **Device Maintenance Assistant** (Use Case 1)
   - **Patient Engagement Analyst** (Use Case 2)
3. Start asking questions!

---

## 🎬 Demo Scripts

Each use case includes a detailed 20-minute demo script:

| Use Case | Demo Script |
|----------|-------------|
| Predictive Maintenance | [DEMO_SCRIPT.md](use_cases/01_predictive_maintenance/DEMO_SCRIPT.md) |
| Patient Engagement | [DEMO_SCRIPT.md](use_cases/02_patient_engagement/DEMO_SCRIPT.md) |

---

## 🎯 Key Personas

### Use Case 1: Predictive Maintenance
| Persona | Focus |
|---------|-------|
| Executive (C-Suite) | ROI, fleet health, revenue protection |
| Operations Center | Risk triage, predictions, dispatch decisions |
| Field Technician | Work orders, troubleshooting, repair guidance |

### Use Case 2: Patient Engagement
| Persona | Focus |
|---------|-------|
| Executive (C-Suite) | Revenue at risk, churn prediction, ROI |
| Data Science | Correlation analysis, model validation |
| Provider Success | At-risk accounts, intervention strategies |
| Content/Product | Content performance, optimization |

---

## 💰 Combined Business Value

| Metric | Use Case 1 | Use Case 2 | Total Impact |
|--------|------------|------------|--------------|
| **Cost Savings** | $96M/year | - | $96M/year |
| **Revenue Protected** | Ad revenue | Provider contracts | Millions |
| **Prediction Accuracy** | >85% | >85% | Enterprise AI |
| **Time to Insight** | Seconds | Seconds | 10x faster |

---

## 📚 References

- [Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence)
- [Best Practices for Building Cortex Agents](https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/best-practices-to-building-cortex-agents/best-practices-to-building-cortex-agents.md)
- [Cortex Search Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Semantic Views](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model)

---

**Built with ❄️ Snowflake Cortex**
