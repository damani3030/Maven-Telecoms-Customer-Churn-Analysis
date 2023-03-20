-- MAVEN TELECOM  -- DATA IMPORTATION

-- First steps were to create a table to house all the data and to import the csv.

CREATE TABLE customers (
    customerid VARCHAR(50),
    gender VARCHAR(10),
    age SMALLINT,
    married BOOLEAN DEFAULT false,
    num_of_dependents SMALLINT,
    city VARCHAR(100),
    zip_code INTEGER,
    latitude NUMERIC,
    longitude NUMERIC,
    num_of_referrals SMALLINT,
    tenure_in_months SMALLINT,
    offer VARCHAR(20),
    phone_service BOOLEAN,
    avg_monthly_long_dist_charge NUMERIC,
    multiple_lines BOOLEAN,
    internet_service BOOLEAN,
    internet_type VARCHAR(20),
    avg_monthly_gb_download SMALLINT,
    online_security BOOLEAN,
    online_backup BOOLEAN,
    device_protection_plan BOOLEAN,
    premium_tech_support BOOLEAN,
    streaming_tv BOOLEAN,
    streaming_movies BOOLEAN,
    streaming_music BOOLEAN,
    unlimited_data BOOLEAN,
    contract VARCHAR(30),
    paperless_billing BOOLEAN,
    payment_method VARCHAR(30),
    monthly_charge NUMERIC, 
    total_charges NUMERIC,
    total_refunds NUMERIC,
    total_extra_data_charges NUMERIC,
    total_long_dist_charges NUMERIC,
    total_revenue NUMERIC,
    customer_status VARCHAR(20),
    churn_category VARCHAR(20),
    churn_reason TEXT
)

-- DATA CLEANING AND PREP

SELECT COUNT(DISTINCT customerid) AS customer_count
FROM customers

-- Checking for duplicates in customerid
SELECT customerid, COUNT(customerid) AS customer_count
FROM customers
GROUP BY customerid
HAVING COUNT(customerid) > 1

-- DEEP DIVE ANALYSIS

-- Looking at the general categories each gender stated why they switched companies. And looked at total revenue lost per category.

SELECT churn_category,
		gender,
		SUM(total_revenue) AS revenue_lost
FROM customers
WHERE churn_category IS NOT NULL
GROUP BY churn_category, gender
ORDER BY SUM(total_revenue) DESC

----------------------------------------------------------

-- What percentage of customers churned per category?

SELECT churn_category, 
		COUNT(churn_category) AS num_churn_reasons,
		(SELECT COUNT(churn_category) FROM customers)
 	AS total_num_churns_reasons,
 	ROUND((COUNT(churn_category) * 100) / 
 	(SELECT COUNT(customerid) FROM customers WHERE churn_category IS NOT NULL)::numeric, 2)||'%'
 	AS percent_of_users_churned_per_category 
FROM customers
WHERE churn_category IS NOT NULL
GROUP BY churn_category
ORDER BY num_churn_reasons DESC

----------------------------------------------------------

-- What are the top 10 specific reasons for losing customers

SELECT churn_reason,
		COUNT(churn_reason) AS count_reasons
FROM customers
WHERE customer_status = 'Churned' --AND churn_reason LIKE 'Competitor%'
GROUP BY churn_reason
ORDER BY count_reasons DESC
LIMIT 10

---------------------------------------------------------

-- Most popular choice of internet and offer for customers that churned

SELECT COUNT(customerid) AS num_customers, internet_type, offer
FROM customers
WHERE customer_status = 'Churned' AND internet_type IS NOT NULL
GROUP BY internet_type, offer
ORDER BY num_customers DESC

---------------------------------------------------------

-- What are the average monthly charges per contract.

SELECT contract, COUNT(contract) AS contract_count, 
		AVG(monthly_charge) AS avg_monthly_charge_per_contract
FROM customers
WHERE churn_category IS NOT NULL
GROUP BY contract
ORDER BY contract_count DESC

------------------------------------------------

-- What cities are bringing the highest revenues and their population?

SELECT city, population, SUM(total_revenue) AS total_revenue_per_zipcode
FROM customers
INNER JOIN zipcode
ON zipcode.zip_code = customers.zip_code
WHERE customer_status IN ('Stayed', 'Joined')
GROUP BY zipcode.zip_code, city
ORDER BY total_revenue_per_zipcode DESC

-----------------------------------------

--Looking for the % of monthly users that are churned

SELECT contract, customer_status,
		COUNT(customer_status) AS amount_churned,
		(SELECT COUNT(customerid) FROM customers WHERE contract = 'Month-to-Month')
		AS total_monthly_accs,
		ROUND((COUNT(customer_status) * 100) / 
	 	(SELECT COUNT(customerid) FROM customers WHERE contract LIKE 'Month%')::numeric, 2)||'%'
		AS percent_of_monthly_contract_users_churned 
FROM customers
WHERE customer_status = 'Churned' AND contract LIKE 'Month%'
GROUP BY contract, customer_status
ORDER BY contract

----------------------------------------------------------------

-- What are the average monthly and total charges for each payment method?

SELECT AVG(monthly_charge) AS avg_monthly_charge,
		SUM(total_charges) AS total_charges,
		payment_method
FROM customers
WHERE customer_status = 'Churned'
GROUP BY payment_method

-----------------------------------------


