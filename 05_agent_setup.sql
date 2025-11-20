-- ============================================================================
-- Patient Point IXR Analytics - Cortex Agent Setup
-- ============================================================================
-- Description: Creates Snowflake Cortex Agent with dual-tool orchestration:
--              1. Analyst Tool - Structured analytics via semantic model
--              2. Search Tool - Unstructured content discovery via Cortex Search
--
-- Best Practices Reference: 
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS;

-- ============================================================================
-- Prerequisites: Role and Privilege Setup
-- ============================================================================
-- Per Snowflake best practices, grant CORTEX_AGENT_USER role to appropriate users

-- Grant Cortex Agent User role to SYSADMIN (adjust as needed for your organization)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE SYSADMIN;

-- Ensure necessary privileges for agent creation
GRANT CREATE AGENT ON SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS TO ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- Stage Setup for Semantic Model File
-- ============================================================================

-- Create internal stage for the semantic model YAML
CREATE STAGE IF NOT EXISTS SEMANTIC_MODEL_STAGE
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for Cortex Analyst semantic model YAML file';

-- Upload the semantic model YAML file to stage
-- Note: After running this script, upload 04_semantic_model.yaml to this stage using:
-- 
-- Option 1 (SnowSQL):
--   PUT file:///path/to/04_semantic_model.yaml @SEMANTIC_MODEL_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
--
-- Option 2 (Snowsight UI):
--   Navigate to: Databases → PATIENTPOINT_DB → IXR_ANALYTICS → Stages → SEMANTIC_MODEL_STAGE
--   Click "Upload Files" and select 04_semantic_model.yaml

-- Verify stage contents
LIST @SEMANTIC_MODEL_STAGE;

-- ============================================================================
-- Cortex Analyst Service Setup
-- ============================================================================

-- Create Cortex Analyst service using the semantic model
-- Best Practice: Use descriptive names and specify warehouse for resource management
CREATE OR REPLACE CORTEX ANALYST SERVICE PATIENT_IMPACT_ANALYST
    SEMANTIC_MODEL_FILE = '@SEMANTIC_MODEL_STAGE/04_semantic_model.yaml'
    WAREHOUSE = COMPUTE_WH
    COMMENT = 'Cortex Analyst for Patient Point IXR engagement and clinical outcomes analysis';

-- Verify Analyst service creation
SHOW CORTEX ANALYST SERVICES IN SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS;

-- Test the analyst with a sample query (optional)
/*
SELECT SNOWFLAKE.CORTEX.COMPLETE_ANALYST(
    'PATIENT_IMPACT_ANALYST',
    'Did an increase in scrolling lead to more vaccines administered?'
) AS response;
*/

-- ============================================================================
-- Cortex Agent Creation with Native Tools Configuration
-- ============================================================================
-- Best Practice: Use Snowflake's native CREATE CORTEX AGENT syntax with tools
-- instead of custom Python UDFs for better integration with Snowflake Intelligence

CREATE OR REPLACE CORTEX AGENT PATIENT_IMPACT_AGENT
    -- Agent Instructions: Define the agent's purpose and behavior
    INSTRUCTIONS = '
You are the Patient Point IXR Analytics Engine, an expert AI assistant specialized in analyzing 
the relationship between digital patient engagement and clinical healthcare outcomes.

Your primary capabilities:
1. ANALYTICAL INSIGHTS: Use the Cortex Analyst tool to query structured data about:
   - Patient engagement metrics (scrolling, clicks, dwell time)
   - Clinical outcomes (vaccinations, screenings, appointment adherence)
   - Provider performance and churn analysis
   - Trend analysis by specialty, region, and time period

2. CONTENT DISCOVERY: Use the Cortex Search tool to find relevant medical content:
   - Educational videos and articles
   - Health topics and guidance
   - Content effectiveness analysis

WHEN TO USE EACH TOOL:
- Use ANALYST tool for: metrics, trends, correlations, comparisons, "how many", aggregations, impact analysis
- Use SEARCH tool for: content topics, "what content", "find articles", educational materials, recommendations
- Use BOTH tools when: analyzing which content drove specific outcomes

