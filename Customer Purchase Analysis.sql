/* Customer Wise Total Purchase Analysis

	Q.1 What is the total Order Count,Total Purchased Item Type,
Total Product Quantity purchased by customer spent at the restaurant?  */

WITH Customer_Extract AS (
		SELECT 
		 Customer.CustomerKey,
		 Customer.Name,
		 Customer.Gender,
		 Customer.State,
		 Customer.State_Code,
		 COUNT(DISTINCT Sales.Order_Number ) AS Order_Count,
		 COUNT(DISTINCT Sales.ProductKey ) AS Purchased_Product_Item_Type_Count,
		 SUM(Sales.Quantity) AS Total_Product_Quantity
		 FROM [BIA].[dbo].[Global_Electronics_Retailer_Customers] AS Customer
		 LEFT JOIN [BIA].[dbo].[Global_Electronics_Retailer.Sales] AS Sales
		 ON Customer.CustomerKey = Sales.CustomerKey
		 GROUP BY
		 Customer.CustomerKey,
		 Customer.Name,
		 Customer.Gender,
		 Customer.State,
		 Customer.State_Code
 ),


	Customer_Sales_Extract AS (
	SELECT
	Sales.CustomerKey,
	SUM(Products.Unit_Price_USD) AS Product_Price
	FROM [BIA].[dbo].[Global_Electronics_Retailer.Sales] AS Sales
	LEFT JOIN [BIA].[dbo].[Global_Electronics_Retailer.Products] AS Products
	ON Sales.ProductKey = Products.ProductKey
	GROUP BY
	Sales.CustomerKey
	),
	/* Q.2 Identify the New and Old Customers and No of Repeated Customers?  */

	First_Visit_Date AS 
		(

			SELECT 
				Sales.CustomerKey,
				MIN(Sales.Order_Date) AS First_Visit_Date
			FROM 
				[BIA].[dbo].[Global_Electronics_Retailer.Sales] AS Sales
			GROUP BY
				Sales.CustomerKey

		 ),

	Sales_Table AS 
		(
			SELECT
				*
			FROM
				[BIA].[dbo].[Global_Electronics_Retailer.Sales]
		),

	Is_New_Customer AS
	
	(

			SELECT 
				Sales.CustomerKey,
				(CASE WHEN SUM(CASE WHEN Sales.Order_Date = Ref_Table.First_Visit_Date THEN 0 ELSE 1 END) = 0 THEN 1 ELSE 0 END) AS First_Visit_Flag,
				SUM(CASE WHEN Sales.Order_Date = Ref_Table.First_Visit_Date THEN 0 ELSE 1 END) AS No_Of_Times_Customer_repeated
			FROM
				Sales_Table AS Sales
				LEFT JOIN First_Visit_Date AS Ref_Table
				ON Sales.CustomerKey = Ref_Table.CustomerKey
			GROUP BY
				Sales.CustomerKey
	),

	/* Q.3 Identify the Active Customers?  */

	Is_Active_Customer AS (
		SELECT 
			Sales.CustomerKey,
			MAX(Sales.Order_Date) AS Last_Purchased_Date,
			( CASE 
				WHEN DATEDIFF(MONTH, MAX(Sales.Order_Date), '2024-01-01') < 8 THEN 1 
				ELSE 0 
			END ) AS Is_Active_Customer
		FROM 
			[BIA].[dbo].[Global_Electronics_Retailer.Sales] AS Sales
		GROUP BY 
			Sales.CustomerKey
	)




SELECT

    Customer_Extract.CustomerKey,
	Customer_Extract.Name,
	Customer_Extract.Gender,
	Customer_Extract.State,
	Customer_Extract.State_Code,
	Is_New_Customer.First_Visit_Flag AS Is_New_Customer,
	Is_New_Customer.No_Of_Times_Customer_repeated AS No_Of_Times_Customer_repeated,
	Is_Active_Customer.Is_Active_Customer AS Is_Active_Customer,
	Customer_Extract.Order_Count,
	Customer_Extract.Purchased_Product_Item_Type_Count,
	Customer_Extract.Total_Product_Quantity,
	Customer_Sales_Extract.Product_Price
FROM
	Customer_Extract AS Customer_Extract
LEFT JOIN 
	Customer_Sales_Extract AS Customer_Sales_Extract
ON 
	Customer_Extract.CustomerKey = Customer_Sales_Extract.CustomerKey
LEFT JOIN 
	Is_New_Customer AS Is_New_Customer
ON 
	Customer_Extract.CustomerKey = Is_New_Customer.CustomerKey
LEFT JOIN
	Is_Active_Customer AS Is_Active_Customer
ON
	Customer_Extract.CustomerKey = Is_Active_Customer.CustomerKey 
	
ORDER BY 
	Is_New_Customer.No_Of_Times_Customer_repeated DESC


