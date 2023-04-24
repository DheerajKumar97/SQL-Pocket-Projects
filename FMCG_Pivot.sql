/****** Script for SelectTopNRows command from SSMS  ******/
WITH FMCG_ORDER_PRIORITY_CTE1 AS

			(

				SELECT
						
						[Order_ID],
						[Customer_ID],
						[Name_of_customer],
						[Product],
						[Continent],
						ISNULL([High],0)AS [High (Quantity_Sum)] ,
						ISNULL([Low],0)AS [Low (Quantity_Sum)], 
						ISNULL([Not Specified],0) AS [Not Specified (Quantity_Sum)]

				FROM
						(
							SELECT 
									[Order_ID],
									[Customer_ID],
									[Name_of_customer],
									[Product],
									[Continent],
									[Order_Priority],
									[Order_Quantity]
							FROM 
									[practice].[dbo].[FMCG_Product]
						) Pivot_input

				PIVOT
						(  
							SUM([Pivot_input].[Order_Quantity])  
							FOR [Pivot_input].[Order_Priority] IN ([High], [Low], [Not Specified])  
						) AS Pivot_Output1

			),

FMCG_ORDER_PRIORITY_CTE2 AS

			(
			SELECT 

						[Customer_ID],
						[Name_of_customer],
						[Product],
						ISNULL([High],0)AS [High (Quantity_Sum)] ,
						ISNULL([Low],0)AS [Low (Quantity_Sum)], 
						ISNULL([Not Specified],0) AS [Not Specified (Quantity_Sum)],
						ISNULL([Asia],0)AS [Asia (Order_Count)] ,
						ISNULL([Australia],0)AS [Australia (Order_Count)], 
						ISNULL([North America],0) AS [North_America_Order_Count]

			FROM 

					(

						SELECT 
									[Order_ID],
									[Customer_ID],
									[Name_of_customer],
									[Product],
									[Continent],
									ISNULL([High (Quantity_Sum)],0)AS [High] ,
									ISNULL([Low (Quantity_Sum)],0)AS [Low], 
									ISNULL([Not Specified (Quantity_Sum)],0) AS [Not Specified]

						FROM 
								FMCG_ORDER_PRIORITY_CTE1

					) Pivot_input2


				PIVOT
						(  
							COUNT([Pivot_input2].[Order_ID])  
							FOR [Pivot_input2].[Continent] IN ([Asia], [Australia], [North America])  
						) AS Pivot_Output2

			)


SELECT 


		FMCG_ORDER_PRIORITY_CTE2.[Customer_ID],
		FMCG_ORDER_PRIORITY_CTE2.[Name_of_customer],
		FMCG_ORDER_PRIORITY_CTE2.[Product],
		FMCG_Product.Preferred_Fright_Mode,
		FMCG_Product.Sub_Product,
		FMCG_Product.Business_Segment,
		FMCG_ORDER_PRIORITY_CTE2.[High (Quantity_Sum)],
		FMCG_ORDER_PRIORITY_CTE2.[Low (Quantity_Sum)],
		FMCG_ORDER_PRIORITY_CTE2.[Not Specified (Quantity_Sum)],
		FMCG_ORDER_PRIORITY_CTE2.[Asia (Order_Count)],
		FMCG_ORDER_PRIORITY_CTE2.[Australia (Order_Count)],
		FMCG_ORDER_PRIORITY_CTE2.North_America_Order_Count

FROM 
		[FMCG_ORDER_PRIORITY_CTE2] FMCG_ORDER_PRIORITY_CTE2
JOIN	
		[practice].[dbo].[FMCG_Product] FMCG_Product

ON		
		FMCG_ORDER_PRIORITY_CTE2.Customer_ID = FMCG_Product.Customer_ID



















SELECT 
		*
FROM 
		[practice].[dbo].[FMCG_Product]