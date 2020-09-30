USE AdventureWorks2012;

-- Show last date of changing hourly rate for each worker
SELECT Employee.BusinessEntityID, 
JobTitle, MAX(EmployeePayHistory.RateChangeDate) AS LastRateDate 
FROM HumanResources.Employee 
INNER JOIN HumanResources.EmployeePayHistory 
on HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
GROUP BY Employee.BusinessEntityID, Employee.JobTitle;

-- Show number of years that each worker had worked in each department.If worker is working until now, number of years count until today
SELECT Employee.BusinessEntityID, JobTitle, Department.name as DepName, StartDate, EndDate, 
(ISNULL(DATEPART(yy, EndDate), DATEPART(yy, GETDATE())) - DATEPART(yy, StartDate) ) as Years
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeeDepartmentHistory.BusinessEntityID
INNER JOIN HumanResources.Department
ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID;

-- Show information about all workers with info about department that they are working right now. Also show first word of department title
SELECT Employee.BusinessEntityID, JobTitle, Department.name as DepName, Department.GroupName, SUBSTRING(Department.GroupName, 0, CHARINDEX(' ',Department.GroupName))
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeeDepartmentHistory.BusinessEntityID
INNER JOIN HumanResources.Department
ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID
AND EmployeeDepartmentHistory.EndDate IS NULL;
