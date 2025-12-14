/*******************************************************************************
 * PATIENTPOINT PATIENT ENGAGEMENT ANALYTICS
 * Engagement-Driven Retention & Outcomes Analysis
 * 
 * Part 1: Database Setup and Simulated Demo Data
 * 
 * DEMO NOTE: This script generates SIMULATED data representing PatientPoint's
 * real-world scenario of processing billions of IXR (interaction records) from
 * digital health displays. The synthetic dataset includes:
 *   - 100,000 patient interactions (clicks, swipes, dwell time)
 *   - 10,000 anonymized patients
 *   - 500 healthcare providers
 *   - Realistic engagement-outcome correlations
 * 
 * In production, this data model scales to billions of real-time records.
 * 
 * This script creates the data model for validating:
 * - H1: Patient→Provider Retention (do engaged patients stay with providers?)
 * - H2: Patient Outcomes (does engagement improve health metrics?)
 * - H3: Provider→PatientPoint Retention (do engaged providers stay longer?)
 ******************************************************************************/

-- ============================================================================
-- ROLE AND DATABASE SETUP
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Grant necessary permissions to demo role
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE SF_INTELLIGENCE_DEMO;

USE ROLE SF_INTELLIGENCE_DEMO;

-- Create database for patient engagement analytics
CREATE DATABASE IF NOT EXISTS PATIENTPOINT_ENGAGEMENT;
USE DATABASE PATIENTPOINT_ENGAGEMENT;

-- Create schema
CREATE SCHEMA IF NOT EXISTS ENGAGEMENT_ANALYTICS;
USE SCHEMA ENGAGEMENT_ANALYTICS;

-- Use existing warehouse
USE WAREHOUSE COMPUTE_WH;

-- ============================================================================
-- CORE DIMENSION TABLES
-- ============================================================================

-- Healthcare providers (facilities using PatientPoint devices)
CREATE OR REPLACE TABLE PROVIDERS (
    PROVIDER_ID VARCHAR(20) PRIMARY KEY,
    FACILITY_NAME VARCHAR(100) NOT NULL,
    FACILITY_TYPE VARCHAR(50),  -- Hospital, Urgent Care, Primary Care, Specialty
    CITY VARCHAR(50),
    STATE VARCHAR(2),
    REGION VARCHAR(20),  -- Midwest, Northeast, Southeast, West
    CONTRACT_START_DATE DATE,
    CONTRACT_END_DATE DATE,
    CONTRACT_STATUS VARCHAR(20),  -- ACTIVE, AT_RISK, CHURNED, RENEWED
    MONTHLY_FEE_USD FLOAT,
    DEVICE_COUNT INT,
    ACCOUNT_MANAGER VARCHAR(50),
    NPS_SCORE FLOAT,
    LAST_ENGAGEMENT_REVIEW DATE,
    CHURN_RISK_SCORE FLOAT,  -- 0-100, AI-calculated
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Patients (anonymized)
CREATE OR REPLACE TABLE PATIENTS (
    PATIENT_ID VARCHAR(20) PRIMARY KEY,
    PROVIDER_ID VARCHAR(20),
    AGE_GROUP VARCHAR(20),  -- 18-24, 25-34, 35-44, 45-54, 55-64, 65+
    GENDER VARCHAR(10),
    PRIMARY_CONDITION VARCHAR(50),  -- Diabetes, Hypertension, General Wellness, etc.
    FIRST_VISIT_DATE DATE,
    LAST_VISIT_DATE DATE,
    TOTAL_VISITS INT,
    STATUS VARCHAR(20),  -- ACTIVE, INACTIVE, CHURNED
    CHURNED_DATE DATE,
    ENGAGEMENT_SCORE FLOAT,  -- 0-100, calculated from interactions
    SATISFACTION_SCORE FLOAT,  -- 1-5 from surveys
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PROVIDER_ID) REFERENCES PROVIDERS(PROVIDER_ID)
);

-- Content library (health education and pharma content)
CREATE OR REPLACE TABLE CONTENT_LIBRARY (
    CONTENT_ID VARCHAR(20) PRIMARY KEY,
    TITLE VARCHAR(200) NOT NULL,
    CATEGORY VARCHAR(50),  -- Health Education, Pharma Ad, Wellness Tips, Condition Management
    SUBCATEGORY VARCHAR(50),
    SPONSOR VARCHAR(100),  -- Pharma company or NULL for PatientPoint content
    TARGET_CONDITION VARCHAR(50),  -- Diabetes, Heart Health, Mental Health, etc.
    CONTENT_TYPE VARCHAR(30),  -- Video, Interactive, Infographic, Quiz
    DURATION_SECONDS INT,
    LANGUAGE VARCHAR(20) DEFAULT 'English',
    PUBLISH_DATE DATE,
    STATUS VARCHAR(20),  -- ACTIVE, ARCHIVED, TESTING
    EFFECTIVENESS_SCORE FLOAT,  -- 0-100, based on engagement metrics
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- INTERACTION RECORDS (IXR) - The core event data
-- ============================================================================

CREATE OR REPLACE TABLE PATIENT_INTERACTIONS (
    INTERACTION_ID VARCHAR(36) PRIMARY KEY,
    PATIENT_ID VARCHAR(20),
    PROVIDER_ID VARCHAR(20),
    DEVICE_ID VARCHAR(20),
    CONTENT_ID VARCHAR(20),
    INTERACTION_TYPE VARCHAR(30),  -- VIEW, CLICK, SWIPE, SCROLL, COMPLETE, SKIP
    INTERACTION_TIMESTAMP TIMESTAMP_NTZ,
    DWELL_TIME_SECONDS INT,
    COMPLETION_PERCENTAGE FLOAT,  -- 0-100
    SESSION_ID VARCHAR(36),
    SCREEN_LOCATION VARCHAR(20),  -- WAITING_ROOM, EXAM_ROOM, CHECKOUT
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PATIENT_ID) REFERENCES PATIENTS(PATIENT_ID),
    FOREIGN KEY (PROVIDER_ID) REFERENCES PROVIDERS(PROVIDER_ID),
    FOREIGN KEY (CONTENT_ID) REFERENCES CONTENT_LIBRARY(CONTENT_ID)
);

