--Data Cleaning
--1. Products Table
--Check for Duplicates

-- Identify duplicate rows in Products table
SELECT Product_ID, COUNT(*) AS DuplicateCount
FROM Products
GROUP BY Product_ID
HAVING COUNT(*) > 1;

--There is no Duplicate Value but if you find we ducplicate value then used following query for removing duplicate value

-- Remove duplicate rows from Products table
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_ID) AS RowNum
    FROM Products
)
DELETE FROM CTE WHERE RowNum > 1;

--Check for Missing or Invalid Values

-- Find missing values in Products table
SELECT *
FROM Products
WHERE Product_ID IS NULL 
   OR Product_Name IS NULL 
   OR Product_Category IS NULL 
   OR Product_Cost IS NULL 
   OR Product_Price IS NULL;

-- Find negative costs or prices in Products table
SELECT *
FROM Products
WHERE Product_Cost < 0 OR Product_Price < 0;

-- Find cases where Product_Price < Product_Cost
SELECT *
FROM Products
WHERE Product_Price < Product_Cost;

--2. Inventory Table
--Check for Duplicates

-- Identify duplicate rows in Inventory table
SELECT Store_ID, Product_ID, COUNT(*) AS DuplicateCount
FROM Inventory
GROUP BY Store_ID, Product_ID
HAVING COUNT(*) > 1;

--There is also no Duplicate Value but if you find we ducplicate value then used following query for removing duplicate value

-- Remove duplicate rows from Inventory table
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Store_ID, Product_ID ORDER BY Store_ID, Product_ID) AS RowNum
    FROM Inventory
)
DELETE FROM CTE WHERE RowNum > 1;

--Check for Missing or Invalid Values

-- Find missing values in Inventory table
SELECT *
FROM Inventory
WHERE Store_ID IS NULL OR Product_ID IS NULL OR Stock_On_Hand IS NULL;

-- Find negative Stock_On_Hand values in Inventory table
SELECT *
FROM Inventory
WHERE Stock_On_Hand < 0;

--3. Stores Table
--Check for Duplicates

-- Identify duplicate rows in Stores table
SELECT Store_ID, COUNT(*) AS DuplicateCount
FROM Stores
GROUP BY Store_ID
HAVING COUNT(*) > 1;

--There is also no Duplicate Value but if we find ducplicate value then used following query for removing duplicate value

-- Remove duplicate rows from Stores table
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Store_ID ORDER BY Store_ID) AS RowNum
    FROM Stores
)
DELETE FROM CTE WHERE RowNum > 1;

--Check for Missing or Invalid Values

-- Find missing values in Stores table
SELECT *
FROM Stores
WHERE Store_ID IS NULL 
   OR Store_Name IS NULL 
   OR Store_City IS NULL 
   OR Store_Location IS NULL 
   OR Store_Open_Date IS NULL;

-- Find future open dates in Stores table
SELECT *
FROM Stores
WHERE Store_Open_Date > GETDATE();

--4. Sales Table
--Check for Duplicates

-- Identify duplicate rows in Sales table
SELECT Sale_ID, COUNT(*) AS DuplicateCount
FROM Sales
GROUP BY Sale_ID
HAVING COUNT(*) > 1;

--It's also no Duplicate Value but if we find ducplicate value then used following query for removing duplicate value

-- Remove duplicate rows from Sales table
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Sale_ID ORDER BY Sale_ID) AS RowNum
    FROM Sales
)
DELETE FROM CTE WHERE RowNum > 1;

--Check for Missing or Invalid Values

-- Find missing values in Sales table
SELECT *
FROM Sales
WHERE Sale_ID IS NULL OR Date IS NULL OR Store_ID IS NULL 
   OR Product_ID IS NULL OR Units IS NULL;

-- Find negative Units in Sales table
SELECT *
FROM Sales
WHERE Units < 0;

--5. Calendar Table
--Check for Duplicates

-- Identify duplicate rows in Calendar table
SELECT Date, COUNT(*) AS DuplicateCount
FROM Calendar
GROUP BY Date
HAVING COUNT(*) > 1;

