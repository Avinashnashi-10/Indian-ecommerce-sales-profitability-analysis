use E_Commerce;

select * from list_order;
select* from orders;
select * from target;

select count(*) from list_order;
select count(*) from orders;
select count(*) from target;


DELIMITER //

CREATE PROCEDURE GetTotalRevenue()
BEGIN
    SELECT SUM(Amount) AS total_revenue
    FROM orders;
END //

DELIMITER ;
call getTotalRevenue();

DELIMITER //
CREATE procedure getLoyalCustomer()
begin
select CustomerName,count(*) as Loyal_customer from list_order
group by CustomerName
having count(*)>1;
end//
DELIMITER ;

call getLoyalCustomer();


DELIMITER //
CREATE procedure getTotalProfit()
begin
select sum(Profit) as Total_Profit from orders;
end//
DELIMITER ;

call getTotalProfit();


DELIMITER //
CREATE procedure getTotalUnitSold()
begin
select sum(Quantity) as Total_Quantity from orders;
end//
DELIMITER ;

call getTotalUnitSold();


select Category,sum(Amount) as Revenue,sum(Profit) as Total_Profit,sum(Quantity) as TotalUnitSold 
from orders
group by Category
order by Revenue desc;

select Category,sum(Amount) as Revenue,sum(Profit) as Total_Profit,
round(sum(profit)/sum(amount) *100,2) as Profit_margin
from orders
group by Category
order by Profit_margin desc;


select 
`Sub-Category`,
sum(Amount) as Revenue,
sum(Profit) as Total_Profit,
sum(Quantity) as TotalUnitSold 
from orders
group by `Sub-Category`
order by Revenue desc;



select 
	`Sub-Category`,
    sum(Amount) as Revenue,
    sum(Profit) as Profit,
    round(sum(Profit)/sum(Amount)*100 ,2) as Profit_margin
from orders
group by `Sub-Category`
order by Profit_margin desc;


select 
`Sub-Category`,
sum(Amount) as Revenue,
sum(Profit) as Total_Profit,
sum(Quantity) as TotalUnitSold 
from orders
group by `Sub-Category`
having Total_Profit < 0
order by Total_profit;


select 
	l.State,
    sum(O.Amount) as Revenue,
    sum(O.Profit) as Profit
FROM List_order L
	RIGHT JOIN ORDERS O
    on l.`Order ID` = O.`Order ID`
group by l.state
order by Revenue desc;
    
select 
	l.State,
    sum(O.Amount) as Revenue,
    sum(O.Profit) as Profit,
    Round(sum(O.Profit)/sum(O.Amount)*100,2) as Profit_margin
FROM List_order L
	INNER JOIN ORDERS O
    on l.`Order ID` = O.`Order ID`
group by l.state
order by Profit_margin desc;

select l.State,Sum(O.Amount) as Revenue
from list_order l
inner join Orders O
on O.`Order ID`=l.`Order ID`
group by l.State
order by Revenue desc
limit 5;

select l.State,Sum(O.Amount) as Revenue,sum(Profit) as Profit
from list_order l
inner join Orders O
on O.`Order ID`=l.`Order ID`
group by l.State
order by Profit desc
limit 5;

select 
	l.State,
    sum(O.Amount) as Revenue,
    sum(O.Profit) as Profit,
    Round(sum(O.Profit)/sum(O.Amount)*100,2) as Profit_margin
FROM List_order L
	INNER JOIN ORDERS O
    on l.`Order ID` = O.`Order ID`
group by l.state
order by Profit_margin desc
limit 5;


select date_format(l.`Order Date`,'%Y-%m')as month,sum(o.Amount) as Revenue,sum(o.profit) as Profit
from list_order l
inner join orders o
on l.`Order ID` = O.`Order ID`
group by month
order by month;

select date_format(l.`Order Date`,'%Y-%m')as month,sum(o.Amount) as Revenue,sum(o.profit) as Profit
from list_order l
inner join orders o
on l.`Order ID` = O.`Order ID`
group by month
order by profit 
limit 1;

select date_format(l.`Order Date`,'%Y-%m')as month,sum(o.Amount) as Revenue,sum(o.profit) as Profit
from list_order l
inner join orders o
on l.`Order ID` = O.`Order ID`
group by month
order by profit desc
limit 1;

select
	o.Category,
    sum(o.Amount) as Revenue,
    sum(o.Profit) as Profit 
from List_order l
inner join orders o
    on l.`Order ID`=o.`Order ID`
where date_format(l.`Order Date`,'%Y-%m') = '2018-06'
group by o.Category
order by Profit asc;

select
	o.Category,
    sum(o.Amount) as Revenue,
    sum(o.Profit) as Profit ,
    sum(Quantity) as Quantity,
    round(sum(o.Amount)/sum(o.Profit) *100,2) as Profit_margin
from List_order l
inner join orders o
    on l.`Order ID`=o.`Order ID`
where date_format(l.`Order Date`,'%Y-%m') = '2018-06'
group by o.Category
order by Profit asc;

