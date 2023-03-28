use [EN-Employees]

SELECT * FROM sysobjects WHERE xtype='U' 

select * from Employee_Table
select * from Department_Table

select * from Employee
select * from Manager
select * from Department
select * from Designation
select * from Salary

/* #################################################################################################################### */

GO
with Employee_Manager_Dept_CTE as
(
select 
emp.employee_id,
emp.employee_name,
emp_dept.dept_name as emp_dept,
mng.manager_id,
mng.manager_name,
mng_dept.dept_name as mng_dept
from Employee emp
join Manager mng
on 
emp.employee_id = mng.employee_id
and
emp.employee_id <> mng.manager_id
join Department mng_dept
on
mng.manager_id = mng_dept.employee_id
join Department emp_dept
on
 emp.employee_id= emp_dept.employee_id
),


Manager_Salary as 
(
SELECT tab1.employee_id,employee_salary as manager_salary FROM salary sal
join Employee_Manager_Dept_CTE tab1
on sal.employee_id = tab1.manager_id
),

Employee_Salary as 
(
SELECT tab1.employee_id, employee_salary FROM salary sal
join Employee_Manager_Dept_CTE tab1
on sal.employee_id = tab1.employee_id
),

Employee_Gender as
(
SELECT tab1.employee_id, emp.employee_gender from Employee emp
join Employee_Manager_Dept_CTE tab1
on emp.employee_id = tab1.employee_id
),

Manager_Gender as
(
SELECT tab1.employee_id, emp.employee_gender from Employee emp
join Employee_Manager_Dept_CTE tab1
on emp.employee_id = tab1.manager_id
),

Manager_Dept as 
(
SELECT tab1.employee_id,dept.dept_name as manager_dept FROM Department dept
join Employee_Manager_Dept_CTE tab1
on dept.employee_id = tab1.manager_id
),

Employee_Dept as 
(
SELECT tab1.employee_id,dept.dept_name as emplyoee_dept FROM Department dept
join Employee_Manager_Dept_CTE tab1
on dept.employee_id = tab1.employee_id
),

Employee_Manager_CTE as
(
select 
tab1.employee_id,
tab1.employee_name,
tab4.employee_Gender,
tab3.employee_salary,
tab7.emplyoee_dept,
tab1.manager_id,
tab1.manager_name,
tab5.employee_Gender as manager_Gender,
tab2.manager_salary,
tab6.manager_dept
from 
Employee_Manager_Dept_CTE tab1
join Manager_Salary tab2
on tab1.employee_id = tab2.employee_id
join Employee_Salary tab3
on tab1.employee_id = tab3.employee_id
join Employee_Gender tab4
on tab1.employee_id = tab4.employee_id
join Manager_Gender tab5
on tab1.employee_id = tab5.employee_id
join Manager_Dept tab6
on tab1.employee_id = tab6.employee_id
join Employee_Dept tab7
on tab1.employee_id = tab7.employee_id
),

Employee_Gender_Pivot as
(

select emplyoee_dept,
ISNULL(Male,0) AS  Employee_Male ,
ISNULL(Female,0) AS  Employee_Female 
from 
(select emplyoee_dept,employee_Gender, count(employee_id) as emp_count from Employee_Manager_CTE
group by emplyoee_dept, employee_Gender) as groupby_clause
pivot
(
sum(emp_count)
for employee_gender in ([Male],[Female])
) as pivottable
),

Manager_Gender_Pivot as
(

select manager_dept,
ISNULL(Male,0) AS  Manager_Male ,
ISNULL(Female,0) AS  Manager_Female 
from 
(select manager_dept,manager_Gender, count(manager_id) as emp_count from Employee_Manager_CTE
group by manager_dept, manager_Gender) as groupby_clause
pivot
(
sum(emp_count)
for manager_Gender in ([Male],[Female])
) as pivottable
)

/* #################################################################################################################### */

/*select * from Employee_Manager_CTE

select * from Employee_Gender_Pivot ep
left join Manager_Gender_Pivot mp
on ep.emplyoee_dept = mp.manager_dept*/