--There is no any duplivate value is here

-- Remove duplicate rows from Calendar table
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Date ORDER BY Date) AS RowNum
    FROM Calendar
)
DELETE FROM CTE WHERE RowNum > 1;

--Check for Missing Dates

-- Find missing dates in Calendar table
SELECT *
FROM Calendar
WHERE Date IS NULL;

-- First Analysis

-- Monthly Sales Trend Comparison Between 2022 and 2023
SELECT 
    YEAR(s.Date) AS Sales_Year,
    MONTH(s.Date) AS Sales_Month,
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    SUM(s.Units * p.Product_Price) AS Total_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
JOIN 
    Stores st ON s.Store_ID = st.Store_ID
JOIN 
    Calendar c ON s.Date = c.Date
WHERE 
    YEAR(s.Date) IN (2022, 2023) -- Filter for years 2022 and 2023
GROUP BY 
    YEAR(s.Date),
    MONTH(s.Date),
    st.Store_Name,
    st.Store_City,
    st.Store_Location
ORDER BY 
    Sales_Year,
    Sales_Month,
    st.Store_Name;

-- Monthly Sales Comparison Between 2022 and 2023
SELECT 
    YEAR(s.Date) AS Sales_Year,
    MONTH(s.Date) AS Sales_Month,
    SUM(s.Units * p.Product_Price) AS Monthly_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
WHERE 
    YEAR(s.Date) IN (2022, 2023) -- Filter for years 2022 and 2023
GROUP BY 
    YEAR(s.Date),
    MONTH(s.Date)
ORDER BY 
    Sales_Year,
    Sales_Month;

-- Quarterly Sales Comparison Between 2022 and 2023
SELECT 
    YEAR(s.Date) AS Sales_Year,
    DATEPART(QUARTER, s.Date) AS Sales_Quarter,
    SUM(s.Units * p.Product_Price) AS Quarterly_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
WHERE 
    YEAR(s.Date) IN (2022, 2023) -- Filter for years 2022 and 2023
GROUP BY 
    YEAR(s.Date),
    DATEPART(QUARTER, s.Date)
ORDER BY 
    Sales_Year,
    Sales_Quarter;

--Second Analysis

-- Sales Trend Over Different Stores and Best and Least Five Performing Stores
SELECT 
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    SUM(s.Units * p.Product_Price) AS Total_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
JOIN 
    Stores st ON s.Store_ID = st.Store_ID
WHERE 
    YEAR(s.Date) = 2023  -- Year for which sales trend is needed
GROUP BY 
    st.Store_Name,
    st.Store_City,
    st.Store_Location
ORDER BY 
    Total_Sales DESC;  -- Sort in descending order to get best performing stores first

-- Top 5 Best Performing Stores
SELECT TOP 5
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    SUM(s.Units * p.Product_Price) AS Total_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
JOIN 
    Stores st ON s.Store_ID = st.Store_ID
WHERE 
    YEAR(s.Date) = 2023
GROUP BY 
    st.Store_Name,
    st.Store_City,
    st.Store_Location
ORDER BY 
    Total_Sales DESC;  -- Display top 5 performing stores

-- Bottom 5 Least Performing Stores
SELECT TOP 5
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    SUM(s.Units * p.Product_Price) AS Total_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
JOIN 
    Stores st ON s.Store_ID = st.Store_ID
WHERE 
    YEAR(s.Date) = 2023
GROUP BY 
    st.Store_Name,
    st.Store_City,
    st.Store_Location
ORDER BY 
    Total_Sales ASC;  -- Display bottom 5 performing stores

-- Stores Performing Better than Last Year (2022 vs. 2023)
SELECT 
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    SUM(CASE WHEN YEAR(s.Date) = 2023 THEN s.Units * p.Product_Price ELSE 0 END) AS Sales_2023,
    SUM(CASE WHEN YEAR(s.Date) = 2022 THEN s.Units * p.Product_Price ELSE 0 END) AS Sales_2022
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
JOIN 
    Stores st ON s.Store_ID = st.Store_ID
WHERE 
    YEAR(s.Date) IN (2022, 2023)  -- Filter for 2022 and 2023
