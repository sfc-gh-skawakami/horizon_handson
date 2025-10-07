-- Marketing Performance Analytics Database Schema
-- Snowflake SQL CREATE TABLE statements
-- Generated from schema_documentation.json

USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE DATABASE marketing_performance_analytics;
-- create governance schema
CREATE OR REPLACE SCHEMA marketing_performance_analytics.governance;
-- create raw data schema
CREATE OR REPLACE SCHEMA marketing_performance_analytics.RAW_DATA;

-- ==============================================
-- Core Marketing Tables
-- ==============================================

-- Marketing Channels Table
CREATE OR REPLACE TABLE marketing_channels (
    channel_id NUMBER(38,0) PRIMARY KEY,
    channel_name VARCHAR(255) NOT NULL,
    channel_type VARCHAR(100) NOT NULL,
    cost_per_lead NUMBER(10,2) NOT NULL,
    avg_conversion_rate NUMBER(5,4) NOT NULL
);

-- Marketing Teams Table
CREATE OR REPLACE TABLE marketing_teams (
    team_id NUMBER(38,0) PRIMARY KEY,
    team_name VARCHAR(255) NOT NULL,
    manager_name VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL
);

-- Target Audiences Table
CREATE OR REPLACE TABLE target_audiences (
    audience_id NUMBER(38,0) PRIMARY KEY,
    audience_name VARCHAR(255) NOT NULL,
    segment VARCHAR(100) NOT NULL,
    size_estimate NUMBER(38,0) NOT NULL,
    avg_lifetime_value NUMBER(38,0) NOT NULL
);

