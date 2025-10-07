-- Sales Performance Analytics - Snowflake Table Creation Script
-- Generated from schema_documentation.json
-- Maps pandas data types to Snowflake data types according to:
-- https://docs.snowflake.com/en/sql-reference/intro-summary-data-types

USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE DATABASE sales_performance_analytics;
-- create governance schema
CREATE OR REPLACE SCHEMA sales_performance_analytics.governance;
-- create raw data schema
CREATE OR REPLACE SCHEMA sales_performance_analytics.RAW_DATA;



-- Sales Teams Table
CREATE OR REPLACE TABLE sales_teams (
    team_id INTEGER NOT NULL,
    team_name VARCHAR(255) NOT NULL,
    manager_name VARCHAR(255) NOT NULL,
    region VARCHAR(100) NOT NULL,
    PRIMARY KEY (team_id)
);

-- Territories Table
CREATE OR REPLACE TABLE territories (
    territory_id INTEGER NOT NULL,
    territory_name VARCHAR(255) NOT NULL,
    region VARCHAR(100) NOT NULL,
    states VARCHAR(500) NOT NULL,
    PRIMARY KEY (territory_id)
);

-- Products Table
CREATE OR REPLACE TABLE products (
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price NUMBER(10,2) NOT NULL,
    cost NUMBER(10,2) NOT NULL,
    PRIMARY KEY (product_id)
);

-- Customer Segments Table
CREATE OR REPLACE TABLE customer_segments (
    segment_id INTEGER NOT NULL,
    segment_name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    avg_deal_size INTEGER NOT NULL,
    PRIMARY KEY (segment_id)
);

-- Campaigns Table
CREATE OR REPLACE TABLE campaigns (
    campaign_id INTEGER NOT NULL,
    campaign_name VARCHAR(255) NOT NULL,
    campaign_type VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    target_audience VARCHAR(100) NOT NULL,
    expected_leads INTEGER NOT NULL,
    PRIMARY KEY (campaign_id)
);

-- Sales Representatives Table
CREATE OR REPLACE TABLE sales_representatives (
    rep_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    team_id INTEGER NOT NULL,
    territory_id INTEGER NOT NULL,
    hire_date DATE NOT NULL,
    experience_level VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    quota INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL,
    commission_rate NUMBER(5,3) NOT NULL,
    PRIMARY KEY (rep_id),
    FOREIGN KEY (team_id) REFERENCES sales_teams(team_id),
    FOREIGN KEY (territory_id) REFERENCES territories(territory_id)
);

-- Customers Table
CREATE OR REPLACE TABLE customers (
    customer_id INTEGER NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    industry VARCHAR(100) NOT NULL,
    company_size INTEGER NOT NULL,
    segment_id INTEGER NOT NULL,
    customer_tier VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL,
    last_interaction DATE NOT NULL,
    country VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    annual_revenue INTEGER NOT NULL,
    decision_makers INTEGER NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (segment_id) REFERENCES customer_segments(segment_id)
);

