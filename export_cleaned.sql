/* ============================================================
   export_cleaned.sql
   OPTIONAL helper: exports the 3 cleaned tables to CSV using
   SQL Server's built-in BCP-via-xp_cmdshell is overkill for a
   simple project, so instead this project documents the SSMS
   GUI way to do this (see RUN_GUIDE.md, Step 1d):

     Right-click each table result grid > "Save Results As..."
     -> choose cleaned/customers.csv, cleaned/addresses.csv,
        cleaned/payment_methods.csv

   This file just re-runs the SELECTs so you have something to
   right-click "Save Results As" on on without re-running the
   whole clean_sql.sql script.
   ============================================================ */

USE EcommerceAnalystProject;
GO

SELECT * FROM dbo.Customers;
GO
SELECT * FROM dbo.Addresses;
GO
SELECT * FROM dbo.PaymentMethods;
GO