-- ============================================================================
-- PATIENT OUTCOMES (for correlation analysis)
-- ============================================================================

CREATE OR REPLACE TABLE PATIENT_OUTCOMES (
    OUTCOME_ID VARCHAR(36) PRIMARY KEY,
    PATIENT_ID VARCHAR(20),
    OUTCOME_TYPE VARCHAR(50),  -- A1C_LEVEL, BLOOD_PRESSURE, MEDICATION_ADHERENCE, APPOINTMENT_KEPT
    OUTCOME_VALUE FLOAT,
    OUTCOME_DATE DATE,
    MEASUREMENT_SOURCE VARCHAR(30),  -- EHR, SURVEY, CLAIM
    BENCHMARK_VALUE FLOAT,  -- Target/healthy value
    IS_IMPROVED BOOLEAN,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PATIENT_ID) REFERENCES PATIENTS(PATIENT_ID)
);

-- ============================================================================
-- ENGAGEMENT SCORES (aggregated metrics)
-- ============================================================================

CREATE OR REPLACE TABLE ENGAGEMENT_SCORES (
    SCORE_ID VARCHAR(36) PRIMARY KEY,
    ENTITY_TYPE VARCHAR(20),  -- PATIENT, PROVIDER
    ENTITY_ID VARCHAR(20),
    CALCULATION_DATE DATE,
    TOTAL_INTERACTIONS INT,
    TOTAL_DWELL_TIME_SECONDS INT,
    AVG_COMPLETION_RATE FLOAT,
    UNIQUE_CONTENT_VIEWED INT,
    SESSIONS_COUNT INT,
    ENGAGEMENT_SCORE FLOAT,  -- 0-100, weighted calculation
    ENGAGEMENT_TREND VARCHAR(20),  -- INCREASING, STABLE, DECLINING
    PERCENTILE_RANK INT,  -- 1-100
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CHURN EVENTS (historical for model training)
-- ============================================================================

CREATE OR REPLACE TABLE CHURN_EVENTS (
    EVENT_ID VARCHAR(36) PRIMARY KEY,
    ENTITY_TYPE VARCHAR(20),  -- PATIENT, PROVIDER
    ENTITY_ID VARCHAR(20),
    CHURN_DATE DATE,
    DAYS_SINCE_LAST_ACTIVITY INT,
    ENGAGEMENT_SCORE_AT_CHURN FLOAT,
    PREDICTED_CHURN_PROBABILITY FLOAT,
    ACTUAL_CHURN BOOLEAN,
    CHURN_REASON VARCHAR(100),
    WIN_BACK_ATTEMPTED BOOLEAN,
    WIN_BACK_SUCCESSFUL BOOLEAN,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SAMPLE DATA GENERATION
-- ============================================================================

-- Generate Providers (500 facilities)
INSERT INTO PROVIDERS (PROVIDER_ID, FACILITY_NAME, FACILITY_TYPE, CITY, STATE, REGION, 
    CONTRACT_START_DATE, CONTRACT_END_DATE, CONTRACT_STATUS, MONTHLY_FEE_USD, 
    DEVICE_COUNT, ACCOUNT_MANAGER, NPS_SCORE, LAST_ENGAGEMENT_REVIEW, CHURN_RISK_SCORE)
SELECT 
    'PRV-' || LPAD(SEQ4()::VARCHAR, 4, '0') as PROVIDER_ID,
    CASE MOD(SEQ4(), 10)
        WHEN 0 THEN 'Metro Health Center'
        WHEN 1 THEN 'Community Medical Group'
        WHEN 2 THEN 'Family Care Associates'
        WHEN 3 THEN 'Regional Hospital'
        WHEN 4 THEN 'Wellness Clinic'
        WHEN 5 THEN 'Urgent Care Plus'
        WHEN 6 THEN 'Specialty Medical Center'
        WHEN 7 THEN 'Primary Care Partners'
        WHEN 8 THEN 'Healthcare Alliance'
        ELSE 'Medical Associates'
    END || ' ' || SEQ4()::VARCHAR as FACILITY_NAME,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Hospital'
        WHEN 1 THEN 'Primary Care'
        WHEN 2 THEN 'Urgent Care'
        ELSE 'Specialty'
    END as FACILITY_TYPE,
    CASE MOD(SEQ4(), 12)
        WHEN 0 THEN 'Chicago'
        WHEN 1 THEN 'Detroit'
        WHEN 2 THEN 'Cleveland'
        WHEN 3 THEN 'Indianapolis'
        WHEN 4 THEN 'Columbus'
        WHEN 5 THEN 'Milwaukee'
        WHEN 6 THEN 'Cincinnati'
        WHEN 7 THEN 'Minneapolis'
        WHEN 8 THEN 'St. Louis'
        WHEN 9 THEN 'Kansas City'
        WHEN 10 THEN 'Louisville'
        ELSE 'Grand Rapids'
    END as CITY,
    CASE MOD(SEQ4(), 12)
        WHEN 0 THEN 'IL'
        WHEN 1 THEN 'MI'
        WHEN 2 THEN 'OH'
        WHEN 3 THEN 'IN'
        WHEN 4 THEN 'OH'
        WHEN 5 THEN 'WI'
        WHEN 6 THEN 'OH'
        WHEN 7 THEN 'MN'
        WHEN 8 THEN 'MO'
        WHEN 9 THEN 'MO'
        WHEN 10 THEN 'KY'
        ELSE 'MI'
    END as STATE,
    'Midwest' as REGION,
    DATEADD('month', -1 * (MOD(SEQ4(), 36) + 6), CURRENT_DATE()) as CONTRACT_START_DATE,
    DATEADD('month', 12 + MOD(SEQ4(), 24), CURRENT_DATE()) as CONTRACT_END_DATE,
    CASE 
        WHEN MOD(SEQ4(), 20) = 0 THEN 'CHURNED'
        WHEN MOD(SEQ4(), 10) = 0 THEN 'AT_RISK'
        WHEN MOD(SEQ4(), 5) = 0 THEN 'RENEWED'
        ELSE 'ACTIVE'
    END as CONTRACT_STATUS,
    1500 + (MOD(SEQ4(), 20) * 100) as MONTHLY_FEE_USD,
    2 + MOD(SEQ4(), 8) as DEVICE_COUNT,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Sarah Johnson'
        WHEN 1 THEN 'Michael Chen'
        WHEN 2 THEN 'Emily Rodriguez'
        WHEN 3 THEN 'David Kim'
        ELSE 'Lisa Thompson'
    END as ACCOUNT_MANAGER,
    -- NPS: Higher for ACTIVE/RENEWED, lower for AT_RISK/CHURNED
    CASE 
        WHEN MOD(SEQ4(), 20) = 0 THEN 3 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 3  -- Churned: 3-6
        WHEN MOD(SEQ4(), 10) = 0 THEN 5 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 3  -- At Risk: 5-8
        ELSE 7 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 3  -- Active: 7-10
    END as NPS_SCORE,
    DATEADD('day', -1 * MOD(SEQ4(), 60), CURRENT_DATE()) as LAST_ENGAGEMENT_REVIEW,
    -- Churn risk: Higher for AT_RISK/CHURNED
    CASE 
        WHEN MOD(SEQ4(), 20) = 0 THEN 85 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 15  -- Churned: 85-100
        WHEN MOD(SEQ4(), 10) = 0 THEN 60 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 25  -- At Risk: 60-85
        ELSE 5 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 40  -- Active: 5-45
    END as CHURN_RISK_SCORE
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- Generate Patients (10,000 patients)
INSERT INTO PATIENTS (PATIENT_ID, PROVIDER_ID, AGE_GROUP, GENDER, PRIMARY_CONDITION,
    FIRST_VISIT_DATE, LAST_VISIT_DATE, TOTAL_VISITS, STATUS, CHURNED_DATE,
    ENGAGEMENT_SCORE, SATISFACTION_SCORE)
SELECT 
    'PAT-' || LPAD(SEQ4()::VARCHAR, 6, '0') as PATIENT_ID,
    'PRV-' || LPAD((MOD(SEQ4(), 500))::VARCHAR, 4, '0') as PROVIDER_ID,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN '18-24'
        WHEN 1 THEN '25-34'
        WHEN 2 THEN '35-44'
        WHEN 3 THEN '45-54'
        WHEN 4 THEN '55-64'
        ELSE '65+'
    END as AGE_GROUP,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Male'
        WHEN 1 THEN 'Female'
        ELSE 'Other'
    END as GENDER,
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Diabetes'
        WHEN 1 THEN 'Hypertension'
        WHEN 2 THEN 'Heart Disease'
        WHEN 3 THEN 'Respiratory'
        WHEN 4 THEN 'Mental Health'
        WHEN 5 THEN 'Arthritis'
        WHEN 6 THEN 'General Wellness'
        ELSE 'Preventive Care'
    END as PRIMARY_CONDITION,
    DATEADD('day', -1 * (365 + MOD(SEQ4(), 730)), CURRENT_DATE()) as FIRST_VISIT_DATE,
    DATEADD('day', -1 * MOD(SEQ4(), 90), CURRENT_DATE()) as LAST_VISIT_DATE,
    3 + MOD(SEQ4(), 20) as TOTAL_VISITS,
    CASE 
        WHEN MOD(SEQ4(), 15) = 0 THEN 'CHURNED'
        WHEN MOD(SEQ4(), 8) = 0 THEN 'INACTIVE'
        ELSE 'ACTIVE'
    END as STATUS,
    CASE WHEN MOD(SEQ4(), 15) = 0 
        THEN DATEADD('day', -1 * (30 + MOD(SEQ4(), 180)), CURRENT_DATE()) 
        ELSE NULL 
    END as CHURNED_DATE,
    -- Engagement score: Higher for ACTIVE, lower for CHURNED
    CASE 
        WHEN MOD(SEQ4(), 15) = 0 THEN 15 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 30  -- Churned: 15-45
        WHEN MOD(SEQ4(), 8) = 0 THEN 30 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 30   -- Inactive: 30-60
        ELSE 50 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 50  -- Active: 50-100
    END as ENGAGEMENT_SCORE,
    3.0 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 2.0 as SATISFACTION_SCORE
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- Generate Content Library (200 content items)
INSERT INTO CONTENT_LIBRARY (CONTENT_ID, TITLE, CATEGORY, SUBCATEGORY, SPONSOR, 
    TARGET_CONDITION, CONTENT_TYPE, DURATION_SECONDS, PUBLISH_DATE, STATUS, EFFECTIVENESS_SCORE)
SELECT 
    'CNT-' || LPAD(SEQ4()::VARCHAR, 4, '0') as CONTENT_ID,
    CASE MOD(SEQ4(), 20)
        WHEN 0 THEN 'Understanding Your A1C Levels'
        WHEN 1 THEN 'Heart-Healthy Eating Tips'
        WHEN 2 THEN 'Managing Stress and Anxiety'
        WHEN 3 THEN 'Blood Pressure Basics'
        WHEN 4 THEN 'Diabetes Prevention Guide'
        WHEN 5 THEN 'Exercise for Better Health'
        WHEN 6 THEN 'Medication Reminder Tips'
        WHEN 7 THEN 'Sleep and Your Health'
        WHEN 8 THEN 'Nutrition Label Reading'
        WHEN 9 THEN 'Walking for Wellness'
        WHEN 10 THEN 'Understanding Cholesterol'
        WHEN 11 THEN 'Mental Health Awareness'
        WHEN 12 THEN 'Flu Prevention Tips'
        WHEN 13 THEN 'Healthy Aging Guide'
        WHEN 14 THEN 'Pain Management Options'
        WHEN 15 THEN 'Respiratory Health Tips'
        WHEN 16 THEN 'Weight Management Basics'
        WHEN 17 THEN 'Smoking Cessation Support'
        WHEN 18 THEN 'Vaccine Information'
        ELSE 'General Wellness Tips'
    END || ' - Version ' || (MOD(SEQ4(), 5) + 1)::VARCHAR as TITLE,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Health Education'
        WHEN 1 THEN 'Pharma Ad'
        WHEN 2 THEN 'Wellness Tips'
        ELSE 'Condition Management'
    END as CATEGORY,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Prevention'
        WHEN 1 THEN 'Treatment'
        WHEN 2 THEN 'Lifestyle'
        WHEN 3 THEN 'Medication'
        ELSE 'Awareness'
    END as SUBCATEGORY,
    CASE 
        WHEN MOD(SEQ4(), 4) = 1 THEN  -- Pharma Ads have sponsors
            CASE MOD(SEQ4(), 8)
                WHEN 0 THEN 'Pfizer'
                WHEN 1 THEN 'Merck'
                WHEN 2 THEN 'Johnson & Johnson'
                WHEN 3 THEN 'AbbVie'
                WHEN 4 THEN 'Bristol-Myers Squibb'
                WHEN 5 THEN 'Eli Lilly'
                WHEN 6 THEN 'AstraZeneca'
                ELSE 'Novartis'
            END
        ELSE NULL  -- Non-pharma content
    END as SPONSOR,
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Diabetes'
        WHEN 1 THEN 'Heart Health'
        WHEN 2 THEN 'Mental Health'
        WHEN 3 THEN 'Respiratory'
        WHEN 4 THEN 'General Wellness'
        WHEN 5 THEN 'Pain Management'
        WHEN 6 THEN 'Preventive Care'
        ELSE 'Chronic Disease'
    END as TARGET_CONDITION,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Video'
        WHEN 1 THEN 'Interactive'
        WHEN 2 THEN 'Infographic'
        ELSE 'Quiz'
    END as CONTENT_TYPE,
    30 + MOD(SEQ4(), 150) as DURATION_SECONDS,
    DATEADD('day', -1 * MOD(SEQ4(), 365), CURRENT_DATE()) as PUBLISH_DATE,
    CASE WHEN MOD(SEQ4(), 20) = 0 THEN 'ARCHIVED' ELSE 'ACTIVE' END as STATUS,
    40 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 60 as EFFECTIVENESS_SCORE
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- Generate Patient Interactions (100,000 interaction records)
INSERT INTO PATIENT_INTERACTIONS (INTERACTION_ID, PATIENT_ID, PROVIDER_ID, DEVICE_ID,
    CONTENT_ID, INTERACTION_TYPE, INTERACTION_TIMESTAMP, DWELL_TIME_SECONDS,
    COMPLETION_PERCENTAGE, SESSION_ID, SCREEN_LOCATION)
SELECT 
    UUID_STRING() as INTERACTION_ID,
    'PAT-' || LPAD((MOD(SEQ4(), 10000))::VARCHAR, 6, '0') as PATIENT_ID,
    'PRV-' || LPAD((MOD(SEQ4(), 500))::VARCHAR, 4, '0') as PROVIDER_ID,
    'DEV-' || LPAD((MOD(SEQ4(), 2000))::VARCHAR, 4, '0') as DEVICE_ID,
    'CNT-' || LPAD((MOD(SEQ4(), 200))::VARCHAR, 4, '0') as CONTENT_ID,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'VIEW'
        WHEN 1 THEN 'CLICK'
        WHEN 2 THEN 'SWIPE'
        WHEN 3 THEN 'SCROLL'
        WHEN 4 THEN 'COMPLETE'
        ELSE 'SKIP'
    END as INTERACTION_TYPE,
    DATEADD('hour', -1 * MOD(SEQ4(), 2160), CURRENT_TIMESTAMP()) as INTERACTION_TIMESTAMP,  -- Last 90 days
    CASE MOD(SEQ4(), 6)
        WHEN 4 THEN 60 + MOD(SEQ4(), 120)  -- COMPLETE: 60-180 seconds
        WHEN 5 THEN 3 + MOD(SEQ4(), 10)    -- SKIP: 3-13 seconds
        ELSE 10 + MOD(SEQ4(), 60)          -- Others: 10-70 seconds
    END as DWELL_TIME_SECONDS,
    CASE MOD(SEQ4(), 6)
        WHEN 4 THEN 90 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 10  -- COMPLETE: 90-100%
        WHEN 5 THEN UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 20       -- SKIP: 0-20%
        ELSE 20 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 70         -- Others: 20-90%
    END as COMPLETION_PERCENTAGE,
    UUID_STRING() as SESSION_ID,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'WAITING_ROOM'
        WHEN 1 THEN 'EXAM_ROOM'
        ELSE 'CHECKOUT'
    END as SCREEN_LOCATION
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Generate Patient Outcomes (5,000 outcome records)
INSERT INTO PATIENT_OUTCOMES (OUTCOME_ID, PATIENT_ID, OUTCOME_TYPE, OUTCOME_VALUE,
    OUTCOME_DATE, MEASUREMENT_SOURCE, BENCHMARK_VALUE, IS_IMPROVED)
SELECT 
    UUID_STRING() as OUTCOME_ID,
    'PAT-' || LPAD((MOD(SEQ4(), 5000))::VARCHAR, 6, '0') as PATIENT_ID,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'A1C_LEVEL'
        WHEN 1 THEN 'BLOOD_PRESSURE_SYSTOLIC'
        WHEN 2 THEN 'MEDICATION_ADHERENCE'
        WHEN 3 THEN 'APPOINTMENT_KEPT'
        ELSE 'SATISFACTION_SCORE'
    END as OUTCOME_TYPE,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 5.5 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 4.5  -- A1C: 5.5-10%
        WHEN 1 THEN 110 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 50   -- BP: 110-160
        WHEN 2 THEN 50 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 50    -- Adherence: 50-100%
        WHEN 3 THEN UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 100        -- Appointment: 0-100%
        ELSE 3 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 2             -- Satisfaction: 3-5
    END as OUTCOME_VALUE,
    DATEADD('day', -1 * MOD(SEQ4(), 180), CURRENT_DATE()) as OUTCOME_DATE,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'EHR'
        WHEN 1 THEN 'SURVEY'
        ELSE 'CLAIM'
    END as MEASUREMENT_SOURCE,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 7.0   -- A1C target
        WHEN 1 THEN 120.0 -- BP target
        WHEN 2 THEN 80.0  -- Adherence target
        WHEN 3 THEN 90.0  -- Appointment target
        ELSE 4.0          -- Satisfaction target
    END as BENCHMARK_VALUE,
    -- Placeholder - will be updated based on engagement correlation
    FALSE as IS_IMPROVED
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- UPDATE IS_IMPROVED BASED ON ENGAGEMENT SCORE
-- Creates strong correlation: High engagement = Higher improvement probability
-- ============================================================================

UPDATE PATIENT_OUTCOMES o
SET IS_IMPROVED = (
    CASE 
        -- High engagement (score >= 70): 70-85% improvement rate
        WHEN p.ENGAGEMENT_SCORE >= 70 THEN UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) < 0.75
        -- Medium engagement (score 40-70): 50-60% improvement rate  
        WHEN p.ENGAGEMENT_SCORE >= 40 THEN UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) < 0.55
        -- Low engagement (score < 40): 30-40% improvement rate
        ELSE UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) < 0.35
    END
)
FROM PATIENTS p
WHERE o.PATIENT_ID = p.PATIENT_ID;