RESPONSE STYLE:
- Start with key insights and actionable findings
- Support with specific numbers and percentages
- Reference data sources (scroll depth, click rates, etc.)
- For correlation questions, emphasize the strength of relationships
- Always be clear about what the data shows

Remember: Your goal is to prove that high digital engagement leads to better clinical outcomes 
and reduced provider churn.'
    
    -- Sample Questions: Guide users on what they can ask
    SAMPLE_QUESTIONS = (
        'Did an increase in scrolling lead to more vaccines administered?',
        'Show the correlation between dwell time and preventative screenings',
        'Which content topics drove the highest appointment show rates?',
        'What is the relationship between engagement and provider churn?',
        'Compare clinical outcomes across different medical specialties',
        'Show me monthly trends in engagement and clinical outcomes',
        'What content do we have about flu vaccines?',
        'How do different regions compare in terms of engagement?',
        'What outcomes do providers with high engagement achieve?',
        'Which providers are at risk of churning based on engagement?'
    )
    
    -- Tools Configuration: Define available tools for the agent
    TOOLS = (
        -- Tool 1: Cortex Analyst for structured data analysis
        CORTEX_ANALYST(
            SERVICE_NAME => 'PATIENT_IMPACT_ANALYST',
            WAREHOUSE => 'COMPUTE_WH',
            TIMEOUT => 300,  -- 5 minutes timeout for complex queries
            DESCRIPTION => 'Analyzes structured data on patient engagement metrics and clinical outcomes. Use for quantitative questions about metrics, trends, and correlations.'
        ),
        
        -- Tool 2: Cortex Search for unstructured content retrieval
        CORTEX_SEARCH(
            SERVICE_NAME => 'CONTENT_SEARCH_SVC',
            MAX_RESULTS => 10,
            DESCRIPTION => 'Searches medical education content library including videos, articles, and health guidance. Use for questions about content topics and recommendations.'
        )
    )
    
    -- Warehouse for agent execution
    WAREHOUSE = COMPUTE_WH
    
    -- Metadata
    COMMENT = 'IXR Analytics Engine: AI agent for analyzing digital engagement impact on clinical outcomes';

-- ============================================================================
-- Verify Agent Creation
-- ============================================================================

SHOW CORTEX AGENTS IN SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS;

-- Describe the agent to see configuration
DESC CORTEX AGENT PATIENT_IMPACT_AGENT;

-- ============================================================================
-- Access Control and Security (Best Practices)
-- ============================================================================

-- Grant agent usage to SYSADMIN role
GRANT USAGE ON CORTEX AGENT PATIENT_IMPACT_AGENT TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX ANALYST SERVICE PATIENT_IMPACT_ANALYST TO ROLE SYSADMIN;

-- Grant access to underlying data objects
GRANT USAGE ON DATABASE PATIENTPOINT_DB TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS TO ROLE SYSADMIN;
GRANT SELECT ON ALL TABLES IN SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS TO ROLE SYSADMIN;
GRANT SELECT ON ALL VIEWS IN SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS TO ROLE SYSADMIN;

-- Optional: Grant MONITOR privilege to track agent performance
GRANT MONITOR ON CORTEX AGENT PATIENT_IMPACT_AGENT TO ROLE SYSADMIN;

-- Best Practice: Revoke broad access if too permissive
-- REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE PUBLIC;

-- ============================================================================
-- Test Agent with Sample Queries
-- ============================================================================
-- Note: The agent can be accessed via Snowflake Intelligence UI or programmatically

-- Test 1: Analytical query about engagement impact
/*
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'PATIENT_IMPACT_AGENT',
    'Did an increase in scrolling lead to more vaccines administered?'
) AS response;
*/

-- Test 2: Content search query
/*
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'PATIENT_IMPACT_AGENT',
    'What content do we have about flu vaccines?'
) AS response;
*/

-- Test 3: Combined analytical and content query
/*
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'PATIENT_IMPACT_AGENT',
    'Which content topics drove the highest vaccination rates?'
) AS response;
*/

-- ============================================================================
-- Monitoring and Maintenance (Best Practices)
-- ============================================================================

