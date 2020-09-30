USE AdventureWorks2012;
-- Show number of departments that are included in group 'Executive General and Administration'
SELECT COUNT(*) as DepartmentCount FROM HumanResources.Department 
WHERE GroupName = 'Executive General and Administration';

-- Show 5 youngest workers
Select TOP 5 BusinessEntityID, JobTitle, Gender, BirthDate, LoginID FROM 
HumanResources.Employee ORDER BY BirthDate DESC;

-- Show list of female workers, hired at Tuesday. At field LoginID change domain 'adventure-works' to 'adventure-works2012'
Select BusinessEntityID, JobTitle, Gender, HireDate, 
REPLACE(LoginID, 'adventure-works', 'adventure-works2012') as LoginID 
from HumanResources.Employee 
WHERE Gender = 'F'AND DATEPART(dw, HireDate) = '3';