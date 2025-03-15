-- step 4
-- count all the customers
select count(*) as customers_count
from customers;

-- step 5
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
		to_char(sales.sale_date, 'fmday') as day_of_week,
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

-- step 6
-- customers age groups
select 
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category,
	count(*) as age_count
from customers
group by age_category
order by age_category;

-- sales by month
select
	to_char(sales.sale_date, 'YYYY-MM') as selling_month,
	count(distinct sales.customer_id) as total_customers,
	floor(sum(sales.quantity * products.price)) as income
from sales
join products on sales.product_id = products.product_id
group by selling_month;

-- first sale if it was done during speccial offer period (with zero price)
with first_sale as (
	select
		distinct customer_id,
		first_value(sales_person_id) over (partition by customer_id order by sale_date) as sales_person,
		first_value(product_id) over (partition by customer_id order by sale_date) as product,
		first_value(sale_date) over (partition by customer_id order by sale_date) as first_sale_date
	from sales
	order by customer_id
)
select
	CONCAT(customers.first_name, ' ',  customers.last_name) as customer,
	first_sale_date as sale_date,
	CONCAT(employees.first_name, ' ',  employees.last_name) as seller
from first_sale
join employees on first_sale.sales_person = employees.employee_id
join customers on first_sale.customer_id = customers.customer_id
join products on first_sale.product = products.product_id
where products.price = 0;
