-- Delete Duplicate from Table
-- First way starts
SELECT FirstName, LastName, COUNT(*) FROM DeleteDuplicateFromTable
GROUP BY FirstName, LastName
HAVING COUNT(*) > 1 -- Check how many duplicates are in the table

DELETE FROM DeleteDuplicateFromTable
WHERE EmployeeId NOT IN
(SELECT MAX(EmployeeId) AS ID
FROM DeleteDuplicateFromTable
GROUP BY FirstName, LastName)
-- First way ends

-- Second way starts
WITH Employee_CTE AS
(SELECT EmployeeId, FirstName, LastName,
RANK() OVER(PARTITION BY FirstName, LastName ORDER BY EmployeeId DESC) AS RANKDATA
FROM DeleteDuplicateFromTable)

DELETE FROM Employee_CTE
WHERE RANKDATA > 1

--SELECT EmployeeId, FirstName, LastName,
--ROW_NUMBER() OVER(PARTITION BY FirstName, LastName ORDER BY EmployeeId DESC) AS RANKDATA
--FROM DeleteDuplicateFromTable

-- Second way ends
GO

-- Nth Highest Salary
-- First way starts
SELECT * FROM NthHighestSalary
WHERE Salary = 
(SELECT MAX(Salary) FROM NthHighestSalary
WHERE Salary <
(SELECT MAX(Salary) FROM NthHighestSalary
WHERE Salary <
(SELECT MAX(Salary) FROM dbo.NthHighestSalary)))
-- First way ends

-- Second way starts
SELECT TOP 1 * FROM 
(SELECT TOP 4 * FROM NthHighestSalary
ORDER BY Salary DESC) AS Salary_Order
ORDER BY Salary
-- Second ways ends

-- Third way starts
WITH Salary_CTE AS
(SELECT TOP 4 * FROM NthHighestSalary
ORDER BY Salary DESC)

SELECT TOP 1 * FROM Salary_CTE
ORDER BY Salary
-- Third way ends

-- Fourth way starts
WITH Sal_CTE AS
(SELECT *,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS Salary_Order
FROM NthHighestSalary)

SELECT * FROM Sal_CTE
WHERE Salary_Order = 3

--SELECT *,
--ROW_NUMBER() OVER (ORDER BY Salary DESC) AS Salary_Order
--FROM NthHighestSalary

--SELECT *,
--RANK() OVER (ORDER BY Salary DESC) AS Salary_Order
--FROM NthHighestSalary
-- Fourth way ends
GO

-- Employee Manager Hierarchy
SELECT emp.FirstName + ' ' + emp.LastName AS Employee, mg.FirstName + ' ' + mg.LastName AS Manager
FROM EmployeeManagerHierarchy emp
JOIN EmployeeManagerHierarchy mg ON emp.ManagerId = mg.EmployeeId
GO

-- Pivot Data
SELECT Id, [Name], [Gender], [Salary]
FROM
(SELECT Id, Name AS EName, Value FROM PivotData) AS Source_Table
PIVOT
(MAX(Value)
FOR
EName IN([Name], [Gender], [Salary])) AS Pivot_Table
GO

-- Order by month in year
-- First way starts
SELECT SalesMonthName, SalesDate, SUM(SalesAmount) AS TotalSales FROM OrderByMonthInYear
GROUP BY SalesMonthName,SalesDate
ORDER BY 
(CASE WHEN SalesMonthName = 'January' THEN 1
WHEN SalesMonthName = 'February' THEN 2
WHEN SalesMonthName = 'March' THEN 3
WHEN SalesMonthName = 'April' THEN 4
WHEN SalesMonthName = 'May' THEN 5
WHEN SalesMonthName = 'June' THEN 6
WHEN SalesMonthName = 'July' THEN 7
WHEN SalesMonthName = 'August' THEN 8
WHEN SalesMonthName = 'September' THEN 9
WHEN SalesMonthName = 'October' THEN 10
WHEN SalesMonthName = 'November' THEN 11
WHEN SalesMonthName = 'December' THEN 12
ELSE NULL
END)
-- First way ends

-- Second way starts
SELECT DATENAME(MONTH, SalesDate) AS MonthName, MONTH(SalesDate) AS MonthId, SUM(SalesAmount) AS TotalSales 
FROM OrderByMonthInYear
GROUP BY SalesDate
ORDER BY MONTH(SalesDate)
-- Second way ends
GO

