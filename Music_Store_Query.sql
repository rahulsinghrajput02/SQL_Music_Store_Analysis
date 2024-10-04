-- Find how much amount spent by each customer on artists?
-- Write a query to return customer name, artist name and total spent

SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  bsa.artist_name,
  SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
  invoice i
  JOIN customer c ON c.customer_id = i.customer_id
  JOIN invoice_line il ON il.invoice_id = i.invoice_id
  JOIN track t ON t.track_id = il.track_id
  JOIN album alb ON alb.album_id = t.album_id
  JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 
  c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 
  amount_spent DESC;
  
  
-- We want to find out the most popular music Genre for each country. We determine the most popular
-- genre as the genre with the higest amount of purchases.

-- WITH popular_genre AS (
--     SELECT count(invoice_line.quantity) AS purchases , customer.country, genre.name, genre.genre_id,
--     ROW_NUMBER() over (PARTITION BY  customer.country ORDER BY  count(invoice_line.quantity) DESC) AS RowNo
--     FROM invoice_line
--     join invoice on invoice.invoice_id = invoice_line.invoice_id
--     join customer on customer.customer_id = invoice.customer_id
--     join genre on genre.genre_id = track.genre_id
--     GROUP BY customer.country, genre.name, genre.genre_id
--     ORDER BY customer.country , count(invoice_line.quantity) DESC;

WITH popular_genre AS (
    SELECT count(invoice_line.quantity) AS purchases , customer.country, genre.name, genre.genre_id,
    ROW_NUMBER() over (PARTITION BY  customer.country ORDER BY  count(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    join invoice on invoice.invoice_id = invoice_line.invoice_id
    join customer on customer.customer_id = invoice.customer_id
    join track on track.track_id = invoice_line.track_id
    join genre on genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY customer.country , count(invoice_line.quantity) DESC
)
SELECT * FROM popular_genre where RowNo <= 1;

-- Write a query that determines the customer  that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent. For 
-- countries where the top customer  and how much they spent. For Countries where the top amount
-- spent is shared, provide all customers who spent this amount.

WITH Customer_with_country AS (
    SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
    ROW_NUMBER () OVER (PARTITION BY billing_country ORDER BY SUM(total)DESC) AS RowNo
    FROM invoice
    join customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer_id, first_name, last_name, billing_country
    order by billing_country ASC, sum(total) DESC
)
SELECT * FROM  Customer_with_country WHERE RowNo <= 1;

--  Write query to return the email, first name ,  last name , & Genre of all Rock Music listeners. 
--  Return your list ordered alphabetically  by email starting  with A

select customer.first_name, customer.last_name, customer.email
FROM customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id IN
	(SELECT track.track_id FROM track
	join genre on genre.genre_id = track.genre_id
	WHERE  genre.name LIKE "Rock")

ORDER BY email;

-- Lets's invite the artists who have written the most rock music in our dataset. write a query 
-- the returns the artist name and total track count of the top rock bands

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN  artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE "Rock"
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Return all the track names that have a song length longer than the average song length.
-- Return the name and milliseconds for each track. Order by the song length with the 
-- longest song listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds >
       (SELECT AVG(milliseconds) AS average_song_length
       FROM track)
ORDER BY milliseconds DESC;

-- Who is the senior most employee based on job title?

SELECT  first_name, last_name, title
FROM employee
ORDER BY title DESC
LIMIT 1;

-- Which countries have the most invoices?

SELECT COUNT(*) , billing_country
FROM invoice
GROUP BY billing_country;

-- What are top 3 values of total invoice

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Which city has  the best customers? We would like to throw a
-- promotional Music Festival in the city we made the most money. Write
-- a query that returns one city that has the higest sum of invoice
-- totals. Return both the city name & sum of all  invoice totals

SELECT SUM(total) AS total_invoice, billing_city 
FROM invoice 
GROUP BY billing_city
ORDER BY billing_city DESC;

-- Who is the best customer? The customer who has spent the most money will be declared
-- the best customer. Write a query that returns the person who has spent the most 
-- money.

SELECT customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) AS total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC;
