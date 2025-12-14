/*******************************************************************************
 * PATIENTPOINT PATIENT ENGAGEMENT ANALYTICS
 * Engagement-Driven Retention & Outcomes Analysis
 * 
 * Part 3: Cortex Search Services
 * 
 * Prerequisites: Run 01_create_database_and_data.sql first
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_ENGAGEMENT;
USE SCHEMA ENGAGEMENT_ANALYTICS;

-- ============================================================================
-- CONTENT LIBRARY SEARCH
-- Enables natural language search across health education content
-- ============================================================================

-- Create a searchable view of content with rich metadata
CREATE OR REPLACE VIEW V_CONTENT_SEARCH AS
SELECT 
    CONTENT_ID,
    TITLE,
    CATEGORY,
    SUBCATEGORY,
    COALESCE(SPONSOR, 'PatientPoint') as SPONSOR,
    TARGET_CONDITION,
    CONTENT_TYPE,
    DURATION_SECONDS,
    STATUS,
    EFFECTIVENESS_SCORE,
    PUBLISH_DATE,
    -- Combine into searchable text
    CONCAT(
        'Title: ', TITLE, '. ',
        'Category: ', CATEGORY, ' - ', SUBCATEGORY, '. ',
        'Target Condition: ', TARGET_CONDITION, '. ',
        'Format: ', CONTENT_TYPE, '. ',
        'Duration: ', DURATION_SECONDS, ' seconds. ',
        CASE WHEN SPONSOR IS NOT NULL 
            THEN 'Sponsored by: ' || SPONSOR || '. '
            ELSE 'PatientPoint original content. '
        END,
        'Effectiveness Score: ', ROUND(EFFECTIVENESS_SCORE, 1), '/100.'
    ) as SEARCH_TEXT
FROM CONTENT_LIBRARY
WHERE STATUS = 'ACTIVE';

-- Create Cortex Search service for content
CREATE OR REPLACE CORTEX SEARCH SERVICE CONTENT_SEARCH_SVC
    ON SEARCH_TEXT
    ATTRIBUTES CATEGORY, TARGET_CONDITION, SPONSOR, CONTENT_TYPE
    WAREHOUSE = COMPUTE_WH
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            CONTENT_ID,
            TITLE,
            CATEGORY,
            SUBCATEGORY,
            SPONSOR,
            TARGET_CONDITION,
            CONTENT_TYPE,
            DURATION_SECONDS,
            EFFECTIVENESS_SCORE,
            SEARCH_TEXT
        FROM V_CONTENT_SEARCH
    );

GRANT USAGE ON CORTEX SEARCH SERVICE CONTENT_SEARCH_SVC TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- CHURN INSIGHTS SEARCH
-- Enables search across churn events and reasons
-- ============================================================================

-- Create a searchable view of churn patterns
-- Note: Simplified to avoid outer joins with non-equality predicates (not supported by Cortex Search change tracking)
CREATE OR REPLACE VIEW V_CHURN_INSIGHTS AS
SELECT 
    EVENT_ID,
    ENTITY_TYPE,
    ENTITY_ID,
    CHURN_DATE,
    DAYS_SINCE_LAST_ACTIVITY,
    ENGAGEMENT_SCORE_AT_CHURN,
    PREDICTED_CHURN_PROBABILITY,
    CHURN_REASON,
    WIN_BACK_ATTEMPTED,
    WIN_BACK_SUCCESSFUL,
    -- Searchable text (without joined data to support change tracking)
    CONCAT(
        ENTITY_TYPE, ' churn event. ',
        'Entity ID: ', ENTITY_ID, '. ',
        'Reason: ', COALESCE(CHURN_REASON, 'Unknown'), '. ',
        'Engagement at churn: ', ROUND(ENGAGEMENT_SCORE_AT_CHURN, 1), '/100. ',
        'Days inactive before churn: ', DAYS_SINCE_LAST_ACTIVITY, '. ',
        'Predicted probability: ', ROUND(PREDICTED_CHURN_PROBABILITY * 100, 1), '%. ',
        CASE WHEN WIN_BACK_ATTEMPTED THEN 'Win-back was attempted. ' ELSE '' END,
        CASE WHEN WIN_BACK_SUCCESSFUL THEN 'Win-back successful!' ELSE '' END
    ) as SEARCH_TEXT
FROM CHURN_EVENTS;

-- Create Cortex Search service for churn insights
CREATE OR REPLACE CORTEX SEARCH SERVICE CHURN_INSIGHTS_SVC
    ON SEARCH_TEXT
    ATTRIBUTES ENTITY_TYPE, CHURN_REASON
    WAREHOUSE = COMPUTE_WH
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            EVENT_ID,
            ENTITY_TYPE,
            ENTITY_ID,
            CHURN_DATE,
            DAYS_SINCE_LAST_ACTIVITY,
            ENGAGEMENT_SCORE_AT_CHURN,
            CHURN_REASON,
            WIN_BACK_ATTEMPTED,
            WIN_BACK_SUCCESSFUL,
            SEARCH_TEXT
        FROM V_CHURN_INSIGHTS
    );

GRANT USAGE ON CORTEX SEARCH SERVICE CHURN_INSIGHTS_SVC TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- ENGAGEMENT BEST PRACTICES KNOWLEDGE BASE
-- Curated insights for improving engagement
-- ============================================================================

CREATE OR REPLACE TABLE ENGAGEMENT_BEST_PRACTICES (
    PRACTICE_ID VARCHAR(20) PRIMARY KEY,
    CATEGORY VARCHAR(50),
    TITLE VARCHAR(200),
    DESCRIPTION TEXT,
    SUCCESS_RATE FLOAT,
    APPLICABLE_TO VARCHAR(50),  -- PATIENT, PROVIDER, BOTH
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert best practices
INSERT INTO ENGAGEMENT_BEST_PRACTICES (PRACTICE_ID, CATEGORY, TITLE, DESCRIPTION, SUCCESS_RATE, APPLICABLE_TO)
VALUES
    ('BP-001', 'Content Strategy', 'Personalize content by condition', 
     'Patients with diabetes show 45% higher engagement when shown diabetes-specific content. Use condition-based targeting to improve relevance and completion rates.', 
     0.85, 'PATIENT'),
    
    ('BP-002', 'Timing Optimization', 'Optimize for waiting room dwell time', 
     'Average waiting room time is 18 minutes. Content under 3 minutes has 80% completion rate vs 40% for longer content. Prioritize short, impactful content.', 
     0.80, 'PATIENT'),
    
    ('BP-003', 'Engagement Recovery', 'Early intervention for declining engagement', 
     'Patients with engagement declining for 2+ consecutive visits have 3x churn risk. Trigger personalized re-engagement within 48 hours of detected decline.', 
     0.72, 'PATIENT'),
    
    ('BP-004', 'Provider Retention', 'Quarterly business reviews with engagement data', 
     'Providers who receive quarterly engagement reports are 60% less likely to churn. Include patient outcomes correlation and ROI metrics.', 
     0.88, 'PROVIDER'),
    
    ('BP-005', 'Content Refresh', 'Monthly content rotation', 
     'Facilities with monthly content updates see 25% higher patient engagement than those with static content. Recommend seasonal and condition-relevant updates.', 
     0.75, 'BOTH'),
    
    ('BP-006', 'Multi-Modal Content', 'Use video + interactive mix', 
     'Combining video content with interactive quizzes increases completion rates by 35% and improves health knowledge retention by 50%.', 
     0.78, 'PATIENT'),
    
    ('BP-007', 'Win-Back Strategy', 'Targeted win-back campaigns', 
     'Churned patients contacted within 30 days with personalized content recommendations have 25% win-back success rate vs 8% after 90 days.', 
     0.65, 'PATIENT'),
    
    ('BP-008', 'Provider Engagement', 'Staff training on patient engagement', 
     'Facilities where staff encourage screen usage see 40% higher patient interaction rates. Provide training materials and talking points.', 
     0.82, 'PROVIDER'),
    
    ('BP-009', 'Pharma ROI', 'Track pharma content engagement by condition', 
     'Pharma partners see 3x higher ROI when their content is targeted to patients with matching conditions vs general placement.', 
     0.90, 'BOTH'),
    
    ('BP-010', 'Churn Prediction', 'Act on high-risk scores immediately', 
     'Providers with churn risk scores above 70 require immediate account manager intervention. 80% of unaddressed high-risk providers churn within 90 days.', 
     0.70, 'PROVIDER');

-- Create searchable view
CREATE OR REPLACE VIEW V_BEST_PRACTICES_SEARCH AS
SELECT 
    PRACTICE_ID,
    CATEGORY,
    TITLE,
    DESCRIPTION,
    SUCCESS_RATE,
    APPLICABLE_TO,
    CONCAT(
        'Best Practice: ', TITLE, '. ',
        'Category: ', CATEGORY, '. ',
        'Applies to: ', APPLICABLE_TO, '. ',
        'Success Rate: ', ROUND(SUCCESS_RATE * 100, 0), '%. ',
        'Details: ', DESCRIPTION
    ) as SEARCH_TEXT
FROM ENGAGEMENT_BEST_PRACTICES;

-- Create Cortex Search service for best practices
CREATE OR REPLACE CORTEX SEARCH SERVICE BEST_PRACTICES_SVC
    ON SEARCH_TEXT
    ATTRIBUTES CATEGORY, APPLICABLE_TO
    WAREHOUSE = COMPUTE_WH
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            PRACTICE_ID,
            CATEGORY,
            TITLE,
            DESCRIPTION,
            SUCCESS_RATE,
            APPLICABLE_TO,
            SEARCH_TEXT
        FROM V_BEST_PRACTICES_SEARCH
    );

GRANT USAGE ON CORTEX SEARCH SERVICE BEST_PRACTICES_SVC TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SHOW CORTEX SEARCH SERVICES IN SCHEMA ENGAGEMENT_ANALYTICS;

-- Test searches
SELECT 
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENTPOINT_ENGAGEMENT.ENGAGEMENT_ANALYTICS.CONTENT_SEARCH_SVC',
        '{
            "query": "diabetes education content",
            "columns": ["CONTENT_ID", "TITLE", "CATEGORY", "TARGET_CONDITION"],
            "limit": 5
        }'
    );

SELECT 
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'PATIENTPOINT_ENGAGEMENT.ENGAGEMENT_ANALYTICS.BEST_PRACTICES_SVC',
        '{
            "query": "how to reduce patient churn",
            "columns": ["PRACTICE_ID", "TITLE", "DESCRIPTION", "SUCCESS_RATE"],
            "limit": 5
        }'
    );