-- Generate Engagement Scores (for patients and providers)
-- Patient engagement scores
INSERT INTO ENGAGEMENT_SCORES (SCORE_ID, ENTITY_TYPE, ENTITY_ID, CALCULATION_DATE,
    TOTAL_INTERACTIONS, TOTAL_DWELL_TIME_SECONDS, AVG_COMPLETION_RATE,
    UNIQUE_CONTENT_VIEWED, SESSIONS_COUNT, ENGAGEMENT_SCORE, ENGAGEMENT_TREND, PERCENTILE_RANK)
SELECT 
    UUID_STRING() as SCORE_ID,
    'PATIENT' as ENTITY_TYPE,
    'PAT-' || LPAD(SEQ4()::VARCHAR, 6, '0') as ENTITY_ID,
    CURRENT_DATE() as CALCULATION_DATE,
    10 + MOD(SEQ4(), 100) as TOTAL_INTERACTIONS,
    300 + MOD(SEQ4(), 3000) as TOTAL_DWELL_TIME_SECONDS,
    30 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 70 as AVG_COMPLETION_RATE,
    5 + MOD(SEQ4(), 30) as UNIQUE_CONTENT_VIEWED,
    2 + MOD(SEQ4(), 15) as SESSIONS_COUNT,
    20 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 80 as ENGAGEMENT_SCORE,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'INCREASING'
        WHEN 1 THEN 'STABLE'
        ELSE 'DECLINING'
    END as ENGAGEMENT_TREND,
    1 + MOD(SEQ4(), 100) as PERCENTILE_RANK
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- Provider engagement scores
INSERT INTO ENGAGEMENT_SCORES (SCORE_ID, ENTITY_TYPE, ENTITY_ID, CALCULATION_DATE,
    TOTAL_INTERACTIONS, TOTAL_DWELL_TIME_SECONDS, AVG_COMPLETION_RATE,
    UNIQUE_CONTENT_VIEWED, SESSIONS_COUNT, ENGAGEMENT_SCORE, ENGAGEMENT_TREND, PERCENTILE_RANK)
