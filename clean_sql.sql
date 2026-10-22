/* ============================================================
   clean_sql.sql
   Run this in SSMS (Query Editor), connected to the
   EcommerceAnalystProject database, AFTER you have imported the
   7 raw files below using SSMS's Import Flat File wizard
   (see RUN_GUIDE.md, Step 1).

   Expected staging tables (created by the wizard, one per file):
     dbo.customers_010626, dbo.customers_020626, dbo.customers_030626
     dbo.addresses_010626, dbo.addresses_020626, dbo.addresses_030626
     dbo.payment_methods_010626

   Produces 3 final, cleaned tables:
     dbo.Customers
     dbo.Addresses
     dbo.PaymentMethods
   ============================================================ */

USE EcommerceAnalystProject;
GO

------------------------------------------------------------
-- 1. CUSTOMERS: union the 3 dated batches + fix the
--    typographic apostrophe (’) that shows up in some names/emails
------------------------------------------------------------
IF OBJECT_ID('dbo.Customers') IS NOT NULL DROP TABLE dbo.Customers;
GO

WITH AllCustomers AS (
    SELECT CustomerID, FirstName, LastName, Email, PhoneNumber, DateOfBirth, RegistrationDate, PreferredPaymentMethodID FROM dbo.customers_010626
    UNION ALL
    SELECT CustomerID, FirstName, LastName, Email, PhoneNumber, DateOfBirth, RegistrationDate, PreferredPaymentMethodID FROM dbo.customers_020626
    UNION ALL
    SELECT CustomerID, FirstName, LastName, Email, PhoneNumber, DateOfBirth, RegistrationDate, PreferredPaymentMethodID FROM dbo.customers_030626
)
SELECT
    CustomerID,
    -- NCHAR(8217) = the curly/typographic apostrophe (U+2019) that shows up
    -- in a few source names/emails; using the code point instead of a
    -- literal character avoids file-encoding issues in different editors
    REPLACE(FirstName, NCHAR(8217), '''')        AS FirstName,
    REPLACE(LastName,  NCHAR(8217), '''')        AS LastName,
    REPLACE(Email,     NCHAR(8217), '''')        AS Email,
    PhoneNumber,
    TRY_CAST(DateOfBirth AS DATE)                AS DateOfBirth,
    TRY_CAST(RegistrationDate AS DATE)           AS RegistrationDate,
    PreferredPaymentMethodID
INTO dbo.Customers
FROM AllCustomers;
GO

------------------------------------------------------------
-- 2. ADDRESSES: union the 3 dated batches, replace underscores
--    with spaces, collapse the embedded line breaks inside
--    AddressLine1 into a single readable line, and cast PinCode
--    from text like "60162.0" to a clean integer
------------------------------------------------------------
IF OBJECT_ID('dbo.Addresses') IS NOT NULL DROP TABLE dbo.Addresses;
GO

WITH AllAddresses AS (
    SELECT AddressID, CustomerID, AddressLine1, City, State, PinCode, AddressType FROM dbo.addresses_010626
    UNION ALL
    SELECT AddressID, CustomerID, AddressLine1, City, State, PinCode, AddressType FROM dbo.addresses_020626
    UNION ALL
    SELECT AddressID, CustomerID, AddressLine1, City, State, PinCode, AddressType FROM dbo.addresses_030626
)
SELECT
    AddressID,
    CustomerID,
    REPLACE(
        REPLACE(
            REPLACE(REPLACE(AddressLine1, CHAR(13), ' '), CHAR(10), ', '),
        '_', ' '),
    '  ', ' ')                                   AS AddressLine1,
    REPLACE(City, '_', ' ')                      AS City,
    REPLACE(State, '_', ' ')                      AS State,
    TRY_CAST(TRY_CAST(PinCode AS FLOAT) AS INT)   AS PinCode,
    AddressType
INTO dbo.Addresses
FROM AllAddresses;
GO

------------------------------------------------------------
-- 3. PAYMENT METHODS: single small reference table, load as-is
------------------------------------------------------------
IF OBJECT_ID('dbo.PaymentMethods') IS NOT NULL DROP TABLE dbo.PaymentMethods;
GO

SELECT PaymentMethodID, MethodName
INTO dbo.PaymentMethods
FROM dbo.payment_methods_010626;
GO

------------------------------------------------------------
-- 4. Quick row-count check (compare against RUN_GUIDE.md expectations)
------------------------------------------------------------
SELECT 'Customers' AS TableName, COUNT(*) AS NumRows FROM dbo.Customers
UNION ALL
SELECT 'Addresses', COUNT(*) FROM dbo.Addresses
UNION ALL
SELECT 'PaymentMethods', COUNT(*) FROM dbo.PaymentMethods;
GO