select
	o.`Sub-Category`,
    sum(o.Amount) as Revenue,
    sum(o.Profit) as Profit 
from List_order l
inner join orders o
    on l.`Order ID`=o.`Order ID`
where date_format(l.`Order Date`,'%Y-%m') = '2018-06'
group by o.`Sub-Category`
order by Profit asc
limit 10;

SELECT
    DATE_FORMAT(l.`Order Date`, '%Y-%m') AS month,
    o.Category,
    SUM(o.Amount) AS actual_revenue,
    s.Target AS target,
    SUM(o.Amount) - s.Target AS difference,
    ROUND(SUM(o.Amount) / s.Target * 100, 2) AS achievement_pct
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
JOIN target s
    ON DATE_FORMAT(l.`Order Date`, '%Y-%m') =
       DATE_FORMAT(s.`Month of Order Date`, '%Y-%m')
    AND o.Category = s.Category
GROUP BY
    month,
    o.Category,
    s.Target
ORDER BY month, o.Category;



WITH actual_sales AS (
    SELECT
        DATE_FORMAT(l.`Order Date`, '%Y-%m') AS month,
        o.Category,
        SUM(o.Amount) AS actual_revenue
    FROM list_order l
    JOIN orders o
        ON l.`Order ID` = o.`Order ID`
    GROUP BY month, o.Category
)

SELECT
    a.Category,
    SUM(a.actual_revenue) AS actual_revenue,
    SUM(s.Target) AS total_target,
    ROUND(
        SUM(a.actual_revenue) / SUM(s.Target) * 100,
        2
    ) AS achievement_pct
FROM actual_sales a
JOIN target s
    ON a.month = DATE_FORMAT(s.`Month of Order Date`, '%Y-%m')
    AND a.Category = s.Category
GROUP BY a.Category
ORDER BY achievement_pct DESC;


SELECT
l.CustomerName,
SUM(o.Amount) AS revenue,
SUM(o.Profit) AS profit
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY l.CustomerName
ORDER BY revenue DESC
LIMIT 10;


SELECT
l.CustomerName,
SUM(o.Amount) AS revenue,
SUM(o.Profit) AS profit
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY l.CustomerName
HAVING SUM(o.Profit) < 0
ORDER BY profit ASC;


SELECT
    l.CustomerName,
    SUM(o.Amount) AS revenue,
    SUM(o.Profit) AS profit
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
GROUP BY l.CustomerName
HAVING SUM(o.Profit) < 0
ORDER BY profit ASC
LIMIT 5;

SELECT
    l.CustomerName,
    o.`Sub-Category`,
    o.Amount,
    o.Profit,
    o.Quantity
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
WHERE l.CustomerName = 'Shishu'
ORDER BY o.Profit ASC;

SELECT
    `Sub-Category`,
    SUM(Amount) AS revenue,
    SUM(Profit) AS profit
FROM orders
WHERE `Sub-Category` = 'Bookcases'
GROUP BY `Sub-Category`;


SELECT
    l.`Order ID`,
    l.`Order Date`,
    l.CustomerName,
    o.`Sub-Category`,
    o.Amount,
    o.Profit,
    o.Quantity
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
WHERE l.CustomerName = 'Shishu'
  AND o.`Sub-Category` = 'Bookcases'
ORDER BY o.Profit ASC;

SELECT
l.`Order ID`,
l.CustomerName,
l.`Order Date`,
o.Amount,
o.Profit,
o.Quantity
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
WHERE o.`Sub-Category` = 'Bookcases'
AND o.Profit < 0
ORDER BY o.Profit ASC;


SELECT
    l.CustomerName,
    SUM(o.Profit) AS bookcase_profit
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
WHERE o.`Sub-Category` = 'Bookcases'
GROUP BY l.CustomerName
HAVING SUM(o.Profit) < 0
ORDER BY bookcase_profit ASC
LIMIT 5;

SELECT
    l.CustomerName,
    SUM(o.Amount) AS revenue,
    SUM(o.Profit) AS profit,
    ROUND(SUM(o.Profit) / SUM(o.Amount) * 100, 2) AS profit_margin
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
WHERE o.`Sub-Category` = 'Bookcases'
GROUP BY l.CustomerName
HAVING SUM(o.Profit) < 0
ORDER BY profit_margin ASC
LIMIT 5;

SELECT
    l.CustomerName,
    COUNT(DISTINCT l.`Order ID`) AS order_count,
    SUM(o.Amount) AS revenue,
    SUM(o.Profit) AS profit
FROM list_order l
JOIN orders o
    ON l.`Order ID` = o.`Order ID`
GROUP BY l.CustomerName
ORDER BY order_count DESC;

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit
FROM (
    SELECT
        l.CustomerName,
        COUNT(DISTINCT l.`Order ID`) AS order_count,
        SUM(o.Amount) AS revenue,
        SUM(o.Profit) AS profit
    FROM list_order l
    JOIN orders o
        ON l.`Order ID` = o.`Order ID`
    GROUP BY l.CustomerName
) AS customer_summary
GROUP BY customer_type;