-- Leads Table
CREATE OR REPLACE TABLE leads (
    lead_id INTEGER NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    company_size INTEGER NOT NULL,
    industry VARCHAR(100) NOT NULL,
    lead_source VARCHAR(100) NOT NULL,
    campaign_id INTEGER,
    assigned_rep_id INTEGER,
    lead_score INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_date DATE NOT NULL,
    last_activity DATE NOT NULL,
    converted_date DATE,
    PRIMARY KEY (lead_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
    FOREIGN KEY (assigned_rep_id) REFERENCES sales_representatives(rep_id)
);

-- Opportunities Table
CREATE OR REPLACE TABLE opportunities (
    opportunity_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rep_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    opportunity_name VARCHAR(255) NOT NULL,
    stage VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    value INTEGER NOT NULL,
    probability INTEGER NOT NULL,
    expected_value NUMBER(15,2) NOT NULL,
    created_date DATE NOT NULL,
    close_date DATE NOT NULL,
    last_activity DATE NOT NULL,
    competitor VARCHAR(100) NOT NULL,
    decision_criteria VARCHAR(1000) NOT NULL,
    next_steps VARCHAR(500) NOT NULL,
    PRIMARY KEY (opportunity_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Deals Table
CREATE OR REPLACE TABLE deals (
    deal_id INTEGER NOT NULL,
    opportunity_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rep_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    deal_name VARCHAR(255) NOT NULL,
    deal_value INTEGER NOT NULL,
    close_date DATE NOT NULL,
    contract_length_months INTEGER NOT NULL,
    payment_terms VARCHAR(50) NOT NULL,
    renewal_probability INTEGER NOT NULL,
    customer_satisfaction INTEGER NOT NULL,
    implementation_status VARCHAR(50) NOT NULL,
    upsell_potential INTEGER NOT NULL,
    PRIMARY KEY (deal_id),
    FOREIGN KEY (opportunity_id) REFERENCES opportunities(opportunity_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Activities Table
CREATE OR REPLACE TABLE activities (
    activity_id INTEGER NOT NULL,
    opportunity_id INTEGER NOT NULL,
    rep_id INTEGER NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    activity_date DATE NOT NULL,
    duration_minutes INTEGER NOT NULL,
    outcome VARCHAR(50) NOT NULL,
    next_action VARCHAR(500) NOT NULL,
    next_action_date DATE NOT NULL,
    PRIMARY KEY (activity_id),
    FOREIGN KEY (opportunity_id) REFERENCES opportunities(opportunity_id),
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id)
);

-- Sales Metrics Table
CREATE OR REPLACE TABLE sales_metrics (
    metric_id VARCHAR(50) NOT NULL,
    rep_id INTEGER NOT NULL,
    month VARCHAR(7) NOT NULL,
    quota NUMBER(15,2) NOT NULL,
    deals_closed INTEGER NOT NULL,
    deals_value INTEGER NOT NULL,
    opportunities_created INTEGER NOT NULL,
    activities_completed INTEGER NOT NULL,
    calls_made INTEGER NOT NULL,
    emails_sent INTEGER NOT NULL,
    meetings_scheduled INTEGER NOT NULL,
    conversion_rate NUMBER(5,3) NOT NULL,
    avg_deal_size INTEGER NOT NULL,
    pipeline_value INTEGER NOT NULL,
    forecast_accuracy NUMBER(5,3) NOT NULL,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id)
);

-- Commissions Table
CREATE OR REPLACE TABLE commissions (
    commission_id INTEGER NOT NULL,
    deal_id INTEGER NOT NULL,
    rep_id INTEGER NOT NULL,
    deal_value INTEGER NOT NULL,
    commission_rate NUMBER(5,3) NOT NULL,
    commission_amount NUMBER(15,2) NOT NULL,
    payment_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    tax_withheld NUMBER(15,2) NOT NULL,
    PRIMARY KEY (commission_id),
    FOREIGN KEY (deal_id) REFERENCES deals(deal_id),
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id)
);

-- Comments for documentation
COMMENT ON TABLE sales_teams IS 'Sales team organizational structure';
COMMENT ON TABLE territories IS 'Sales territories and regions';
COMMENT ON TABLE products IS 'Product catalog with pricing information';
COMMENT ON TABLE customer_segments IS 'Customer segmentation for analytics';
COMMENT ON TABLE campaigns IS 'Marketing campaigns and lead generation';
COMMENT ON TABLE sales_representatives IS 'Individual sales representatives with quotas and commission rates';
COMMENT ON TABLE customers IS 'Customer information and company details';
COMMENT ON TABLE leads IS 'Lead generation and qualification data';
COMMENT ON TABLE opportunities IS 'Sales opportunities and pipeline management';
COMMENT ON TABLE deals IS 'Closed deals and transaction details';
COMMENT ON TABLE activities IS 'Sales activities including calls, emails, and meetings';
COMMENT ON TABLE sales_metrics IS 'Monthly sales performance metrics per representative';
COMMENT ON TABLE commissions IS 'Commission tracking and payment details';

-- Data Type Mapping Reference:
-- pandas int64 -> Snowflake INTEGER
-- pandas float64 -> Snowflake NUMBER(precision, scale)
-- pandas object -> Snowflake VARCHAR(length)
-- pandas bool -> Snowflake BOOLEAN
-- pandas datetime64[ns] -> Snowflake DATE
-- Composite keys -> Snowflake VARCHAR for flexibility
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
CREATE OR REPLACE GIT REPOSITORY sales_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/sfc-gh-skawakami/horizon_handson.git';

-- ==============================================
-- Copy Files from git stage to stage
-- ==============================================
CREATE OR REPLACE FILE FORMAT public.csv_ff 
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
COPY FILES INTO @public.raw_data FROM @public.GIT_INTEGRATION_FOR_HANDSON/branches/main/sales/data/
PATTERN = '.*.csv';


COPY INTO activities FROM @public.raw_data/activities.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO campaigns FROM @public.raw_data/campaigns.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO commissions FROM @public.raw_data/commissions.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO customer_segments FROM @public.raw_data/customer_segments.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO customers FROM @public.raw_data/customers.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO deals FROM @public.raw_data/deals.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO leads FROM @public.raw_data/leads.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO opportunities FROM @public.raw_data/opportunities.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO products FROM @public.raw_data/products.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO sales_metrics FROM @public.raw_data/sales_metrics.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO sales_representatives FROM @public.raw_data/sales_representatives.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO sales_teams FROM @public.raw_data/sales_teams.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO territories FROM @public.raw_data/territories.csv
FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- ==============================================