use sakila;

#1a. Display the first and last names of all actors from the table `actor`.
SELECT 
    first_name, last_name
FROM
    actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
ALTER TABLE actor ADD COLUMN actor_name VARCHAR(50);
UPDATE actor 
SET 
    actor_name = CONCAT(first_name, ' ', last_name)
WHERE
    actor_id > 0;
SELECT 
    UPPER(actor_name)
FROM
    actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
    actor_name
FROM
    actor
WHERE
    actor_name LIKE '%GEN%'; 

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%LI%';

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');
    
#3a, 3b (Create "description" column of BLOB type, realize it's a bad idea and delete it)
ALTER TABLE actor ADD COLUMN description BLOB;
ALTER TABLE actor DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
	last_name, COUNT(*)
FROM 
	actor
GROUP BY last_name
ORDER BY 2 DESC;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
	last_name, COUNT(*)
FROM 
	actor
GROUP BY last_name
HAVING COUNT(*) >1
ORDER BY 2 DESC;

#4c/4d (Change Groucho Williams to Harpo and back again)
SELECT 
	actor_id, actor_name
FROM
	actor
WHERE
	actor_name = "GROUCHO WILLIAMS";

UPDATE
	actor
SET 
	actor_name = "HARPO WILLIAMS"
WHERE
	actor_id = 172;
    
UPDATE
	actor
SET 
	actor_name = "GROUCHO WILLIAMS"
WHERE
	actor_id = 172;
    
#You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT first_name, last_name, address FROM staff s
JOIN address a
USING (address_id);

#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT 
    staff_id, SUM(amount) AS august_total, first_name, last_name
FROM
    payment
        JOIN
    staff s USING (staff_id)
WHERE
    payment_date LIKE '2005-08%'
GROUP BY staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT 
    f.film_id, title, COUNT(actor_id)
FROM
    film f
        INNER JOIN
    film_actor a ON a.film_id = f.film_id
GROUP BY title;	

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film_id FROM film 
WHERE title = "Hunchback Impossible";

SELECT COUNT(*) from inventory WHERE film_id = 439;

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT c.customer_id, last_name, SUM(amount) as "total paid" FROM customer c
INNER JOIN payment p WHERE c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

#* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with 
#the letters `K` and `Q` whose language is English.

SELECT title from film 
WHERE title LIKE "k%" OR title LIKE "q%" AND language_id = 1 
;

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT f.title, a.first_name, a.last_name, f.film_id from film f
JOIN film_actor fa 
ON fa.film_id = f.film_id
INNER JOIN actor a
ON a.actor_id = fa.actor_id
WHERE title = "Alone Trip" AND fa.film_id = f.film_id;


#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
#Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email, country FROM customer c
JOIN address a ON a.address_id = c.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON co.country_id = ci.country_id
WHERE co.country = "canada";

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as _family_ films.

SELECT title, category_id FROM film f
JOIN film_category c ON c.film_id = f.film_id
WHERE category_id = 8;

#7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(rental_id) as "rentals" from film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY title
ORDER BY COUNT(rental_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(amount) from payment p
JOIN staff s ON s.staff_id = p.staff_id
JOIN store st ON st.store_id = s.store_id
GROUP BY st.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address a ON a.address_id = s.address_id
JOIN city c ON c.city_id = a.city_id
JOIN country co ON co.country_id = c.country_id;


#7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name as "genre", SUM(amount) as "gross revenue" from payment p
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film_category fc ON fc.film_id = i.film_id
JOIN category c on c.category_id = fc.category_id
GROUP BY c.name 
ORDER BY SUM(amount) DESC LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_5 AS
SELECT c.name as "genre", SUM(amount) as "gross revenue" from payment p
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film_category fc ON fc.film_id = i.film_id
JOIN category c on c.category_id = fc.category_id
GROUP BY c.name 
ORDER BY SUM(amount) DESC LIMIT 5;

#8b. How would you display the view that you created in 8a?

SELECT * FROM top_5;

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_5;