-- Compare with previous quarter sales
SELECT SalesYear, QuarterName, SalesAmount,
LAG(SalesAmount) OVER(PARTITION BY SalesYear ORDER BY QuarterName) AS Previous_Sales,
(SalesAmount - (LAG(SalesAmount) OVER(PARTITION BY SalesYear ORDER BY QuarterName))) AS Diff
FROM CompareWithPreviousQuarterSales

--SELECT SalesYear, QuarterName, SalesAmount,
--LEAD(SalesAmount) OVER(PARTITION BY SalesYear ORDER BY QuarterName DESC) AS Previous_Sales,
--(SalesAmount - (LEAD(SalesAmount) OVER(PARTITION BY SalesYear ORDER BY QuarterName DESC))) AS Diff
--FROM CompareWithPreviousQuarterSales [LEAD Function finds after data, on the other hand LAG Function finds previous data]
GO

-- Splite Concatenated String
WITH Name_CTE AS
(SELECT EmployeeId, Value ,
ROW_NUMBER() OVER(Partition BY EmployeeId ORDER BY EmployeeId) AS ROWNUM
FROM SpliteConcatenatedString
CROSS APPLY
string_split(EmployeeName, ','))

SELECT EmployeeId, [1] AS First_Name, [2] AS Middle_Name, [3] AS Last_Name
FROM Name_CTE
PIVOT
(MAX(VALUE)
FOR 
ROWNUM IN([1],[2],[3])) AS Pivot_Table

--SELECT LEFT(EmployeeName,CHARINDEX(',', EmployeeName)-1) AS First_Name
--,RIGHT(EmployeeName,CHARINDEX(',', EmployeeName)-1) AS Last_Name
--FROM SpliteConcatenatedString
--SELECT VALUE FROM string_split('Abdur,Rahim',',')
GO

-- Replace Special Characters
SELECT * , REPLACE(EmployeeName, ',',' ')
FROM SpliteConcatenatedString

SELECT * , REPLACE(REPLACE(REPLACE(EmployeeName, CHAR(9),''), CHAR(10), ''), CHAR(13), '')
FROM SpliteConcatenatedString
GO

-- Calculate working days without weekends
SELECT DATEDIFF(DAY, '2022-07-10', '2022-07-23') + 1
- DATEDIFF(WEEK,'2022-07-10', '2022-07-23') * 2
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-10') = 'Sunday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-23') = 'Saturday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-10') = 'Saturday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-23') = 'Sunday' THEN 1 ELSE 0 END)

SELECT DATEDIFF(DAY, '2022-07-15', '2022-07-30') + 1
- DATEDIFF(WEEK,'2022-07-15', '2022-07-30') * 2
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-15') = 'Friday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-30') = 'Saturday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-15') = 'Saturday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-07-30') = 'Friday' THEN 1 ELSE 0 END)

SELECT DATEDIFF(DAY, '2022-01-01', '2022-01-31') + 1
- DATEDIFF(WEEK,'2022-01-01', '2022-01-31') * 2
- (CASE WHEN DATENAME(WEEKDAY, '2022-01-01') = 'Friday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-01-31') = 'Saturday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-01-01') = 'Saturday' THEN 1 ELSE 0 END)
- (CASE WHEN DATENAME(WEEKDAY, '2022-01-31') = 'Friday' THEN 1 ELSE 0 END)
GO

-- Find Age from Birth Date
SELECT Id, FirstName, LastName,BirthDate,
(CASE WHEN
DATEADD(YEAR,DATEDIFF(YEAR, BirthDate, GETDATE()), BirthDate) > GETDATE() 
THEN DATEDIFF(YEAR, BirthDate, GETDATE()) -1
ELSE
DATEDIFF(YEAR, BirthDate, GETDATE()) END) AS AGE
FROM FindAgeFromBirthDate
WHERE MONTH(BirthDate) > MONTH(GETDATE())
GO

-- Remove Zero from decimal value
SELECT *, CAST(Salary AS FLOAT) AS Sal 
FROM NthHighestSalary
GO

-- Extract Number and Alphabet from Alphanumeric string
SELECT *,
TRIM(TRANSLATE(EmployeeName, '0123456789','          ')) AS Name,
TRIM(TRANSLATE(EmployeeName, TRANSLATE(EmployeeName, '0123456789','          '), SPACE(LEN(TRANSLATE(EmployeeName, '0123456789','          '))))) AS ID
FROM ExtractNumberAndAlphabet
GO

-- Cumulative Sum
SELECT EmployeeId, FirstName, LastName, DepartmentName, Gender, CAST(Salary AS FLOAT) AS SAL,
CAST(SUM(Salary) OVER(PARTITION BY DepartmentName ORDER BY EmployeeId) AS FLOAT) AS CumulativeSum
FROM CumulativeSum
