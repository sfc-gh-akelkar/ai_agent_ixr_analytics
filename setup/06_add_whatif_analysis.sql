/*******************************************************************************
 * PATIENTPOINT PATIENT ENGAGEMENT ANALYTICS
 * 
 * Part 6: What-If Analysis Views for Cortex Agent
 * 
 * WHY CUSTOMERS CARE:
 * - Executives want to know "what would happen if we improved by X%?"
 * - These views let the agent answer hypothetical ROI questions
 * - Quantifies the business case for investment in engagement programs
 * 
 * Prerequisites: Run scripts 01-05 first
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_ENGAGEMENT;
USE SCHEMA ENGAGEMENT_ANALYTICS;

-- ============================================================================
-- VIEW 1: WHAT-IF ENGAGEMENT IMPROVEMENT SCENARIOS
-- ============================================================================
-- Answers: "What's the financial impact if we improve engagement by X%?"

CREATE OR REPLACE VIEW V_WHATIF_ENGAGEMENT_IMPROVEMENT AS
WITH current_metrics AS (
    SELECT 
        (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as current_at_risk_providers,
        (SELECT SUM(MONTHLY_FEE_USD * 12) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as current_at_risk_revenue,
        (SELECT AVG(ENGAGEMENT_SCORE) FROM PATIENTS) as current_avg_engagement,
        (SELECT COUNT(*) FROM PATIENTS WHERE STATUS = 'CHURNED') as current_churned_patients,
        (SELECT COUNT(*) FROM PATIENTS) as total_patients
)
SELECT 
    -- Scenario parameters
    improvement_pct as ENGAGEMENT_IMPROVEMENT_PCT,
    
    -- Current state
    cm.current_avg_engagement as CURRENT_AVG_ENGAGEMENT,
    cm.current_avg_engagement * (1 + improvement_pct/100.0) as PROJECTED_AVG_ENGAGEMENT,
    
    -- Provider churn reduction (assumption: 10% engagement improvement = 5% churn reduction)
    cm.current_at_risk_providers as CURRENT_AT_RISK_PROVIDERS,
    ROUND(cm.current_at_risk_providers * (1 - (improvement_pct * 0.5 / 100.0))) as PROJECTED_AT_RISK_PROVIDERS,
    cm.current_at_risk_providers - ROUND(cm.current_at_risk_providers * (1 - (improvement_pct * 0.5 / 100.0))) as PROVIDERS_SAVED,
    
    -- Revenue impact
    cm.current_at_risk_revenue as CURRENT_AT_RISK_REVENUE,
    ROUND(cm.current_at_risk_revenue * (improvement_pct * 0.5 / 100.0)) as REVENUE_PROTECTED,
    
    -- Patient churn reduction (assumption: 10% engagement improvement = 8% patient churn reduction)
    cm.current_churned_patients as CURRENT_CHURNED_PATIENTS,
    ROUND(cm.current_churned_patients * (improvement_pct * 0.8 / 100.0)) as PATIENTS_RETAINED,
    
    -- Churn rate impact
    ROUND(cm.current_churned_patients * 100.0 / cm.total_patients, 2) as CURRENT_CHURN_RATE_PCT,
    ROUND((cm.current_churned_patients - (cm.current_churned_patients * improvement_pct * 0.8 / 100.0)) * 100.0 / cm.total_patients, 2) as PROJECTED_CHURN_RATE_PCT,
    
    -- Business case summary
    CONCAT('A ', improvement_pct, '% improvement in patient engagement would protect approximately $', 
           ROUND(cm.current_at_risk_revenue * (improvement_pct * 0.5 / 100.0) / 1000, 0), 
           'K in annual revenue and retain ', 
           ROUND(cm.current_churned_patients * (improvement_pct * 0.8 / 100.0)), 
           ' additional patients.') as BUSINESS_IMPACT_SUMMARY
    
FROM current_metrics cm
CROSS JOIN (
    SELECT 5 as improvement_pct UNION ALL
    SELECT 10 UNION ALL
    SELECT 15 UNION ALL
    SELECT 20 UNION ALL
    SELECT 25 UNION ALL
    SELECT 30
) scenarios;

-- ============================================================================
-- VIEW 2: CHURN REDUCTION ROI CALCULATOR
-- ============================================================================
-- Answers: "What's the ROI if we reduce churn by X%?"

CREATE OR REPLACE VIEW V_WHATIF_CHURN_REDUCTION AS
WITH current_metrics AS (
    SELECT 
        (SELECT SUM(MONTHLY_FEE_USD * 12) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as at_risk_revenue,
        (SELECT SUM(MONTHLY_FEE_USD * 12) FROM PROVIDERS WHERE CONTRACT_STATUS = 'CHURNED') as lost_revenue,
        (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as at_risk_count,
        (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'CHURNED') as churned_count
)
SELECT 
    churn_reduction_pct as CHURN_REDUCTION_PCT,
    
    -- Revenue recovery from at-risk
    cm.at_risk_revenue as CURRENT_AT_RISK_REVENUE,
    ROUND(cm.at_risk_revenue * churn_reduction_pct / 100.0) as REVENUE_SAVED_FROM_AT_RISK,
    
    -- Providers retained
    cm.at_risk_count as CURRENT_AT_RISK_PROVIDERS,
    ROUND(cm.at_risk_count * churn_reduction_pct / 100.0) as PROVIDERS_RETAINED,
    
    -- Estimated program cost (assumption: $50K per 10% churn reduction)
    ROUND(churn_reduction_pct * 5000) as ESTIMATED_PROGRAM_COST,
    
    -- Net ROI
    ROUND(cm.at_risk_revenue * churn_reduction_pct / 100.0) - ROUND(churn_reduction_pct * 5000) as NET_ROI,
    ROUND((cm.at_risk_revenue * churn_reduction_pct / 100.0) / NULLIF(churn_reduction_pct * 5000, 0), 1) as ROI_MULTIPLIER,
    
    -- Summary
    CONCAT('Reducing churn by ', churn_reduction_pct, '% would save $', 
           ROUND(cm.at_risk_revenue * churn_reduction_pct / 100.0 / 1000, 0), 
           'K annually. Estimated cost: $', ROUND(churn_reduction_pct * 5, 0), 
           'K. Net ROI: $', ROUND((cm.at_risk_revenue * churn_reduction_pct / 100.0 - churn_reduction_pct * 5000) / 1000, 0), 'K.') as ROI_SUMMARY
           
FROM current_metrics cm
CROSS JOIN (
    SELECT 10 as churn_reduction_pct UNION ALL
    SELECT 20 UNION ALL
    SELECT 30 UNION ALL
    SELECT 40 UNION ALL
    SELECT 50
) scenarios;

-- ============================================================================
-- VIEW 3: INTERVENTION PRIORITY MATRIX
-- ============================================================================
-- Answers: "Which providers should we focus on first?"

CREATE OR REPLACE VIEW V_INTERVENTION_PRIORITY AS
SELECT 
    PROVIDER_ID,
    FACILITY_NAME,
    FACILITY_TYPE,
    ACCOUNT_MANAGER,
    CHURN_RISK_SCORE,
    ANNUAL_REVENUE_AT_RISK,
    PATIENT_ENGAGEMENT_SCORE,
    NPS_SCORE,
    ENGAGEMENT_TREND,
    
    -- Priority score (weighted: revenue 40%, churn risk 40%, engagement trend 20%)
    ROUND(
        (CHURN_RISK_SCORE * 0.4) + 
        (ANNUAL_REVENUE_AT_RISK / 1000 * 0.4) + 
        (CASE ENGAGEMENT_TREND 
            WHEN 'DECLINING' THEN 30 
            WHEN 'STABLE' THEN 15 
            ELSE 0 
        END * 0.2)
    , 1) as PRIORITY_SCORE,
    
    -- Priority tier
    CASE 
        WHEN CHURN_RISK_SCORE >= 70 AND ANNUAL_REVENUE_AT_RISK > 30000 THEN 'CRITICAL - Immediate Action'
        WHEN CHURN_RISK_SCORE >= 60 THEN 'HIGH - This Week'
        WHEN CHURN_RISK_SCORE >= 40 THEN 'MEDIUM - This Month'
        ELSE 'LOW - Monitor'
    END as PRIORITY_TIER,
    
    -- Recommended action
    CASE 
        WHEN CHURN_RISK_SCORE >= 70 THEN 'Executive escalation + on-site visit within 48 hours'
        WHEN ENGAGEMENT_TREND = 'DECLINING' THEN 'Content refresh + engagement review call'
        WHEN NPS_SCORE < 7 THEN 'Customer success outreach to address satisfaction issues'
        ELSE 'Standard quarterly business review'
    END as RECOMMENDED_ACTION
    
FROM V_PROVIDER_HEALTH
WHERE CONTRACT_STATUS != 'CHURNED'
ORDER BY PRIORITY_SCORE DESC;

-- ============================================================================
-- VIEW 4: EXECUTIVE SUMMARY FOR CHATBOT
-- ============================================================================
-- A single view the agent can query for quick executive summaries

CREATE OR REPLACE VIEW V_EXECUTIVE_QUICK_STATS AS
SELECT 
    -- Key counts
    (SELECT COUNT(*) FROM PATIENTS) as TOTAL_PATIENTS,
    (SELECT COUNT(*) FROM PATIENTS WHERE STATUS = 'ACTIVE') as ACTIVE_PATIENTS,
    (SELECT COUNT(*) FROM PROVIDERS) as TOTAL_PROVIDERS,
    (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as AT_RISK_PROVIDERS,
    
    -- Revenue
    (SELECT ROUND(SUM(MONTHLY_FEE_USD * 12), 0) FROM PROVIDERS WHERE CONTRACT_STATUS = 'ACTIVE') as TOTAL_ACTIVE_ARR,
    (SELECT ROUND(SUM(MONTHLY_FEE_USD * 12), 0) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as AT_RISK_ARR,
    
    -- Engagement
    (SELECT ROUND(AVG(ENGAGEMENT_SCORE), 1) FROM PATIENTS) as AVG_PATIENT_ENGAGEMENT,
    (SELECT ROUND(AVG(ENGAGEMENT_SCORE), 1) FROM PATIENTS WHERE STATUS = 'ACTIVE') as AVG_ACTIVE_ENGAGEMENT,
    (SELECT ROUND(AVG(ENGAGEMENT_SCORE), 1) FROM PATIENTS WHERE STATUS = 'CHURNED') as AVG_CHURNED_ENGAGEMENT,
    
    -- Hypothesis validation
    (SELECT ROUND(AVG(CASE WHEN IS_IMPROVED THEN 1 ELSE 0 END) * 100, 1) 
     FROM V_ENGAGEMENT_OUTCOMES_CORRELATION WHERE ENGAGEMENT_TIER = 'HIGH') as HIGH_ENGAGEMENT_IMPROVEMENT_PCT,
    (SELECT ROUND(AVG(CASE WHEN IS_IMPROVED THEN 1 ELSE 0 END) * 100, 1) 
     FROM V_ENGAGEMENT_OUTCOMES_CORRELATION WHERE ENGAGEMENT_TIER = 'LOW') as LOW_ENGAGEMENT_IMPROVEMENT_PCT,
     
    -- Model performance
    (SELECT ROUND(precision_pct, 1) FROM V_MODEL_PERFORMANCE) as CHURN_PREDICTION_PRECISION,
    (SELECT ROUND(recall_pct, 1) FROM V_MODEL_PERFORMANCE) as CHURN_PREDICTION_RECALL;

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT ON VIEW V_WHATIF_ENGAGEMENT_IMPROVEMENT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW V_WHATIF_CHURN_REDUCTION TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW V_INTERVENTION_PRIORITY TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW V_EXECUTIVE_QUICK_STATS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Test what-if scenarios
SELECT * FROM V_WHATIF_ENGAGEMENT_IMPROVEMENT WHERE ENGAGEMENT_IMPROVEMENT_PCT = 20;
SELECT * FROM V_WHATIF_CHURN_REDUCTION WHERE CHURN_REDUCTION_PCT = 25;
SELECT * FROM V_INTERVENTION_PRIORITY LIMIT 10;
SELECT * FROM V_EXECUTIVE_QUICK_STATS;

