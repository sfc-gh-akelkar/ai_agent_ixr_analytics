/*============================================================================
  Ops Center (Snowflake Intelligence): Semantic View for Work Orders
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW SV_WORK_ORDERS
  TABLES (
    wo AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_WORK_ORDERS_CURRENT
      PRIMARY KEY (WORK_ORDER_ID)
      WITH SYNONYMS = ('work orders', 'tickets', 'dispatch queue', 'ops queue')
      COMMENT = 'Current open/in-progress work orders generated from watchlist/predictions.'
  )
  DIMENSIONS (
    wo.work_order_id AS wo.WORK_ORDER_ID
      COMMENT = 'Unique work order identifier',
    wo.device_id AS wo.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen', 'screen id')
      COMMENT = 'Device ID associated with this work order',
    wo.status AS wo.STATUS
      WITH SYNONYMS = ('work order status', 'state')
      SAMPLE_VALUES = ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
      COMMENT = 'Work order status: OPEN, IN_PROGRESS, COMPLETED, or CANCELLED',
    wo.priority AS wo.PRIORITY
      WITH SYNONYMS = ('urgency', 'priority level')
      SAMPLE_VALUES = ('P1', 'P2', 'P3')
      COMMENT = 'Priority level: P1 (due <8h, critical), P2 (due <24h), P3 (due <72h)',
    wo.created_at AS wo.CREATED_AT
      WITH SYNONYMS = ('created', 'created at', 'opened at')
      COMMENT = 'Timestamp when work order was created',
    wo.updated_at AS wo.UPDATED_AT
      WITH SYNONYMS = ('updated', 'updated at', 'last modified')
      COMMENT = 'Timestamp when work order was last updated',
    wo.due_by AS wo.DUE_BY
      WITH SYNONYMS = ('due', 'due by', 'deadline', 'sla', 'due date')
      COMMENT = 'Timestamp by which work order should be completed',
    wo.issue_type AS wo.ISSUE_TYPE
      WITH SYNONYMS = ('issue', 'failure type', 'problem type')
      SAMPLE_VALUES = ('Network Connectivity', 'Power Supply', 'Overheating', 'Display Panel', 'Software Crash', 'Firmware Bug')
      COMMENT = 'Type of issue: Network Connectivity, Power Supply, Overheating, Display Panel, Software Crash, Firmware Bug',
    wo.recommended_channel AS wo.RECOMMENDED_CHANNEL
      WITH SYNONYMS = ('channel', 'remote or field', 'dispatch type', 'resolution channel')
      SAMPLE_VALUES = ('REMOTE', 'FIELD')
      COMMENT = 'Recommended resolution channel: REMOTE (fix remotely) or FIELD (requires technician dispatch)'
  )
  METRICS (
    wo.open_work_orders AS COUNT(wo.WORK_ORDER_ID)
      COMMENT = 'Count of open/in-progress work orders.',
    wo.p1_count AS COUNT_IF(wo.PRIORITY = 'P1')
      COMMENT = 'Count of P1 (critical, due <8h) work orders.',
    wo.p2_count AS COUNT_IF(wo.PRIORITY = 'P2')
      COMMENT = 'Count of P2 (high, due <24h) work orders.',
    wo.p3_count AS COUNT_IF(wo.PRIORITY = 'P3')
      COMMENT = 'Count of P3 (routine, due <72h) work orders.',
    wo.field_dispatch_count AS COUNT_IF(wo.RECOMMENDED_CHANNEL = 'FIELD')
      COMMENT = 'Count of work orders requiring field technician dispatch.',
    wo.remote_fix_count AS COUNT_IF(wo.RECOMMENDED_CHANNEL = 'REMOTE')
      COMMENT = 'Count of work orders that can be resolved remotely.'
  )
  COMMENT = 'Ops Center semantic view: work order queue with priority, status, and recommended resolution channel.'
  COPY GRANTS;

SELECT 'SV_WORK_ORDERS semantic view created ✅' AS STATUS;