SELECT
CASE
WHEN order_count = 1 THEN 'One-time'
ELSE 'Repeat'
END AS customer_type,
COUNT(*) AS customers,
ROUND(SUM(revenue) / COUNT(*), 2) AS avg_revenue_per_customer,
ROUND(SUM(profit) / COUNT(*), 2) AS avg_profit_per_customer
FROM (
    SELECT
l.CustomerName,
COUNT(DISTINCT l.`Order ID`) AS order_count,
SUM(o.Amount) AS revenue,
SUM(o.Profit) AS profit
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY l.CustomerName
) AS customer_summary
GROUP BY customer_type;

SELECT
`Sub-Category`,
SUM(Quantity) AS total_quantity,
SUM(Amount) AS revenue,
SUM(Profit) AS profit
FROM orders
GROUP BY `Sub-Category`
ORDER BY total_quantity DESC;

SELECT
`Sub-Category`,
SUM(Quantity) AS total_quantity,
SUM(Profit) AS total_profit,
ROUND(SUM(Profit) / SUM(Quantity), 2) AS profit_per_unit
FROM orders
GROUP BY `Sub-Category`
ORDER BY profit_per_unit DESC;

SELECT
l.`Order ID`,
l.CustomerName,
o.`Sub-Category`,
o.Amount,
o.Profit,
o.Quantity
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
ORDER BY o.Profit ASC
LIMIT 10;

SELECT
`Sub-Category`,
SUM(Profit) AS total_profit,
SUM(CASE WHEN Profit < 0 THEN Profit ELSE 0 END) AS loss_from_loss_orders,
COUNT(CASE WHEN Profit < 0 THEN 1 END) AS loss_order_count
FROM orders
GROUP BY `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC;

-- view

CREATE  VIEW category_performance AS
SELECT
    Category,
    SUM(Amount) AS total_revenue,
    SUM(Profit) AS total_profit,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(Profit) / SUM(Amount) * 100, 2) AS profit_margin
FROM orders
GROUP BY Category;

SELECT * FROM category_performance;

CREATE  VIEW state_performance AS
SELECT
l.State,
SUM(o.Amount) AS total_revenue,
SUM(o.Profit) AS total_profit,
SUM(o.Quantity) AS total_quantity,
ROUND(SUM(o.Profit) / SUM(o.Amount) * 100, 2) AS profit_margin
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY l.State;

SELECT * FROM state_performance
ORDER BY total_profit DESC;


CREATE VIEW monthly_performance AS
SELECT
DATE_FORMAT(l.`Order Date`, '%Y-%m') AS month,
SUM(o.Amount) AS total_revenue,
SUM(o.Profit) AS total_profit,
SUM(o.Quantity) AS total_quantity
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY month;

SELECT * FROM monthly_performance
ORDER BY month;


CREATE  VIEW customer_performance AS
SELECT
l.CustomerName,
COUNT(DISTINCT l.`Order ID`) AS order_count,
SUM(o.Amount) AS total_revenue,
SUM(o.Profit) AS total_profit,
ROUND(SUM(o.Profit) / SUM(o.Amount) * 100, 2) AS profit_margin
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY l.CustomerName;

SELECT * FROM customer_performance
ORDER BY total_revenue DESC;


CREATE  VIEW target_vs_actual AS
WITH actual_sales AS (
SELECT
DATE_FORMAT(l.`Order Date`, '%Y-%m') AS month,
o.Category,
SUM(o.Amount) AS actual_revenue
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
GROUP BY
month,
o.Category
)
SELECT
a.month,
a.Category,
a.actual_revenue,
s.Target AS target_revenue,
a.actual_revenue - s.Target AS difference,
ROUND(
	a.actual_revenue / s.Target * 100,
        2
    ) AS achievement_pct
FROM actual_sales a
JOIN target s
ON a.month = DATE_FORMAT(s.`Month of Order Date`, '%Y-%m')
AND a.Category = s.Category;


SELECT * FROM target_vs_actual
ORDER BY month, Category;



SHOW FULL TABLES
WHERE Table_type = 'VIEW';


DELIMITER //

CREATE PROCEDURE GetSalesByState(IN state_name VARCHAR(100))
BEGIN
SELECT
l.State,
SUM(o.Amount) AS total_revenue,
SUM(o.Profit) AS total_profit,
ROUND(SUM(o.Profit) / SUM(o.Amount) * 100, 2) AS profit_margin
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
WHERE l.State = state_name
GROUP BY l.State;
END //

DELIMITER ;

CALL GetSalesByState('Maharashtra');

CALL GetSalesByState('Delhi');

CALL GetSalesByState('Karnataka');


DELIMITER //

CREATE PROCEDURE GetSalesByDate(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
SELECT
SUM(o.Amount) AS total_revenue,
SUM(o.Profit) AS total_profit,
SUM(o.Quantity) AS total_quantity
FROM list_order l
JOIN orders o
ON l.`Order ID` = o.`Order ID`
WHERE l.`Order Date` BETWEEN start_date AND end_date;
END //

DELIMITER ;

CALL GetSalesByDate('2018-04-01', '2018-06-30');