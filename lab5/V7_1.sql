use AdventureWorks2012;
go

-- create scalar-valued function that will get as argument currency code (Sales.Currency.CurrencyCode)
-- and return last established exchange rate to USD (Sales.CurrencyRate.ToCurrencyCode).

create function Sales.LastCurrencyRateUsd (@currencyCode nchar(3))
returns money as
begin
	declare @lastDate datetime
	declare @lastCurrencyRate money
	
	select @lastDate = max(CurrencyRateDate)
	from Sales.CurrencyRate
	where FromCurrencyCode = N'USD' 
	      and ToCurrencyCode = @currencyCode;
		  
	select @lastCurrencyRate = EndOfDayRate
	from Sales.CurrencyRate
	where FromCurrencyCode = N'USD' 
	      and ToCurrencyCode = @currencyCode 
		  and CurrencyRateDate = @lastDate;				
	return @lastCurrencyRate;
end
go

print(Sales.LastCurrencyRateUsd(N'CAD'));
go

select 
	CurrencyRateID,
	CurrencyRateDate,
	FromCurrencyCode,
	ToCurrencyCode, 
	EndOfDayRate 
from Sales.CurrencyRate 
where FromCurrencyCode = N'USD'
	  and ToCurrencyCode = N'CAD'
order by CurrencyRateDate desc; 
go

 -- create inline table-valued function that will get as argument product ID (Production.Product.ProductID)
 -- and return order details for purchase of this product from Purchasing.PurchaseOrderDetail,
 -- where quantity of purchased slots are greater than 1000 (OrderQty)
create function Purchasing.GetPurchaseOrderDetail(@productID int)
returns table 
as
return 
	select *
	from Purchasing.PurchaseOrderDetail
	where ProductID = @productID
		  and OrderQty > 1000;
go

select 
	count(PurchaseOrderID) 
from Purchasing.GetPurchaseOrderDetail(325);
go

select 
	count(PurchaseOrderID)
from Purchasing.PurchaseOrderDetail
where ProductID = 325 and OrderQty > 1000;
go

 -- call function for each product using operator CROSS APPLY.
 -- call function for each product using operator OUTER APPLY.

select 
	Product.ProductID,
	Product.Name,
	PurchaseOrderID,
	PurchaseOrderDetailID,
	OrderQty 
from Production.Product
cross apply Purchasing.GetPurchaseOrderDetail(ProductID);
go

select 
	Product.ProductID,
	Product.Name,
	PurchaseOrderID,
	PurchaseOrderDetailID,
	OrderQty 
from Production.Product
outer apply Purchasing.GetPurchaseOrderDetail(ProductID);
go

-- change created inline table-valued function, making it multistatement table-valued
-- (previously save it for checking creation code inline table-valued function)

create function Purchasing.GetPurchaseOrderDetailMulti(@productID int)
returns @resultTable table (
	PurchaseOrderID int, 
	PurchaseOrderDetailID int,
	DueDate datetime,
	OrderQty smallint,
	ProductID int,
	UnitPrice money,
	LineTotal money,
	ReceivedQty decimal(8,2),
	RejectedQty decimal(8,2),
	StockedQty decimal(9,2),
	ModifiedDate datetime) 
as 
begin
	insert into @resultTable
		select 
			PurchaseOrderID,
			PurchaseOrderDetailID,
			DueDate,
			OrderQty,
			ProductID,
			UnitPrice,
			LineTotal,
			ReceivedQty,
			RejectedQty,
			StockedQty,
			ModifiedDate
		from Purchasing.PurchaseOrderDetail
		where ProductID = @productID
			  and OrderQty > 1000;
	return
end
go


select 
	PurchaseOrderID,
	PurchaseOrderDetailID,
	ProductID,
	OrderQty
from Purchasing.GetPurchaseOrderDetailMulti(325);
go

select 
	PurchaseOrderID,
	PurchaseOrderDetailID,
	ProductID,
	OrderQty
from Purchasing.GetPurchaseOrderDetail(325);
go