SELECT 
    UUID_STRING() as SCORE_ID,
    'PROVIDER' as ENTITY_TYPE,
    'PRV-' || LPAD(SEQ4()::VARCHAR, 4, '0') as ENTITY_ID,
    CURRENT_DATE() as CALCULATION_DATE,
    500 + MOD(SEQ4(), 5000) as TOTAL_INTERACTIONS,
    15000 + MOD(SEQ4(), 150000) as TOTAL_DWELL_TIME_SECONDS,
    40 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 60 as AVG_COMPLETION_RATE,
    20 + MOD(SEQ4(), 150) as UNIQUE_CONTENT_VIEWED,
    50 + MOD(SEQ4(), 500) as SESSIONS_COUNT,
    30 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 70 as ENGAGEMENT_SCORE,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'INCREASING'
        WHEN 1 THEN 'STABLE'
        ELSE 'DECLINING'
    END as ENGAGEMENT_TREND,
    1 + MOD(SEQ4(), 100) as PERCENTILE_RANK
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- Generate Churn Events (historical for model validation)
INSERT INTO CHURN_EVENTS (EVENT_ID, ENTITY_TYPE, ENTITY_ID, CHURN_DATE,
    DAYS_SINCE_LAST_ACTIVITY, ENGAGEMENT_SCORE_AT_CHURN, PREDICTED_CHURN_PROBABILITY,
    ACTUAL_CHURN, CHURN_REASON, WIN_BACK_ATTEMPTED, WIN_BACK_SUCCESSFUL)
