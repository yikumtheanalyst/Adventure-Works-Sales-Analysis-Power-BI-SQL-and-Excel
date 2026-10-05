use AdventureWorksDW2019
go

declare @Year_Number INT=2013
declare @InternetSales decimal(16,2),@ResellerSales decimal(16,2), @InternetOrders int,@ResellerOrders int
,@Internet_Unitssold int, @Reseller_Unitssold int, @Internet_GP decimal(16,2),@Reseller_GP decimal(16,2)

/*DimDate */
--select * from DimDate where year(FullDateAlternateKey) in(2010,2011,2012,2013)
--order by 1

/* FactInternetSales */
--select
--@InternetSales=sum(SalesAmount)
--,@InternetOrders=count(distinct SalesOrderNumber)
--,@Internet_Unitssold = sum(OrderQuantity)
--,@Internet_GP=sum(SalesAmount) - sum(TotalProductCost)
--from FactInternetSales
--where year(OrderDate) = @Year_Number

/* FactResellerSales */
select
@ResellerSales= sum(SalesAmount)
,@ResellerOrders= count(distinct SalesOrderNumber)
,@Reseller_Unitssold = sum(OrderQuantity)
,@Reseller_GP=sum(SalesAmount) - sum(TotalProductCost)
from FactResellerSales where year(OrderDate) = @Year_Number

drop table #Sales
select
'InternetSales' as 'Data_Source'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct CustomerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
into #Sales
from FactInternetSales
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by year(OrderDate)
union all
select
'ResellerSales' as 'Data_Source'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct ResellerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
from FactResellerSales
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by
year(OrderDate)
order by Year_Number desc,[Data_Source]
;
select * from #Sales;

/* By Year and Month*/
select
'InternetSales' as 'Data_Source'
,year(OrderDate) as 'Year_Number'
,Month(OrderDate) as 'Month_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct CustomerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
from FactInternetSales
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by year(OrderDate),Month(OrderDate)
union all
select
'ResellerSales' as 'Data_Source'
,year(OrderDate) as 'Year_Number'
,Month(OrderDate) as 'Month_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct ResellerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
from FactResellerSales
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by
year(OrderDate)
,Month(OrderDate)
order by Year_Number desc,Month(OrderDate),[Data_Source]
/* Total Products */
select Year_Number,count(distinct ProductKey) as 'Total Products'
,count(ProductKey) as 'Test Total Products'
from 
(
	select year(OrderDate) as 'Year_Number',ProductKey from FactInternetSales where year(OrderDate)  in(@Year_Number,@Year_Number-1)
	union 
	select year(OrderDate) as 'Year_Number',ProductKey  from FactResellerSales where year(OrderDate)  in(@Year_Number,@Year_Number-1)
)t
group by Year_Number


/*
Customers
*/
drop table #Internet_Sales
select
'InternetSales' as 'Data_Source'
,year(OrderDate) as 'Year_Number'
--,Month(OrderDate) as 'Month_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct CustomerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
into #Internet_Sales
from FactInternetSales
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by year(OrderDate)--,Month(OrderDate)

drop table #InternetSales_Customers
select distinct 
year(OrderDate) as 'Year_Number'
,CustomerKey
into #InternetSales_Customers
from FactInternetSales
where year(OrderDate)  in(@Year_Number,@Year_Number-1) 
;

--select count(distinct customerkey) from #InternetSales_Customers;

drop table #py
drop table #cy
select * into #py from #InternetSales_Customers a where Year_Number=2012
select * into #cy from #InternetSales_Customers a where Year_Number=2013

declare @PY_Total_Customers decimal(9,2)
declare @CY_Total_Customers decimal(9,2)
declare @CY_Total_Revenue decimal(16,4)
select @PY_Total_Customers=count(distinct CustomerKey) from #py where Year_Number=2012;
select @CY_Total_Customers=count(distinct CustomerKey) from #cy where Year_Number=2013;

--select @CY_Total_Revenue = [Sales Amount] from #Sales where Year_Number=2013;
select @CY_Total_Revenue = [Sales Amount] from #Internet_Sales where Year_Number=2013;

select * from #Internet_Sales;

select 
@CY_Total_Revenue as 'Total_Revenue',@CY_Total_Customers as 'Internet Customer'
,@CY_Total_Revenue/@CY_Total_Customers as 'Average Revenue /  Customer';

