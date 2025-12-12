/*============================================================================
  Run-all script (Snowflake Workspaces friendly)

  Snowflake Workspaces does not currently support "run this whole folder" as a
  single action. The most reliable approach is:

  1) Upload these SQL files to an internal stage (same filenames).
  2) Run this single script, which executes each staged file in order.

  Expected staged paths (example):
    @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/00_setup.sql
    @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/01_generate_sample_data.sql
    ...
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

-- Stage location for your SQL assets
USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA OPERATIONS;

CREATE STAGE IF NOT EXISTS OPERATIONS.DEMO_SQL_STAGE
  COMMENT = 'Stage containing demo SQL files for run-all execution.';

-- Execute each script from the stage in a deterministic order
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/00_setup.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/01_generate_sample_data.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/10_curated_analytics_views.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/12_cortex_search_kb.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/11_semantic_views.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/20_anomaly_watchlist.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/21_semantic_view_anomaly_watchlist.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/30_failure_predictions.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/31_semantic_views_predictions.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/40_work_orders.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/41_semantic_view_work_orders.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/50_remote_remediation.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/51_semantic_view_remote_remediation.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/60_executive_kpis.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/61_semantic_view_executive_kpis.sql;
EXECUTE IMMEDIATE FROM @PREDICTIVE_MAINTENANCE.OPERATIONS.DEMO_SQL_STAGE/70_cortex_agent.sql;

SELECT 'Run-all complete ✅' AS STATUS;


