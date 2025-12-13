# 📊 Use Case 2: Patient Engagement Analytics

**AI-Powered Engagement Analysis for PatientPoint Digital Health Platforms**

## Overview

PatientPoint operates digital health displays in healthcare waiting rooms and exam rooms, collecting billions of patient interactions (clicks, swipes, dwell time). This use case demonstrates how Snowflake Intelligence and Cortex Agents can validate the hypothesis that **patient engagement correlates with better provider retention and improved patient outcomes**.

## Three Hypotheses to Validate

| Hypothesis | Question | Business Impact |
|------------|----------|-----------------|
| **H1: Patient Retention** | Do engaged patients stay with their providers? | Prove value to providers |
| **H2: Patient Outcomes** | Does engagement improve health metrics? | Prove value to pharma partners |
| **H3: Provider Retention** | Do providers with engaged patients stay with PatientPoint? | Protect PatientPoint revenue |

## Business Impact

| Metric | Value |
|--------|-------|
| At-Risk Revenue | Identified proactively |
| Churn Prediction | >85% accuracy |
| Outcome Correlation | Statistically validated |
| Intervention Time | Seconds vs weeks |

## Setup Scripts

Run in order:

```bash
01_create_database_and_data.sql    # Database, tables, sample data
02_create_semantic_views.sql       # Semantic views for Cortex Analyst
03_create_cortex_search.sql        # Content and best practices search
04_create_agent.sql                # Agent configuration
```

## Demo Script

See [DEMO_SCRIPT.md](DEMO_SCRIPT.md) for the full 20-minute demo walkthrough.

## Data Model

### Core Tables

| Table | Records | Description |
|-------|---------|-------------|
| PROVIDERS | 500 | Healthcare facilities with contracts |
| PATIENTS | 10,000 | Anonymized patient profiles |
| PATIENT_INTERACTIONS | 100,000 | Click/swipe/dwell events |
| CONTENT_LIBRARY | 200 | Health education content |
| PATIENT_OUTCOMES | 5,000 | Health metrics and outcomes |
| ENGAGEMENT_SCORES | 10,500 | Aggregated engagement metrics |
| CHURN_EVENTS | 1,000 | Historical churn records |

### Key Views

| View | Purpose |
|------|---------|
| V_PATIENT_ENGAGEMENT | Patient-level engagement and churn risk |
| V_PROVIDER_HEALTH | Provider retention and revenue metrics |
| V_ENGAGEMENT_OUTCOMES_CORRELATION | Engagement-outcome analysis |
| V_CONTENT_PERFORMANCE | Content effectiveness metrics |
| V_ENGAGEMENT_ROI | Executive business impact |

## Key Personas

| Persona | Focus |
|---------|-------|
| Executive (C-Suite) | Revenue at risk, ROI, prediction accuracy |
| Data Science | Correlation analysis, model validation |
| Provider Success | At-risk accounts, intervention strategies |
| Content/Product | Content performance, optimization |

## Sample Questions

```
# Executive
"How much revenue is at risk from provider churn?"
"How accurate is our churn prediction model?"

# Data Science
"Does engagement correlate with health outcome improvements?"
"Compare improvement rates by engagement tier"

# Provider Success
"Which providers are at high risk of churning?"
"What are best practices to reduce churn?"

# Content
"Which content has the highest completion rate?"
"Recommend content for diabetes patients"
```

