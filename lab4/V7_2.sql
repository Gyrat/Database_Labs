use AdventureWorks2012;
go

-- a) Create VIEW, displaying data from tables Sales.Currency and Sales.CurrencyRate.
-- table Sales.Currency must display currency's name for field ToCurrencyCode. 
-- Create unique clustered index in view on field CurrencyRateID.
create view Sales.vCurrencyV2 with schemabinding as
select
	currencyRate.CurrencyRateID,
	currencyRate.CurrencyRateDate,
	currencyRate.FromCurrencyCode,
	currency.Name,
	currency.CurrencyCode,
	currencyRate.AverageRate,
	currencyRate.EndOfDayRate
from Sales.Currency as currency
inner join Sales.CurrencyRate as currencyRate
	on currency.CurrencyCode = currencyRate.ToCurrencyCode
go

create unique clustered index IX_CurrencyRateID
	on Sales.vCurrencyV2 (CurrencyRateID)
go

-- b) create 1 Instead Of trigger for a view on 3 operations Insert, Update, Delete.
-- trigger must execute according operations in tables Sales.Currency and Sales.CurrencyRate.
create trigger Insteadtrigger on Sales.vCurrencyV2
	instead of insert, update, delete
as
begin
	declare @currencyCode nvarchar(50);
	if NOT EXISTS (select * from inserted)
		begin 
			select @currencyCode = deleted.CurrencyCode from deleted;
			delete from Sales.CurrencyRate where ToCurrencyCode = @currencyCode;			
			delete from Sales.Currency where CurrencyCode = @currencyCode
		end;
	else if NOT EXISTS (select * from deleted)
		begin
			if NOT EXISTS (
				select * from Sales.Currency as sc JOIN inserted on inserted.CurrencyCode = sc.CurrencyCode)
			begin
				insert into Sales.Currency (CurrencyCode, Name, ModifiedDate)
				select CurrencyCode, Name, getdate()
				from inserted
			end
			else
				update Sales.Currency set Name = inserted.Name, ModifiedDate = getdate()
				from inserted where Currency.CurrencyCode = inserted.CurrencyCode

			insert into Sales.CurrencyRate(
				CurrencyRateDate,
				FromCurrencyCode,
				ToCurrencyCode,
				AverageRate,
				EndOfDayRate,
				ModifiedDate)
			select 
				CurrencyRateDate,
				FromCurrencyCode,
				CurrencyCode,
				AverageRate,
				EndOfDayRate,
				getdate()
			from inserted
		end;
	else
		begin
			update Sales.Currency set Name = inserted.Name, ModifiedDate = getdate()
			from Sales.Currency as currencies
			join inserted on inserted.CurrencyCode = currencies.CurrencyCode

			update Sales.CurrencyRate set 
				CurrencyRateDate = inserted.CurrencyRateDate,
				AverageRate = inserted.AverageRate,
				EndOfDayRate = inserted.EndOfDayRate,
				ModifiedDate = getdate()
			from Sales.CurrencyRate as currencyRates
			join inserted on inserted.CurrencyRateID = currencyRates.CurrencyRateID
		end;
end;

-- c) add new row in view with new data for Currency and CurrencyRate (set FromCurrencyCode = ‘USD’).
-- trigger must add new rows in tables sales.currency and sales.currencyRate.
-- update addded rows through view. delete rows.
insert into Sales.vCurrencyV2(
	CurrencyRateDate,
	FromCurrencyCode,
	CurrencyCode,
	Name,
	AverageRate,
	EndOfDayRate)
values(getdate(), 'USD','UWU', 'MyName', 2.01, 1.65)
go

select * from Sales.Currency where CurrencyCode = 'UWU'
go       
select * from Sales.CurrencyRate where ToCurrencyCode = 'UWU'
go  

update Sales.vCurrencyV2 set 
	Name='MyNewName',
	AverageRate = 2.33,
	EndOfDayRate=3.1
where CurrencyCode = 'UWU'
go

select * from Sales.Currency where CurrencyCode = 'UWU'   
go    
select * from Sales.CurrencyRate where ToCurrencyCode = 'UWU' 
go

delete from Sales.vCurrencyV2 where CurrencyCode = 'UWU'
go

select * from Sales.Currency where CurrencyCode = 'UWU'   
go    
select * from Sales.CurrencyRate where ToCurrencyCode = 'UWU'  
go