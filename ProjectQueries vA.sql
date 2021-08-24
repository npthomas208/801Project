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
    group by product_name
    order by rev desc;
	
/*
6. How many customers are “whales” i.e., have spent, in their lifetime, more than 
$4,000? How many are “shrimps,” having spent less than $20?
*/

select concat(first_name,' ',last_name) as 'name', sum(quantity*unit_price) as 'rev' 
	from customers
	inner join orders
	on orders.customer_id = customers.id
    inner join order_details
    on orders.id = order_details.order_id
    group by name
    order by rev desc;


/*
7. Who are the top three suppliers by revenue, and where are they located?
*/



/*
8. What’s the best-selling product, based on the number of times the product has 
been ordered?
*/



/*
9. Who are our best performing employees in terms of the number of units sold?
*/



/*
10. Who are our best performing employees in terms of the dollar amount sold?
*/