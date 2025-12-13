# 🔧 Use Case 1: Predictive Device Maintenance

**AI-Powered IoT Device Maintenance for PatientPoint HealthScreens**

## Overview

PatientPoint operates 500,000 HealthScreen devices across healthcare facilities nationwide. This use case demonstrates how Snowflake Intelligence and Cortex Agents enable:

- **Predictive failure detection** - 24-48 hour advance warning
- **Automated remote remediation** - 60%+ issues fixed without dispatch
- **Cost optimization** - $96M annual savings projected

## Business Impact

| Metric | Value |
|--------|-------|
| Annual Cost Baseline | $185M (field dispatches) |
| Projected Savings | $96M (52% reduction) |
| Remote Fix Rate | 60%+ |
| Prediction Accuracy | >85% |

## Setup Scripts

Run in order:

```bash
01_create_database_and_data.sql    # Database, tables, sample data
02_create_semantic_views.sql       # Semantic views for Cortex Analyst
03_create_cortex_search.sql        # Knowledge base search services
04_create_agent.sql                # Agent configuration
05_predictive_simulation.sql       # Predictive analytics views
```

## Demo Script

See [DEMO_SCRIPT.md](DEMO_SCRIPT.md) for the full 20-minute demo walkthrough.

## Key Personas

| Persona | Focus |
|---------|-------|
| Executive (C-Suite) | ROI, fleet health, revenue protection |
| Operations Center | Risk triage, predictions, dispatch decisions |
| Field Technician | Work orders, troubleshooting, repair guidance |

