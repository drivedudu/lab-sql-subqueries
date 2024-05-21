-- Challenge
-- Write SQL queries to perform the following tasks using the Sakila database:
-- 
-- 1 Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT count(i.inventory_id) AS avaliable
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';


SELECT count(*) AS avaliable
from inventory i
WHERE i.film_id = (SELECT f.film_id FROM  film f WHERE f.title = 'Alone Trip');


-- 2 List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);


-- 3 Use a subquery to display all actors who appear in the film "Alone Trip".

-- SELECT f.film_id FROM  film f WHERE f.title = 'Alone Trip';
-- 
-- (SELECT fa.actor_id 
-- FROM  film_actor fa 
-- WHERE fa.film_id = (
-- 							SELECT f.film_id FROM  film f WHERE f.title = 'Alone Trip'
-- 						));
-- 

-- SELECT a.first_name
-- FROM actor a
-- WHERE a.actor_id IN (
-- 							SELECT fa.actor_id 
-- 							FROM  film_actor fa 
-- 							WHERE fa.film_id = (
-- 														SELECT f.film_id FROM  film f WHERE f.title = 'Alone Trip'
-- 													)
-- );

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'Alone Trip';


-- Bonus:
-- 


-- 4 Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';


-- 5 Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.

-- SELECT 
-- 	concat(c.first_name,' ',c.last_name) AS FullName,
--     c.email,
--     co.country
-- FROM 
--     customer AS c
-- JOIN 
--     address AS a ON c.address_id = a.address_id
-- JOIN 
--     city AS ci ON a.city_id = ci.city_id
-- JOIN 
--     country AS co ON ci.country_id = co.country_id
-- WHERE co.country = 'Canada';

SELECT 
	CONCAT(c.first_name,' ',c.last_name) AS FullName,
    c.email
FROM 
    customer AS c
WHERE 
    c.address_id IN (SELECT address_id FROM address WHERE city_id IN (SELECT city_id FROM city WHERE country_id = (SELECT country_id FROM country WHERE country = 'Canada')));

    
    
-- 6 Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

-- SELECT 
--     f.title AS film_title
-- FROM 
--     film_actor fa
-- JOIN 
--     film f ON fa.film_id = f.film_id
-- WHERE 
--     fa.actor_id = (
--         SELECT 
--             actor_id
--         FROM 
--             (
--                 SELECT 
--                     actor_id, COUNT(*) AS film_count
--                 FROM 
--                     film_actor
--                 GROUP BY 
--                     actor_id
--                 ORDER BY 
--                     COUNT(*) DESC
--                 LIMIT 1
--             ) AS popular_actor
--     );
-- 
SELECT 
    a.first_name AS actor_first_name,
    a.last_name AS actor_last_name,
    f.title AS film_title
FROM 
    film_actor fa
JOIN 
    film f ON fa.film_id = f.film_id
JOIN 
    actor a ON fa.actor_id = a.actor_id
WHERE 
    fa.actor_id = (

                SELECT 
                    actor_id
                FROM 
                    film_actor
                GROUP BY 
                    actor_id
                ORDER BY 
                    COUNT(*) DESC
                LIMIT 1
  
    );


-- 7 Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

-- SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount)
-- FROM customer c
-- JOIN payment p ON p.customer_id = c.customer_id
-- JOIN 
-- GROUP BY c.customer_id
-- ORDER BY SUM(p.amount) DESC
-- LIMIT 1;
-- 
SELECT DISTINCT  f.title AS film_title
FROM 
    rental r
JOIN 
    payment p ON r.customer_id = p.customer_id
JOIN 
    inventory i ON r.inventory_id = i.inventory_id
JOIN 
    film f ON i.film_id = f.film_id
WHERE 
    p.customer_id = ( SELECT 
	                    customer_id
		                FROM 
		                    payment
		                GROUP BY 
		                    customer_id
		                ORDER BY 
		                    SUM(amount) DESC
		                LIMIT 1
							 );


-- 8 Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.

SELECT p.customer_id AS ID_customer, SUM(p.amount) AS Total_spent
FROM 
    payment p
GROUP BY 
	ID_customer
Having 
    Total_spent > AVG(p.amount);
	 
-- 	  (
--         SELECT 
--             AVG(total_payment)
--         FROM 
--             (
--                 SELECT 
--                     customer_id, SUM(amount) AS total_payment
--                 FROM 
--                     payment
--                 GROUP BY 
--                     customer_id
--                 ORDER BY 
--                     SUM(amount) DESC                
--             ) AS prof_customer
--     );