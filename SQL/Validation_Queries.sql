use AdventureWorksDW2019
go

declare @Year_Number INT=2013
declare @InternetSales decimal(16,2),
@ResellerSales decimal(16,2), 
@InternetOrders int,@ResellerOrders int
,@Internet_Unitssold int, 
@Reseller_Unitssold int, 
@Internet_GP decimal(16,2),
@Reseller_GP decimal(16,2)

/*
-- Commas and 2 decimal places
SELECT FORMAT(49926384.50, 'N2');
-- 49,926,384.50

-- Commas and no decimals
SELECT FORMAT(49926384.50, 'N0');
-- 49,926,385

-- Currency
SELECT FORMAT(49926384.50, 'C2', 'en-US');
-- $49,926,384.50

-- Percentage
SELECT FORMAT(0.4669, 'P2');
-- 46.69%
*/

/* FactInternetSales */
select
@ResellerSales= sum(SalesAmount)
,@ResellerOrders= count(distinct SalesOrderNumber)
,@Reseller_Unitssold = sum(OrderQuantity)
,@Reseller_GP=sum(SalesAmount) - sum(TotalProductCost)
from FactResellerSales where year(OrderDate) = @Year_Number

	drop table #Sales
	select
	'InternetSales' as 'Data_Source'
	,dt.CalendarYear as 'Year_Number'
	,dt.MonthNumberOfYear as 'Month_Number'
	,pc.EnglishProductCategoryName as 'Category'
	,psc.EnglishProductSubcategoryName as 'Subcategory'
	,p.EnglishProductName as 'ProductName'
	,fi.ProductKey
	,SalesAmount
	,SalesOrderNumber
	,OrderQuantity
	,SalesAmount - TotalProductCost as 'Gross Profit'
	,fi.CustomerKey as Customerkey_ResellerKey
	,'' as 'ResellerName'
	,convert(varchar(5),fi.CustomerKey) + ' ' + cst.LastName + ' ' + cst.FirstName as 'Customer_Name'	
	,TotalProductCost
	,'' 'Salesperson'
	,0 as SalespersonKey
	,spt.SalesTerritoryCountry
	,spt.SalesTerritoryGroup
	,spt.SalesTerritoryRegion
	into #Sales
	from FactInternetSales fi
	left join DimDate dt on fi.OrderDateKey=dt.DateKey
	left join DimProduct p on fi.ProductKey=p.ProductKey
	left join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
	left join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
	left join DimCustomer cst on fi.CustomerKey=cst.CustomerKey	
	inner join DimSalesTerritory spt on fi.SalesTerritoryKey=spt.SalesTerritoryKey
	where year(fi.OrderDate) in(2011,2012,2013)

	union all
	select
	'ResellerSales' as 'Data_Source'
	,dt.CalendarYear as 'Year_Number'
	,dt.MonthNumberOfYear as 'Month_Number'
	,pc.EnglishProductCategoryName as 'Category'
	,psc.EnglishProductSubcategoryName as 'Subcategory'
	,p.EnglishProductName as 'ProductName'
	,fi.ProductKey
	,SalesAmount
	,SalesOrderNumber
	,OrderQuantity
	,SalesAmount - TotalProductCost as 'Gross Profit'
	,fi.ResellerKey as Customerkey_ResellerKey
	,rs.ResellerName as 'ResellerName'
	,rs.ResellerName as 'Customer_Name'	
	,TotalProductCost
	,convert(varchar(50),fi.EmployeeKey) + ' ' + ep.LastName + ' ' + ep.FirstName as 'Salesperson'
	,fi.EmployeeKey as SalespersonKey
	,spt.SalesTerritoryCountry
	,spt.SalesTerritoryGroup
	,spt.SalesTerritoryRegion
	from FactResellerSales fi
	left join DimDate dt on fi.OrderDateKey=dt.DateKey
	left join DimProduct p on fi.ProductKey=p.ProductKey
	left join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
	left join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
	left join DimReseller rs on fi.ResellerKey=rs.ResellerKey
	inner join DimEmployee ep on fi.EmployeeKey=ep.EmployeeKey and ep.SalesPersonFlag=1
	inner join DimSalesTerritory spt on fi.SalesTerritoryKey=spt.SalesTerritoryKey
	where year(fi.OrderDate) in(2011,2012,2013)
	;

