/*============================================================================
  Create Semantic Views for Snowflake Intelligence / Cortex Analyst (Split Views)

  This script creates multiple narrowly scoped semantic views (recommended) so
  Snowflake Intelligence / Cortex Analyst can be configured with focused tools.

  Prereqs:
  - Run sql/01_setup_database.sql
  - Run sql/02_generate_sample_data.sql
  - Run sql/20_intelligence_semantic_layer.sql

  Docs:
  - CREATE SEMANTIC VIEW syntax: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
============================================================================*/

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

/*----------------------------------------------------------------------------
  1) Fleet status semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_FLEET_STATUS
  TABLES (
    fleet AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_FLEET_DEVICE_STATUS
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('fleet status', 'device status', 'screen status')
      COMMENT = 'Current fleet health status and device metadata (threshold-based).'
  )
  DIMENSIONS (
    fleet.device_id AS DEVICE_ID
      WITH SYNONYMS = ('device', 'screen', 'screen id', 'display id')
      COMMENT = 'Unique identifier for an in-office screen.',
    fleet.device_model AS DEVICE_MODEL WITH SYNONYMS = ('model', 'hardware model'),
    fleet.facility_name AS FACILITY_NAME WITH SYNONYMS = ('clinic', 'facility', 'location'),
    fleet.facility_city AS FACILITY_CITY,
    fleet.facility_state AS FACILITY_STATE WITH SYNONYMS = ('state', 'region'),
    fleet.environment_type AS ENVIRONMENT_TYPE WITH SYNONYMS = ('placement', 'room type'),
    fleet.overall_status AS OVERALL_STATUS WITH SYNONYMS = ('health status', 'status'),
    fleet.temp_status AS TEMP_STATUS,
    fleet.power_status AS POWER_STATUS
  )
  METRICS (
    fleet.fleet_size AS COUNT(fleet.device_id) COMMENT = 'Total number of devices in the fleet.',
    fleet.critical_devices AS COUNT_IF(fleet.overall_status = 'CRITICAL') COMMENT = 'Count of devices in CRITICAL status.',
    fleet.warning_devices AS COUNT_IF(fleet.overall_status = 'WARNING') COMMENT = 'Count of devices in WARNING status.',
    fleet.avg_temperature_f AS AVG(fleet.temperature_f) COMMENT = 'Average current temperature (F) across fleet.',
    fleet.avg_power_w AS AVG(fleet.power_w) COMMENT = 'Average current power consumption (W) across fleet.',
    fleet.total_active_errors AS SUM(fleet.error_count) COMMENT = 'Sum of current error counts across fleet.'
  )
  COMMENT = 'PatientPoint semantic view: fleet health and device status.'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  2) Telemetry trends semantic view (daily rollups)
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_TELEMETRY_DAILY
  TABLES (
    telemetry AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_DEVICE_TELEMETRY_DAILY
      PRIMARY KEY (DEVICE_ID, DAY)
      COMMENT = 'Daily aggregated telemetry for the last 30 days.'
  )
  DIMENSIONS (
    telemetry.device_id AS DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    telemetry.day AS DAY WITH SYNONYMS = ('date', 'day')
  )
  METRICS (
    telemetry.avg_temperature_f AS AVG(telemetry.avg_temperature_f) COMMENT = 'Avg temperature (F) per day (already rolled up).',
    telemetry.max_temperature_f AS MAX(telemetry.max_temperature_f) COMMENT = 'Max temperature (F) per day.',
    telemetry.avg_power_w AS AVG(telemetry.avg_power_w) COMMENT = 'Avg power (W) per day.',
    telemetry.max_power_w AS MAX(telemetry.max_power_w) COMMENT = 'Max power (W) per day.',
    telemetry.avg_latency_ms AS AVG(telemetry.avg_latency_ms) COMMENT = 'Avg latency (ms) per day.',
    telemetry.max_latency_ms AS MAX(telemetry.max_latency_ms) COMMENT = 'Max latency (ms) per day.',
    telemetry.avg_packet_loss_pct AS AVG(telemetry.avg_packet_loss_pct) COMMENT = 'Avg packet loss (%) per day.',
    telemetry.total_errors AS SUM(telemetry.total_errors) COMMENT = 'Total errors per day.'
  )
  COMMENT = 'PatientPoint semantic view: telemetry trends (daily rollups).'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  3) Maintenance incidents semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_MAINTENANCE_INCIDENTS
  TABLES (
    inc AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_MAINTENANCE_INCIDENTS
      PRIMARY KEY (MAINTENANCE_ID)
      COMMENT = 'Maintenance incident history with enriched context.'
  )
  DIMENSIONS (
    inc.maintenance_id AS MAINTENANCE_ID,
    inc.device_id AS DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    inc.incident_date AS INCIDENT_DATE WITH SYNONYMS = ('incident time', 'failure time'),
    inc.failure_type AS FAILURE_TYPE WITH SYNONYMS = ('issue type', 'failure mode'),
    inc.resolution_type AS RESOLUTION_TYPE WITH SYNONYMS = ('fix type', 'remediation type'),
    inc.remote_fix_successful AS REMOTE_FIX_SUCCESSFUL WITH SYNONYMS = ('resolved remotely', 'remote fix worked')
  )
  METRICS (
    inc.incident_count AS COUNT(inc.maintenance_id) COMMENT = 'Total number of maintenance incidents.',
    inc.avg_downtime_hours AS AVG(inc.downtime_hours) COMMENT = 'Average downtime hours for incidents.',
    inc.avg_total_cost_usd AS AVG(inc.total_cost_usd) COMMENT = 'Average total incident cost (USD).',
    inc.avg_revenue_impact_usd AS AVG(inc.revenue_impact_usd) COMMENT = 'Average revenue impact (USD).'
  )
  COMMENT = 'PatientPoint semantic view: maintenance incident history.'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  4) Remote resolution performance semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_REMOTE_RESOLUTION_RATES
  TABLES (
    rr AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_REMOTE_RESOLUTION_RATES
      PRIMARY KEY (FAILURE_TYPE)
      COMMENT = 'Remote resolution rates by failure type.'
  )
  DIMENSIONS (
    rr.failure_type AS FAILURE_TYPE WITH SYNONYMS = ('issue type', 'failure mode')
  )
  METRICS (
    rr.incidents AS SUM(rr.incidents) COMMENT = 'Number of incidents for failure type.',
    rr.remote_attempts AS SUM(rr.remote_attempts) COMMENT = 'Remote fix attempts.',
    rr.remote_successes AS SUM(rr.remote_successes) COMMENT = 'Remote fix successes.',
    rr.remote_success_rate AS AVG(rr.remote_success_rate) COMMENT = 'Remote success rate.',
    rr.avg_total_cost_usd AS AVG(rr.avg_total_cost_usd) COMMENT = 'Average total cost (USD).',
    rr.avg_downtime_hours AS AVG(rr.avg_downtime_hours) COMMENT = 'Average downtime hours.'
  )
  COMMENT = 'PatientPoint semantic view: remote resolution performance.'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  5) Baseline (pre-ML) semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_BASELINE_PRE_ML
  TABLES (
    b AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_BASELINE_PRE_ML
      PRIMARY KEY (AS_OF)
      COMMENT = 'Pre-ML baseline monitoring metrics (threshold-based).'
  )
  DIMENSIONS (
    b.as_of AS AS_OF WITH SYNONYMS = ('as of', 'timestamp')
  )
  METRICS (
    b.fleet_size AS MAX(b.fleet_size),
    b.devices_critical AS MAX(b.devices_critical),
    b.devices_warning AS MAX(b.devices_warning),
    b.devices_healthy AS MAX(b.devices_healthy),
    b.devices_requiring_review_today AS MAX(b.devices_requiring_review_today),
    b.charts_to_review_if_manual AS MAX(b.charts_to_review_if_manual)
  )
  COMMENT = 'PatientPoint semantic view: baseline (pre-ML) monitoring workload and counts.'
  COPY GRANTS;

SHOW SEMANTIC VIEWS LIKE 'SV_%';