SELECT 
    UUID_STRING() as EVENT_ID,
    CASE WHEN MOD(SEQ4(), 3) = 0 THEN 'PROVIDER' ELSE 'PATIENT' END as ENTITY_TYPE,
    CASE WHEN MOD(SEQ4(), 3) = 0 
        THEN 'PRV-' || LPAD((MOD(SEQ4(), 25))::VARCHAR, 4, '0')  -- ~25 churned providers
        ELSE 'PAT-' || LPAD((MOD(SEQ4(), 667))::VARCHAR, 6, '0')  -- ~667 churned patients
    END as ENTITY_ID,
    DATEADD('day', -1 * (30 + MOD(SEQ4(), 300)), CURRENT_DATE()) as CHURN_DATE,
    60 + MOD(SEQ4(), 120) as DAYS_SINCE_LAST_ACTIVITY,
    15 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 35 as ENGAGEMENT_SCORE_AT_CHURN,  -- Low engagement at churn
    0.6 + UNIFORM(0::FLOAT, 1::FLOAT, RANDOM()) * 0.4 as PREDICTED_CHURN_PROBABILITY,  -- Model predicted high churn
    TRUE as ACTUAL_CHURN,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Switched provider'
        WHEN 1 THEN 'Moved location'
        WHEN 2 THEN 'Dissatisfied with service'
        WHEN 3 THEN 'Cost concerns'
        ELSE 'Unknown'
    END as CHURN_REASON,
    CASE WHEN MOD(SEQ4(), 3) = 0 THEN TRUE ELSE FALSE END as WIN_BACK_ATTEMPTED,
    CASE WHEN MOD(SEQ4(), 10) = 0 THEN TRUE ELSE FALSE END as WIN_BACK_SUCCESSFUL
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- ============================================================================
-- ANALYTICAL VIEWS
-- ============================================================================