/* Executive Summary */	
	select
	'Executive Summary Page' as 'Power BI Page',
	Year_Number
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Sales_Amount'
	,FORMAT((select sum(SalesAmount) from #Sales b where a.Year_Number=b.Year_Number and Data_Source='InternetSales'), 'C0', 'en-US') as 'Internet Sales'
	,FORMAT((select sum(SalesAmount) from #Sales b where a.Year_Number=b.Year_Number and Data_Source='ResellerSales'), 'C0', 'en-US') as 'Reseller Sales'
	,FORMAT(count(distinct SalesOrderNumber),'N0') as  'Total_Orders'
	,FORMAT(sum(OrderQuantity),'N0') as 'Units_Sold'
	,FORMAT((select count(distinct Customerkey_ResellerKey) from #Sales b where a.Year_Number=b.Year_Number and Data_Source='InternetSales'), 'N0') as 'Internet Customers'
	,FORMAT((select count(distinct Customerkey_ResellerKey) from #Sales b where a.Year_Number=b.Year_Number and Data_Source='ResellerSales'), 'N0') as 'Active Reseller'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross_Profit'
	,FORMAT(count(distinct Customerkey_ResellerKey), 'N0') as 'Customer_Count'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total_Product_Cost'
	,FORMAT(sum(SalesAmount)/sum(OrderQuantity), 'C2', 'en-US') as 'Average Selling Price'
	,FORMAT((select sum(SalesAmount)/count(distinct SalesOrderNumber) from #Sales b where a.Year_Number=b.Year_Number and Data_Source='InternetSales'), 'C2', 'en-US') as 'Internet AOV'
	,FORMAT((select sum(SalesAmount)/count(distinct SalesOrderNumber) from #Sales b where a.Year_Number=b.Year_Number and Data_Source='ResellerSales'), 'C2', 'en-US') as 'Reseller AOV'	
	from #Sales a
	where Year_Number in(2012,2013)
	group by
	Year_Number
	order by 
	Year_Number desc
	;

	/* Total Unique Products*/
	select
		Year_Number,count(distinct ProductKey) as 'Total Products Sold'
	from #Sales
	where Year_Number in(2012,2013)
	group by Year_Number
	order by Year_Number desc;

/*
Total Sales by Category
*/
	select
	'Total Sales by Category' as 'Data_Source',
	Year_Number
	,Category
	,round(sum(SalesAmount),0)  as 'SalesAmount'	
	from #Sales a
	where Year_Number=2013
	group by
	Year_Number
	,Category
	order by 
	Year_Number desc, SalesAmount desc;

	/* Top 5 Sales by Subcategory */
	select top 5
	'Top 5 Sales by Subcategory' as 'Data_Source',
	Year_Number
	,Subcategory
	,round(sum(SalesAmount),0)  as 'SalesAmount'	
	from #Sales a
	where Year_Number=2013
	group by
	Year_Number
	,Subcategory
	order by 
	Year_Number desc, SalesAmount desc;

	/* Top 5 Sales by Product */
	select top 5
	'Top 5 Sales by Product' as 'Data_Source',
	Year_Number
	,ProductName
	,round(sum(SalesAmount),0)  as 'SalesAmount'	
	from #Sales a
	where Year_Number=2013
	group by
	Year_Number
	,ProductName
	order by 
	Year_Number desc, SalesAmount desc;

	/* Top 10 Internet Customers by Sales */
	select top 10
	'Top 10 Internet Customers by Sales' as 'Data_Source',
	Year_Number
	,Customer_Name
	,round(sum(SalesAmount),0)  as 'SalesAmount'	
	from #Sales a
	where Year_Number=2013 and [Data_Source]='InternetSales'
	group by
	Year_Number
	,Customer_Name
	order by 
	Year_Number desc, SalesAmount desc;

	/* Top 10 Active Resellers by Sales */
	select top 10
	'Top 10 Active Resellers by Sales' as 'Data_Source',
	Year_Number
	,Customer_Name
	,round(sum(SalesAmount),0)  as 'SalesAmount'	
	from #Sales a
	where Year_Number=2013 and [Data_Source]='ResellerSales'
	group by
	Year_Number
	,Customer_Name
	order by 
	Year_Number desc, SalesAmount desc;

/* Profitability Analysis Page */

--KPI
select
	'Profitability Analysis Page' as 'Power BI Page',
	Year_Number
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total Product Cost'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross Profit'
	,FORMAT((sum(SalesAmount) - sum(TotalProductCost))/sum(SalesAmount), 'P2') as 'Gross Profit Margin%'

	,FORMAT(sum(case when Data_Source='InternetSales' then SalesAmount else 0 end) - 
	sum(case when Data_Source='InternetSales' then TotalProductCost else 0 end), 'C0', 'en-US') as 'InternetSales Gross Profit'
	,FORMAT((sum(case when Data_Source='InternetSales' then SalesAmount else 0 end) - 
	sum(case when Data_Source='InternetSales' then TotalProductCost else 0 end))
	/sum(case when Data_Source='InternetSales' then SalesAmount else 0 end), 'P2') as 'InternetSales Profit Margin%'

	,FORMAT(sum(case when Data_Source='ResellerSales' then SalesAmount else 0 end) - 
	sum(case when Data_Source='ResellerSales' then TotalProductCost else 0 end), 'C0', 'en-US') as 'Reseller Gross Profit'
	,FORMAT((sum(case when Data_Source='ResellerSales' then SalesAmount else 0 end) - 
	sum(case when Data_Source='ResellerSales' then TotalProductCost else 0 end))
	/sum(case when Data_Source='ResellerSales' then SalesAmount else 0 end), 'P2') as 'Reseller Profit Margin%'
	from #Sales a
	where Year_Number in(2012,2013)
	group by
	Year_Number
	order by 
	Year_Number desc;

--Gross Profit by Category
declare @Gross_Profit_2013 decimal(16,0)
Select @Gross_Profit_2013= sum(SalesAmount) - sum(TotalProductCost) from #Sales where Year_Number in(2013);
select
	'Profitability Analysis Page' as 'Power BI Page',
	Category
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total Product Cost'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross Profit'
	,@Gross_Profit_2013 as 'Total Gross Profit'
	,FORMAT((sum(SalesAmount) - sum(TotalProductCost))/@Gross_Profit_2013, 'P2') as 'Gross Profit Margin%'
	from #Sales a
	where Year_Number in(2013)
	group by
	Category;

--Top 5 Gross Profit by Subcategory
	select Top 5
	'Profitability Analysis Page' as 'Power BI Page',
	Subcategory
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total Product Cost'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross Profit'
	from #Sales a
	where Year_Number in(2013)
	group by
	Subcategory
	order by (sum(SalesAmount) - sum(TotalProductCost)) desc
	;

--Top 5 Gross Profit by Product
	select Top 5
	'Profitability Analysis Page' as 'Power BI Page',
	ProductName
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total Product Cost'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross Profit'
	from #Sales a
	where Year_Number in(2013)
	group by
	ProductName
	order by (sum(SalesAmount) - sum(TotalProductCost))
	;

--Bottom 5 Products by Gross Profit
	select Top 5
	'Profitability Analysis Page' as 'Power BI Page',
	ProductName
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total Product Cost'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross Profit'
	from #Sales a
	where Year_Number in(2013)
	group by
	ProductName
	order by (sum(SalesAmount) - sum(TotalProductCost))
	; 

--Bottom 5 Products by Margin %
	select Top 5
	'Profitability Analysis Page' as 'Power BI Page',
	ProductName
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT(sum(TotalProductCost), 'C0', 'en-US') as 'Total Product Cost'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross Profit'
	,FORMAT((sum(SalesAmount) - sum(TotalProductCost))/sum(SalesAmount), 'P2') as 'Gross Profit Margin%'
	from #Sales a
	where Year_Number in(2013)
	group by
	ProductName
	order by (sum(SalesAmount) - sum(TotalProductCost))/sum(SalesAmount)
	; 

/*Product & Sales Page*/

drop table #py_products
drop table #cy_products
select distinct productkey into #py_products from #Sales where Year_Number=2012
select distinct productkey into #cy_products from #Sales where Year_Number=2013

declare @new_products int
declare @products_not_sold int
declare @consistently_not_sold int
select @new_products = count(productkey) 
from ( select productkey from #cy_products except select productkey from #py_products
) t;
select @products_not_sold = count(productkey) 
from ( select productkey from #py_products  except select productkey from #cy_products
) t;

select @consistently_not_sold = count(productkey) 
from ( select productkey from #cy_products intersect select productkey from #py_products
) t;
select @products_not_sold = count(productkey) 
from ( select productkey from #py_products  intersect select productkey from #cy_products
) t;

select Year_Number
,sum([SalesAmount]) as 'Total Sales' 
,count(distinct ProductKey) as 'Total Products Sold'
,count(distinct case when Data_Source='InternetSales' then ProductKey end) as 'Internet Products Sold'
,count(distinct case when Data_Source='ResellerSales' then ProductKey end) as 'Reseller Products Sold' 
,sum(OrderQuantity) as 'Units Sold'
,sum([SalesAmount])/sum(OrderQuantity) as 'Average Selling Price' 
,case when year_number <> 2011 then @consistently_not_sold end as 'Consistently Sold Products'
,case when year_number=2013 then @new_products end as 'Products Newly Sold vs PY'
,case when year_number=2012 then @products_not_sold end as 'Products Not Sold vs PY'
from #Sales
group by Year_Number order by Year_Number desc;


drop table #CY_Top5_products
select top 5 ProductName, sum([SalesAmount]) as 'Combined Sales'
into #CY_Top5_products
from #Sales where Year_Number=2013
group by ProductName
order by [Combined Sales] desc;
select '2013' as Year_Number,* from #CY_Top5_products;

select top 5 '2012' as Year_Number,ProductName, sum([SalesAmount]) as 'Combined Sales'
from #Sales a
where a.Year_Number=2012
and exists(select 1 from  #Sales b where a.ProductName=b.ProductName)
group by ProductName
order by [Combined Sales] desc;

select Year_Number,Data_Source,Category, sum([SalesAmount]) as 'Combined Sales'
from #Sales a
where a.Year_Number=2013
group by Year_Number,Data_Source,Category
order by [Combined Sales] desc;

/* Top 5 Sales by Subcategory */
select top 5 Subcategory, sum([SalesAmount]) as 'Combined Sales'
from #Sales where Year_Number=2013
group by Subcategory
order by [Combined Sales] desc;


/* Customer Performance Page */

drop table #InternetSales_Customers
select distinct 
Year_Number
,Customerkey_ResellerKey as CustomerKey
,Customer_Name
,sum(SalesAmount) as 'Internet Sales'
into #InternetSales_Customers
from #Sales
where Year_Number  in(2012,2013) and [Data_Source]='InternetSales'
group by
Year_Number
,Customerkey_ResellerKey
,Customer_Name
;

select count(distinct customerkey) from #InternetSales_Customers;

drop table #py
drop table #cy
select * into #py from #InternetSales_Customers a where Year_Number=2012
select * into #cy from #InternetSales_Customers a where Year_Number=2013

declare @PY_Total_Customers decimal(16,4)
declare @CY_Total_Customers decimal(16,4)
declare @CY_Total_Revenue decimal(16,4)
select @PY_Total_Customers=count(distinct CustomerKey) from #py where Year_Number=2012;
select @CY_Total_Customers=count(distinct CustomerKey) from #cy where Year_Number=2013;
select @CY_Total_Revenue = sum([SalesAmount]) from #Sales where Year_Number=2013 and [Data_Source]='InternetSales';

select 
@CY_Total_Revenue as 'Total_Revenue',@CY_Total_Customers as 'Internet Customer'
,FORMAT(@CY_Total_Revenue/@CY_Total_Customers, 'P2') as 'Average Revenue /  Customer';

select 
'New Customers' as 'Customer Type',
count(distinct CustomerKey) as 'New Customers'
,Format(count(distinct CustomerKey)/@CY_Total_Customers, 'P2') as 'Rate'
, Format(0, 'P2') as 'Retention Rate'
from (
select CustomerKey from #cy 
except
select CustomerKey from #py
)t --New Customers
union all
select 
'Returning Customers' as 'Customer Type',
count(distinct CustomerKey) as 'Returning Customers'
,Format(count(distinct CustomerKey)/@CY_Total_Customers, 'P2') as 'Rate'
,Format(count(distinct CustomerKey)/@PY_Total_Customers, 'P2')as 'Retention Rate'
from (
select CustomerKey  from #cy 
intersect
select CustomerKey from #py)t --Returning Customers
union all
select 
'Lost Customers' as 'Customer Type',
count(distinct CustomerKey) as 'Lost Customers'
,Format(count(distinct CustomerKey)/@PY_Total_Customers, 'P2') as 'Rate'
, Format(0, 'P2') as 'Retention Rate'
from (
select CustomerKey from #py 
except
select CustomerKey  from #cy) t; --Lost Customers

drop table #CY_Top5_Customers
select top 5 * into #CY_Top5_Customers from #InternetSales_Customers
where Year_Number=2013 order by [Internet Sales] desc;

select * from #CY_Top5_Customers;
select top 5 a.* from #InternetSales_Customers a
where a.Year_Number=2012
and exists(select 1 from  #CY_Top5_Customers b where a.Customer_Name=b.Customer_Name)
order by a.[Internet Sales] desc
;

--/* Salesperson Performance */

drop table #Salesperson;
select * into #Salesperson from #sales where Year_Number <>2011 and Data_Source='ResellerSales';

-- KPI
select Year_Number
,sum([SalesAmount]) as 'Reseller Sales' 
,count(distinct ProductKey) as 'Total Products Sold'
,count(distinct case when Data_Source='ResellerSales' then ProductKey end) as 'Total Products Sold'
,count(distinct SalesOrderNumber) as 'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum([SalesAmount])/sum(OrderQuantity) as 'Average Selling Price'
,Format(sum([SalesAmount])/ count(distinct SalespersonKey), 'C0', 'en-US') as 'Sales per Salesperson'
,count(distinct Customerkey_ResellerKey) as 'Active Resellers'
,Format(sum([SalesAmount])/ count(distinct SalesOrderNumber), 'C0', 'en-US') as 'Reseller AOV'
,Format(case when year_number=2013 then 
(	count(distinct Customerkey_ResellerKey)/
	cast(Lead(count(distinct Customerkey_ResellerKey)) over( Order by Year_Number desc) as decimal(9,4))
)-1 end, 'P2') as 'Active Resellers YoY %'
,Format(case when year_number=2013 then 
(	count(distinct SalesOrderNumber)/
	cast(Lead(count(distinct SalesOrderNumber)) over( Order by Year_Number desc) as decimal(9,4))
)-1 end, 'P2') as 'Reseller Orders YoY %'
from #Salesperson
group by Year_Number 
order by Year_Number desc;

drop table #cy_salesperson;
select top 5 Year_Number,Salesperson, sum(SalesAmount) as SalesAmount into #cy_salesperson 
from #Salesperson where Year_Number=2013
group by Year_Number,Salesperson order by [SalesAmount] desc;

select 
'Top 5 Salespeople by Sales — CY vs PY' as 'Data_Source',
	* 
from #cy_salesperson 
;
select top 5 'Top 5 Salespeople by Sales — CY vs PY' as 'Data_Source',
Year_Number,Salesperson, sum(SalesAmount) as SalesAmount  from #Salesperson a 
where Year_Number=2012 
and exists(select 1 from #cy_salesperson b where a.Salesperson=b.Salesperson)
 group by Year_Number,Salesperson order by [SalesAmount] desc;

 --Active Resellers by Salesperson
	select 
		Year_Number
		,count(distinct Customerkey_ResellerKey) as 'Active Resellers'
		,Salesperson
		,sum(SalesAmount) as SalesAmount
	from #Salesperson
	where Year_Number=2013
	group by Year_Number,Salesperson
	order by [Active Resellers] desc;

--Salesperson Sales Contribution %
	declare @salesperson_total_sales decimal(16,0)
	select @salesperson_total_sales=sum(SalesAmount) from #Salesperson where Year_Number=2013;
	select @salesperson_total_sales;

	select 
	Year_Number
	,count(distinct Customerkey_ResellerKey) as 'Active Resellers'
	,Salesperson
	,sum(SalesAmount) as 'Total Sales'
	,@salesperson_total_sales as 'Grand Total Sales'
	,Format((sum(SalesAmount)/@salesperson_total_sales),'P2') as 'Salesperson Contribution %'
	from #Salesperson
	where Year_Number=2013
	group by Year_Number,Salesperson
	order by (sum(SalesAmount)/@salesperson_total_sales) desc;

--Reseller Sales by Territory
	select 
		Year_Number
		,count(distinct Customerkey_ResellerKey) as 'Active Resellers'
		,SalesTerritoryRegion
		,sum(SalesAmount) as SalesAmount
	from #Salesperson
	where Year_Number=2013
	group by Year_Number,SalesTerritoryRegion
	order by [Active Resellers] desc;

--Region & Territory
	--KPI

	select
	'Region & Territory Page' as 'Power BI Page',
	Year_Number
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Total Sales'
	,FORMAT((	select sum(SalesAmount) 
				from #Sales b 
				where a.Year_Number=b.Year_Number
				and Data_Source='InternetSales'
			), 'C0', 'en-US') as 'Internet Sales'
	,FORMAT((	select sum(SalesAmount)
				from #Sales b
				where a.Year_Number=b.Year_Number
				and Data_Source='ResellerSales'
			), 'C0', 'en-US') as 'Reseller Sales'
	,FORMAT(count(distinct SalesOrderNumber),'N0') as  'Total_Orders'
	,FORMAT(sum(OrderQuantity),'N0') as 'Units_Sold'	
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross_Profit'		
	,FORMAT(round((sum(SalesAmount) - sum(TotalProductCost)),0)/round(sum(SalesAmount),0),'P2') as 'Profit Margin YoY %'
	,Format(case when year_number=2013 then 
	(	sum(SalesAmount)-
		cast(Lead(sum(SalesAmount)) over( Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(sum(SalesAmount))   over( Order by Year_Number desc) as decimal(16,4)) end, 'P2') as 'Sales YoY %'
	,Format(case when year_number=2013 then 
	(	count(distinct SalesOrderNumber)-
		cast(Lead(count(distinct SalesOrderNumber)) over( Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(count(distinct SalesOrderNumber))   over( Order by Year_Number desc) as decimal(16,4)) end, 'P2') as 'Orders YoY %'
	,Format(case when year_number=2013 then 
	(	sum(OrderQuantity)-
		cast(Lead(sum(OrderQuantity)) over( Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(sum(OrderQuantity))   over( Order by Year_Number desc) as decimal(16,4)) end, 'P2') as 'Units Sold YoY %'
	,Format(case when year_number=2013 then 
	(	sum(case when Data_Source='InternetSales' then SalesAmount else 0 end)-
		cast(Lead(sum(case when Data_Source='InternetSales' then SalesAmount else 0 end)) over( Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(sum(case when Data_Source='InternetSales' then SalesAmount else 0 end))   over( Order by Year_Number desc) as decimal(16,4)) end, 'P2') as 'Internet Sales YoY %'
	,Format(case when year_number=2013 then 
	(	sum(case when Data_Source='ResellerSales' then SalesAmount else 0 end)-
		cast(Lead(sum(case when Data_Source='ResellerSales' then SalesAmount else 0 end)) over( Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(sum(case when Data_Source='ResellerSales' then SalesAmount else 0 end))   over( Order by Year_Number desc) as decimal(16,4)) end, 'P2') as 'Reseller Sales YoY %'
		
	from #Sales a
	where Year_Number in(2012,2013)
	group by
	Year_Number 
	;

	--Internet vs Reseller Sales by Territory
	select 
		Data_Source
		,SalesTerritoryRegion
		,sum(SalesAmount) as SalesAmount
	from #Sales
	where Year_Number in(2013)
	group by Data_Source,SalesTerritoryRegion
	order by SalesTerritoryRegion,SalesAmount desc;

	--Total Sales by Territory
	select 
		Year_Number
		,SalesTerritoryRegion
		,sum(SalesAmount) as SalesAmount
	from #Sales
	where Year_Number=2013
	group by Year_Number,SalesTerritoryRegion
	order by SalesAmount desc;
	
	declare @Territory_total_sales decimal(16,0)
	select @Territory_total_sales=sum(SalesAmount) from #Salesperson where Year_Number=2013;

	--Profit Margin % by Territory
	select
	'Region & Territory Page' as 'Power BI Page',
	Year_Number
	,SalesTerritoryRegion
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Sales_Amount'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross_Profit'		
	,FORMAT((sum(SalesAmount) - sum(TotalProductCost))/sum(SalesAmount),'P2') as 'Profit Margin YoY %'
	from #Sales a
	where Year_Number in(2013)
	group by
	Year_Number
	,SalesTerritoryRegion
	order by 
	(sum(SalesAmount) - sum(TotalProductCost))/sum(SalesAmount) desc
	;

	--Sales YoY % by Territory
	drop table #SalesYoYbyTerritory
	select
	'Region & Territory Page' as 'Power BI Page',
	Year_Number
	,SalesTerritoryRegion
	,sum(SalesAmount) as SalesAmount_1
	,FORMAT(sum(SalesAmount), 'C0', 'en-US') as 'Sales_Amount'
	,FORMAT(sum(SalesAmount) - sum(TotalProductCost), 'C0', 'en-US') as 'Gross_Profit'		
	,FORMAT((sum(SalesAmount) - sum(TotalProductCost))/sum(SalesAmount),'P2') as 'Profit Margin YoY %'
	,Format(case when year_number=2013 then 
	(	sum(SalesAmount)-
		cast(Lead(sum(SalesAmount)) over( partition by SalesTerritoryRegion Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(sum(SalesAmount)) over( partition by SalesTerritoryRegion Order by Year_Number desc) as decimal(16,4)) end, 'P2') as 'Sales YoY %'
	,case when year_number=2013 then 
	(	sum(SalesAmount)-
		cast(Lead(sum(SalesAmount)) over( partition by SalesTerritoryRegion Order by Year_Number desc) as decimal(16,4))
	)/cast(Lead(sum(SalesAmount)) over( partition by SalesTerritoryRegion Order by Year_Number desc) as decimal(16,4)) end as 'Sorting_Field'
	into #SalesYoYbyTerritory
	from #Sales a
	where Year_Number in(2012,2013)
	group by
	Year_Number
	,SalesTerritoryRegion
	order by 
	sum(SalesAmount) - sum(TotalProductCost) desc
	;
	select * from #SalesYoYbyTerritory
	where Year_Number=2013 
	order by Sorting_Field desc;