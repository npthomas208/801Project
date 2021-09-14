use project;

/*
1. What were our total sales per quarter last year?
*/

select quarter(order_date),sum(quantity*unit_price)
	from orders
	inner join order_details
    on orders.id = order_details.order_id
    group by quarter(order_date);	

/*
2. Which are our highest revenue-generating products?
*/

select product_id, product_name,sum(quantity*unit_price) as 'rev'
	from orders
	inner join order_details
    on orders.id = order_details.order_id
    inner join products
    on products.id = order_details.product_id
    group by product_id
    order by rev desc;

/*
3. Who are our largest customers?
*/

select company, sum(quantity*unit_price) as 'rev' 
	from customers
	inner join orders
	on orders.customer_id = customers.id
    inner join order_details
    on orders.id = order_details.order_id
    group by company
    order by rev desc;

/*
4. Which countries are our most important markets?
*/

select country_region, sum(quantity*unit_price) as 'rev' 
	from customers
	inner join orders
	on orders.customer_id = customers.id
    inner join order_details
    on orders.id = order_details.order_id
    group by country_region
    order by rev desc;

/*
5. What’s the best-selling product, based on the number of units sold?
*/

select product_id, product_name,sum(quantity) as 'rev'
	from orders
	inner join order_details
    on orders.id = order_details.order_id
    inner join products
    on products.id = order_details.product_id
    group by product_id
    order by rev desc;
	
/*
6. How many customers are “whales” i.e., have spent, in their lifetime, more than 
$4,000? How many are “shrimps,” having spent less than $20?
*/

select * from
	(select concat(first_name,' ',last_name) as 'name_', sum(quantity*unit_price) as 'rev' 
	from customers
	inner join orders
	on orders.customer_id = customers.id
    inner join order_details
    on orders.id = order_details.order_id
    group by name_
    order by rev desc) as tmp
    where rev > 4000;

select * from
	(select concat(first_name,' ',last_name) as 'name_', sum(quantity*unit_price) as 'rev' 
	from customers
	inner join orders
	on orders.customer_id = customers.id
    inner join order_details
    on orders.id = order_details.order_id
    group by name_
    order by rev desc) as tmp
    where rev < 20;


/*
7. Who are the top three suppliers by revenue, and where are they located?

Assuming we sell all products ordered... I'm assuming we can base revenue on the assume list price in the products table, instead of the order details.unit_price
*/

select customer_order_id from inventory_transactions
	where customer_order_id is not null;

select type_name from inventory_transactions
    inner join inventory_transaction_types
    on inventory_transaction_types.id = inventory_transactions.transaction_type;

/*
There appears to be exactly 0 waste.
*/

select suppliers.company,
	products.product_name,
    type_name,
    sum(inventory_transactions.quantity*products.list_price) as 'revenue'
	from suppliers
    inner join purchase_orders
    on suppliers.id = purchase_orders.supplier_id
    inner join purchase_order_details
    on purchase_orders.id = purchase_order_details.purchase_order_id
	inner join inventory_transactions
    on inventory_transactions.id = purchase_order_details.inventory_id
	inner join products
    on products.id = inventory_transactions.product_id
    inner join inventory_transaction_types
    on inventory_transaction_types.id = inventory_transactions.transaction_type
    group by suppliers.company, products.product_name, type_name
    order by revenue desc;

/*
Are there multiple suppliers for products?
*/

select products.id,company
	from suppliers
    inner join purchase_orders
    on suppliers.id = purchase_orders.supplier_id
    inner join purchase_order_details
    on purchase_orders.id = purchase_order_details.purchase_order_id
	inner join inventory_transactions
    on inventory_transactions.id = purchase_order_details.inventory_id
	inner join products
    on products.id = inventory_transactions.product_id
    group by products.id,company;
    
/*
There appears to be a one to one relationship between product and supplier.
*/

/*
8. What’s the best-selling product, based on the number of times the product has 
been ordered?
*/

