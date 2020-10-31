-- a) add to table dbo,PersonPhone fields OrdersCount int and CardType nvarchar(50).
-- also create counting field IsSuperior, that will = 1 if CardType = 'SuperiorCard' and 0 for others.
alter table dbo.PersonPhone add OrdersCount int;
go

alter table dbo.PersonPhone add CardType nvarchar(50);
go

alter table dbo.PersonPhone add IsSuperior as iif(CardType = 'SuperiorCard', 1, 0);
go

select * from dbo.PersonPhone;
go

-- b) create temporary table #PersonPhone with primary key on field BusinessEntityID.
-- temporary table must include all fields from table dbo,PersonPhone exept field IsSuperior
create table #PersonPhone (
	BusinessEntityID int not null,
	PhoneNumber nvarchar(25) not null,
	PhoneNumberTypeID bigint,
	ModifiedDate datetime not null,
	PostalCode nvarchar(15) not null,
	OrdersCount int,
	CardType nvarchar(50));
go

alter table #PersonPhone
add constraint PK_PersonPhone_BusinessEntityID primary key (BusinessEntityID);
go

-- c) fill temp table with data from dbo.PersonPhone. Field CardType fill with data from table Sales.CreditCard.
-- Count quantity of orders that are payed with each card (CreditCardID) in table Sales.SalesOrderHeader and fill with these values field OrdersCount.
-- Counting quantity of orders from Common Table Expression (CTE).
with CardOrders (CardID, CardOrdersCount) as (
	select 
		Sales.SalesOrderHeader.CreditCardID,
		count(Sales.SalesOrderHeader.CreditCardID)
	from Sales.SalesOrderHeader
	group by Sales.SalesOrderHeader.CreditCardID
)
insert into #PersonPhone (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	PostalCode,
	OrdersCount,
	CardType)
select 
	dbo.PersonPhone.BusinessEntityID,
	dbo.PersonPhone.PhoneNumber,
	dbo.PersonPhone.PhoneNumberTypeID,
	dbo.PersonPhone.ModifiedDate,
	dbo.PersonPhone.PostalCode,
	CardOrders.CardOrdersCount,
	Sales.CreditCard.CardType
from dbo.PersonPhone
left join Sales.PersonCreditCard
on dbo.PersonPhone.BusinessEntityID = Sales.PersonCreditCard.BusinessEntityID
left join Sales.CreditCard
on Sales.PersonCreditCard.CreditCardID = Sales.CreditCard.CreditCardID
left join CardOrders
on Sales.CreditCard.CreditCardID = CardOrders.CardID;
go

select * from #PersonPhone
order by BusinessEntityID asc;
go

-- d) delete from table dbo.PersonPhone 1 row (where BusinessEntityID = 297)
delete from dbo.PersonPhone where BusinessEntityID = 297;
go

-- e) write Merge expression that uses dbo.PersonPhone as target and tebp table as source. foe linking target and source use BusinessEntityID.
-- update fields OrdersCount and CardType if row exists in source and target.
-- if row exists in temp table but dont exist in target, add row to dbo.PersonPhone.
-- if in dbo.PersonPhone exists such row that dont exist in temp table, delete row from dbo.PersonPhone.

insert into dbo.PersonPhone (
	BusinessEntityID,
	PhoneNumber,
	ModifiedDate,
	PostalCode)
values (
	123123123,
	'123123123',
	CURRENT_TIMESTAMP,
	'123123123');
go

select * from dbo.PersonPhone
where BusinessEntityID = 123123123;
go

merge dbo.PersonPhone a 
using #PersonPhone b
on (a.BusinessEntityID = b.BusinessEntityID)
when matched 
	then update set 
		a.OrdersCount = b.OrdersCount, 
		a.CardType = b.CardType
when not matched by target
	then insert (
		BusinessEntityID,
		PhoneNumber,
		PhoneNumberTypeID,
		ModifiedDate,
		PostalCode,
		OrdersCount,
		CardType) 
	values (
		b.BusinessEntityID,
		b.PhoneNumber,
		b.PhoneNumberTypeID,
		b.ModifiedDate,
		b.PostalCode,
		b.OrdersCount,
		b.CardType)
when not matched by source
	then delete;
go

select * from dbo.PersonPhone where BusinessEntityID = 297 or BusinessEntityID = 123123123;
go