-- Reference time view for consistent demo data
CREATE OR REPLACE VIEW V_DEMO_REFERENCE_TIME AS
SELECT 
    MAX(INTERACTION_TIMESTAMP) as REFERENCE_TIMESTAMP,
    MAX(INTERACTION_TIMESTAMP)::DATE as REFERENCE_DATE,
    DATE_TRUNC('month', MAX(INTERACTION_TIMESTAMP)) as REFERENCE_MONTH_START
FROM PATIENT_INTERACTIONS;

-- Patient engagement analysis view
CREATE OR REPLACE VIEW V_PATIENT_ENGAGEMENT AS
SELECT 
    p.PATIENT_ID,
    p.PROVIDER_ID,
    pr.FACILITY_NAME,
    pr.FACILITY_TYPE,
    pr.CITY,
    pr.STATE,
    p.AGE_GROUP,
    p.GENDER,
    p.PRIMARY_CONDITION,
    p.STATUS as PATIENT_STATUS,
    p.FIRST_VISIT_DATE,
    p.LAST_VISIT_DATE,
    p.TOTAL_VISITS,
    p.ENGAGEMENT_SCORE,
    p.SATISFACTION_SCORE,
    es.TOTAL_INTERACTIONS,
    es.TOTAL_DWELL_TIME_SECONDS,
    es.AVG_COMPLETION_RATE,
    es.UNIQUE_CONTENT_VIEWED,
    es.SESSIONS_COUNT,
    es.ENGAGEMENT_TREND,
    es.PERCENTILE_RANK,
    CASE 
        WHEN p.STATUS = 'CHURNED' THEN 'CHURNED'
        WHEN p.ENGAGEMENT_SCORE < 30 THEN 'HIGH_RISK'
        WHEN p.ENGAGEMENT_SCORE < 50 THEN 'MEDIUM_RISK'
        WHEN p.ENGAGEMENT_SCORE < 70 THEN 'LOW_RISK'
        ELSE 'HEALTHY'
    END as CHURN_RISK_CATEGORY,
    DATEDIFF('day', p.LAST_VISIT_DATE, (SELECT REFERENCE_DATE FROM V_DEMO_REFERENCE_TIME)) as DAYS_SINCE_LAST_VISIT
FROM PATIENTS p
LEFT JOIN PROVIDERS pr ON p.PROVIDER_ID = pr.PROVIDER_ID
LEFT JOIN ENGAGEMENT_SCORES es ON p.PATIENT_ID = es.ENTITY_ID AND es.ENTITY_TYPE = 'PATIENT';

