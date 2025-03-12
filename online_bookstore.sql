create Database ONLINE_BOOOKSTORE
USE ONLINE_BOOOKSTORE

DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID INT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books
SELECT * FROM Customers
SELECT * FROM Orders

BULK INSERT Books
FROM 'C:\Users\ssmsd\Desktop\SQL_Resume_Project-main\SQL_Resume_Project-main\Books.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skip header row (adjust as needed)
    FIELDTERMINATOR = ',',  -- Separator for values
    ROWTERMINATOR = '0x0a',  -- New line as row delimiter
    TABLOCK
); 

BULK INSERT Customers
FROM 'C:\Users\ssmsd\Desktop\SQL_Resume_Project-main\SQL_Resume_Project-main\Customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skip header row (adjust as needed)
    FIELDTERMINATOR = ',',  -- Separator for values
    ROWTERMINATOR = '0x0a',  -- New line as row delimiter
    TABLOCK
);

BULK INSERT Orders
FROM 'C:\Users\ssmsd\Desktop\SQL_Resume_Project-main\SQL_Resume_Project-main\Orders.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skip header row (adjust as needed)
    FIELDTERMINATOR = ',',  -- Separator for values
    ROWTERMINATOR = '0x0a',  -- New line as row delimiter
    TABLOCK
);

-- retreive all books in fiction genre 
select 
Book_ID,
Genre
from 
Books
where 
Genre = 'fiction'

--find books published after the year 1950
select *
from
books
where 
Published_Year > 1950

--customers from canada
select * 
from 
Customers
where 
Country = 'Canada'

--orders placed in nov 2023
select * from Orders
where 
Order_Date between '2023-11-01' and '2023-11-30'

--total stocks of books available 
select 
SUM(stock) as [total stock]
from 
Books

--details of most expensive book
select 
max(price) as 'most expensive book'
from
books
--or
SELECT * 
FROM Books
order by Price desc
offset 1 row fetch next 1 row only

--for sql server 
select top 10*
from books
order by price

--all genre available in books table
select 
distinct 
Genre
from 
Books

--books with lowest stock 
select top 1* 
from 
books 
order by Stock asc

--total revenue generated from all orders
select 
sum(total_amount)
as 'REVENUE'
from Orders

--total number of books sold for each genre
select
b.genre,
sum(o.Quantity) as 'TOTAL BOOKS SOLD'
from 
books b 
join 
Orders o 
on b.Book_ID = o.Book_ID
group by 
b.Genre

--AVERAGE PRICE OF BOOKS IN THE FANTASY GENRE
select 
b.Genre,
round(avg(price),2) as 'avg price of "fantasy" genre'
from 
books b
where 
genre = 'fantasy'
group by 
b.Genre

--list customers who have placed atleast 2 orders
select 
c.Customer_ID,
c.Name,
count(o.Order_ID) as'order count'
from 
Customers c
join 
orders o
on c.Customer_ID = o.Customer_ID
group by c.Customer_ID,c.Name
having count(o.Order_ID)>=2
order by Customer_ID desc


--most frequently ordered book

SELECT top 10
    b.Book_ID,
    b.Title,
    COUNT(o.order_id) AS [order count]
FROM Books b
JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title
ORDER BY COUNT(o.order_id) DESC;

--or
SELECT b.Book_ID, b.Title, COUNT(o.order_id) AS order_count
FROM Books b
JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title
HAVING COUNT(o.order_id) = (
    -- Subquery to get the maximum order count
    SELECT MAX(order_count) 
    FROM (
        SELECT COUNT(o.order_id) AS order_count
        FROM Books b
        JOIN Orders o ON b.Book_ID = o.Book_ID
        GROUP BY b.Book_ID
    ) AS Subquery
);

--select top 3 most expensive books of 'fantasy' genre
select top 3
*
from books
where Genre='fantasy' 
order by price desc 

--total quantity of books sold by each author
select 
b.Author,
sum(o.Quantity) as 'total books sold'
from 
books b join orders o on 
b.Book_ID = o.Book_ID
group by 
b.Author

--list cities where customer who spend over $30 are located
select top 1
c.Customer_ID,
c.Name,
sum(o.Total_Amount) as 'total amount'
from 
orders o
join 
customers c
on o.Customer_ID = c.Customer_ID
group by c.Customer_ID, c.Name
order by 'total amount' desc 

--or 
select 
distinct c.city,
o.Total_Amount
from orders o
join customers c on o.Customer_ID = c.Customer_ID
where o.total_amount>30

-- calculate the stock remaining after fullfilling all orders
select 
b.Book_ID,b.Title,b.stock,
coalesce(sum(quantity),0) as 'order quantity',
b.stock - coalesce(sum(quantity),0) as 'Remaining Qty'
from books b
left join orders o 
on b.Book_ID = o.Book_ID
group by b.Book_ID,b.Title,b.Stock
--having b.Book_ID =  273
order by b.Book_ID