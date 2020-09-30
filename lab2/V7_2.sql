USE AdventureWorks2012;
-- a) Create table dbo.PersonPhone with same structure as Person.PersonPhone without indexes, constraints and triggers
CREATE TABLE dbo.PersonPhone
(
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL
)
-- b) Using instruction ALTER TABLE create for table dbo.PersonPhone complex primary key from fields BusinessEntityID and PhoneNumber
ALTER TABLE dbo.PersonPhone
  ADD CONSTRAINT PK_PersonPhone PRIMARY KEY (BusinessEntityID, PhoneNumber); 
;
-- c) Using instruction ALTER TABLE create for table dbo.PersonPhone new field PostalCode nvarchar(15) and constraint for that field banishing filling that field with letters
ALTER TABLE dbo.PersonPhone
	ADD PostalCode nvarchar(15),
	CONSTRAINT Check_PostalCode CHECK (PostalCode NOT LIKE '%[A-Za-z]%') 
;
-- d) Using instruction ALTER TABLE create for table dbo.PersonPhone constraint DEFAULT for field PostalCode and make default value = '0'
ALTER TABLE dbo.PersonPhone
	ADD CONSTRAINT Def_PostalCode DEFAULT '0' FOR PostalCode;

-- e) Fill new table with data from Person.PersonPhone but with contacts with type 'Cell' from table PhoneNumberType

-- f) change type of field PhoneNumberID to BIGINT and possible to be null
ALTER TABLE dbo.PersonPhone
	ALTER COLUMN PhoneNumberTypeID BIGINT NULL;