-- Provider engagement and churn risk view
CREATE OR REPLACE VIEW V_PROVIDER_HEALTH AS
SELECT 
    p.PROVIDER_ID,
    p.FACILITY_NAME,
    p.FACILITY_TYPE,
    p.CITY,
    p.STATE,
    p.REGION,
    p.CONTRACT_STATUS,
    p.CONTRACT_START_DATE,
    p.CONTRACT_END_DATE,
    p.MONTHLY_FEE_USD,
    p.DEVICE_COUNT,
    p.ACCOUNT_MANAGER,
    p.NPS_SCORE,
    p.CHURN_RISK_SCORE,
    es.TOTAL_INTERACTIONS,
    es.TOTAL_DWELL_TIME_SECONDS,
    es.AVG_COMPLETION_RATE,
    es.ENGAGEMENT_SCORE as PATIENT_ENGAGEMENT_SCORE,
    es.ENGAGEMENT_TREND,
    es.PERCENTILE_RANK,
    (SELECT COUNT(*) FROM PATIENTS pt WHERE pt.PROVIDER_ID = p.PROVIDER_ID) as TOTAL_PATIENTS,
    (SELECT COUNT(*) FROM PATIENTS pt WHERE pt.PROVIDER_ID = p.PROVIDER_ID AND pt.STATUS = 'ACTIVE') as ACTIVE_PATIENTS,
    (SELECT COUNT(*) FROM PATIENTS pt WHERE pt.PROVIDER_ID = p.PROVIDER_ID AND pt.STATUS = 'CHURNED') as CHURNED_PATIENTS,
    (SELECT AVG(pt.ENGAGEMENT_SCORE) FROM PATIENTS pt WHERE pt.PROVIDER_ID = p.PROVIDER_ID) as AVG_PATIENT_ENGAGEMENT,
    CASE 
        WHEN p.CONTRACT_STATUS = 'CHURNED' THEN 'CHURNED'
        WHEN p.CHURN_RISK_SCORE >= 70 THEN 'CRITICAL'
        WHEN p.CHURN_RISK_SCORE >= 50 THEN 'HIGH'
        WHEN p.CHURN_RISK_SCORE >= 30 THEN 'MEDIUM'
        ELSE 'LOW'
    END as CHURN_RISK_CATEGORY,
    p.MONTHLY_FEE_USD * 12 as ANNUAL_REVENUE_AT_RISK
FROM PROVIDERS p
LEFT JOIN ENGAGEMENT_SCORES es ON p.PROVIDER_ID = es.ENTITY_ID AND es.ENTITY_TYPE = 'PROVIDER';

-- Engagement-Outcome Correlation View
CREATE OR REPLACE VIEW V_ENGAGEMENT_OUTCOMES_CORRELATION AS
SELECT 
    p.PATIENT_ID,
    p.ENGAGEMENT_SCORE,
    p.STATUS as PATIENT_STATUS,
    p.PRIMARY_CONDITION,
    o.OUTCOME_TYPE,
    o.OUTCOME_VALUE,
    o.BENCHMARK_VALUE,
    o.IS_IMPROVED,
    CASE 
        WHEN p.ENGAGEMENT_SCORE >= 70 THEN 'HIGH'
        WHEN p.ENGAGEMENT_SCORE >= 40 THEN 'MEDIUM'
        ELSE 'LOW'
    END as ENGAGEMENT_TIER,
    CASE WHEN o.IS_IMPROVED THEN 1 ELSE 0 END as IMPROVED_FLAG
FROM PATIENTS p
JOIN PATIENT_OUTCOMES o ON p.PATIENT_ID = o.PATIENT_ID;

