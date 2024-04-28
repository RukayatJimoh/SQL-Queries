--create a table to load the fmKunde_combine data
/*CREATE TABLE "ENPALCASESTUDY"."PUBLIC"."fmKunde_combined" (
    customer_number VARCHAR(10),
    salutation VARCHAR(10),
    account_number VARCHAR(35),
    country VARCHAR(10),
    postal_code VARCHAR(10)
);
ALTER TABLE "ENPALCASESTUDY"."PUBLIC"."fmKunde_combined"
MODIFY COLUMN postal_code VARCHAR(35);*/

--create a table to load the fmBuchung_combined data

/*CREATE TABLE "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined" (
    amount NUMERIC(18, 2), 
    booking_type VARCHAR(60),
    booking_date DATE,
    booking_key VARCHAR(10),
    booking_status VARCHAR(10),
    credit_debit VARCHAR(1),
    valuta_date DATE,
    processing_key VARCHAR(10),
    account_number VARCHAR(10),
    account_number_addition VARCHAR(10)
);*/
ALTER TABLE "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined"
MODIFY COLUMN account_number VARCHAR(61)

ALTER TABLE "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined"
MODIFY COLUMN booking_status VARCHAR(61)
--create a table to load the fmKonto_combined data

/*CREATE TABLE "ENPALCASESTUDY"."PUBLIC"."fmKonto_combined" (
    effective_interest NUMERIC(5, 2),
    redemption_date DATE,
    redemption_status VARCHAR(10),
    account_number VARCHAR(10),
    spv_tag VARCHAR(10),
    contract_start_date DATE,
    customer_number VARCHAR(10), 
    account_balance NUMERIC(18, 2),
    nominal_interest NUMERIC(5, 2)
);*/



/*ALTER TABLE "ENPALCASESTUDY"."PUBLIC"."fmKonto_combined"
MODIFY COLUMN account_number VARCHAR(61);*/

--create a table to load the fmBKDetail_combined data
/*CREATE TABLE "ENPALCASESTUDY"."PUBLIC"."fmBKDetail_combined" (
    cost NUMERIC(10, 2),
    maturity_date DATE,
    sepa_mandat BOOLEAN,
    current_principal_balance NUMERIC(18, 2),
    arrears_balance NUMERIC(10, 2),
    arrears_balance_costs NUMERIC(10, 2),
    arrears_since_date DATE, 
    arrears_days INTEGER,
    arrears_repayment NUMERIC(10, 2),
    arrears_overdue_interest NUMERIC(10, 2),
    arrears_interest NUMERIC(10, 2),
    loan_start_date DATE,
    original_balance NUMERIC(18, 2),
    annuity NUMERIC(10, 2),
    account_number VARCHAR(61),
    credit_score VARCHAR(1)     
);*/


SELECT *,
FROM "fmKonto_combined"
WHERE ACCOUNT_NUMBER IS NULL

DELETE FROM "ENPALCASESTUDY"."PUBLIC"."fmKonto_combined"
WHERE ACCOUNT_NUMBER IS NULL;

SELECT *,
FROM "fmBKDetail_combined"
WHERE ACCOUNT_NUMBER NOT LIKE 'DE%'

DELETE FROM "ENPALCASESTUDY"."PUBLIC"."fmBKDetail_combined"
WHERE ACCOUNT_NUMBER NOT LIKE 'DE%';

---cleaning the konton table 
SELECT *,
FROM "fmKunde_combined"
WHERE CUSTOMER_NUMBER NOT LIKE 'C%'

--deleting the outlier
DELETE FROM "ENPALCASESTUDY"."PUBLIC"."fmKunde_combined"
WHERE CUSTOMER_NUMBER NOT LIKE 'C%';

 -- put story
SELECT *,
FROM "fmKunde_combined"
WHERE COUNTRY IS NULL

UPDATE "ENPALCASESTUDY"."PUBLIC"."fmKunde_combined"
SET COUNTRY = 'DE'
WHERE COUNTRY IS NULL;

SELECT *,
FROM "fmKunde_combined"
WHERE NOT REGEXP_LIKE(POSTAL_CODE, '^[0-9]+$');

UPDATE "ENPALCASESTUDY"."PUBLIC"."fmKunde_combined"
SET POSTAL_CODE = 
    CASE TRIM(POSTAL_CODE)
        WHEN 'Halle'  THEN '06108'
        WHEN 'Gro -Umstadt'  THEN '64823'
        WHEN 'Lippstadt'  THEN '59555'
        WHEN 'Wildpoldsried'  THEN '87499'
        WHEN 'Ingolstadt'  THEN '85049'
        WHEN 'Altenstadt'  THEN '63674'
        WHEN 'L beck'  THEN '23552'
        WHEN 'Ostfriesland'  THEN '26605'
        WHEN 'Ostseebad'  THEN '23944'
        WHEN 'Goethestadt'  THEN '06246'
     END   
