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
/*
3. Who are our largest customers?
*/
/*
4. Which countries are our most important markets?
*/
/*
5. What’s the best-selling product, based on the number of units sold?
*/
/*
6. How many customers are “whales” i.e., have spent, in their lifetime, more than 
$4,000? How many are “shrimps,” having spent less than $20?
*/
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