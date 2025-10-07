-- Support Performance Analytics Database Schema
-- Generated SQL statements for Snowflake
USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE DATABASE support_performance_analytics;
-- create governance schema
CREATE OR REPLACE SCHEMA support_performance_analytics.governance;
-- create raw data schema
CREATE OR REPLACE SCHEMA support_performance_analytics.RAW_DATA;


-- ==============================================
-- Core Reference Tables
-- ==============================================

CREATE OR REPLACE TABLE support_teams (
    team_id NUMBER PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE OR REPLACE TABLE ticket_categories (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    sla_hours NUMBER NOT NULL
);

CREATE OR REPLACE TABLE ticket_priorities (
    priority_id NUMBER PRIMARY KEY,
    priority_name VARCHAR(50) NOT NULL,
    description VARCHAR(200) NOT NULL,
    sla_hours NUMBER NOT NULL,
    escalation_hours NUMBER NOT NULL
);

CREATE OR REPLACE TABLE ticket_statuses (
    status_id NUMBER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description VARCHAR(200) NOT NULL,
    is_active BOOLEAN NOT NULL,
    is_resolved BOOLEAN NOT NULL
);

-- ==============================================
-- Main Entity Tables
-- ==============================================

CREATE OR REPLACE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(25) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    company_size NUMBER NOT NULL,
    customer_tier VARCHAR(20) NOT NULL,
    signup_date DATE NOT NULL,
    last_interaction DATE NOT NULL,
    country VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    annual_revenue NUMBER NOT NULL,
    support_plan VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE OR REPLACE TABLE support_agents (
    agent_id NUMBER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    team_id NUMBER NOT NULL,
    hire_date DATE NOT NULL,
    role VARCHAR(50) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL,
    max_concurrent_tickets NUMBER NOT NULL,
    languages VARCHAR(200) NOT NULL,
    certifications VARCHAR(200) NOT NULL,
    FOREIGN KEY (team_id) REFERENCES support_teams(team_id)
);

CREATE OR REPLACE TABLE knowledge_base (
    article_id NUMBER PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content VARCHAR(4000) NOT NULL,
    category VARCHAR(100) NOT NULL,
    tags VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    created_date DATE NOT NULL,
    last_updated DATE NOT NULL,
    views NUMBER NOT NULL,
    helpful_votes NUMBER NOT NULL,
    not_helpful_votes NUMBER NOT NULL,
    is_published BOOLEAN NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL
);

-- ==============================================
-- Central Fact Table
-- ==============================================

CREATE OR REPLACE TABLE tickets (
    ticket_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    assigned_agent_id NUMBER,
    product_id NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    priority_id NUMBER NOT NULL,
    status_id NUMBER NOT NULL,
    subject VARCHAR(200) NOT NULL,
    description VARCHAR(2000) NOT NULL,
    created_date TIMESTAMP NOT NULL,
    resolved_date TIMESTAMP,
    last_updated TIMESTAMP NOT NULL,
    first_response_date TIMESTAMP,
    resolution_time_hours NUMBER(10,2),
    response_time_hours NUMBER(10,2),
    customer_satisfaction NUMBER(2,1),
    is_escalated BOOLEAN NOT NULL,
    escalation_reason VARCHAR(200),
    tags VARCHAR(200) NOT NULL,
    source VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (assigned_agent_id) REFERENCES support_agents(agent_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (category_id) REFERENCES ticket_categories(category_id),
    FOREIGN KEY (priority_id) REFERENCES ticket_priorities(priority_id),
    FOREIGN KEY (status_id) REFERENCES ticket_statuses(status_id)
);

-- ==============================================
-- Activity and Response Tables
-- ==============================================

CREATE OR REPLACE TABLE ticket_responses (
    response_id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    agent_id NUMBER,
    response_type VARCHAR(50) NOT NULL,
    content VARCHAR(2000) NOT NULL,
    response_date TIMESTAMP NOT NULL,
    is_internal BOOLEAN NOT NULL,
    time_spent_minutes NUMBER NOT NULL,
    is_solution BOOLEAN NOT NULL,
    solution_rating NUMBER(2,1),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    FOREIGN KEY (agent_id) REFERENCES support_agents(agent_id)
);

CREATE OR REPLACE TABLE ticket_attachments (
    attachment_id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_type VARCHAR(20) NOT NULL,
    file_size_mb NUMBER(10,2) NOT NULL,
    uploaded_date TIMESTAMP NOT NULL,
    uploaded_by VARCHAR(50) NOT NULL,
    description VARCHAR(200) NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);

-- ==============================================
-- Analytics and Performance Tables
-- ==============================================

CREATE OR REPLACE TABLE customer_satisfaction (
    csat_id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    customer_id NUMBER NOT NULL,
    rating NUMBER NOT NULL,
    survey_date DATE NOT NULL,
    comments VARCHAR(1000),
    would_recommend BOOLEAN NOT NULL,
    response_time_satisfaction NUMBER NOT NULL,
    resolution_satisfaction NUMBER NOT NULL,
    agent_satisfaction NUMBER NOT NULL,
    follow_up_required BOOLEAN NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE OR REPLACE TABLE escalations (
    escalation_id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    from_agent_id NUMBER,
    to_agent_id NUMBER NOT NULL,
    escalation_reason VARCHAR(200),
    escalation_date TIMESTAMP NOT NULL,
    escalation_level NUMBER NOT NULL,
    resolution_time_hours NUMBER NOT NULL,
    is_resolved BOOLEAN NOT NULL,
    notes VARCHAR(500) NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    FOREIGN KEY (from_agent_id) REFERENCES support_agents(agent_id),
    FOREIGN KEY (to_agent_id) REFERENCES support_agents(agent_id)
);

CREATE OR REPLACE TABLE sla_violations (
    violation_id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    violation_type VARCHAR(50) NOT NULL,
    sla_hours NUMBER NOT NULL,
    actual_hours NUMBER(10,2) NOT NULL,
    violation_date TIMESTAMP NOT NULL,
    severity VARCHAR(20) NOT NULL,
    impact VARCHAR(20) NOT NULL,
    action_taken VARCHAR(100) NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);

CREATE OR REPLACE TABLE resolution_times (
    resolution_id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    priority_id NUMBER NOT NULL,
    resolution_time_hours NUMBER(10,2),
    response_time_hours NUMBER(10,2),
    first_response_time_hours NUMBER(10,2),
    sla_target_hours NUMBER NOT NULL,
    priority_sla_hours NUMBER NOT NULL,
    is_sla_met BOOLEAN,
    resolution_date TIMESTAMP,
    agent_count NUMBER NOT NULL,
    response_count NUMBER NOT NULL,
    escalation_count NUMBER NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    FOREIGN KEY (category_id) REFERENCES ticket_categories(category_id),
    FOREIGN KEY (priority_id) REFERENCES ticket_priorities(priority_id)
);

CREATE OR REPLACE TABLE support_metrics (
    metric_id VARCHAR(50) PRIMARY KEY,
    agent_id NUMBER NOT NULL,
    month VARCHAR(7) NOT NULL,
    tickets_assigned NUMBER NOT NULL,
    tickets_resolved NUMBER NOT NULL,
    tickets_escalated NUMBER NOT NULL,
    avg_resolution_time_hours NUMBER(10,2) NOT NULL,
    avg_response_time_hours NUMBER(10,2) NOT NULL,
    customer_satisfaction NUMBER(3,2) NOT NULL,
    first_call_resolution_rate NUMBER(3,3) NOT NULL,
    sla_compliance_rate NUMBER(3,3) NOT NULL,
    productivity_score NUMBER(3,2) NOT NULL,
    knowledge_base_contributions NUMBER NOT NULL,
    training_hours NUMBER NOT NULL,
    FOREIGN KEY (agent_id) REFERENCES support_agents(agent_id)
);


-- ==============================================
-- Create Git Integration for data ingestion
-- ==============================================
use role accountadmin;
-- Git連携のため、API統合を作成する
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-skawakami/horizon_handson.git')
  ENABLED = TRUE;

-- GIT統合の作成
use role sysadmin;
CREATE OR REPLACE GIT REPOSITORY support_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/sfc-gh-skawakami/horizon_handson.git';

-- ==============================================
-- Copy Files from git stage to stage
-- ==============================================
CREATE OR REPLACE FILE FORMAT support_performance_analytics.public.csv_ff 
type = 'csv'
FIELD_DELIMITER = ','
PARSE_HEADER = TRUE
FIELD_OPTIONALLY_ENCLOSED_BY='"'
TRIM_SPACE=TRUE
;

CREATE OR REPLACE stage public.raw_data
    FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
    DIRECTORY = ( ENABLE = TRUE);

-- ==============================================
-- Copy data fro git stage to tables
-- ==============================================
COPY FILES INTO @public.raw_data FROM @public.GIT_INTEGRATION_FOR_HANDSON/branches/main/support/data/
PATTERN = '.*.csv';

COPY INTO customer_satisfaction FROM @public.raw_data/customer_satisfaction.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO customers FROM @public.raw_data/customers.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO escalations FROM @public.raw_data/escalations.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO knowledge_base FROM @public.raw_data/knowledge_base.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO products FROM @public.raw_data/products.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO resolution_times FROM @public.raw_data/resolution_times.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO sla_violations FROM @public.raw_data/sla_violations.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO support_agents FROM @public.raw_data/support_agents.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO support_metrics FROM @public.raw_data/support_metrics.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO support_teams FROM @public.raw_data/support_teams.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO ticket_attachments FROM @public.raw_data/ticket_attachments.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO ticket_categories FROM @public.raw_data/ticket_categories.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO ticket_priorities FROM @public.raw_data/ticket_priorities.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO ticket_responses FROM @public.raw_data/ticket_responses.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO ticket_statuses FROM @public.raw_data/ticket_statuses.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO tickets FROM @public.raw_data/tickets.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