WHERE TRIM(POSTAL_CODE) IN ('Halle','Gro -Umstadt','Lippstadt','Wildpoldsried','Ingolstadt','Altenstadt','L beck','Ostfriesland','Ostseebad','Goethestadt');
--put story
SELECT
  *
FROM
  "fmBuchung_combined"
  WHERE LENGTH (ACCOUNT_NUMBER) < 4
-- put story
DELETE FROM "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined"
WHERE ACCOUNT_NUMBER = 1;

-- put story
UPDATE "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined"
SET ACCOUNT_NUMBER = 
    CASE 
        WHEN LENGTH(ACCOUNT_NUMBER) = 5 THEN CONCAT(ACCOUNT_NUMBER_ADDITION, '0000', ACCOUNT_NUMBER)
        WHEN LENGTH(ACCOUNT_NUMBER) = 6 THEN CONCAT(ACCOUNT_NUMBER_ADDITION, '000', ACCOUNT_NUMBER)
        WHEN LENGTH(ACCOUNT_NUMBER) = 7 THEN CONCAT(ACCOUNT_NUMBER_ADDITION, '00', ACCOUNT_NUMBER)
        ELSE ACCOUNT_NUMBER
    END;
    
--put story
SELECT DISTINCT BOOKING_TYPE
FROM
  "fmBuchung_combined"
WHERE BOOKING_TYPE LIKE '%Sondertilgung%';

--put story
UPDATE "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined"
SET booking_type = TRIM(booking_type)

--put story
UPDATE "ENPALCASESTUDY"."PUBLIC"."fmBuchung_combined"
SET booking_status = 
    CASE 
        WHEN booking_status = 1 THEN 'Deferred'
        WHEN booking_status = 10 THEN 'Clarified distributed revenue'
        WHEN booking_status = 11 THEN 'Split revenue'
        WHEN booking_status = 12 THEN 'Unresolved to FiBu'
        WHEN booking_status = 13 THEN 'Suspended'
        WHEN booking_status = 14 THEN 'Free for release'
        WHEN booking_status = 15 THEN 'Release rejected'
        WHEN booking_status = 16 THEN 'Free for cancellation release'
        WHEN booking_status = 17 THEN 'Cancelled'
        WHEN booking_status = 18 THEN 'Cancelled unprocessed'
        WHEN booking_status = 2 THEN 'Processed'
        WHEN booking_status = 3 THEN 'Free for processing'
        WHEN booking_status = 4 THEN 'Reversed'
        WHEN booking_status = 5 THEN 'Misposted'
        WHEN booking_status = 6 THEN 'Deleted'
        WHEN booking_status = 7 THEN 'Reversal Disbursement'
        WHEN booking_status = 8 THEN 'Internal tax posting for payment distribution (delete after export)'
        WHEN booking_status = 9 THEN 'Unresolved taxed out revenue'
        ELSE booking_status -- keep the original value if it doesn't match any condition
    END;

    -- reset the SPV_TAG
UPDATE "fmKonto_combined"
SET SPV_TAG = 
    CASE 
        WHEN SPV_TAG = '10' THEN 'Enpal_bv'
        WHEN SPV_TAG = '20' THEN 'GFS_Alpha'
        ELSE SPV_TAG
    END;


    ---Deriving insights 
- counting the number of accounts 
--total number of customers account 
SELECT COUNT (DISTINCT CUSTOMER_NUMBER)AS Total_Number_of_Customer
FROM "fmKunde_combined"

--total number of customer accounts based on account number 
SELECT COUNT (DISTINCT ACCOUNT_NUMBER)AS Total_Number_of_Customer
FROM "fmKunde_combined"

-- Aggregating the number of customers based on gender
 SELECT COUNT(DISTINCT ACCOUNT_NUMBER) AS account_counts,SALUTATION
FROM
  "fmKunde_combined"
GROUP BY SALUTATION

--distinct booking type
SELECT DISTINCT BOOKING_TYPE AS booking_type
FROM
  "fmBuchung_combined"
  
    --Customers with prepayment
SELECT COUNT (DISTINCT ACCOUNT_NUMBER)AS Number_of_Customer,
BOOKING_TYPE
FROM
  "fmBuchung_combined"
WHERE BOOKING_TYPE LIKE '%Sondertilgung%'
GROUP BY BOOKING_TYPE;

