# Host: mmatshez.lmu.build
# Username: matshez_admin
# Password: Genesis8848#

# 1. Display the details of all the films from the film table for R-rated films. (1 point)
SELECT * 
FROM film 
	WHERE rating = 'R';

# 2. Select the customer_id, first_name, and last_name for the active customers  (0 means inactive). 
#	Sort the customers by their last name and restrict the results to 10 customers. (1 point)
SELECT customer_id, first_name, last_name
FROM customer
	WHERE active = 1
	ORDER BY last_name
LIMIT 10;

# 3. Select the film titles that contains “an” in the title (1 point)
SELECT title
FROM film
	WHERE title LIKE '%an%';
    
#4.	Select film_id, title, rental_duration, and description for films with a rental duration of 
#	3 days and the title starts with “AIR” (1 point)

SELECT film_id, title, rental_duration, description
FROM film
	WHERE rental_duration = 3 
		AND title LIKE 'AIR%';
        
# 5. Select film_id, title, rental_rate, and rental_duration for films that can be rented for more than 1 day 
#	and at a cost of $0.99 or more. Sort the results by rental_rate then rental_duration. (2 points)

SELECT film_id, title, rental_rate, rental_duration
FROM film
WHERE rental_duration > 1 AND rental_rate >= 0.99
ORDER BY rental_rate, rental_duration;

# 6. Show the total number of customers from each of the countries (3 points)

SELECT country, COUNT(*) AS total_customers
FROM address
INNER JOIN city 
ON address.city_id = city.city_id
INNER JOIN country 
ON city.country_id = country.country_id
INNER JOIN customer 
ON address.address_id = customer.address_id
GROUP BY country;

# 7. Select film_id, title, replacement_cost, and rental_rate for films that cost $20 or more to replace 
# and the cost to rent is less than a dollar. (2 points)

SELECT film_id, title, replacement_cost, rental_rate
FROM film
WHERE replacement_cost >= 20.00 
	AND rental_rate < 1.00;
    
# 8. Select film_id, title, and rating for films that do not have a G, PG, and PG-13 rating.  
# Do not use the OR logical operator. (2 points)

SELECT film_id, title, rating
FROM film
	WHERE rating NOT IN ('G', 'PG', 'PG-13');

# 9. Using sub-queries show the film title, length, and rental rate for all the films for actors Penelope Guiness 
# and Tom Miranda (2 points)

SELECT film.title, film.length, film.rental_rate
FROM film
WHERE film.film_id IN (
  SELECT film_actor.film_id
  FROM film_actor
  INNER JOIN actor ON film_actor.actor_id = actor.actor_id
  WHERE actor.first_name = 'Penelope' AND actor.last_name = 'Guiness'
)
OR film.film_id IN (
  SELECT film_actor.film_id
  FROM film_actor
  INNER JOIN actor ON film_actor.actor_id = actor.actor_id
  WHERE actor.first_name = 'Tom' AND actor.last_name = 'Miranda'
);

# 10. Make a copy of the film table.  INSERT your favorite movie into this copy of the film table. 
# You can arbitrarily set the column values as long as they are related to the column. Only assign values 
# to columns that are not automatically handled by MySQL. (2 points)

-- create a new table named 'film_copy' based on the 'film' table
CREATE TABLE film_copy LIKE film;

-- copy the data from the 'film' table to the 'film_copy' table
INSERT INTO film_copy 
SELECT * 
FROM film;

-- insert my favorite movie into the 'film_copy' table
INSERT INTO film_copy (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features)
VALUES ('The Dark Knight', 'Batman fights the Joker in a battle for Gotham', 2008, 1, 3, 4.99, 152, 19.99, 'PG-13', 'Commentaries, Trailers');

# Check to confirm it worked and did not make typos
SELECT * 
FROM film_copy 
	WHERE title = 'The Dark Knight';
    
# 11. INSERT your two favorite actors/actresses into the actor table with a single SQL statement. (2 points)

INSERT INTO actor (first_name, last_name)
VALUES ('Keanu', 'Reeves'), ('Emma', 'Watson');

# Confirmation it worked
SELECT first_name, last_name
FROM actor
	WHERE first_name LIKE '%Keanu%' OR first_name LIKE '%Emma%';

# 12. The address2 column in the address table inconsistently defines what it means to not have an address2 associated 
# with an address. UPDATE the address2 column to an empty string where the address2 value is currently null. (2 points)

