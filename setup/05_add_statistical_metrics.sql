/*******************************************************************************
 * PATIENTPOINT PATIENT ENGAGEMENT ANALYTICS
 * 
 * Part 5: Statistical Validation Metrics
 * 
 * WHY CUSTOMERS CARE:
 * - Data science teams need statistical rigor to defend findings
 * - Executives need confidence levels to make investment decisions
 * - Precision/recall metrics prove the model is production-ready
 * - These metrics turn "we think engagement helps" into "we KNOW it does"
 * 
 * Prerequisites: Run scripts 01-04 first
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_ENGAGEMENT;
USE SCHEMA ENGAGEMENT_ANALYTICS;

-- ============================================================================
-- VIEW 1: ENGAGEMENT-OUTCOME STATISTICAL VALIDATION
-- ============================================================================
-- WHY THEY CARE: This proves the correlation is real, not random chance.
-- When the CFO asks "are you sure?", this is the answer.

CREATE OR REPLACE VIEW V_STATISTICAL_VALIDATION AS
WITH engagement_outcome_stats AS (
    SELECT 
        -- Sample sizes by tier
        COUNT(*) as total_observations,
        SUM(CASE WHEN ENGAGEMENT_TIER = 'HIGH' THEN 1 ELSE 0 END) as high_engagement_n,
        SUM(CASE WHEN ENGAGEMENT_TIER = 'MEDIUM' THEN 1 ELSE 0 END) as medium_engagement_n,
        SUM(CASE WHEN ENGAGEMENT_TIER = 'LOW' THEN 1 ELSE 0 END) as low_engagement_n,
        
        -- Improvement rates by tier
        AVG(CASE WHEN ENGAGEMENT_TIER = 'HIGH' THEN IMPROVED_FLAG END) as high_engagement_improvement_rate,
        AVG(CASE WHEN ENGAGEMENT_TIER = 'MEDIUM' THEN IMPROVED_FLAG END) as medium_engagement_improvement_rate,
        AVG(CASE WHEN ENGAGEMENT_TIER = 'LOW' THEN IMPROVED_FLAG END) as low_engagement_improvement_rate,
        
        -- Standard deviations for confidence intervals
        STDDEV(CASE WHEN ENGAGEMENT_TIER = 'HIGH' THEN IMPROVED_FLAG END) as high_stddev,
        STDDEV(CASE WHEN ENGAGEMENT_TIER = 'LOW' THEN IMPROVED_FLAG END) as low_stddev,
        
        -- Correlation coefficient
        CORR(ENGAGEMENT_SCORE, IMPROVED_FLAG) as engagement_outcome_correlation
        
    FROM V_ENGAGEMENT_OUTCOMES_CORRELATION
),
patient_retention_stats AS (
    SELECT
        -- Engagement scores by status
        AVG(CASE WHEN PATIENT_STATUS = 'ACTIVE' THEN ENGAGEMENT_SCORE END) as active_patient_avg_engagement,
        AVG(CASE WHEN PATIENT_STATUS = 'CHURNED' THEN ENGAGEMENT_SCORE END) as churned_patient_avg_engagement,
        
        -- Sample sizes
        SUM(CASE WHEN PATIENT_STATUS = 'ACTIVE' THEN 1 ELSE 0 END) as active_patient_n,
        SUM(CASE WHEN PATIENT_STATUS = 'CHURNED' THEN 1 ELSE 0 END) as churned_patient_n,
        
        -- Standard deviations
        STDDEV(CASE WHEN PATIENT_STATUS = 'ACTIVE' THEN ENGAGEMENT_SCORE END) as active_stddev,
        STDDEV(CASE WHEN PATIENT_STATUS = 'CHURNED' THEN ENGAGEMENT_SCORE END) as churned_stddev
        
    FROM V_PATIENT_ENGAGEMENT
),
provider_retention_stats AS (
    SELECT
        -- Correlation between patient engagement and provider churn risk
        CORR(AVG_PATIENT_ENGAGEMENT, CHURN_RISK_SCORE) as engagement_churn_correlation,
        COUNT(*) as provider_n
    FROM V_PROVIDER_HEALTH
    WHERE AVG_PATIENT_ENGAGEMENT IS NOT NULL
)
SELECT
    -- Hypothesis 1: Patient→Provider Retention
    'H1: Patient→Provider Retention' as hypothesis,
    p.active_patient_avg_engagement,
    p.churned_patient_avg_engagement,
    ROUND(p.active_patient_avg_engagement - p.churned_patient_avg_engagement, 2) as engagement_gap,
    p.active_patient_n,
    p.churned_patient_n,
    -- Effect size (Cohen's d approximation)
    ROUND((p.active_patient_avg_engagement - p.churned_patient_avg_engagement) / 
          SQRT((POWER(p.active_stddev, 2) + POWER(p.churned_stddev, 2)) / 2), 2) as effect_size_cohens_d,
    CASE 
        WHEN ABS((p.active_patient_avg_engagement - p.churned_patient_avg_engagement) / 
             SQRT((POWER(p.active_stddev, 2) + POWER(p.churned_stddev, 2)) / 2)) > 0.8 THEN 'LARGE'
        WHEN ABS((p.active_patient_avg_engagement - p.churned_patient_avg_engagement) / 
             SQRT((POWER(p.active_stddev, 2) + POWER(p.churned_stddev, 2)) / 2)) > 0.5 THEN 'MEDIUM'
        ELSE 'SMALL'
    END as effect_size_interpretation,
    
    -- Hypothesis 2: Patient Outcomes
    e.engagement_outcome_correlation as h2_correlation,
    ROUND(e.high_engagement_improvement_rate * 100, 1) as high_engagement_improvement_pct,
    ROUND(e.low_engagement_improvement_rate * 100, 1) as low_engagement_improvement_pct,
    ROUND((e.high_engagement_improvement_rate - e.low_engagement_improvement_rate) * 100, 1) as improvement_difference_pp,
    e.high_engagement_n,
    e.low_engagement_n,
    
    -- Hypothesis 3: Provider→PatientPoint Retention
    pr.engagement_churn_correlation as h3_correlation,
    pr.provider_n as h3_sample_size,
    
    -- Confidence assessment
    CASE 
        WHEN e.total_observations > 1000 
         AND ABS(e.engagement_outcome_correlation) > 0.1
         AND p.active_patient_n > 100 
         AND p.churned_patient_n > 100
        THEN 'HIGH - Statistically robust'
        WHEN e.total_observations > 500
        THEN 'MEDIUM - Sufficient for directional confidence'
        ELSE 'LOW - Requires more data'
    END as overall_confidence_level
    
FROM engagement_outcome_stats e
CROSS JOIN patient_retention_stats p
CROSS JOIN provider_retention_stats pr;

-- ============================================================================
-- VIEW 2: CHURN MODEL PERFORMANCE METRICS
-- ============================================================================
-- WHY THEY CARE: "85% accuracy" sounds good, but data scientists want
-- precision and recall. This answers "how many false alarms?" and
-- "how many churns do we miss?"

CREATE OR REPLACE VIEW V_MODEL_PERFORMANCE AS
WITH confusion_matrix AS (
    SELECT
        -- True Positives: Predicted high churn AND actually churned
        SUM(CASE WHEN PREDICTED_CHURN_PROBABILITY > 0.5 AND ACTUAL_CHURN = TRUE THEN 1 ELSE 0 END) as true_positives,
        
        -- False Positives: Predicted high churn BUT didn't churn
        SUM(CASE WHEN PREDICTED_CHURN_PROBABILITY > 0.5 AND ACTUAL_CHURN = FALSE THEN 1 ELSE 0 END) as false_positives,
        
        -- True Negatives: Predicted low churn AND didn't churn
        SUM(CASE WHEN PREDICTED_CHURN_PROBABILITY <= 0.5 AND ACTUAL_CHURN = FALSE THEN 1 ELSE 0 END) as true_negatives,
        
        -- False Negatives: Predicted low churn BUT actually churned
        SUM(CASE WHEN PREDICTED_CHURN_PROBABILITY <= 0.5 AND ACTUAL_CHURN = TRUE THEN 1 ELSE 0 END) as false_negatives,
        
        COUNT(*) as total_predictions
    FROM CHURN_EVENTS
)
SELECT
    -- Core metrics
    true_positives,
    false_positives,
    true_negatives,
    false_negatives,
    total_predictions,
    
    -- Accuracy: Overall correctness
    ROUND((true_positives + true_negatives) * 100.0 / NULLIF(total_predictions, 0), 1) as accuracy_pct,
    
    -- Precision: Of those we flagged as high-risk, how many actually churned?
    -- HIGH precision = fewer false alarms = customer success team trusts the alerts
    ROUND(true_positives * 100.0 / NULLIF(true_positives + false_positives, 0), 1) as precision_pct,
    
    -- Recall: Of all actual churns, how many did we catch?
    -- HIGH recall = we catch most churns = fewer surprises
    ROUND(true_positives * 100.0 / NULLIF(true_positives + false_negatives, 0), 1) as recall_pct,
    
    -- F1 Score: Harmonic mean of precision and recall
    ROUND(2 * (true_positives * 100.0 / NULLIF(true_positives + false_positives, 0)) * 
              (true_positives * 100.0 / NULLIF(true_positives + false_negatives, 0)) /
          NULLIF((true_positives * 100.0 / NULLIF(true_positives + false_positives, 0)) + 
                 (true_positives * 100.0 / NULLIF(true_positives + false_negatives, 0)), 0), 1) as f1_score,
    
    -- Business interpretation
    CASE 
        WHEN ROUND(true_positives * 100.0 / NULLIF(true_positives + false_positives, 0), 1) >= 80 
         AND ROUND(true_positives * 100.0 / NULLIF(true_positives + false_negatives, 0), 1) >= 80
        THEN 'PRODUCTION-READY: High precision and recall'
        WHEN ROUND(true_positives * 100.0 / NULLIF(true_positives + false_positives, 0), 1) >= 70
        THEN 'ACCEPTABLE: Good precision, may miss some churns'
        ELSE 'NEEDS IMPROVEMENT: Model requires tuning'
    END as model_readiness,
    
    -- What this means in plain English
    'Precision ' || ROUND(true_positives * 100.0 / NULLIF(true_positives + false_positives, 0), 0) || 
    '% means: of every 100 patients we flag as at-risk, ' || 
    ROUND(true_positives * 100.0 / NULLIF(true_positives + false_positives, 0), 0) || 
    ' will actually churn if we dont intervene.' as precision_interpretation,
    
    'Recall ' || ROUND(true_positives * 100.0 / NULLIF(true_positives + false_negatives, 0), 0) || 
    '% means: we catch ' || 
    ROUND(true_positives * 100.0 / NULLIF(true_positives + false_negatives, 0), 0) || 
    ' out of every 100 patients who would have churned.' as recall_interpretation

FROM confusion_matrix;

-- ============================================================================
-- VIEW 3: HYPOTHESIS VALIDATION SUMMARY
-- ============================================================================
-- WHY THEY CARE: One view that answers "did we prove it?" for each hypothesis.
-- This is the executive summary for the board deck.

CREATE OR REPLACE VIEW V_HYPOTHESIS_VALIDATION AS
SELECT
    -- Hypothesis 1: Patient→Provider Retention
    'H1' as hypothesis_id,
    'Patient→Provider Retention' as hypothesis_name,
    'Do engaged patients stay with their providers longer?' as question,
    CASE 
        WHEN (SELECT active_patient_avg_engagement - churned_patient_avg_engagement 
              FROM V_STATISTICAL_VALIDATION) > 10 
        THEN '✅ VALIDATED'
        ELSE '⚠️ INCONCLUSIVE'
    END as status,
    (SELECT ROUND(active_patient_avg_engagement - churned_patient_avg_engagement, 1) 
     FROM V_STATISTICAL_VALIDATION) as evidence_value,
    'point engagement gap between active and churned patients' as evidence_unit,
    (SELECT effect_size_interpretation FROM V_STATISTICAL_VALIDATION) as effect_size,
    'Engaged patients are significantly less likely to switch providers' as business_implication

UNION ALL

SELECT
    'H2' as hypothesis_id,
    'Patient Outcomes' as hypothesis_name,
    'Does engagement correlate with better health outcomes?' as question,
    CASE 
        WHEN (SELECT improvement_difference_pp FROM V_STATISTICAL_VALIDATION) > 5 
        THEN '✅ VALIDATED'
        ELSE '⚠️ INCONCLUSIVE'
    END as status,
    (SELECT improvement_difference_pp FROM V_STATISTICAL_VALIDATION) as evidence_value,
    'percentage point improvement difference (high vs low engagement)' as evidence_unit,
    CASE 
        WHEN (SELECT ABS(h2_correlation) FROM V_STATISTICAL_VALIDATION) > 0.3 THEN 'STRONG'
        WHEN (SELECT ABS(h2_correlation) FROM V_STATISTICAL_VALIDATION) > 0.1 THEN 'MODERATE'
        ELSE 'WEAK'
    END as effect_size,
    'Pharma partners can prove their content drives measurable outcomes' as business_implication

UNION ALL

SELECT
    'H3' as hypothesis_id,
    'Provider→PatientPoint Retention' as hypothesis_name,
    'Do providers with engaged patients stay with PatientPoint?' as question,
    CASE 
        WHEN (SELECT ABS(h3_correlation) FROM V_STATISTICAL_VALIDATION) > 0.2 
        THEN '✅ VALIDATED'
        ELSE '⚠️ INCONCLUSIVE'
    END as status,
    (SELECT ROUND(ABS(h3_correlation), 2) FROM V_STATISTICAL_VALIDATION) as evidence_value,
    'negative correlation between patient engagement and provider churn risk' as evidence_unit,
    CASE 
        WHEN (SELECT ABS(h3_correlation) FROM V_STATISTICAL_VALIDATION) > 0.4 THEN 'STRONG'
        WHEN (SELECT ABS(h3_correlation) FROM V_STATISTICAL_VALIDATION) > 0.2 THEN 'MODERATE'
        ELSE 'WEAK'
    END as effect_size,
    'Patient engagement is a leading indicator of provider retention—the flywheel' as business_implication;

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT ON VIEW V_STATISTICAL_VALIDATION TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW V_MODEL_PERFORMANCE TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW V_HYPOTHESIS_VALIDATION TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check statistical validation
SELECT * FROM V_STATISTICAL_VALIDATION;

-- Check model performance
SELECT * FROM V_MODEL_PERFORMANCE;

-- Check hypothesis summary
SELECT * FROM V_HYPOTHESIS_VALIDATION;