--Customers with Special prepayment on capital paid--
SELECT COUNT (DISTINCT ACCOUNT_NUMBER)AS Number_of_Customer,
BOOKING_TYPE
FROM
  "fmBuchung_combined"
WHERE BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%'
GROUP BY BOOKING_TYPE;

-- joining the fmKunde_combined with fmBuchung_combined table
SELECT 
    K.SALUTATION,
    K.POSTAL_CODE,
    B.BOOKING_KEY,
    B.BOOKING_TYPE,
    B.ACCOUNT_NUMBER
FROM "fmBuchung_combined" B 
 LEFT JOIN 
   "fmKunde_combined" K ON  B.ACCOUNT_NUMBER =K.ACCOUNT_NUMBER;

-------------------
--Filtering
SELECT COUNT(DISTINCT ACCOUNT_NUMBER)
FROM
(SELECT 
    K.SALUTATION,
    K.POSTAL_CODE,
    B.BOOKING_KEY,
    B.BOOKING_TYPE,
    B.ACCOUNT_NUMBER
FROM "fmBuchung_combined" B 
 LEFT JOIN 
   "fmKunde_combined" K ON  B.ACCOUNT_NUMBER =K.ACCOUNT_NUMBER
WHERE BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%') AS subquery

-- aggregating the prepayment based on amount
SELECT 
    K.SALUTATION,
    K.POSTAL_CODE,
    B.BOOKING_KEY,
    B.BOOKING_TYPE,
    B.ACCOUNT_NUMBER,
    SUM(B.AMOUNT) AS TOTAL_PREPAYMENT
FROM "fmBuchung_combined" B 
 LEFT JOIN 
   "fmKunde_combined" K ON  B.ACCOUNT_NUMBER =K.ACCOUNT_NUMBER
WHERE BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%'
GROUP BY K.SALUTATION, K.POSTAL_CODE, B.BOOKING_KEY, B.BOOKING_TYPE,B.ACCOUNT_NUMBER;


-- investigating the customers that cancelled prepayment 
SELECT *
  FROM "fmBuchung_combined"
    WHERE BOOKING_TYPE LIKE '%Sondertilgung%'

SELECT *
  FROM "fmBuchung_combined"
    WHERE ACCOUNT_NUMBER LIKE '%Sondertilgung%'

    --combined table
    
CREATE VIEW SavedView AS
SELECT BKD.ACCOUNT_NUMBER, BKD.CURRENT_PRINCIPAL_BALANCE, BKD.LOAN_START_DATE, BKD.ORIGINAL_BALANCE,BKD.ANNUITY,BKD.CREDIT_SCORE,
        KO.SPV_TAG,KO.ACCOUNT_BALANCE,KO.CUSTOMER_NUMBER,
        K.POSTAL_CODE,K.SALUTATION
  FROM "fmKunde_combined" AS K
  JOIN "fmKonto_combined" AS KO ON K.ACCOUNT_NUMBER = KO.ACCOUNT_NUMBER
  JOIN "fmBKDetail_combined" AS BKD ON K.ACCOUNT_NUMBER = KO.ACCOUNT_NUMBER


--prepaid data
/* SELECT 
    B.BOOKING_TYPE,
    B.ACCOUNT_NUMBER,
    SUM(B.AMOUNT) AS TOTAL_PREPAYMENT
FROM "fmBuchung_combined" AS B
WHERE BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%'
GROUP BY B.BOOKING_STATUS,B.BOOKING_TYPE,B.ACCOUNT_NUMBER */


---joining all four tables
SELECT  B.ACCOUNT_NUMBER,KO.CUSTOMER_NUMBER, BKD.CURRENT_PRINCIPAL_BALANCE, BKD.LOAN_START_DATE, BKD.ORIGINAL_BALANCE,BKD.ANNUITY,BKD.CREDIT_SCORE,
        KO.SPV_TAG,KO.ACCOUNT_BALANCE,KO.CUSTOMER_NUMBER,
        K.POSTAL_CODE,K.SALUTATION,
        B.BOOKING_TYPE, B.ACCOUNT_NUMBER,
        SUM(B.AMOUNT) AS TOTAL_PREPAYMENT
FROM "fmKunde_combined" AS K
JOIN "fmKonto_combined" AS KO ON K.ACCOUNT_NUMBER = KO.ACCOUNT_NUMBER
JOIN "fmBKDetail_combined" AS BKD ON K.ACCOUNT_NUMBER = BKD.ACCOUNT_NUMBER
JOIN "fmBuchung_combined" AS B ON K.ACCOUNT_NUMBER = B.ACCOUNT_NUMBER
WHERE B.BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%'
GROUP BY BKD.ACCOUNT_NUMBER, BKD.CURRENT_PRINCIPAL_BALANCE, BKD.LOAN_START_DATE, BKD.ORIGINAL_BALANCE,BKD.ANNUITY,BKD.CREDIT_SCORE,
        KO.SPV_TAG,KO.ACCOUNT_BALANCE,KO.CUSTOMER_NUMBER,
        K.POSTAL_CODE,K.SALUTATION,
        B.BOOKING_TYPE, B.ACCOUNT_NUMBER;

        ---for the postal code 
SELECT 
    ROW_NUMBER() OVER () AS ID,
    B.ACCOUNT_NUMBER,
    KO.CUSTOMER_NUMBER, 
    BKD.CURRENT_PRINCIPAL_BALANCE, 
    BKD.LOAN_START_DATE, 
    BKD.ORIGINAL_BALANCE,
    BKD.ANNUITY,
    BKD.CREDIT_SCORE,
    KO.SPV_TAG,
    KO.ACCOUNT_BALANCE,
    KO.CUSTOMER_NUMBER,
    K.POSTAL_CODE,
    LEFT(K.POSTAL_CODE, 2) AS TWO_DIGITS_POSTALCODE, -- New column to extract the first two digits of postal code
    K.SALUTATION,
    B.BOOKING_TYPE,
    B.ACCOUNT_NUMBER,
    SUM(B.AMOUNT) AS TOTAL_PREPAYMENT
FROM "fmKunde_combined" AS K
JOIN "fmKonto_combined" AS KO ON K.ACCOUNT_NUMBER = KO.ACCOUNT_NUMBER
JOIN "fmBKDetail_combined" AS BKD ON K.ACCOUNT_NUMBER = BKD.ACCOUNT_NUMBER
JOIN "fmBuchung_combined" AS B ON K.ACCOUNT_NUMBER = B.ACCOUNT_NUMBER
WHERE B.BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%'
GROUP BY 
    B.ACCOUNT_NUMBER, 
    KO.CUSTOMER_NUMBER, 
    BKD.CURRENT_PRINCIPAL_BALANCE, 
    BKD.LOAN_START_DATE, 
    BKD.ORIGINAL_BALANCE,
    BKD.ANNUITY,
    BKD.CREDIT_SCORE,
    KO.SPV_TAG,
    KO.ACCOUNT_BALANCE,
    KO.CUSTOMER_NUMBER,
    K.POSTAL_CODE,
    K.SALUTATION,
    B.BOOKING_TYPE;



SELECT 
    ROW_NUMBER() OVER (ORDER BY B.ACCOUNT_NUMBER) AS ID,--New column to create ID 
    B.ACCOUNT_NUMBER,
    KO.CUSTOMER_NUMBER, 
    BKD.CURRENT_PRINCIPAL_BALANCE, 
    BKD.LOAN_START_DATE, 
    BKD.ORIGINAL_BALANCE,
    BKD.ANNUITY,
    BKD.CREDIT_SCORE,
    KO.SPV_TAG,
    KO.ACCOUNT_BALANCE,
    KO.CUSTOMER_NUMBER,
    K.POSTAL_CODE,
    LEFT(K.POSTAL_CODE, 2) AS SHORT_POSTCODE, -- New column to extract the first two digits of postal code
    K.SALUTATION,
    B.BOOKING_TYPE,
    B.ACCOUNT_NUMBER,
    SUM(B.AMOUNT) AS TOTAL_PREPAYMENT
FROM "fmKunde_combined" AS K
JOIN "fmKonto_combined" AS KO ON K.ACCOUNT_NUMBER = KO.ACCOUNT_NUMBER
JOIN "fmBKDetail_combined" AS BKD ON K.ACCOUNT_NUMBER = BKD.ACCOUNT_NUMBER
JOIN "fmBuchung_combined" AS B ON K.ACCOUNT_NUMBER = B.ACCOUNT_NUMBER
WHERE B.BOOKING_TYPE LIKE '%Gezahlte Sondertilgung auf Kapital%'
GROUP BY 
    B.ACCOUNT_NUMBER, 
    KO.CUSTOMER_NUMBER, 
    BKD.CURRENT_PRINCIPAL_BALANCE, 
    BKD.LOAN_START_DATE, 
    BKD.ORIGINAL_BALANCE,
    BKD.ANNUITY,
    BKD.CREDIT_SCORE,
    KO.SPV_TAG,
    KO.ACCOUNT_BALANCE,
    KO.CUSTOMER_NUMBER,
    K.POSTAL_CODE,
    K.SALUTATION,
    B.BOOKING_TYPE;