UPDATE address
SET address2 = ''
	WHERE address2 IS NULL;

# I received a message saying 4 rows changed but I cannot determine which ones. Also, the column still defaults to null. 
# Confirm with Dr. Seal if I am answering the question correctly. 
SHOW columns
FROM address;

# 13. For each of the films, list the film title and all the actors (first and last names) in that film.  
# The result should display one row for each film.  Note that you have to use the GROUP_CONCATENATE function. (3 points)

SELECT film.title, GROUP_CONCAT(actor.first_name, ' ', actor.last_name) AS actors
FROM film
JOIN film_actor 
ON film.film_id = film_actor.film_id
JOIN actor 
ON film_actor.actor_id = actor.actor_id
GROUP BY film.film_id;

# 14. Multiple parts:
#	a.	Film title and number of copies in each store
#	b.	The film titles that were never returned and the corresponding customer names
#	c.	A final query that would show the store id, film title, number of copies that the store is supposed to 
#	have (as found in query 1) and the number of copies never returned (hint: query 2 and either VIEWS/CTE/Subqueries and JOIN).
#	(6 points)

# Part a)
SELECT film.title, inventory.store_id, COUNT(*) AS num_copies
FROM inventory
JOIN film 
ON inventory.film_id = film.film_id
GROUP BY film.film_id, inventory.store_id;

# Part b)
SELECT film.title, customer.first_name, customer.last_name
FROM rental
JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
JOIN film 
ON inventory.film_id = film.film_id
JOIN customer 
ON rental.customer_id = customer.customer_id
	WHERE rental.return_date IS NULL;
    
# Part c) 
SELECT 
  i.store_id, 
  f.title, 
  COUNT(i.film_id) AS num_copies, 
  (SELECT COUNT(*) 
	FROM rental r JOIN 
		inventory inv 
			ON r.inventory_id = inv.inventory_id 
				WHERE inv.film_id = i.film_id 
					AND r.return_date IS NULL) AS num_not_returned
FROM inventory i
JOIN film f 
ON i.film_id = f.film_id
GROUP BY i.store_id, f.title;

### SPECIALTY FOODS SECTION

# 16. Count the number of records in the order table. (1 points)

SELECT COUNT(*) AS num_orders 
FROM Orders;
# 830 orders

# 17. The warehouse manager wants to know all of the products the company carries. Generate a list of all the products 
# with all of the columns. (1 point)

SELECT*
FROM Products;

# 18. The marketing department wants to run a direct mail marketing campaign to its American, Canadian, and Mexican customers.
# Write a query to gather the data needed for a mailing label. (2 points)

SELECT CompanyName, ContactName, Address, City, Region, PostalCode, Country
FROM Customers
WHERE Country IN ('USA', 'Canada', 'Mexico');

# 19. HR wants to celebrate hire date anniversaries for the sales representatives in the USA office. 
# Develop a query that would give HR the information they need to coordinate hire date anniversary gifts. 
# Sort the data as you see best fit. (2 points)

SELECT FirstName, LastName, HireDate
FROM Employees
	WHERE Title = 'Sales Representative' AND Country = 'USA'
		ORDER BY HireDate DESC;

# 20. Customer service noticed an increase in shipping errors for orders handled by the employee, Janet Leverling. 
# Return the OrderIDs handled by Janet so that the orders can be inspected for other errors. (2 points)

SELECT OrderID
FROM Orders
WHERE EmployeeID = (
    SELECT EmployeeID
    FROM Employees
    WHERE FirstName = 'Janet' AND LastName = 'Leverling'
);

# 21. The sales team wants to develop stronger supply chain relationships with its suppliers by reaching out to the managers
# who have the decision making power to create a just-in-time inventory arrangement. Display the supplier's company name, 
# contact name, title, and phone number for suppliers who have manager or mgr in their title. (2 points)

SELECT CompanyName, ContactName, ContactTitle, Phone
FROM Suppliers
WHERE ContactTitle LIKE '%manager%' OR ContactTitle LIKE '%mgr%';

# 22. The warehouse packers want to label breakable products with a fragile sticker. Identify the products with glasses, 
# jars, or bottles and are not discontinued (0 = not discontinued). (2 points)

SELECT ProductName
FROM Products
WHERE (ProductName LIKE '%glasses%' OR ProductName LIKE '%jars%' 
	OR ProductName LIKE '%bottles%')
		AND Discontinued = 0;