GROUP BY 
    st.Store_Name,
    st.Store_City,
    st.Store_Location
HAVING 
    SUM(CASE WHEN YEAR(s.Date) = 2023 THEN s.Units * p.Product_Price ELSE 0 END) > 
    SUM(CASE WHEN YEAR(s.Date) = 2022 THEN s.Units * p.Product_Price ELSE 0 END)  -- Compare 2023 vs 2022
ORDER BY 
    Sales_2023 DESC;  -- Sort stores based on performance in 2023

--Third Analysis

-- Products Performing Well and Contributing Most to Sales
SELECT 
    p.Product_Name,
    p.Product_Category,
    SUM(s.Units * p.Product_Price) AS Total_Sales
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
GROUP BY 
    p.Product_Name,
    p.Product_Category
ORDER BY 
    Total_Sales DESC;  -- Sort to show the highest performing products first


-- Half-Yearly Sales Comparison Based on Max Date
WITH HalfYearSales AS (
    SELECT 
        YEAR(s.Date) AS Sales_Year,
        CASE 
            WHEN MONTH(s.Date) BETWEEN 1 AND 6 THEN 'H1'  -- First half of the year (Jan-June)
            ELSE 'H2'  -- Second half of the year (July-Dec)
        END AS Half_Year,
        SUM(s.Units * p.Product_Price) AS Total_Sales
    FROM 
        Sales s
    JOIN 
        Products p ON s.Product_ID = p.Product_ID
    WHERE 
        s.Date <= (SELECT MAX(Date) FROM Sales)  -- Max date of sales data
    GROUP BY 
        YEAR(s.Date),
        CASE 
            WHEN MONTH(s.Date) BETWEEN 1 AND 6 THEN 'H1'
            ELSE 'H2'
        END
)
SELECT 
    Sales_Year,
    Half_Year,
    Total_Sales
FROM 
    HalfYearSales
ORDER BY 
    Sales_Year DESC, 
    Half_Year DESC;

-- High Demand Product Among All Locations as per the Sales
SELECT 
    p.Product_Name,
    p.Product_Category,
    SUM(s.Units) AS Total_Units_Sold
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
JOIN 
    Stores st ON s.Store_ID = st.Store_ID
GROUP BY 
    p.Product_Name,
    p.Product_Category
ORDER BY 
    Total_Units_Sold DESC  -- Show the most demanded product first


--Fourth Analysis
-- Average Inventory as per Store and Product
SELECT 
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    p.Product_Name,
    p.Product_Category,
    AVG(i.Stock_On_Hand) AS Avg_Inventory
FROM 
    Inventory i
JOIN 
    Stores st ON i.Store_ID = st.Store_ID
JOIN 
    Products p ON i.Product_ID = p.Product_ID
GROUP BY 
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    p.Product_Name,
    p.Product_Category
ORDER BY 
    st.Store_Name, p.Product_Name;

-- Inventory Turnover Ratio with Average Inventory Comparison by Store
SELECT 
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    p.Product_Name,
    p.Product_Category,
    AVG(i.Stock_On_Hand) AS Avg_Inventory,
    SUM(s.Units * p.Product_Cost) AS COGS,  -- Assuming Product_Cost is used for COGS
    CASE 
        WHEN AVG(i.Stock_On_Hand) = 0 THEN 0  -- If average inventory is zero, set turnover ratio to 0
        ELSE (SUM(s.Units * p.Product_Cost) / AVG(i.Stock_On_Hand)) 
    END AS Inventory_Turnover_Ratio
FROM 
    Inventory i
JOIN 
    Stores st ON i.Store_ID = st.Store_ID
JOIN 
    Products p ON i.Product_ID = p.Product_ID
JOIN 
    Sales s ON s.Product_ID = p.Product_ID
WHERE 
    i.Store_ID = s.Store_ID  -- Ensure matching store IDs for both inventory and sales
GROUP BY 
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    p.Product_Name,
    p.Product_Category
ORDER BY 
    Inventory_Turnover_Ratio DESC, st.Store_Name, p.Product_Name;
