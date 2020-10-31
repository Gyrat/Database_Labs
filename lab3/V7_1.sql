use AdventureWorks2012;
-- a) add to table dbo.PersonPhone field City type nvarchar(30);
alter table dbo.PersonPhone
add City nvarchar(30);
-- b) create table variable with same structure as dbo.PersonPhone and fill it with data from dbo.PersonPhone.
-- Field City fill with data from table Person,Adress field City, field PostalCode with data from Person.Address field PostalCode.
-- If field PostalCode contains letters then fill the field with default value;

declare @dboPersonPhone table (
	BusinessEntityID int not null,
	PhoneNumber nvarchar(25) not null,
	PhoneNumberTypeID bigint,
	ModifiedDate datetime not null,
	PostalCode nvarchar(15) not null,
	City nvarchar(30)
);

insert into @dboPersonPhone (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	PostalCode,
	City
)
select 
	PersonPhone.BusinessEntityID,
	PersonPhone.PhoneNumber,
	PersonPhone.PhoneNumberTypeID,
	PersonPhone.ModifiedDate,
	case when (patindex('%[a-zA-Z]%', Address.PostalCode) = 0) then Address.PostalCode else '0' end,
	Address.City
from dbo.PersonPhone
inner join Person.BusinessEntityAddress
on dbo.PersonPhone.BusinessEntityID = Person.BusinessEntityAddress.BusinessEntityID
inner join Person.Address
on Person.BusinessEntityAddress.AddressID = Person.Address.AddressID;

--select * from @dboPersonPhone;

-- c) update data in fields PostalCode and City in dbo.PersonPhone with data from table variable. Also update data in field PhoneNumber.
-- Add code '1 (11)' for telephones that have no code.
update dbo.PersonPhone
set dbo.PersonPhone.PostalCode = dboPersonPhone.PostalCode,
	dbo.PersonPhone.City = dboPersonPhone.City,
	dbo.PersonPhone.PhoneNumber = iif(patindex(
		'1 (11)%', dbo.PersonPhone.PhoneNumber) = 0, 
		'1 (11)' + dbo.PersonPhone.PhoneNumber,
		dbo.PersonPhone.PhoneNumber)
from dbo.PersonPhone 
inner join @dboPersonPhone as dboPersonPhone
on dbo.PersonPhone.BusinessEntityID = dboPersonPhone.BusinessEntityID;
go

select * from dbo.PersonPhone;
go

-- d) Delete data from dbo.PersonPhone for employees. It means that PersonType field in Person.Person = 'EM'

select BusinessEntityID, PersonType from Person.Person;
go

delete from dbo.PersonPhone 
where exists (
	select BusinessEntityID, PersonType
	from Person.Person
	where dbo.PersonPhone.BusinessEntityID = Person.Person.BusinessEntityID 
		  and Person.Person.PersonType = 'EM'); 
go

select * from dbo.PersonPhone;
go

-- e) delete field City from table, delete all created constraints and default value. Names of constraints you can find at metadata
-- Names of default values find yourself and show code which you used for search;
alter table dbo.PersonPhone
drop column City;
go

select * from dbo.PersonPhone;
go

alter table dbo.PersonPhone
drop constraint Check_PostalCode;
go

alter table dbo.PersonPhone
drop constraint Def_PostalCode;
go

-- f) drop table dbo.PersonPhone
drop table dbo.PersonPhone;
go