select 
'New Customers' as 'Customer Type',
count(distinct CustomerKey) as 'New Customers'
, count(distinct CustomerKey)/@CY_Total_Customers as 'Rate'
, 0 as 'Retention Rate'
from (
select CustomerKey from #cy 
except
select CustomerKey from #py)t --New Customers
union all
select 
'Returning Customers' as 'Customer Type',
count(distinct CustomerKey) as 'Returning Customers'
, count(distinct CustomerKey)/@CY_Total_Customers as 'Rate'
, count(distinct CustomerKey)/@PY_Total_Customers as 'Retention Rate'
from (
select CustomerKey  from #cy 
intersect
select CustomerKey from #py)t --Returning Customers
union all
select 
'Lost Customers' as 'Customer Type',
count(distinct CustomerKey) as 'Lost Customers'
, count(distinct CustomerKey)/@PY_Total_Customers as 'Rate'
, 0 as 'Retention Rate'
from (
select CustomerKey from #py 
except
select CustomerKey  from #cy) t; --Lost Customers

drop table #Customers_Internet_Sales
select

'InternetSales' as 'Data_Source'
,convert(varchar(50),fs.CustomerKey) as 'CustomerKey'
,convert(varchar(50),fs.CustomerKey) + ' - ' + ct.LastName + ' ' + ct.FirstName as 'Customer LN FN'
,year(OrderDate) as 'Year_Number'
--,Month(OrderDate) as 'Month_Number'
,sum(SalesAmount) as 'Internet Sales'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
--,count(distinct fs.CustomerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
into #Customers_Internet_Sales
from FactInternetSales fs
inner join DimCustomer ct on fs.CustomerKey=ct.CustomerKey
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by 
convert(varchar(50),fs.CustomerKey) + ' - ' + ct.LastName + ' ' + ct.FirstName 
,fs.CustomerKey
,year(OrderDate)--,Month(OrderDate)
;

drop table #CY_Top5_Customers
select top 5 * into #CY_Top5_Customers from #Customers_Internet_Sales
where Year_Number=2013 order by [Internet Sales] desc;

select * from #CY_Top5_Customers;
select top 5 a.* from #Customers_Internet_Sales a
where a.Year_Number=2012
and exists(select 1 from  #CY_Top5_Customers b where a.[Customer LN FN]=b.[Customer LN FN])
order by a.[Internet Sales] desc
;


select * from #Customers_Internet_Sales
--where Year_Number=2013
--order by [Internet Sales] desc
where [Customer LN FN] like '%turner jordan%'
and Year_Number=2013
order by [Internet Sales] desc

select CustomerKey,OrderDate, SalesAmount from FactInternetSales where CustomerKey=11420
order by 2



/*Products - Subcategory - Category*/
--select
--p.*
--from DimProduct p
--inner join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
--inner join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey


drop table #Products_Sales
select
'InternetSales' as 'Data_Source'
,pc.EnglishProductCategoryName as 'Category'
,psc.EnglishProductSubcategoryName as 'Subcategory'
,fi.ProductKey
,p.EnglishProductName as 'Product_Name'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct CustomerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
into #Products_Sales
from FactInternetSales fi
inner join DimProduct p on fi.ProductKey=p.ProductKey
inner join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
inner join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by 
year(OrderDate)
,pc.EnglishProductCategoryName
,psc.EnglishProductSubcategoryName 
,p.EnglishProductName
,fi.ProductKey
union all
select
'ResellerSales' as 'Data_Source'
,pc.EnglishProductCategoryName as 'Category'
,psc.EnglishProductSubcategoryName as 'Subcategory'
,fi.ProductKey
,p.EnglishProductName as 'Product_Name'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct ResellerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
from FactResellerSales fi
inner join DimProduct p on fi.ProductKey=p.ProductKey
inner join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
inner join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by
year(OrderDate)
,pc.EnglishProductCategoryName
,psc.EnglishProductSubcategoryName 
,p.EnglishProductName
,fi.ProductKey
order by Year_Number desc,[Data_Source]

drop table #py_products
drop table #cy_products
select distinct productkey into #py_products from #Products_Sales where Year_Number=2012
select distinct productkey into #cy_products from #Products_Sales where Year_Number=2013

declare @new_products int
declare @products_not_sold int
select @new_products = count(productkey) 
from ( select productkey from #cy_products except select productkey from #py_products
) t;
select @products_not_sold = count(productkey) 
from ( select productkey from #py_products  except select productkey from #cy_products
) t;

drop table #CY_Top5_products
select top 5 Product_Name, sum([Sales Amount]) as 'Combined Sales'
into #CY_Top5_products
from #Products_Sales where Year_Number=2013
group by Product_Name
order by [Combined Sales] desc;
select '2013' as Year_Number,* from #CY_Top5_products;

select top 5 '2012' as Year_Number,Product_Name, sum([Sales Amount]) as 'Combined Sales'
from #Products_Sales a
where a.Year_Number=2012
and exists(select 1 from  #Products_Sales b where a.Product_Name=b.Product_Name)
group by Product_Name
order by [Combined Sales] desc;

select * from #CY_Top5_Customers;
select top 5 a.* from #Customers_Internet_Sales a
where a.Year_Number=2012
and exists(select 1 from  #CY_Top5_Customers b where a.[Customer LN FN]=b.[Customer LN FN])
order by a.[Internet Sales] desc
;

select Year_Number
,sum([Sales Amount]) as 'Total Sales' 
,count(distinct ProductKey) as 'Total Products Sold'
,count(distinct case when Data_Source='InternetSales' then ProductKey end) as 'Internet Products Sold'
,count(distinct case when Data_Source='ResellerSales' then ProductKey end) as 'Reseller Products Sold' 
,sum([Units Sold]) as 'Units Sold'
,sum([Sales Amount])/sum([Units Sold]) as 'Average Selling Price' 
,case when year_number=2013 then @new_products end as 'Products Newly Sold vs PY'
,case when year_number=2012 then @products_not_sold end as 'Products Not Sold vs PY'
from #Products_Sales
group by Year_Number order by Year_Number desc;

/* Salesperson Performance */

drop table #salesperson_sales
select
'ResellerSales' as 'Data_Source'
,fi.ResellerKey
,convert(varchar(50),fi.EmployeeKey) as 'EmployeeKey'
,convert(varchar(50),fi.EmployeeKey) + ' ' + ep.LastName + ' ' + ep.FirstName as 'Salesperson'
,spt.SalesTerritoryRegion
--,pc.EnglishProductCategoryName as 'Category'
--,psc.EnglishProductSubcategoryName as 'Subcategory'
--,fi.ProductKey
--,p.EnglishProductName as 'Product_Name'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct ResellerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
into #salesperson_sales
from FactResellerSales fi
inner join DimEmployee ep on fi.EmployeeKey=ep.EmployeeKey and ep.SalesPersonFlag=1
inner join DimSalesTerritory spt on fi.SalesTerritoryKey=spt.SalesTerritoryKey
--inner join DimProduct p on fi.ProductKey=p.ProductKey
--inner join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
--inner join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
where year(OrderDate)  in(@Year_Number,@Year_Number-1)
group by
year(OrderDate)
,fi.EmployeeKey
,convert(varchar(50),fi.EmployeeKey) + ' ' + ep.LastName + ' ' + ep.FirstName
,fi.ResellerKey
,spt.SalesTerritoryRegion
--,pc.EnglishProductCategoryName
--,psc.EnglishProductSubcategoryName 
--,p.EnglishProductName
--,fi.ProductKey
order by Year_Number desc,[Data_Source]
;

--drop table #py_salesperson;
drop table #cy_salesperson;
select top 5 * into #cy_salesperson from #salesperson_sales where Year_Number=2013 order by [Sales Amount] desc;

select top 5 * from #salesperson_sales a
where Year_Number=2012 and exists(select 1 from #cy_salesperson b where a.Salesperson=b.Salesperson)
order by [Sales Amount] desc;

select
Year_Number,
sum([Sales Amount]) as 'Total Sales'
,sum([Units Sold]) as 'Units Sold'
,sum([Total Orders]) as 'Total Orders'
,count(distinct ResellerKey) as 'Active Resellers'
,sum([Sales Amount])/count(distinct EmployeeKey) as 'Sales per Salesperson'
,sum([Sales Amount]) / sum([Total Orders])  as 'Resellers AOV'
from #salesperson_sales
group by Year_Number order by Year_Number desc
;

select
Year_Number
--,Salesperson
,sum([Sales Amount]) as 'Total Sales'
,sum([Units Sold]) as 'Units Sold'
,sum([Total Orders]) as 'Total Orders'
,count(distinct ResellerKey) as 'Active Resellers'
,sum([Sales Amount])/count(distinct EmployeeKey) as 'Sales per Salesperson'
,sum([Sales Amount]) / sum([Total Orders])  as 'Resellers AOV'
from #salesperson_sales sp
where Year_Number=2013
group by 
Year_Number
--,sp.Salesperson
order by [Active Resellers] desc
;

select
Year_Number
,Salesperson
,sum([Sales Amount]) as 'Total Sales'
,sum([Units Sold]) as 'Units Sold'
,sum([Total Orders]) as 'Total Orders'
,count(distinct ResellerKey) as 'Active Resellers'
,sum([Sales Amount])/count(distinct EmployeeKey) as 'Sales per Salesperson'
,sum([Sales Amount]) / sum([Total Orders])  as 'Resellers AOV'
from #salesperson_sales sp
where Year_Number=2013
group by 
Year_Number
,sp.Salesperson
order by [Active Resellers] desc
;

drop table #SalesTerritoryRegion
select
'InternetSales' as 'Data_Source'
,spt.SalesTerritoryRegion
,spt.SalesTerritoryGroup
--,pc.EnglishProductCategoryName as 'Category'
--,psc.EnglishProductSubcategoryName as 'Subcategory'
--,fi.ProductKey
--,p.EnglishProductName as 'Product_Name'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct CustomerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
into #SalesTerritoryRegion
from FactInternetSales fi
inner join DimSalesTerritory spt on fi.SalesTerritoryKey=spt.SalesTerritoryKey
--inner join DimProduct p on fi.ProductKey=p.ProductKey
--inner join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
--inner join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
where year(OrderDate)  in(@Year_Number,@Year_Number-1,@Year_Number-2)
group by 
year(OrderDate)
,spt.SalesTerritoryGroup
--,pc.EnglishProductCategoryName
--,psc.EnglishProductSubcategoryName 
--,p.EnglishProductName
--,fi.ProductKey
,spt.SalesTerritoryRegion
union all
select
'ResellerSales' as 'Data_Source'
,spt.SalesTerritoryRegion
,spt.SalesTerritoryGroup
--,pc.EnglishProductCategoryName as 'Category'
--,psc.EnglishProductSubcategoryName as 'Subcategory'
--,fi.ProductKey
--,p.EnglishProductName as 'Product_Name'
,year(OrderDate) as 'Year_Number'
,sum(SalesAmount) as 'Sales Amount'
,count(distinct SalesOrderNumber) as  'Total Orders'
,sum(OrderQuantity) as 'Units Sold'
,sum(SalesAmount) - sum(TotalProductCost) as 'Gross Profit'
,count(distinct ResellerKey) as 'Customer_Count'
,sum(TotalProductCost) as 'TotalProductCost'
from FactResellerSales fi
--inner join DimProduct p on fi.ProductKey=p.ProductKey
--inner join DimProductSubcategory psc on p.ProductSubcategoryKey=psc.ProductSubcategoryKey
--inner join DimProductCategory pc on psc.ProductCategoryKey=pc.ProductCategoryKey
inner join DimSalesTerritory spt on fi.SalesTerritoryKey=spt.SalesTerritoryKey
where year(OrderDate)  in(@Year_Number,@Year_Number-1,@Year_Number-2)
group by
year(OrderDate)
--,pc.EnglishProductCategoryName
--,psc.EnglishProductSubcategoryName 
--,p.EnglishProductName
--,fi.ProductKey
,fi.ResellerKey
,spt.SalesTerritoryRegion
,spt.SalesTerritoryGroup
order by Year_Number desc,[Data_Source]

select
Year_Number
,[Data_Source]
,SalesTerritoryRegion
,SalesTerritoryGroup
,sum([Sales Amount]) as 'Total Sales'
,sum([Units Sold]) as 'Units Sold'
,sum([Total Orders]) as 'Total Orders'
,sum([Sales Amount]) / sum([Total Orders])  as 'Resellers AOV'
,sum([Gross Profit]) as 'Gross Profit'
from #SalesTerritoryRegion sp
--where Year_Number=2013
group by 
Year_Number
,sp.SalesTerritoryRegion
,[Data_Source]
,SalesTerritoryGroup

order by Year_Number desc,[Total Sales] desc
;