-- create_database.sql
-- Run this first in SSMS (connected to your local SQL Server instance)
-- before using the Import Flat File wizard or running clean_sql.sql.

IF DB_ID('EcommerceAnalystProject') IS NULL
BEGIN
    CREATE DATABASE EcommerceAnalystProject;
END
GO
