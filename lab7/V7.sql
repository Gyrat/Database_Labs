use AdventureWorks2012;
go

 -- show data from fields [ProductID], [Name] of table [Production].[Product]
 -- and fields [ProductModelID] ? [Name] of table [Production].[ProductModel] in form of xml, saved in variable

declare @xml xml; 
 
set @xml = (
	select top 2
		p.ProductID as [@ID],
		p.Name,
		pm.ProductModelID as [Model/@ID],
		pm.Name as [Model/Name]
	from Production.Product as p
	inner join Production.ProductModel pm
	on p.ProductModelID = pm.ProductModelID
	for xml path ('Product'), root('Products')
);

select @xml;
go