-- Content Performance View
CREATE OR REPLACE VIEW V_CONTENT_PERFORMANCE AS
SELECT 
    c.CONTENT_ID,
    c.TITLE,
    c.CATEGORY,
    c.SUBCATEGORY,
    c.SPONSOR,
    c.TARGET_CONDITION,
    c.CONTENT_TYPE,
    c.DURATION_SECONDS,
    c.EFFECTIVENESS_SCORE,
    COUNT(DISTINCT i.INTERACTION_ID) as TOTAL_INTERACTIONS,
    COUNT(DISTINCT i.PATIENT_ID) as UNIQUE_PATIENTS,
    AVG(i.DWELL_TIME_SECONDS) as AVG_DWELL_TIME,
    AVG(i.COMPLETION_PERCENTAGE) as AVG_COMPLETION_RATE,
    SUM(CASE WHEN i.INTERACTION_TYPE = 'COMPLETE' THEN 1 ELSE 0 END) as COMPLETION_COUNT,
    SUM(CASE WHEN i.INTERACTION_TYPE = 'SKIP' THEN 1 ELSE 0 END) as SKIP_COUNT,
    ROUND(SUM(CASE WHEN i.INTERACTION_TYPE = 'COMPLETE' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(COUNT(*), 0), 2) as COMPLETION_RATE_PCT
FROM CONTENT_LIBRARY c
LEFT JOIN PATIENT_INTERACTIONS i ON c.CONTENT_ID = i.CONTENT_ID
GROUP BY 1,2,3,4,5,6,7,8,9;

-- ROI Analysis View
CREATE OR REPLACE VIEW V_ENGAGEMENT_ROI AS
SELECT 
    -- Synthetic key for semantic view compatibility
    'ROI_SUMMARY' as ROI_ID,
    
    -- Patient Metrics
    (SELECT COUNT(*) FROM PATIENTS) as TOTAL_PATIENTS,
    (SELECT COUNT(*) FROM PATIENTS WHERE STATUS = 'ACTIVE') as ACTIVE_PATIENTS,
    (SELECT COUNT(*) FROM PATIENTS WHERE STATUS = 'CHURNED') as CHURNED_PATIENTS,
    ROUND((SELECT COUNT(*) FROM PATIENTS WHERE STATUS = 'CHURNED') * 100.0 / 
          NULLIF((SELECT COUNT(*) FROM PATIENTS), 0), 2) as PATIENT_CHURN_RATE_PCT,
    
    -- Provider Metrics
    (SELECT COUNT(*) FROM PROVIDERS) as TOTAL_PROVIDERS,
    (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'ACTIVE') as ACTIVE_PROVIDERS,
    (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as AT_RISK_PROVIDERS,
    (SELECT COUNT(*) FROM PROVIDERS WHERE CONTRACT_STATUS = 'CHURNED') as CHURNED_PROVIDERS,
    
    -- Revenue Metrics
    (SELECT SUM(MONTHLY_FEE_USD * 12) FROM PROVIDERS WHERE CONTRACT_STATUS = 'ACTIVE') as ANNUAL_ACTIVE_REVENUE,
    (SELECT SUM(MONTHLY_FEE_USD * 12) FROM PROVIDERS WHERE CONTRACT_STATUS = 'AT_RISK') as ANNUAL_AT_RISK_REVENUE,
    (SELECT SUM(MONTHLY_FEE_USD * 12) FROM PROVIDERS WHERE CONTRACT_STATUS = 'CHURNED') as ANNUAL_LOST_REVENUE,
    
    -- Engagement Metrics
    (SELECT AVG(ENGAGEMENT_SCORE) FROM PATIENTS WHERE STATUS = 'ACTIVE') as AVG_ACTIVE_PATIENT_ENGAGEMENT,
    (SELECT AVG(ENGAGEMENT_SCORE) FROM PATIENTS WHERE STATUS = 'CHURNED') as AVG_CHURNED_PATIENT_ENGAGEMENT,
    
    -- Correlation Metrics (simplified)
    (SELECT ROUND(AVG(CASE WHEN IS_IMPROVED THEN 1 ELSE 0 END) * 100, 2) 
     FROM V_ENGAGEMENT_OUTCOMES_CORRELATION WHERE ENGAGEMENT_TIER = 'HIGH') as HIGH_ENGAGEMENT_IMPROVEMENT_PCT,
    (SELECT ROUND(AVG(CASE WHEN IS_IMPROVED THEN 1 ELSE 0 END) * 100, 2) 
     FROM V_ENGAGEMENT_OUTCOMES_CORRELATION WHERE ENGAGEMENT_TIER = 'LOW') as LOW_ENGAGEMENT_IMPROVEMENT_PCT,
    
    -- Churn Prediction Accuracy (from historical data)
    (SELECT ROUND(AVG(CASE WHEN PREDICTED_CHURN_PROBABILITY > 0.5 AND ACTUAL_CHURN THEN 1 ELSE 0 END) * 100, 2)
     FROM CHURN_EVENTS) as CHURN_PREDICTION_ACCURACY_PCT;

-- Executive Dashboard View
CREATE OR REPLACE VIEW V_EXECUTIVE_DASHBOARD AS
SELECT 
    -- Overall Health
    'ENGAGEMENT_ANALYTICS' as DASHBOARD_TYPE,
    (SELECT REFERENCE_DATE FROM V_DEMO_REFERENCE_TIME) as AS_OF_DATE,
    
    -- Patient Metrics
    (SELECT COUNT(*) FROM PATIENTS) as TOTAL_PATIENTS,
    (SELECT COUNT(*) FROM PATIENTS WHERE STATUS = 'ACTIVE') as ACTIVE_PATIENTS,
    (SELECT ROUND(AVG(ENGAGEMENT_SCORE), 1) FROM PATIENTS) as AVG_ENGAGEMENT_SCORE,
    (SELECT ROUND(AVG(SATISFACTION_SCORE), 2) FROM PATIENTS) as AVG_SATISFACTION,
    
    -- Provider Metrics
    (SELECT COUNT(*) FROM PROVIDERS) as TOTAL_PROVIDERS,
    (SELECT COUNT(*) FROM PROVIDERS WHERE CHURN_RISK_SCORE >= 60) as HIGH_RISK_PROVIDERS,
    (SELECT ROUND(SUM(MONTHLY_FEE_USD * 12), 0) FROM PROVIDERS WHERE CHURN_RISK_SCORE >= 60) as REVENUE_AT_RISK,
    
    -- Engagement Metrics
    (SELECT COUNT(*) FROM PATIENT_INTERACTIONS) as TOTAL_INTERACTIONS,
    (SELECT ROUND(AVG(DWELL_TIME_SECONDS), 1) FROM PATIENT_INTERACTIONS) as AVG_DWELL_TIME,
    (SELECT ROUND(AVG(COMPLETION_PERCENTAGE), 1) FROM PATIENT_INTERACTIONS) as AVG_COMPLETION_RATE,
    
    -- Outcome Metrics
    (SELECT ROUND(AVG(CASE WHEN IS_IMPROVED THEN 1 ELSE 0 END) * 100, 1) FROM PATIENT_OUTCOMES) as OUTCOME_IMPROVEMENT_RATE;

-- ============================================================================
-- VERIFY DATA
-- ============================================================================

SELECT 'PROVIDERS' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM PROVIDERS
UNION ALL
SELECT 'PATIENTS', COUNT(*) FROM PATIENTS
UNION ALL
SELECT 'CONTENT_LIBRARY', COUNT(*) FROM CONTENT_LIBRARY
UNION ALL
SELECT 'PATIENT_INTERACTIONS', COUNT(*) FROM PATIENT_INTERACTIONS
UNION ALL
SELECT 'PATIENT_OUTCOMES', COUNT(*) FROM PATIENT_OUTCOMES
UNION ALL
SELECT 'ENGAGEMENT_SCORES', COUNT(*) FROM ENGAGEMENT_SCORES
UNION ALL
SELECT 'CHURN_EVENTS', COUNT(*) FROM CHURN_EVENTS;

-- Sample data verification
SELECT * FROM V_EXECUTIVE_DASHBOARD;
SELECT * FROM V_ENGAGEMENT_ROI;

