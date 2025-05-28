# Data Engineering: dbt + Snowflake

Learn how to use dbt and Snowflake to transform data more effectively.

## Course Overview:

The Data Engineering: dbt + Snowflake training course is designed to help engineers effectively contribute to data models in data build tool (dbt) and answer complex questions using data. Dbt is a command-line tool that enables data analysts and engineers to transform data in their warehouse more effectively. Snowflake architecture allows storage and computes to scale independently. The course covers how to build data models using dbt. Students will also learn how to write advanced SQL queries in Snowflake.

The course begins with an introduction to dbt and Jinja. Next, students will learn how to build production-quality data pipelines with dbt and Snowflake. Finally, students will learn how to maintain and grow data pipelines over time.

## Productivity Objectives:

After this course, you will be able to:

- Utilize dbt proficiently
- Develop SQL queries in Snowflake
- Explain how to deploy dbt models to production
- Indicate how to tune a dbt project to leverage Snowflake functionality

## Course Duration:

This course will be delivered in 3 Days

## Course Delivery:

DI will work with you and your team to define the most appropriate delivery structure, schedule and dates. Structure, schedule and dates will be determined by project schedule, team availability and classroom availability. And of course, it will also be determined by DI’s instructor availability.

## Course Outline:

### Introduction to dbt
- Runs, Sources, and Docs
  - What would it look like if to do this manually
  - What dbt is doing when to call dbt to run
  - dbt model configurations (tables vs views)
  - The `ref` function and how dbt builds its DAG
  - How to define and use sources
  - Source freshness
  - How to add definitions to models and sources
  - Docs blocks
  - How to generate docs (IDE and CLI)
- Lab
  - Putting together the building blocks of a dbt project
  - Adding sources
  - Writing models
  - Setting up source freshness
  - Writing documentation

### Jinja, Schema Tests, and Custom Tests
- Intro to templating languages
- Set, for, if, macros in Jinja (agnostic of dbt)
- Using Jinja in the context of SQL
- dbt specific uses of Jinja (adapter methods, target, etc)
- Adding tests to a dbt project
- How tests in dbt work
- Writing a custom schema test
- Writing a custom data test
- Lab
  - Adding tests to a project
  - Writing a custom schema test
  - Writing a custom data test
  - Improving an SQL query by using dbt adapter methods

### Snapshots, Seeds
- Why snapshots are important
- How to set up snapshots (check vs timestamp)
- What snapshots are used for
- Setting up seed files in dbt
- Good use-cases for seed files (i.e. replacing case when statements)
- Setting data types for seed files
- Lab
  - Fixing issues with seed files
  - Using seed files for filtering and joining
  - Setting up a snapshot of a source
  - Setting up a snapshot of a metrics table

### Data Modelling, Project Structure, and Packages
- Pure star-schema
- Why star-schema isn’t as relevant anymore
- What makes a dbt project a dbt project? (dbt_project.yml walkthrough)
- Model types (fact, dimension, staging, intermediate, utils.)
- Project structure – files
- Project structure – DAG
- Project structure – database
- Example of projects
- Importing other projects (packages.yml)

---

### Advanced SQL techniques

#### CTEs vs Subqueries, query optimization
- Focusing on code readability
- Why subqueries have historically been used
- Subqueries in Snowflake
- CTEs vs ephemeral models (in dbt)
- Optimization methods and query profiles

- Lab
  - Re-factoring a query using subqueries to using CTEs
  - Breaking up a large model into ephemeral models in dbt

#### Window functions, filtering, calendar spines
- How window functions works
- Use cases for window functions
- Creating history tables with calendar spines
- Using window functions to do rolling aggregates
- Using window functions to find following or preceding values
- Filtering using Regex vs ilike

- Lab
  - Generating a calendar spine in Snowflake (without dbt)
  - Building a daily user status table (including status yesterday)
  - Building a daily user statistics table (including rolling aggregates)
  - Filtering the tables based on certain email patterns

#### Semi-structured data in Snowflake + Recursive CTEs
- Why semi-structured data is useful
- Parsing strings as JSON
- How to query dictionaries
- How to query arrays
- Lateral flatten
- Casting JSON data types
- Recursive CTEs
- Limitations of Recursive CTEs

- Lab
  - Exercise

---

### Advanced dbt

#### Environments, Deployment and the Software Development Life Cycle
- What do environments look like in dbt?
- How do environments work in dbt Cloud? (environments vs projects)
- Setting up environments for development work (zero-copy clones)
- Opening a pull request
- Continuous Integration with dbt Cloud
- Scheduled Runs
- Blue/Green deploys
- Limiting data in an environment

- Lab
  - Set up a new environment in dbt Cloud that pulls from the master with jobs that run on PR and schedule
  - Add a macro to your project that sets up your development environment (i.e. copies data from production)
  - Open a Pull Request and make sure the CI run kicks off and passes
  - Merge code into master and kick off a ‘production’ run

#### Incremental models
- Why are incremental models needed?
- How to configure an incremental model
- The shortfalls of incremental models
- What’s happening under the hood with incremental models
- Example: Simple incremental model (pure append)
- Example: Complex incremental model (lookback)

- Lab
  - Re-factor model to be incremental

#### Snowflake specifics within dbt
- Clustering
- Selecting warehouses for specific models
- Transient tables
- Query tags
- Copying grants

#### Final dbt tips and tricks
- Analysis folder
- Tags
- Hooks
- Operations
- Audit Helper
- Codegen
- Metrics tables
