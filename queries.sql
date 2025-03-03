-- count all the customers
select count(*) as customers_count
from customers;

-- shows to 10 sellers
select 
	CONCAT(employees.first_name, ' ',  employees.last_name) as seller,
	COUNT(sales.sales_id) as operations,
	floor(sum(sales.quantity * products.price)) as income
from employees
join sales on employees.employee_id = sales.sales_person_id
join products on sales.product_id  = products.product_id
group by seller
order by income desc
limit 10;

-- shows all the sellers whose income is low than average
with avg_income as (
	select AVG(sales.quantity * products.price) as average_total_income
	from sales join products on sales.product_id  = products.product_id
),
	avg_s_income as (
	select
		CONCAT(employees.first_name, ' ',  employees.last_name) as seller,
		FLOOR(AVG(sales.quantity * products.price)) as average_income
	from employees
	join sales on employees.employee_id = sales.sales_person_id
	join products on sales.product_id  = products.product_id
	group by seller
)		
select 
	avg_s_income.seller as seller,
	avg_s_income.average_income as average_income
from avg_s_income, avg_income
where avg_s_income.average_income < avg_income.average_total_income
group by seller, average_income 
order by average_income;

-- shows sellers and their results by day of week
with sales_by_date as (
	select 
		CONCAT(employees.first_name, ' ',  employees.last_name) as seller,
		to_char(sales.sale_date, 'FMDay') as day_of_week,
		extract(isodow from sales.sale_date) as day_number,
		sum(sales.quantity * products.price) as income
	from employees
	join sales on employees.employee_id = sales.sales_person_id
	join products on sales.product_id  = products.product_id
	group by sales.sale_date, seller
	order by day_number
),
sales_by_day as (
	select seller, day_of_week, day_number, floor(sum(income)) as income
	from sales_by_date
	group by seller, day_of_week, day_number
	order by day_number, seller
)
select seller, day_of_week, income
from sales_by_day;