select suppliers.company,
	products.product_name,
    count(purchase_orders.id) as 'po_quantity'
	from suppliers
    inner join purchase_orders
    on suppliers.id = purchase_orders.supplier_id
    inner join purchase_order_details
    on purchase_orders.id = purchase_order_details.purchase_order_id
	inner join inventory_transactions
    on inventory_transactions.id = purchase_order_details.inventory_id
	inner join products
    on products.id = inventory_transactions.product_id
    inner join inventory_transaction_types
    on inventory_transaction_types.id = inventory_transactions.transaction_type
    group by suppliers.company, products.product_name
    order by po_quantity desc;

/*
9. Who are our best performing employees in terms of the number of units sold?
*/

select * from purchase_orders;

select employees.id,first_name,last_name,
	sum(purchase_order_details.quantity) as 'units_sold'
	from employees
    inner join purchase_orders
    on employees.id = purchase_orders.submitted_by
	inner join purchase_order_details
    on purchase_orders.id = purchase_order_details.purchase_order_id
    group by employees.id
    order by units_sold desc;
    
    
/*
10. Who are our best performing employees in terms of the dollar amount sold?
*/

select employees.id,first_name,last_name,
  sum(order_details.quantity*order_details.unit_price) as '$_amount_sold'
  from employees
    inner join orders
    on employees.id = orders.employee_id
  inner join order_details
    on orders.id = order_details.order_id
    group by employees.id
    order by $_amount_sold desc;

/*
GROUP DEVELOPED QUESTIONS...
*/ 

/*
<<<<<<< HEAD
Which state/province consists of the largest number of customer orders within 2019?
=======
1. Which state/province consists of the largest number of purchase orders within 2019? 
orders from cusomers, using the shipped to address:
>>>>>>> e2029a42d245944d0d5fcc9384f8fd88a46432f3
*/

select orders.ship_state_province,
	company,
	count(orders.id) as 'po_counts'
	from orders 
    inner join customers
    on orders.customer_id = customers.id
    group by company,orders.ship_state_province
    order by po_counts desc;

/*
2. How many purchase orders are generated based on customer orders vs restocking from suppliers?
*/

/*
3. What category of products has the highest standard cost?
*/

select category, avg(standard_cost) as avg_standard_cost
	from products 
	group by category
    order by avg_standard_cost desc;

/**** of these which has the highest sc*/

select *
	from products 
	where standard_cost = (select MAX(standard_cost) as maximum from products);
    
/*
4. What is the average difference and standard deviation of the difference between standard cost and actual cost?
*/

/****This first query is investigatory****/

select unit_cost, standard_cost, (unit_cost-standard_cost) as diff
	from purchase_order_details
    inner join products
    on products.id = purchase_order_details.product_id;

/****This one answers the question****/

select avg(diff) as average_difference, stddev_samp(diff) as stddev_difference, 
	(select sum(quantity)
	from purchase_order_details) as total_quantity
    from
	(select (unit_cost-standard_cost) as diff
	from purchase_order_details
    inner join products
    on products.id = purchase_order_details.product_id) as tmp1;

/**** This one defines the total vendor "over change" which is negative, 
which means the company is typically getting discounts *****/

select total_quantity*average_difference as total_vendor_overcharge from
	(select avg(diff) as average_difference, stddev_samp(diff) as stddev_difference, 
	(select sum(quantity)
	from purchase_order_details) as total_quantity
    from
	(select (unit_cost-standard_cost) as diff
	from purchase_order_details
    inner join products
    on products.id = purchase_order_details.product_id) as tm1) as tmp2;

/*
5. What is the worst selling product based on the number of units sold?
*/

select product_id, product_name, sum(quantity) as total_quantity
	from order_details
    inner join products
    on products.id = order_details.product_id
    group by product_id
    order by total_quantity
    limit 1;

/*
6. Who are the worst performing employees based on units sold per region?
*/

/**** This shows all ****/