-- Campaigns Table
CREATE OR REPLACE TABLE campaigns (
    campaign_id NUMBER(38,0) PRIMARY KEY,
    campaign_name VARCHAR(255) NOT NULL,
    campaign_type VARCHAR(100) NOT NULL,
    channel_id NUMBER(38,0) NOT NULL,
    audience_id NUMBER(38,0) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget NUMBER(15,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    objective VARCHAR(100) NOT NULL,
    target_leads NUMBER(38,0) NOT NULL,
    expected_roi NUMBER(5,2) NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    last_modified DATE NOT NULL,
    FOREIGN KEY (channel_id) REFERENCES marketing_channels(channel_id),
    FOREIGN KEY (audience_id) REFERENCES target_audiences(audience_id)
);

-- ==============================================
-- Content and Asset Tables
-- ==============================================

-- Campaign Assets Table
CREATE OR REPLACE TABLE campaign_assets (
    asset_id NUMBER(38,0) PRIMARY KEY,
    campaign_id NUMBER(38,0) NOT NULL,
    asset_name VARCHAR(500) NOT NULL,
    asset_type VARCHAR(100) NOT NULL,
    file_size_mb NUMBER(10,2) NOT NULL,
    creation_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    creator VARCHAR(255) NOT NULL,
    version VARCHAR(20) NOT NULL,
    tags VARCHAR(1000),
    description VARCHAR(1000),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- Content Performance Table
CREATE OR REPLACE TABLE content_performance (
    content_id NUMBER(38,0) PRIMARY KEY,
    asset_id NUMBER(38,0) NOT NULL,
    campaign_id NUMBER(38,0) NOT NULL,
    views NUMBER(38,0) NOT NULL,
    clicks NUMBER(38,0) NOT NULL,
    downloads NUMBER(38,0) NOT NULL,
    shares NUMBER(38,0) NOT NULL,
    comments NUMBER(38,0) NOT NULL,
    likes NUMBER(38,0) NOT NULL,
    engagement_rate NUMBER(5,4) NOT NULL,
    click_through_rate NUMBER(5,4) NOT NULL,
    conversion_rate NUMBER(5,4) NOT NULL,
    time_on_page NUMBER(10,1) NOT NULL,
    bounce_rate NUMBER(5,2) NOT NULL,
    social_reach NUMBER(38,0) NOT NULL,
    organic_traffic NUMBER(38,0) NOT NULL,
    paid_traffic NUMBER(38,0) NOT NULL,
    FOREIGN KEY (asset_id) REFERENCES campaign_assets(asset_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- ==============================================
-- Lead and Activity Tables
-- ==============================================

-- Leads Table
CREATE OR REPLACE TABLE leads (
    lead_id NUMBER(38,0) PRIMARY KEY,
    campaign_id NUMBER(38,0) NOT NULL,
    audience_id NUMBER(38,0) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    company VARCHAR(255) NOT NULL,
    job_title VARCHAR(255),
    industry VARCHAR(100),
    company_size NUMBER(38,0),
    lead_source VARCHAR(100) NOT NULL,
    lead_score NUMBER(38,0) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_date DATE NOT NULL,
    last_activity DATE NOT NULL,
    converted_date DATE,
    country VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    utm_source VARCHAR(100) NOT NULL,
    utm_medium VARCHAR(100) NOT NULL,
    utm_campaign VARCHAR(255) NOT NULL,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
    FOREIGN KEY (audience_id) REFERENCES target_audiences(audience_id)
);

-- Marketing Activities Table
CREATE OR REPLACE TABLE marketing_activities (
    activity_id NUMBER(38,0) PRIMARY KEY,
    lead_id NUMBER(38,0) NOT NULL,
    campaign_id NUMBER(38,0) NOT NULL,
    activity_type VARCHAR(100) NOT NULL,
    activity_date DATE NOT NULL,
    duration_minutes NUMBER(10,2),
    page_url VARCHAR(2000),
    referrer VARCHAR(2000),
    device_type VARCHAR(50) NOT NULL,
    browser VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent VARCHAR(2000) NOT NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(lead_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- Conversions Table
CREATE OR REPLACE TABLE conversions (
    conversion_id NUMBER(38,0) PRIMARY KEY,
    lead_id NUMBER(38,0) NOT NULL,
    campaign_id NUMBER(38,0) NOT NULL,
    conversion_type VARCHAR(100) NOT NULL,
    conversion_date DATE NOT NULL,
    conversion_value NUMBER(15,2) NOT NULL,
    revenue NUMBER(15,2) NOT NULL,
    customer_lifetime_value NUMBER(15,2) NOT NULL,
    conversion_path VARCHAR(500) NOT NULL,
    attribution_model VARCHAR(100) NOT NULL,
    touchpoints_count NUMBER(38,0) NOT NULL,
    days_to_conversion NUMBER(38,0) NOT NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(lead_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- ==============================================
-- Analytics and Performance Tables
-- ==============================================

-- Marketing Metrics Table
CREATE OR REPLACE TABLE marketing_metrics (
    metric_id VARCHAR(100) PRIMARY KEY,
    channel_id NUMBER(38,0) NOT NULL,
    month VARCHAR(7) NOT NULL,
    impressions NUMBER(38,0) NOT NULL,
    clicks NUMBER(38,0) NOT NULL,
    leads_generated NUMBER(38,0) NOT NULL,
    conversions NUMBER(38,0) NOT NULL,
    revenue NUMBER(15,2) NOT NULL,
    cost NUMBER(15,2) NOT NULL,
    roi NUMBER(5,2) NOT NULL,
    ctr NUMBER(5,4) NOT NULL,
    conversion_rate NUMBER(5,4) NOT NULL,
    cost_per_lead NUMBER(10,2) NOT NULL,
    cost_per_conversion NUMBER(10,2) NOT NULL,
    avg_order_value NUMBER(10,2) NOT NULL,
    FOREIGN KEY (channel_id) REFERENCES marketing_channels(channel_id)
);

-- Budget Allocation Table
CREATE OR REPLACE TABLE budget_allocation (
    allocation_id VARCHAR(50) PRIMARY KEY,
    channel_id NUMBER(38,0) NOT NULL,
    quarter VARCHAR(2) NOT NULL,
    year NUMBER(38,0) NOT NULL,
    allocated_budget NUMBER(15,2) NOT NULL,
    spent_budget NUMBER(15,2) NOT NULL,
    planned_spend NUMBER(15,2) NOT NULL,
    budget_utilization NUMBER(5,2) NOT NULL,
    performance_score NUMBER(5,2) NOT NULL,
    recommended_adjustment VARCHAR(50) NOT NULL,
    FOREIGN KEY (channel_id) REFERENCES marketing_channels(channel_id)
);

-- Customer Journey Table
CREATE OR REPLACE TABLE customer_journey (
    journey_id NUMBER(38,0) PRIMARY KEY,
    lead_id NUMBER(38,0) NOT NULL,
    current_stage VARCHAR(100) NOT NULL,
    stage_progression NUMBER(38,0) NOT NULL,
    total_stages NUMBER(38,0) NOT NULL,
    days_in_stage NUMBER(38,0) NOT NULL,
    touchpoints_count NUMBER(38,0) NOT NULL,
    channels_used NUMBER(38,0) NOT NULL,
    content_consumed NUMBER(38,0) NOT NULL,
    engagement_score NUMBER(5,2) NOT NULL,
    next_expected_action VARCHAR(100) NOT NULL,
    predicted_conversion_probability NUMBER(5,2) NOT NULL,
    last_stage_change DATE NOT NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(lead_id)
);

-- Attribution Table
CREATE OR REPLACE TABLE attribution (
    attribution_id NUMBER(38,0) PRIMARY KEY,
    conversion_id NUMBER(38,0) NOT NULL,
    campaign_id NUMBER(38,0) NOT NULL,
    attribution_model VARCHAR(100) NOT NULL,
    attribution_percentage NUMBER(5,2) NOT NULL,
    attributed_revenue NUMBER(15,2) NOT NULL,
    touchpoint_position NUMBER(38,0) NOT NULL,
    days_from_first_touch NUMBER(38,0) NOT NULL,
    days_from_last_touch NUMBER(38,0) NOT NULL,
    channel_weight NUMBER(5,2) NOT NULL,
    interaction_type VARCHAR(100) NOT NULL,
    FOREIGN KEY (conversion_id) REFERENCES conversions(conversion_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- ==============================================
-- Comments and Documentation
-- ==============================================

-- Add table comments for documentation
COMMENT ON TABLE marketing_channels IS 'Marketing channel definitions with cost metrics and conversion rates';
COMMENT ON TABLE marketing_teams IS 'Marketing team organizational structure';
COMMENT ON TABLE target_audiences IS 'Customer audience segments with size estimates and lifetime values';
COMMENT ON TABLE campaigns IS 'Marketing campaigns with budgets, objectives, and performance targets';
COMMENT ON TABLE campaign_assets IS 'Marketing assets (ads, content, etc.) linked to campaigns';
COMMENT ON TABLE content_performance IS 'Content performance metrics including views, clicks, and engagement';
COMMENT ON TABLE leads IS 'Lead generation data with UTM tracking and conversion status';
COMMENT ON TABLE marketing_activities IS 'Marketing activities and touchpoints with engagement data';
COMMENT ON TABLE conversions IS 'Conversion tracking with revenue and attribution data';
COMMENT ON TABLE marketing_metrics IS 'Monthly performance metrics by channel including ROI and CTR';
COMMENT ON TABLE budget_allocation IS 'Quarterly budget distribution across channels with utilization metrics';
COMMENT ON TABLE customer_journey IS 'Customer journey mapping with stage progression and engagement scores';
COMMENT ON TABLE attribution IS 'Marketing attribution data across multiple attribution models';

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
CREATE OR REPLACE GIT REPOSITORY marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/sfc-gh-skawakami/horizon_handson.git';

-- ==============================================
-- Copy data fro git stage to tables
-- ==============================================
CREATE OR REPLACE FILE FORMAT marketing_performance_analytics.public.csv_ff 
type = 'csv';

COPY INTO attribution FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/attribution.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1);

COPY INTO budget_allocation FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/budget_allocation.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO campaigns FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/campaigns.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO campaign_assets FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/campaign_assets.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO content_performance FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/content_performance.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO customer_journey FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/customer_journey.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO leads FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/leads.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO marketing_activities FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/marketing_activities.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO marketing_channels FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/marketing_channels.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO marketing_metrics FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/marketing_metrics.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1);
COPY INTO marketing_teams FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/marketing_teams.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1);
COPY INTO target_audiences FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/target_audiences.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1); 
COPY INTO conversions FROM @marketing_performance_analytics.public.GIT_INTEGRATION_FOR_HANDSON/branches/main/marketing/data/conversions.csv
FILE_FORMAT = (FORMAT_NAME = 'marketing_performance_analytics.public.csv_ff' SKIP_HEADER = 1);
-- ==============================================
-- End of Marketing Performance Analytics Schema
