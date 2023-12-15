select * from customer
select * from actor
select * from film_actor
select * from rental
select * from inventory
--1.1
WITH StaffTotalRevenue AS (
  SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    SUM(p.amount) AS total_revenue
  FROM
    staff s
    JOIN payment p ON s.staff_id = p.staff_id
    JOIN rental r ON p.rental_id = r.rental_id
  WHERE
    EXTRACT(YEAR FROM p.payment_date) = 2017
  GROUP BY
    s.staff_id, s.first_name, s.last_name, s.store_id
)
SELECT
  str.staff_id,
  str.first_name,
  str.last_name,
  str.store_id,
  str.total_revenue
FROM
  StaffTotalRevenue str
WHERE
  NOT EXISTS (
    SELECT 1
    FROM StaffTotalRevenue str2
    WHERE str2.store_id = str.store_id
      AND str2.total_revenue > str.total_revenue
  );
--1.2
SELECT DISTINCT ON (s.store_id)
  s.store_id,
  p.staff_id,
  s.first_name,
  s.last_name,
  SUM(p.amount) AS total_revenue
FROM
  staff s
  JOIN payment p ON s.staff_id = p.staff_id
  JOIN rental r ON p.rental_id = r.rental_id
WHERE
  EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY
  s.store_id, p.staff_id, s.first_name, s.last_name
ORDER BY
  s.store_id, total_revenue DESC;
  
--2.1
SELECT
  f.film_id,
  f.title,
  f.rating,
  COUNT(r.rental_id) AS rental_count
FROM
  film f
  JOIN inventory i ON f.film_id = i.film_id
  JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY
  f.film_id, f.title, f.rating
ORDER BY
  rental_count DESC
LIMIT 5;
--2.2
WITH FilmRentalCounts AS (
  SELECT
    f.film_id,
    f.title,
    f.rating,
    COUNT(r.rental_id) AS rental_count,
    DENSE_RANK() OVER (ORDER BY COUNT(r.rental_id) DESC) AS rank
  FROM
    film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY
    f.film_id, f.title, f.rating
)
SELECT
  film_id,
  title,
  rating,
  rental_count
FROM
  FilmRentalCounts
WHERE
  rank <= 5
LIMIT 5;

--3.1
SELECT a.first_name, a.last_name, max(f.release_year) AS latest_year 
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY a.first_name, a.last_name
ORDER BY latest_year asc;

--3.2

SELECT a.first_name, a.last_name, (SELECT max(f.release_year)
FROM film_actor fa
JOIN film f ON fa.film_id = f.film_id
WHERE fa.actor_id = a.actor_id) 
AS latest_year

FROM actor a ORDER BY latest_year asc;
