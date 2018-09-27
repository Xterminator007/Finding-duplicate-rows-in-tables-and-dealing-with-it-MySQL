#How to find duplicate rows in a table and delete them with SQL
/* For example: Duplicate rows from duplicate_dept table
	dept_no	dept_name			
	d001	Marketing			
	d001	Marketing			
	d002	Finance				
	d002	Finance				
	d003	Human Resources		
	d003	Human Resources		
	d004	Production			
	d004	Production			
	d005	Development			
	d005	Development			
	d006	Quality Management	
	d006	Quality Management	
	d007	Sales				
	d007	Sales				
	d008	Research			
	d008	Research			
	d009	Customer Service	
	d009	Customer Service	
	d010	Business Analysis	
    */
    

/* Display the duplicate rows and the number of time its repeating with COUNT() 
*/
Select 
    dept_no, dept_name, COUNT(*) as count
FROM
    departments_dup
GROUP BY dept_no , dept_name
ORDER BY dept_no ASC;
/* This also includes rows without duplicates */


/* To filter and display just duplicate rows use HAVING() clause 
*/
SELECT 
    dept_no, dept_name, COUNT(*) as count
FROM
    departments_dup
GROUP BY dept_no , dept_name
HAVING COUNT(*) > 1
ORDER BY dept_no ASC;

/* 	The output shows table with one row for each copy with its count. 
	To display both identical rows (original and duplicate rows) : 
	Query the above table again inside nested select.
*/

SELECT 
    *
FROM
    departments_dup
WHERE
    (dept_no ,dept_name) IN (SELECT 
            dept_no, dept_name
        FROM
            departments_dup
        GROUP BY dept_no , dept_name
        HAVING COUNT(*) > 1
        )
ORDER BY dept_no ASC;

/* Note : For large tables this will take a long time as you have to do two full scans of the table
*/

/*
Group By is one way of doing this.
Another way of doing this is using "analytics functions". 
*/

/*
Use OVER() clause after the COUNT(*).
List the columns that define the dulicate items identified in previous steps.
PARTITION BY() clause splits the groups in two.
*/

Select *,count(*) over (partition by dept_no, dept_name) as counts
from departments_dup;

/* What difference did it make?
Unlike GROUP BY, analytics preserves the result set, meaning all rows are displayed.
And also the table is referenced only once making it faster
*/

/*
Now lets display only the duplicated rows by using an inline view.
*/
Select *
from (
Select *,count(*) over (partition by dept_no, dept_name) as counts
from departments_dup) d
where counts > 1;

/* This didnt work as rowid is a function of ORACLE and not MYSQL
delete departments_dup 
where rowid not in (
select min(rowid)
from departments_dup d
group by dept_no, dept_name
);*/
 
#Deleting duplicate rows

/*
Delete using INNER JOIN for departments_dup table with itself
*/

DELETE f FROM departments_dup d
        INNER JOIN
    departments_dup f 
WHERE
    f.dept_no = d.dept_no
    AND f.dept_name = d.dept_name;

    
