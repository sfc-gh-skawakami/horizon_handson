use role orgadmin;

CREATE ACCOUNT hol_account2
  admin_name = <user_name>
  admin_password = '<password>'
  first_name = '<First Name>'
  last_name = '<Last Name>'
  email = '<Email Address>'
  must_change_password = false
  edition = enterprise;

CREATE ACCOUNT hol_account3
  admin_name = <user_name>
  admin_password = '<password>'
  first_name = '<First Name>'
  last_name = '<Last Name>'
  email = '<Email Address>'
  must_change_password = false
  edition = enterprise; 

show accounts;
SET my_curr_account = (SELECT "account_name" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) order by "created_on" ASC LIMIT 1);
select $my_curr_account;
-- Enable users with the ACCOUNTADMIN role to set up Cross-Cloud Auto-Fulfillment
SELECT SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT($my_curr_account);
SELECT SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT('hol_account2');
SELECT SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT('hol_account3');

SHOW ACCOUNTS;
