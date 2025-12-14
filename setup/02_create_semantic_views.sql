/*******************************************************************************
 * PATIENTPOINT PATIENT ENGAGEMENT ANALYTICS
 * Engagement-Driven Retention & Outcomes Analysis
 * 
 * Part 2: Semantic Views for Cortex Analyst
 * 
 * Prerequisites: Run 01_create_database_and_data.sql first
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_ENGAGEMENT;
USE SCHEMA ENGAGEMENT_ANALYTICS;

-- ============================================================================
-- SEMANTIC VIEW 1: PATIENT ENGAGEMENT ANALYTICS
-- For querying patient engagement patterns and churn risk
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_PATIENT_ENGAGEMENT
  TABLES (
    patients AS V_PATIENT_ENGAGEMENT PRIMARY KEY (PATIENT_ID)
  )
  DIMENSIONS (
    patients.patient_id AS patients.PATIENT_ID
      WITH SYNONYMS = ('patient', 'patient id', 'member')
      COMMENT = 'Unique identifier for each patient',
    
    patients.provider_id AS patients.PROVIDER_ID
      WITH SYNONYMS = ('provider', 'facility id')
      COMMENT = 'Healthcare provider where patient is seen',
    
    patients.facility_name AS patients.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'clinic', 'hospital', 'provider name')
      COMMENT = 'Name of the healthcare facility',
    
    patients.facility_type AS patients.FACILITY_TYPE
      WITH SYNONYMS = ('facility category', 'provider type')
      COMMENT = 'Type: Hospital, Primary Care, Urgent Care, Specialty',
    
    patients.city AS patients.CITY
      WITH SYNONYMS = ('location city')
      COMMENT = 'City where facility is located',
    
    patients.state AS patients.STATE
      WITH SYNONYMS = ('location state', 'region')
      COMMENT = 'State where facility is located',
    
    patients.age_group AS patients.AGE_GROUP
      WITH SYNONYMS = ('age', 'age bracket', 'demographic')
      COMMENT = 'Patient age group: 18-24, 25-34, etc.',
    
    patients.gender AS patients.GENDER
      WITH SYNONYMS = ('sex')
      COMMENT = 'Patient gender',
    
    patients.primary_condition AS patients.PRIMARY_CONDITION
      WITH SYNONYMS = ('condition', 'diagnosis', 'health condition')
      COMMENT = 'Primary health condition: Diabetes, Hypertension, etc.',
    
    patients.patient_status AS patients.PATIENT_STATUS
      WITH SYNONYMS = ('status', 'patient state', 'active status')
      COMMENT = 'Patient status: ACTIVE, INACTIVE, CHURNED',
    
    patients.churn_risk_category AS patients.CHURN_RISK_CATEGORY
      WITH SYNONYMS = ('risk', 'churn risk', 'retention risk')
      COMMENT = 'Churn risk level: HEALTHY, LOW_RISK, MEDIUM_RISK, HIGH_RISK, CHURNED',
    
    patients.engagement_trend AS patients.ENGAGEMENT_TREND
      WITH SYNONYMS = ('trend', 'direction')
      COMMENT = 'Engagement trend: INCREASING, STABLE, DECLINING'
  )
  METRICS (
    patients.engagement_score AS AVG(patients.ENGAGEMENT_SCORE)
      WITH SYNONYMS = ('engagement', 'engagement level')
      COMMENT = 'Patient engagement score (0-100)',
    
    patients.satisfaction_score AS AVG(patients.SATISFACTION_SCORE)
      WITH SYNONYMS = ('satisfaction', 'CSAT')
      COMMENT = 'Patient satisfaction score (1-5)',
    
    patients.total_interactions AS MAX(patients.TOTAL_INTERACTIONS)
      WITH SYNONYMS = ('interactions', 'interaction count')
      COMMENT = 'Total number of content interactions',
    
    patients.total_dwell_time AS MAX(patients.TOTAL_DWELL_TIME_SECONDS)
      WITH SYNONYMS = ('dwell time', 'time spent')
      COMMENT = 'Total time spent on content (seconds)',
    
    patients.avg_completion_rate AS MAX(patients.AVG_COMPLETION_RATE)
      WITH SYNONYMS = ('completion rate', 'completion')
      COMMENT = 'Average content completion rate (%)',
    
    patients.unique_content_viewed AS MAX(patients.UNIQUE_CONTENT_VIEWED)
      WITH SYNONYMS = ('content viewed', 'unique content')
      COMMENT = 'Number of unique content pieces viewed',
    
    patients.days_since_last_visit AS MAX(patients.DAYS_SINCE_LAST_VISIT)
      WITH SYNONYMS = ('days inactive', 'recency')
      COMMENT = 'Days since last visit',
    
    patients.total_visits AS MAX(patients.TOTAL_VISITS)
      WITH SYNONYMS = ('visits', 'visit count')
      COMMENT = 'Total number of visits',
    
    patients.total_patients AS COUNT(DISTINCT patients.PATIENT_ID)
      WITH SYNONYMS = ('patient count', 'number of patients')
      COMMENT = 'Total count of patients'
  )
  COMMENT = 'Patient engagement analytics including interaction patterns, satisfaction, and churn risk.';

GRANT SELECT ON SEMANTIC VIEW SV_PATIENT_ENGAGEMENT TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- SEMANTIC VIEW 2: PROVIDER HEALTH & CHURN RISK
-- For querying provider retention and engagement metrics
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_PROVIDER_HEALTH
  TABLES (
    providers AS V_PROVIDER_HEALTH PRIMARY KEY (PROVIDER_ID)
  )
  DIMENSIONS (
    providers.provider_id AS providers.PROVIDER_ID
      WITH SYNONYMS = ('provider', 'facility id')
      COMMENT = 'Unique provider identifier',
    
    providers.facility_name AS providers.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'clinic', 'hospital', 'name')
      COMMENT = 'Healthcare facility name',
    
    providers.facility_type AS providers.FACILITY_TYPE
      WITH SYNONYMS = ('type', 'category')
      COMMENT = 'Facility type: Hospital, Primary Care, etc.',
    
    providers.city AS providers.CITY
      WITH SYNONYMS = ('location')
      COMMENT = 'City location',
    
    providers.state AS providers.STATE
      WITH SYNONYMS = ('region')
      COMMENT = 'State location',
    
    providers.contract_status AS providers.CONTRACT_STATUS
      WITH SYNONYMS = ('status', 'contract state')
      COMMENT = 'Contract status: ACTIVE, AT_RISK, CHURNED, RENEWED',
    
    providers.account_manager AS providers.ACCOUNT_MANAGER
      WITH SYNONYMS = ('AM', 'manager', 'rep')
      COMMENT = 'Assigned account manager',
    
    providers.churn_risk_category AS providers.CHURN_RISK_CATEGORY
      WITH SYNONYMS = ('risk', 'churn risk', 'retention risk')
      COMMENT = 'Churn risk: LOW, MEDIUM, HIGH, CRITICAL, CHURNED',
    
    providers.engagement_trend AS providers.ENGAGEMENT_TREND
      WITH SYNONYMS = ('trend')
      COMMENT = 'Patient engagement trend at facility'
  )
  METRICS (
    providers.monthly_fee AS MAX(providers.MONTHLY_FEE_USD)
      WITH SYNONYMS = ('MRR', 'monthly revenue')
      COMMENT = 'Monthly fee in USD',
    
    providers.annual_revenue AS MAX(providers.ANNUAL_REVENUE_AT_RISK)
      WITH SYNONYMS = ('ARR', 'annual revenue', 'revenue at risk')
      COMMENT = 'Annual revenue at risk',
    
    providers.device_count AS MAX(providers.DEVICE_COUNT)
      WITH SYNONYMS = ('devices', 'screens')
      COMMENT = 'Number of devices at facility',
    
    providers.nps_score AS MAX(providers.NPS_SCORE)
      WITH SYNONYMS = ('NPS', 'net promoter')
      COMMENT = 'Net Promoter Score',
    
    providers.churn_risk_score AS MAX(providers.CHURN_RISK_SCORE)
      WITH SYNONYMS = ('risk score')
      COMMENT = 'AI-calculated churn risk (0-100)',
    
    providers.patient_engagement_score AS MAX(providers.PATIENT_ENGAGEMENT_SCORE)
      WITH SYNONYMS = ('engagement', 'patient engagement')
      COMMENT = 'Average patient engagement at facility',
    
    providers.total_patients AS MAX(providers.TOTAL_PATIENTS)
      WITH SYNONYMS = ('patients', 'patient count')
      COMMENT = 'Total patients at facility',
    
    providers.active_patients AS MAX(providers.ACTIVE_PATIENTS)
      WITH SYNONYMS = ('active')
      COMMENT = 'Active patients at facility',
    
    providers.churned_patients AS MAX(providers.CHURNED_PATIENTS)
      WITH SYNONYMS = ('churned')
      COMMENT = 'Churned patients at facility',
    
    providers.total_providers AS COUNT(DISTINCT providers.PROVIDER_ID)
      WITH SYNONYMS = ('provider count', 'facility count')
      COMMENT = 'Total count of providers'
  )
  COMMENT = 'Provider health metrics including contract status, patient engagement, and churn risk.';

GRANT SELECT ON SEMANTIC VIEW SV_PROVIDER_HEALTH TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- SEMANTIC VIEW 3: ENGAGEMENT-OUTCOMES CORRELATION
-- For analyzing relationship between engagement and health outcomes
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_OUTCOMES_CORRELATION
  TABLES (
    outcomes AS V_ENGAGEMENT_OUTCOMES_CORRELATION PRIMARY KEY (PATIENT_ID)
  )
  DIMENSIONS (
    outcomes.patient_id AS outcomes.PATIENT_ID
      WITH SYNONYMS = ('patient')
      COMMENT = 'Patient identifier',
    
    outcomes.patient_status AS outcomes.PATIENT_STATUS
      WITH SYNONYMS = ('status')
      COMMENT = 'Patient status',
    
    outcomes.primary_condition AS outcomes.PRIMARY_CONDITION
      WITH SYNONYMS = ('condition', 'diagnosis')
      COMMENT = 'Primary health condition',
    
    outcomes.outcome_type AS outcomes.OUTCOME_TYPE
      WITH SYNONYMS = ('metric type', 'measurement')
      COMMENT = 'Type of outcome: A1C_LEVEL, BLOOD_PRESSURE, etc.',
    
    outcomes.engagement_tier AS outcomes.ENGAGEMENT_TIER
      WITH SYNONYMS = ('engagement level', 'tier')
      COMMENT = 'Engagement tier: HIGH, MEDIUM, LOW',
    
    outcomes.is_improved AS outcomes.IS_IMPROVED
      WITH SYNONYMS = ('improved', 'better')
      COMMENT = 'Whether outcome improved'
  )
  METRICS (
    outcomes.engagement_score AS AVG(outcomes.ENGAGEMENT_SCORE)
      WITH SYNONYMS = ('engagement')
      COMMENT = 'Patient engagement score',
    
    outcomes.outcome_value AS AVG(outcomes.OUTCOME_VALUE)
      WITH SYNONYMS = ('value', 'measurement')
      COMMENT = 'Outcome measurement value',
    
    outcomes.benchmark_value AS AVG(outcomes.BENCHMARK_VALUE)
      WITH SYNONYMS = ('target', 'goal')
      COMMENT = 'Target benchmark value',
    
    outcomes.improvement_rate AS AVG(outcomes.IMPROVED_FLAG)
      WITH SYNONYMS = ('improvement percentage', 'success rate')
      COMMENT = 'Percentage of patients who improved',
    
    outcomes.total_outcomes AS COUNT(*)
      WITH SYNONYMS = ('outcome count')
      COMMENT = 'Total number of outcome records'
  )
  COMMENT = 'Correlation analysis between patient engagement and health outcomes.';

GRANT SELECT ON SEMANTIC VIEW SV_OUTCOMES_CORRELATION TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- SEMANTIC VIEW 4: CONTENT PERFORMANCE
-- For analyzing content effectiveness
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_CONTENT_PERFORMANCE
  TABLES (
    content AS V_CONTENT_PERFORMANCE PRIMARY KEY (CONTENT_ID)
  )
  DIMENSIONS (
    content.content_id AS content.CONTENT_ID
      WITH SYNONYMS = ('content', 'content id')
      COMMENT = 'Content identifier',
    
    content.title AS content.TITLE
      WITH SYNONYMS = ('name', 'content title')
      COMMENT = 'Content title',
    
    content.category AS content.CATEGORY
      WITH SYNONYMS = ('type', 'content category')
      COMMENT = 'Category: Health Education, Pharma Ad, etc.',
    
    content.subcategory AS content.SUBCATEGORY
      WITH SYNONYMS = ('sub-category')
      COMMENT = 'Subcategory',
    
    content.sponsor AS content.SPONSOR
      WITH SYNONYMS = ('pharma partner', 'advertiser')
      COMMENT = 'Pharma sponsor (if applicable)',
    
    content.target_condition AS content.TARGET_CONDITION
      WITH SYNONYMS = ('condition', 'target audience')
      COMMENT = 'Target health condition',
    
    content.content_type AS content.CONTENT_TYPE
      WITH SYNONYMS = ('format', 'media type')
      COMMENT = 'Format: Video, Interactive, Infographic, Quiz'
  )
  METRICS (
    content.total_interactions AS MAX(content.TOTAL_INTERACTIONS)
      WITH SYNONYMS = ('interactions', 'views')
      COMMENT = 'Total interactions with content',
    
    content.unique_patients AS MAX(content.UNIQUE_PATIENTS)
      WITH SYNONYMS = ('reach', 'unique viewers')
      COMMENT = 'Unique patients who viewed',
    
    content.avg_dwell_time AS MAX(content.AVG_DWELL_TIME)
      WITH SYNONYMS = ('dwell time', 'time spent')
      COMMENT = 'Average time spent on content',
    
    content.avg_completion_rate AS MAX(content.AVG_COMPLETION_RATE)
      WITH SYNONYMS = ('completion rate')
      COMMENT = 'Average completion rate',
    
    content.completion_rate_pct AS MAX(content.COMPLETION_RATE_PCT)
      WITH SYNONYMS = ('completion percentage')
      COMMENT = 'Completion rate as percentage',
    
    content.effectiveness_score AS MAX(content.EFFECTIVENESS_SCORE)
      WITH SYNONYMS = ('effectiveness', 'performance score')
      COMMENT = 'Overall effectiveness score',
    
    content.total_content AS COUNT(DISTINCT content.CONTENT_ID)
      WITH SYNONYMS = ('content count')
      COMMENT = 'Total count of content items'
  )
  COMMENT = 'Content performance analytics including engagement metrics and effectiveness scores.';

GRANT SELECT ON SEMANTIC VIEW SV_CONTENT_PERFORMANCE TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- SEMANTIC VIEW 5: ROI ANALYSIS
-- For executive-level ROI and business impact questions
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ENGAGEMENT_ROI
  TABLES (
    roi AS V_ENGAGEMENT_ROI PRIMARY KEY (ROI_ID)
  )
  DIMENSIONS (
    roi.roi_id AS roi.ROI_ID
      COMMENT = 'Summary record identifier',
    
    roi.patient_churn_rate AS roi.PATIENT_CHURN_RATE_PCT
      WITH SYNONYMS = ('churn rate', 'attrition rate')
      COMMENT = 'Patient churn rate percentage'
  )
  METRICS (
    roi.total_patients AS MAX(roi.TOTAL_PATIENTS)
      WITH SYNONYMS = ('patients', 'patient count')
      COMMENT = 'Total patients',
    
    roi.active_patients AS MAX(roi.ACTIVE_PATIENTS)
      WITH SYNONYMS = ('active')
      COMMENT = 'Active patients',
    
    roi.churned_patients AS MAX(roi.CHURNED_PATIENTS)
      WITH SYNONYMS = ('churned')
      COMMENT = 'Churned patients',
    
    roi.total_providers AS MAX(roi.TOTAL_PROVIDERS)
      WITH SYNONYMS = ('providers', 'facilities')
      COMMENT = 'Total providers',
    
    roi.at_risk_providers AS MAX(roi.AT_RISK_PROVIDERS)
      WITH SYNONYMS = ('at risk', 'risky providers')
      COMMENT = 'Providers at risk of churning',
    
    roi.annual_active_revenue AS MAX(roi.ANNUAL_ACTIVE_REVENUE)
      WITH SYNONYMS = ('active revenue', 'ARR')
      COMMENT = 'Annual revenue from active providers',
    
    roi.annual_at_risk_revenue AS MAX(roi.ANNUAL_AT_RISK_REVENUE)
      WITH SYNONYMS = ('revenue at risk')
      COMMENT = 'Annual revenue at risk of churn',
    
    roi.annual_lost_revenue AS MAX(roi.ANNUAL_LOST_REVENUE)
      WITH SYNONYMS = ('lost revenue', 'churned revenue')
      COMMENT = 'Annual revenue lost to churn',
    
    roi.avg_active_engagement AS MAX(roi.AVG_ACTIVE_PATIENT_ENGAGEMENT)
      WITH SYNONYMS = ('active patient engagement')
      COMMENT = 'Average engagement of active patients',
    
    roi.avg_churned_engagement AS MAX(roi.AVG_CHURNED_PATIENT_ENGAGEMENT)
      WITH SYNONYMS = ('churned patient engagement')
      COMMENT = 'Average engagement of churned patients',
    
    roi.high_engagement_improvement AS MAX(roi.HIGH_ENGAGEMENT_IMPROVEMENT_PCT)
      WITH SYNONYMS = ('high engagement outcomes')
      COMMENT = 'Outcome improvement rate for high engagement patients',
    
    roi.low_engagement_improvement AS MAX(roi.LOW_ENGAGEMENT_IMPROVEMENT_PCT)
      WITH SYNONYMS = ('low engagement outcomes')
      COMMENT = 'Outcome improvement rate for low engagement patients',
    
    roi.churn_prediction_accuracy AS MAX(roi.CHURN_PREDICTION_ACCURACY_PCT)
      WITH SYNONYMS = ('prediction accuracy', 'model accuracy')
      COMMENT = 'Churn prediction model accuracy'
  )
  COMMENT = 'ROI and business impact analytics for patient engagement.';

GRANT SELECT ON SEMANTIC VIEW SV_ENGAGEMENT_ROI TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SHOW SEMANTIC VIEWS IN SCHEMA ENGAGEMENT_ANALYTICS;

