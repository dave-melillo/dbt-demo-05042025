-- Create a role for Dave
CREATE ROLE student_dave_role;

-- Create a dedicated schema for Dave
CREATE SCHEMA IF NOT EXISTS DBT_DEMO_05042026.STUDENT_DAVE;

-- Grant the role access to the database and schema
GRANT USAGE ON DATABASE DBT_DEMO_05042026 TO ROLE student_dave_role;
GRANT USAGE ON SCHEMA DBT_DEMO_05042026.STUDENT_DAVE TO ROLE student_dave_role;

-- Grant DDL capabilities in Dave's schema
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT 
  ON SCHEMA DBT_DEMO_05042026.STUDENT_DAVE TO ROLE student_dave_role;

-- Grant DML on all future tables in Dave's schema
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE 
  ON FUTURE TABLES IN SCHEMA DBT_DEMO_05042026.STUDENT_DAVE TO ROLE student_dave_role;

-- Create Dave's user account
CREATE USER dave_user
  PASSWORD = 'StrongPassword123!'  -- Change before real use
  DEFAULT_ROLE = student_dave_role
  DEFAULT_WAREHOUSE = COMPUTE_WH;

-- Assign the role to Dave
GRANT ROLE student_dave_role TO USER dave_user;

-- Allow the role to use the warehouse
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE student_dave_role;