select concat(employees.first_name,' ', employees.last_name) as emp,
	orders.ship_country_region, sum(order_details.quantity) as sale_volume, 
    sum(order_details.quantity*unit_price) as total_sales
    from orders
    inner join employees
    on orders.employee_id = employees.id
    inner join order_details
    on order_details.order_id = orders.id
    group by emp, orders.ship_country_region
    with rollup;

/**** This answers the question****/

select concat(employees.first_name,' ', employees.last_name) as emp,
	orders.ship_country_region, sum(order_details.quantity) as sale_volume, 
    sum(order_details.quantity*unit_price) as total_sales
    from orders
    inner join employees
    on orders.employee_id = employees.id
    inner join order_details
    on order_details.order_id = orders.id
    group by emp, orders.ship_country_region
    order by sale_volume
    limit 1;

/*
7. What’s our turnaround time for shipping?
*/

/**** unfortunately all payment dates and expected dates are null ****/
select payment_date
	from purchase_orders;

select payment_date, date_received 
	from purchase_orders
	right join purchase_order_details
    on purchase_orders.id = purchase_order_details.purchase_order_id;

/**** using approved_date as alternative ****/

select approved_date, date_received, datediff(date_received,approved_date) as shipping_days,
	product_name, suppliers.company
	from purchase_orders
	right join purchase_order_details
    on purchase_orders.id = purchase_order_details.purchase_order_id
    inner join products
    on products.id = purchase_order_details.product_id
    inner join suppliers
    on purchase_orders.supplier_id = suppliers.id
    where (approved_date is not null) and (date_received is not null)
    order by shipping_days desc;


/*
8. How does unit cost in the PO detail table differ from standard cost

Duplicate - ignore.
*/

/*
9. What potential surplus/deficit may occur due to transaction waste or failed allocation of resources could result in profit/loss?
*/

/*
<<<<<<< HEAD

What is the variance between standard cost and actual cost?
What is the worst selling product based on the number of units sold?
Who are the worst performing employees based on units sold per region?
What’s our turnaround time for shipping?
Payment date and received 
How does unit cost in the PO detail table differentiate from the standard cost?
What potential surplus/deficit may occur due to failed allocation of resources could result in profit/loss?
How many purchase orders are on hold and what proportions?
How many customer orders are on hold and what proportions?
*/

/*
****What category of product has the highest margin?*****
=======
10. How many pruchase orders are on hold and what proportions?
*/

select * from inventory_transactions
	inner join inventory_transaction_types
    on transaction_type = inventory_transaction_types.id;

select type_name, (purchase_order_id is not null),
	(customer_order_id is not null)
	from inventory_transactions
	inner join inventory_transaction_types
    on inventory_transactions.transaction_type = inventory_transaction_types.id;
    
/*
11. How many customer orders are on hold and what proportions?
*/

/*
12. What product has the highest margin?
>>>>>>> e2029a42d245944d0d5fcc9384f8fd88a46432f3
*/

select *,margin/total_cost 
	as 'perc_margin' from (
	select product_id, product_name,round(sum(order_details.quantity*order_details.unit_price)) as 'total_rev',
	round(sum(order_details.quantity*products.standard_cost)) as 'total_cost',
    round(sum((order_details.quantity*order_details.unit_price-order_details.quantity*products.standard_cost)/order_details.quantity*order_details.unit_price)) as 'margin'
	from orders
	inner join order_details
    on orders.id = order_details.order_id
    inner join products
    on products.id = order_details.product_id
    group by product_id) as tmp 
    order by perc_margin desc;
<<<<<<< HEAD
    
=======

/*
13. What is typical invoice payment lag time, and how do customers compare on average?
*/

select company,avg(datediff(paid_date,invoice_date)) as avg_days_receipt_of_payment
	from orders, invoices, customers
    where orders.id = invoices.order_id and
    customers.id = orders.customer_id
    group by company
    order by avg_days_receipt_of_payment;



>>>>>>> e2029a42d245944d0d5fcc9384f8fd88a46432f3
