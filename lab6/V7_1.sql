use AdventureWorks2012;
go

-- create stored procedure that will return consolidated table (operator PIVOT), displaying data
-- about coworker's quantity (HumanResources.Employee), that work in a certain shift (HumanResources.Shift),
-- it is necessary to show info for each department (HumanResources.Department).
-- Names list of shifts transfer into procedure through input parameter
-- So procedure call will look like EXECUTE  dbo.EmpCountByShift ‘[Day],[Evening],[Night]’

create procedure dbo.getEmpCountByShiftName
    @ShiftsNames nvarchar(50)
as
	declare @query nvarchar(1000);
	
	set @query = 'select DepName,' + @ShiftsNames + '
	from
	(
		select
		    Department.Name AS DepName,
		    Shift.Name AS ShiftName
		from
		    HumanResources.Department
		    join HumanResources.EmployeeDepartmentHistory
		        on Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
		    join HumanResources.Shift
		        on EmployeeDepartmentHistory.ShiftID = Shift.ShiftID
		where
		    EndDate is null
	) as source
	pivot
	(
	    count(ShiftName)
	    for ShiftName
	    in (' + @ShiftsNames + ')
	) as PivotTable'

	exec sp_executesql @query
go

exec dbo.getEmpCountByShiftName '[Day],[Evening],[Night]'