# Nil return

# 23. How many customers are from Brazil and have a role in sales? Your query should only return 1 row. (2 points)

SELECT COUNT(*) AS num_customers
FROM Customers
WHERE Country = 'Brazil' AND EXISTS (
    SELECT *
    FROM Orders
    JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
    WHERE Customers.CustomerID = Orders.CustomerID
      AND Employees.Title LIKE '%Sales%'
);
# 9 customers are from Brazil with a role in sales.

# 24. Who is the oldest employee in terms of age? Your query should only return 1 row. (2 points)

SELECT FirstName, LastName, BirthDate
FROM Employees
ORDER BY BirthDate ASC
LIMIT 1;

# Margaret Peacock born in 1955

# 25. Calculate the total order price per order and product before and after the discount. The products listed should 
# only be for those where a discount was applied. Alias the before discount and after discount expressions. (3 points)

SELECT OrderDetails.OrderID, OrderDetails.ProductID, 
    ROUND((OrderDetails.UnitPrice * OrderDetails.Quantity),2) AS TotalPriceBeforeDiscount,
    ROUND((OrderDetails.UnitPrice * (1 - OrderDetails.Discount) * OrderDetails.Quantity),2) AS TotalPriceAfterDiscount
FROM OrderDetails
WHERE OrderDetails.Discount > 0;

# 26. To assist in determining the company's assets, find the total dollar value for all products in stock. 
# Your query should only return 1 row.  (2 points)

SELECT SUM(Products.UnitPrice * Products.UnitsInStock) AS TotalValueInStock
FROM Products;
# The total value in stock is $74050.85

# 27. Supplier deliveries are confirmed via email and fax. Create a list of suppliers with a missing fax number to help 
# the warehouse receiving team identify who to contact to fill in the missing information. (2 points)

SELECT *
FROM Suppliers
WHERE Fax IS NULL OR Fax = ' ';
# There are 35 suppliers. 

# 28. The PR team wants to promote the company's global presence on the website. Identify a unique and sorted list 
# of countries where the company has customers. (2 points)

SELECT DISTINCT Country
FROM Customers
ORDER BY Country;

# 29. You're the newest hire. INSERT yourself as an employee. You can arbitrarily set the column values as long as 
# they are related to the column. Only assign values to columns that are not automatically handled by MySQL. (2 points)

INSERT INTO Employees (LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, 
	Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath)
VALUES ('Matsheza', 'Michael', 'CFO', 'Mr.', '1987-05-04', '2023-02-18', '1 LMU Drive', 'Los Angeles', 'California', '90045',
	'USA', '(206) 555-5555', '1111', 'Finance and Data Science Prowess', 1, 'http://accweb/emmployees/matsheza.bmp');

# Confirmation it worked.
SELECT *
FROM Employees
WHERE LastName = 'Matsheza';

# LastName, FirstName, Title, TitleOfCourtesy, BirthDate, 
# {LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath}
# {Matsheza, Michael, CFO, Mr., 1987-05-04 00:00:00, 2023-02-18 00:00:00, 1 LMU Drive, Los Angeles, California, 90045, USA, (206) 555-5555, 1111, Finance and Data Science Prowess, 1, 'http://accweb/emmployees/matsheza.bmp'} 

# 30. The supplier, Bigfoot Breweries, recently launched their website. UPDATE their website to bigfootbreweries.com. (2 points)

UPDATE Suppliers
SET HomePage = 'http://www.bigfootbreweries.com'
WHERE CompanyName = 'Bigfoot Breweries';

# 31. The images on the employee profiles are broken. The link to the employee headshot is missing the .com domain extension. 
# Fix the PhotoPath link so that the domain properly resolves. Broken link example: http://accweb/emmployees/buchanan.bmp 
# (2 points)

UPDATE Employees
SET PhotoPath = REPLACE(PhotoPath, 'http://accweb/emmployees/', 'http://accweb.com/emmployees/')
WHERE PhotoPath LIKE 'http://accweb/emmployees/%';

# 32. Create a table each to identify the Low, Medium and High group companies based on their total order amount.  
# Each table should contain the company name, the total order quantity and the group description that it belongs to.  
# An example for Medium group (with partial results) is shown below.  Note that you have to dynamically determine the 
# group membership using the ranges in CustomerGroupThresholds table. (6 points)

SELECT *
FROM CustomerGroupThresholds
LIMIT 10;