-- View agent threads and interactions
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.CORTEX_AGENT_THREADS('PATIENT_IMPACT_AGENT'));

-- View agent execution logs (requires MONITOR privilege)
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.CORTEX_AGENT_LOGS('PATIENT_IMPACT_AGENT'));

-- ============================================================================
-- Helper Functions for Programmatic Access (Optional)
-- ============================================================================

-- Function to create a conversation thread
CREATE OR REPLACE FUNCTION CREATE_AGENT_THREAD()
RETURNS VARCHAR
LANGUAGE SQL
AS $$
    SELECT SNOWFLAKE.CORTEX.CREATE_THREAD('PATIENT_IMPACT_AGENT')
$$;

-- Function to send message to agent in a thread
CREATE OR REPLACE FUNCTION SEND_AGENT_MESSAGE(thread_id VARCHAR, user_message VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS $$
    SELECT SNOWFLAKE.CORTEX.SEND_MESSAGE(
        'PATIENT_IMPACT_AGENT',
        thread_id,
        user_message
    )
$$;

-- ============================================================================
-- Integration with Snowflake Intelligence
-- ============================================================================

/*
USING THE AGENT IN SNOWFLAKE INTELLIGENCE:

1. Navigate to: Snowsight → AI & ML → Agents
2. Select: PATIENT_IMPACT_AGENT
3. Click "Open in Intelligence" or "Test Agent"
4. Start asking questions from the sample questions list

BEST PRACTICES FOR AGENT INTERACTION:
- Use specific, measurable questions for best results
- Reference specific metrics (scroll depth, click count, vaccines, etc.)
- Ask for comparisons across dimensions (specialty, region, time)
- Request visualizations when appropriate
- Follow up with clarifying questions to drill down

EXAMPLE CONVERSATION FLOW:
User: "Did an increase in scrolling lead to more vaccines administered?"
Agent: [Provides correlation analysis with data]
User: "Show me which specialties have the strongest correlation"
Agent: [Breaks down by specialty]
User: "What content are these high-performing providers using?"
Agent: [Uses search tool to identify content]
*/

-- ============================================================================
-- REST API Integration (For Custom Applications)
-- ============================================================================

/*
To integrate the agent into custom applications via REST API:

1. Create a thread:
   POST /api/v2/cortex/agents/{agent_name}/threads

2. Send messages:
   POST /api/v2/cortex/agents/{agent_name}/threads/{thread_id}/messages
   Body: {"content": "Your question here"}

3. Retrieve messages:
   GET /api/v2/cortex/agents/{agent_name}/threads/{thread_id}/messages

Example (using Python):
```python
from snowflake.snowpark import Session

# Create thread
thread_id = session.sql("SELECT SNOWFLAKE.CORTEX.CREATE_THREAD('PATIENT_IMPACT_AGENT')").collect()[0][0]

# Send message
response = session.sql(f"""
    SELECT SNOWFLAKE.CORTEX.SEND_MESSAGE(
        'PATIENT_IMPACT_AGENT',
        '{thread_id}',
        'Show me the correlation between scrolling and vaccinations'
    )
""").collect()

print(response[0][0])
```

For complete REST API documentation, visit:
https://docs.snowflake.com/en/developer-guide/cortex/cortex-agents-api
*/

-- ============================================================================
-- Performance Optimization Tips
-- ============================================================================

/*
BEST PRACTICES FOR OPTIMAL PERFORMANCE:

1. WAREHOUSE SIZING:
   - For PoC/Demo: X-Small to Small warehouse is sufficient
   - For Production: Medium warehouse recommended for concurrent users
   - Consider auto-suspend (60 seconds) and auto-resume

2. SEMANTIC MODEL OPTIMIZATION:
   - Keep verified_queries up to date with common user questions
   - Add synonyms for domain-specific terminology
   - Pre-aggregate complex calculations in views

3. SEARCH SERVICE OPTIMIZATION:
   - Set appropriate target_lag based on data freshness requirements
   - Use filters to reduce search scope when possible
   - Limit max_results to balance relevance and performance

4. MONITORING:
   - Track query latency using CORTEX_AGENT_LOGS
   - Monitor warehouse utilization
   - Review and refine agent instructions based on user feedback

5. COST MANAGEMENT:
   - Set appropriate timeout values (current: 300 seconds)
   - Use result caching where applicable
   - Consider query result reuse for similar questions
*/

-- ============================================================================
-- Troubleshooting Common Issues
-- ============================================================================

/*
ISSUE: "Agent not found" error
SOLUTION: Verify agent exists with: SHOW CORTEX AGENTS;

ISSUE: "Permission denied" errors
SOLUTION: Check role grants:
  GRANT USAGE ON CORTEX AGENT PATIENT_IMPACT_AGENT TO ROLE <your_role>;

ISSUE: Semantic model file not found
SOLUTION: Verify file upload:
  LIST @SEMANTIC_MODEL_STAGE;
  -- Ensure 04_semantic_model.yaml is present

ISSUE: Slow response times
SOLUTION: 
  - Check warehouse size and utilization
  - Review query complexity in semantic model
  - Consider adding indexes to base tables

ISSUE: Agent gives irrelevant responses
SOLUTION:
  - Refine INSTRUCTIONS to be more specific
  - Add more verified_queries to semantic model
  - Review and update tool descriptions
  - Add more synonyms to semantic model

ISSUE: Search returns no results
SOLUTION:
  - Verify CONTENT_SEARCH_SVC is running: SHOW CORTEX SEARCH SERVICES;
  - Check search service has indexed content (wait 1-2 minutes after creation)
  - Test search directly: 
    SELECT * FROM TABLE(CONTENT_SEARCH_SVC!SEARCH(QUERY => 'test', NUM_RESULTS => 5));
*/

-- ============================================================================
-- Version Information and Updates
-- ============================================================================

/*
AGENT VERSION: 1.0
LAST UPDATED: 2024-11-20
SNOWFLAKE FEATURES USED:
  - Cortex Agents
  - Cortex Analyst
  - Cortex Search
  - Semantic Views

FUTURE ENHANCEMENTS:
  1. Add custom stored procedure tools for complex business logic
  2. Integrate with external systems via API tools
  3. Add feedback collection mechanism
  4. Implement A/B testing for agent instruction variations
  5. Add multi-language support
  6. Create specialized agents for different user personas (executives, clinicians, analysts)
*/

SELECT '✓ Cortex Agent created successfully with native tools configuration.' AS STATUS;
SELECT '✓ Agent follows Snowflake best practices for enterprise deployment.' AS BEST_PRACTICES;
SELECT '✓ Ready for use in Snowflake Intelligence or custom applications.' AS INTEGRATION;

-- ============================================================================
-- Quick Reference: Sample Questions by Category
-- ============================================================================

/*
ENGAGEMENT IMPACT QUESTIONS:
- "Did an increase in scrolling lead to more vaccines administered?"
- "Show the correlation between dwell time and preventative screenings"
- "How does click count affect appointment show rates?"
- "What engagement level drives the best clinical outcomes?"

PROVIDER ANALYSIS QUESTIONS:
- "What is the relationship between engagement and provider churn?"
- "Which providers are at risk of churning?"
- "Show me the top 10 providers by vaccination impact"
- "Compare provider retention by engagement level"

SPECIALTY & REGIONAL QUESTIONS:
- "Compare clinical outcomes across different medical specialties"
- "How do different regions compare in terms of engagement?"
- "Which specialty has the highest vaccination rates?"
- "Show regional differences in appointment adherence"

TREND ANALYSIS QUESTIONS:
- "Show me monthly trends in engagement and clinical outcomes"
- "What were the vaccination trends in Q3 2024?"
- "Has engagement improved over time?"
- "Show year-over-year growth in screenings"

CONTENT DISCOVERY QUESTIONS:
- "What content do we have about flu vaccines?"
- "Find content about diabetes management"
- "Which content topics drove the highest appointment show rates?"
- "What are the most effective educational materials?"

BUSINESS VALUE QUESTIONS:
- "What is the ROI of high engagement?"
- "Calculate the impact of scrolling on clinical metrics"
- "Show the business case for the IXR platform"
- "What outcomes justify provider investment in IXR?"
*/
