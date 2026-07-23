-- 1. إنشاء قاعدة البيانات
CREATE DATABASE SuperstoreDB;
GO

USE SuperstoreDB;
GO

-- 2. إنشاء جدول المبيعات
CREATE TABLE SalesData (
     ShipMode VARCHAR(50),
     Segment VARCHAR(50),
     Country VARCHAR(50),
	 City VARCHAR(50),
     State VARCHAR(50),
     PostalCode VARCHAR(50),
     Region VARCHAR(50),
     Category VARCHAR(50),
     SubCategory VARCHAR(50),
     Sales DECIMAL(18,4),
     Quantity INT,
     Discount DECIMAL(18,4),
     Profit DECIMAL(18,4),
);
GO	

-- 3. رفع ملف الـ CSV 
BULK INSERT SalesData
FROM "C:\Users\lenovo\OneDrive\Documents\Data analyst\cv project\SQL\SampleSuperstore.csv"
WITH (
    FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = 'RAW'
)

SELECT * FROM SalesData

-- ===================================================
-- 1. KPI Overview (الملخص المالي العام)
-- ===================================================
SELECT 
     ROUND(SUM(Sales),2) AS Total_Sales,
     ROUND(SUM(Profit),2) AS Total_Profit,
     ROUND((SUM(Profit) / SUM(Sales)*100),2) AS Overall_Profit_Margin_pct,
     ROUND((AVG(discount)*100),2) AS Avg_Discount_pct
FROM SalesData


-- ===================================================
-- 2. Performance by Category & Sub-Category (الأداء حسب الفئات والمنتجات)
-- ===================================================

SELECT 
     Category,
     SubCategory,
     ROUND(SUM(Sales),2) AS Total_Sales,
     ROUND(SUM(Profit),2) AS Total_Profit,
     ROUND((SUM(Profit) / SUM(Sales)*100),2) AS Overall_Profit_Margin_pct
FROM SalesData
GROUP BY Category, SubCategory 
ORDER BY Total_Profit

-- ===================================================
-- 3. Discount vs Profitability Analysis (تأثير الخصومات على الربحية)
-- ===================================================
SELECT 
    CASE 
        WHEN Discount = 0 THEN 'No Discount (0%)'
        WHEN Discount > 0 AND Discount <= 0.20 THEN 'Low Discount (1-20%)'
        WHEN Discount > 0.20 AND Discount <= 0.50 THEN 'Medium Discount (21-50%)'
        ELSE 'High Discount (>50%)'
    END AS Discount_Band,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_pct
FROM SalesData
GROUP BY 
    CASE 
        WHEN Discount = 0 THEN 'No Discount (0%)'
        WHEN Discount > 0 AND Discount <= 0.20 THEN 'Low Discount (1-20%)'
        WHEN Discount > 0.20 AND Discount <= 0.50 THEN 'Medium Discount (21-50%)'
        ELSE 'High Discount (>50%)'
    END
ORDER BY Profit_Margin_pct DESC;


-- ===================================================
-- 4. Segment & Regional Analysis (أداء المناطق وشرائح العملاء)
-- ===================================================
SELECT 
    Region,
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_pct
FROM SalesData
GROUP BY Region, Segment
ORDER BY Region, Profit_Margin_pct DESC;


CREATE VIEW vw_Financial_Performance AS
SELECT 
    ShipMode,
    Segment,
    Country,
    City,
    State,
    Region,
    Category,
    SubCategory,
    Sales,
    Quantity,
    Discount,
    Profit,
    (Sales - Profit) AS Total_Cost, -- حساب التكلفة الإجمالية
    CASE WHEN Profit < 0 THEN 'Loss' ELSE 'Profit' END AS Profit_Status
FROM SalesData;
GO