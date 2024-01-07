use dbmusic
select * from album
select * from employee

--1) Who is the senior most employee based on job title
select top 1 * from employee order by levels desc

select * from invoice

--2) which country have the most invoices
select count(*) as invoice_count,billing_country from invoice group by billing_country order by billing_country desc

--3) what are the top 3 values of total invoice
select top 3 total from invoice order by total desc

--4)Which city has the best customers? We would like to throw a promotional Music Festival
--  in the city we, made the most money. Write a query that returns one city that has the highest sum of invoice totals.
--  Return both the city name and the sum of all invoice totals

select top 1 sum(total) as invoice_total,billing_city from invoice group by billing_city order by invoice_total desc

--5) who is the best customer? The customer who has spent the most money
--   will be declared the best customer. write the query that returns the person who has spent the most money.

select top 1 c.first_name,c.last_name,i.customer_id,sum(i.total) as total from customer as c left join invoice as i on c.customer_id=i.customer_id
group by c.first_name,c.last_name,i.customer_id
order by total desc

--6) Write the query to return the email,first name ,last name, & genre of all rock music listerners.
--   Return your list ordered alphabetically by email starting with A.

select c.customer_id,c.first_name,c.last_name,c.email,g.genre_id,g.name from customer as c left join 
invoice as i on c.customer_id=i.customer_id left join
invoice_line as il on i.invoice_id=il.invoice_id left join
track as t on il.track_id=t.track_id left join
genre as g on t.genre_id= g.genre_id
where g.genre_id = 1 
group by c.customer_id,c.first_name,c.last_name,c.email,g.genre_id,g.name
order by c.email asc

--7)Lets invite the artist who have written the most rock music in our dataset
--  Write a query that returns the artist name and the total track count of top 10 rock bands

select a.artist_id,a.name as artistname,alb.title,t.genre_id,t.track_id,t.name,pt.playlist_id,p.name from artist as a left join
album as alb on a.artist_id=alb.artist_id left join
track as t on alb.album_id=t.album_id left join
playlist_track as pt on t.track_id=pt.track_id left join
playlist as p on pt.playlist_id=p.playlist_id
where genre_id =1
group by a.artist_id,a.name,alb.title,t.genre_id,t.track_id,t.name,pt.playlist_id,p.name
order by a.name desc

select count (a.artist_id),count (a.name),a.name,alb.title,t.genre_id,t.track_id,t.name,pt.playlist_id,p.name from artist as a left join
album as alb on a.artist_id=alb.artist_id left join
track as t on alb.album_id=t.album_id left join
playlist_track as pt on t.track_id=pt.track_id left join
playlist as p on pt.playlist_id=p.playlist_id
where genre_id =1
group by a.artist_id,count (a.name),alb.title,t.genre_id,t.track_id,t.name,pt.playlist_id,p.name
order by a.name desc




--8) Return all the track names that have a song length longer than the average song length.
--   Return the name and milliseconds for each track. Order by the song length with the longest songs listed first

--average song length is 393 seconds 
select avg(milliseconds/1000) from track

--Total tracks that have length greater than avg song length is 493
select milliseconds/1000 as seconds,name from track 
where milliseconds/1000 > 393
order by seconds desc

--Dynamic way 
select name,milliseconds from track where milliseconds >(select AVG(milliseconds) from track) order by milliseconds desc

--9) Find how much amount spend by each customer on artists?
--   Write a query to return customer name, artist name and total spent

select  c.customer_id,c.first_name,c.last_name,sum(t.unit_price * il.quantity / i.total) as total_sum from artist as a left join
album as alb on a.artist_id=alb.artist_id left join
track as t on alb.album_id=t.album_id left join
invoice_line as il on t.track_id=il.track_id left join
invoice as i on il.invoice_id=i.invoice_id left join
customer as c on i.customer_id=c.customer_id
where c.customer_id is not null
group by c.customer_id,c.first_name,c.last_name
order by c.customer_id desc


--10) we want to find out most popular genre for each country.
--We determine the most popular genre as the genre with the highest amount of purchases. 
--write a query that returns each country along with the top genre. For countries where the maximum
--number of purchases is shared return all genres.


select g.name,t.genreid,il.trackid,il.unitprice,il.quantity,i.billingcountry,i.total,i.invoiceid,i.customerid,c.country from genre as g left join
track as t on g.genre_id=t.genre_id left join
invoice_line as il on t.track_id=il.track_id left join
invoice as i on il.invoice_id=i.invoice_id left join
customer as c on i.customer_id=c.customer_id left join
group by g.name,t.genreid,il.trackid,il.unitprice,il.quantity,i.billingcountry,i.total,i.invoiceid,i.customerid,c.country
order by 


select count(il.quantity) as purchases,c.country,i.customer_id,g.name,t.genre_id from genre as g left join
track as t on g.genre_id=t.genre_id left join
invoice_line as il on t.track_id=il.track_id left join
invoice as i on il.invoice_id=i.invoice_id left join
customer as c on i.customer_id=c.customer_id
where c.country is not null
group by c.country,i.customer_id,g.name,t.genre_id
order by purchases desc


--11) Write a query that determines the customer that has spent the most on music for each country.
--Write a query that returns the country along with the top customer and know much they spent.
--For countries where the top amount spent is shared, provide all customers who spent this amount.


WITH CustomerWithTotal AS (
    SELECT c.first_name,c.last_name,SUM(t.unit_price * il.quantity / i.total) AS total_sum,i.billing_country,
        ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(t.unit_price * il.quantity / i.total) DESC) AS RowNo FROM track AS t LEFT JOIN
        invoice_line AS il ON t.track_id = il.track_id LEFT JOIN
        invoice AS i ON il.invoice_id = i.invoice_id LEFT JOIN
        customer AS c ON i.customer_id = c.customer_id
    WHERE c.first_name IS NOT NULL
    GROUP BY c.first_name,c.last_name,i.billing_country
)
SELECT
    first_name,last_name,total_sum,billing_country
FROM CustomerWithTotal
WHERE RowNo <= 1;












