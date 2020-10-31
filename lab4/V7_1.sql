use AdventureWorks2012;
go
-- a) create table Sales.CurrencyHst that will store data about changes in table Sales.Currency.
-- compulsory fields that must be in table are:
-- ID - primary key IDENTITY(1,1)
-- Action - action taken (insert, update or delete)
-- ModifiedDate - date and time when action took place
-- SouceID - primary key of original table
-- UserName - Name of user that did the action
-- create other fields if needed
create table Sales.CurrencyHst (
	ID int identity(1,1) primary key,
	Action nvarchar(15) not null,
	ModifiedDate datetime not null,
	SourceID nchar(3) not null,
	UserName nvarchar(25));
go

-- b) create 3 AFTER triggers for 3 operations Insert, Update, Delete for table Sales.Currency
-- each trigger must fill table Sales.CurrencyHst with adding operation type to field Action
create trigger Sales.trigSalesCurrencyInsert
on Sales.Currency	
after insert as
begin
	set nocount on;
	insert into Sales.CurrencyHst (
		Action, 
		ModifiedDate,
		SourceID,
		UserName)
	select 
		'INSERT',
		CURRENT_TIMESTAMP,
		CurrencyCode,
		CURRENT_USER
	from inserted;
end
go

create trigger Sales.trigSalesCurrencyDelete
on Sales.Currency	
after delete as
begin
	set nocount on;
	insert into Sales.CurrencyHst (
		Action, 
		ModifiedDate,
		SourceID,
		UserName)
	select 
		'DELETE',
		CURRENT_TIMESTAMP,
		CurrencyCode,
		CURRENT_USER
	from deleted;
end
go

create trigger Sales.trigSalesCurrencyUpdate
on Sales.Currency	
after update as
begin
	set nocount on;
	insert into Sales.CurrencyHst (
		Action, 
		ModifiedDate,
		SourceID,
		UserName)
	select 
		'UPDATE',
		CURRENT_TIMESTAMP,
		CurrencyCode,
		CURRENT_USER
	from inserted;
end
go

-- c) create VIEW, displaying all fields of table Sales.Currency. Make impossible to look original code of view.
create view Sales.vCurrency with encryption as select * from Sales.Currency;
go

select definition from sys.sql_modules where object_id = object_id('Sales.vCurrency');
go

select * from Sales.vCurrency order by Name;
go

-- d) add new row to Sales.Currency through view. update this row. delete this row. 
-- check that all 3 operations are in Sales.CurrencyHst.
insert into Sales.vCurrency (
	CurrencyCode,
	Name,
	ModifiedDate)
values (
	N'MYD',
	'My Dollar',
	CURRENT_TIMESTAMP); 
go

update Sales.vCurrency set Name = 'My Ruble' where CurrencyCode = N'MYD';
go

delete from Sales.vCurrency where CurrencyCode = N'MYD';
go 

select * from Sales.CurrencyHst;
go
