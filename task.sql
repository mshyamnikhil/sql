drop Table tbl
(
 SalesAgent nvarchar(10),
 SalesCountry nvarchar(10),
 SalesAmount int
)
Insert into tbl (SalesAgent ,SalesCountry ,SalesAmount )values
('shyam', 'UK', 200),
('nikhil', 'US', 180),
('nikhil', 'UK', 260),
('sriraj', 'India', 450),
('shyam', 'India', 350),
('sriraj', 'US', 200),
('shyam', 'US', 130),
('nikhil', 'India', 540),
('nikhil', 'UK', 120),
('sriraj', 'UK', 220),
('nikhil', 'UK', 420),
('sriraj', 'US', 320),
('shyam', 'US', 340),
('shyam', 'UK', 660),
('nikhil', 'India', 430),
('sriraj', 'India', 230),
('sriraj', 'India', 280),
('shyam', 'UK', 480),
('nikhil', 'US', 360),
('sriraj', 'UK', 140)






Select SalesAgent, India, US, UK
from tbl
Pivot
(
   Sum(SalesAmount) for SalesCountry in ([India],[US],[UK])
) as PivotTable



----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


select salesagent ,salescountry , salesamount from 
(

Select SalesAgent, India, US, UK
from tbl
Pivot
(
   Sum(SalesAmount) for SalesCountry in ([India],[US],[UK])
) as PivotTable

) as p 
unpivot 
(
       SalesAmount
       FOR salesCountry IN (India, US ,UK)
) AS UnpivotExample


--------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


Create Table tb2
(
 SalesAgent varchar(10),
 India int,
 US int,
 UK int
)


Insert into tb2 (SalesAgent,India,US,UK )
 values ('sriraj', 960, 520, 360),
       ('nikhil', 970, 540, 800)


SELECT SalesAgent, Country, SalesAmount
FROM tb2
UNPIVOT
(
       SalesAmount
       FOR Country IN (India, US ,UK)
) AS UnpivotExample

-----------------------------------------------------------------
-----------------------------------------------------------------------


Create Table Employees
(
    Id int primary key,
    Name varchar(10),
    Gender varchar(10),
    Salary int
)

 Insert Into Employees (
    Id ,
    Name ,
    Gender ,
    Salary 
)
Values(1, 'shyam', 'Male', 8000),
 (2, 'nikhil', 'Male', 8000),

 (3, 'bhavana', 'Female', 5000),
 (4, 'satya', 'Female', 4000),
 (5, 'sriraj', 'Male', 3500),
 (6, 'sri', 'Female', 6000),
 (7, 'vamsi', 'Male', 6500),
 (8, 'mounika', 'Female', 4500),
 (9, 'hemanth', 'Male', 7000),
 (10, 'sunny', 'Male', 6800)



 WITH Result AS
(
    SELECT name, Salary, RANK() OVER (partition by gender ORDER BY Salary DESC) AS Salary_Rank
    FROM Employees
)
SELECT TOP 1 Salary FROM Result WHERE gender is male and Salary_Rank = 3  


WITH Result AS
(
    SELECT Salary, Gender,
           DENSE_RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC)
           AS Salary_Rank
    FROM Employees
)
SELECT TOP 1 Salary FROM Result WHERE Salary_Rank = 1
AND Gender = 'Female'



---------------------------------------------------------------------------------
----------------------------------------------------------------------------------

SELECT MIN(salary)
FROM Employees;



SELECT COUNT(*)
FROM Employees;



SELECT SUM(salary)
FROM Employees;


SELECT AVG(salary)
FROM Employees;


-----------------------------------------------------------------------
---------------------------------------------------------------


CREATE TABLE tb3
(
  Id int Primary Key,
  Name varchar(10),
  Gender varchar(10),
  DepartmentId int
)

CREATE TABLE tb3Department
(
 DeptId int Primary Key,
 DeptName varchar(10)
)

Insert into tb3Department (deptid ,deptname )  values
 (1,'IT'),
 (2,'Payroll'),
 (3,'HR'),
 (4,'Admin')



 Insert into tb3 ( id , name, gender , departmentid ) values
 (1,'shyam', 'Male', 3),
 (2,'nikhil', 'Male', 2),
 (3,'bhavana', 'Female', 1),
 (4,'sriraj', 'Male', 4),
 (5,'satya', 'Female', 1),
 (6,'vamsi', 'Male', 3)




 --pivot
 select male , female
  from 
  ( 
 select id , name, gender , departmentid from tb3 ) as sourcetable
 pivot (  max(name) for gender in ( [male] , [female]) ) as pivotable


 ------------------------------------------------
                --cte -----
  -----------------------------------------------------
 With EmployeeCount(DepartmentId, TotalEmployees)
as
(
 Select DepartmentId, COUNT(*) as TotalEmployees
 from tb3
 group by DepartmentId
)

Select DeptName, TotalEmployees
from tb3Department
join EmployeeCount
on tb3Department.DeptId = EmployeeCount.DepartmentId
order by TotalEmployees


-------------------------------------------------------------------------------
   --cte updation --
------------------------------------------------------------------------------

With Employees_Name_Gender
as
(
 Select Id, Name, Gender from tb3
)
Update Employees_Name_Gender Set Gender = 'female' where Id = 1


With EmployeesByDepartment
as
(
 Select Id, Name, Gender, DeptName 
 from tb3
 join tb3Department
 on tb3Department.DeptId = tb3.DepartmentId
)
Update EmployeesByDepartment set Gender = 'Male' where Id = 1



---------------------------------------------------------------------------------------------------
       --CTE RECURSIVE -- 
---------------------------------------------------------------------------------------


Create Table tb4
(
  EmployeeId int Primary key,
  Name varchar(10),
  ManagerId int
)

Insert into tb4(EmployeeId ,Name ,ManagerId)
values
 (1, 'shyam', 2),
 (2, 'nikhil', null),
 (3, 'vamsi', 2),
 (4, 'sri', 3),
 (5, 'bhavana', 1),
 (6, 'hemanth', 3),
 (7, 'sriraj', 1),
 (8, 'Sam', 5),
 (9, 'satya', 1)

 select * from tb4


 With
  EmployeesCTE (EmployeeId, Name, ManagerId, [Level])
  as
  (
    Select EmployeeId, Name, ManagerId, 1
    from tb4
    where ManagerId is null
    
    union all
    
    Select tb4.EmployeeId, tb4.Name, 
    tb4.ManagerId, EmployeesCTE.[Level] + 1
    from tb4
    join EmployeesCTE
    on tb4.ManagerID = EmployeesCTE.EmployeeId
  )
Select EmpCTE.Name as Employee, Isnull(MgrCTE.Name, 'Super Boss') as Manager, 
EmpCTE.[Level] 
from EmployeesCTE EmpCTE
left join EmployeesCTE MgrCTE
on EmpCTE.ManagerId = MgrCTE.EmployeeId
