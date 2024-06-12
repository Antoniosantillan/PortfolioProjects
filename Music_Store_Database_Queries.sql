--Esta base de datos fue creada a partir de las tablas dentro de la carpeta "Music Store Data"
--Dicha carpeta contiene información sobre el inventario de una tienda de discos, asi como la información de cada disco, e información de venta.
--Las tablas en formato "CVS" fueron importadas de manera directa.
--Los términos "Foreing key" de igual forma se agregan manualmente a cada tabla, un ejemplo es el siguiente:
CREATE TABLE "artist" (
	"artist_id"	INTEGER,
	"name"	TEXT,
	PRIMARY KEY("artist_id")
);

CREATE TABLE "album" (
	"album_id"	INTEGER,
	"title"	TEXT,
	"artist_id"	INTEGER,
	PRIMARY KEY("album_id"),
	FOREIGN KEY ("artist_id") REFERENCES artist(artist_id)
);
--En este caso se a agregado la clave PRIMARY KEY a artist_id.
--Notemos que este lenguaje esta adaptado para interfaz estilo sqlite.
--En este caso nuestra base de datos no tiene valores nulos por lo que no hay necesidad de hacer una limpieza de datos.
--Finalmente la base de datos creada tiene por nombre "Music_Store_Database.db"
--A continuación se responderan diferentes preguntas con el objetivo de practicar diferentes tipos de consultas útiles en SQL.
--1 ¿Quién es el empleado de mayor rango según el puesto de trabajo?
SELECT *
FROM employee
ORDER by levels DESC
LIMIT 1
--2 ¿Qué países tienen más facturas?
SELECT count(*) as conteo,
	   billing_country
FROM invoice
GROUP BY billing_country
ORDER by conteo DESC
--3 ¿Cuáles son los 3 valores más altos del total de la factura?
SELECT *
FROM invoice
ORDER by total DESC
LIMIT 3
--4 ¿Qué ciudad tiene los mejores clientes? Devuelve tanto el nombre de la ciudad como la suma de todos los totales de la factura.
SELECT  billing_city,
		sum(total) as Invoice_total
FROM invoice
GROUP BY billing_city
ORDER by Invoice_total DESC
--5 ¿Quién es el mejor cliente? El cliente que haya gastado más dinero
SELECT customer.customer_id,
	   customer.first_name,
	   customer.last_name,
	   sum(invoice.total) as Invoice_Total
FROM customer
JOIN invoice On customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY Invoice_total DESC
LIMIT 1
--6 Escriba una consulta para devolver el correo electrónico, el nombre, el apellido y el género de todos los oyentes de música rock. 
--Devuelve tu lista ordenada alfabéticamente por correo electrónico comenzando con A
SELECT DISTINCT email, 
				first_name,
				last_name
FROM customer
JOIN invoice on customer.customer_id=invoice.customer_id
JOIN invoice_line on invoice.invoice_id=invoice_line.invoice_id
WHERE track_id in (SELECT track_id
				   FROM track
				   JOIN genre on genre.genre_id=track.genre_id
				   where genre.name like "Rock"
				   )
ORDER by email
--7 Escriba una consulta que devuelva el nombre del artista y el recuento total de canciones de las 10 mejores bandas de rock.
--Osea los artistas que han escrito más canciones de rock
SELECT artist.artist_id,
	   artist.name,
	   count(artist.artist_id) as number_of_rock_songs
FROM artist
JOIN album on artist.artist_id=album.artist_id
JOIN track on album.album_id=track.album_id
JOIN genre on genre.genre_id=track.genre_id
WHERE genre.name LIKE "Rock"
GROUP by artist.artist_id
ORDER by number_of_rock_songs DESC
LIMIT 10
--8 Devuelve todos los nombres de pistas que tienen una duración de canción mayor que la duración promedio de la canción. 
--Devuelve el nombre y los milisegundos de cada pista. 
--Ordene por duración de la canción con las canciones más largas enumeradas primero
SELECT name,
	   milliseconds as Duration_milliseconds
FROM track 
WHERE milliseconds>(SELECT avg(milliseconds)
					FROM track
					)
ORDER BY Duration_milliseconds DESC
--9 Encuentre cuánto gastó cada cliente en artistas. 
--Escriba una consulta para devolver el nombre del cliente, el nombre del artista y el total gastado.
SELECT customer.customer_id,
	   first_name,
	   last_name,
	   artist.name as Artist_name,
	   sum(invoice_line.unit_price*invoice_line.quantity) as Total_spent
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice_line.invoice_id=invoice.invoice_id
JOIN track ON track.track_id=invoice_line.track_id
JOIN album ON album.album_id=track.album_id
JOIN artist ON artist.artist_id=album.artist_id
GROUP BY customer.customer_id,artist.artist_id, artist.name
ORDER by customer.customer_id, artist.name
--10 Queremos saber el género musical más popular de cada país. 
--Determinamos el género más popular como el género con mayor cantidad de compras. 
--Escriba una consulta que devuelva cada país junto con el género principal. 
--Para países donde se comparte el número máximo de compras, devolver todos los Géneros
WITH GenreCountryPurchases AS (
	SELECT customer.country,
	   genre.name as genre_name,
	   count(invoice.invoice_id) AS purchases
	FROM customer
	JOIN invoice ON invoice.customer_id=customer.customer_id
	JOIN invoice_line ON invoice_line.invoice_id=invoice.invoice_id
	JOIN track ON track.track_id=invoice_line.track_id
	JOIN genre ON genre.genre_id=track.genre_id
	GROUP BY customer.country, genre.name
),
	MaxGenrePurchases AS (
	SELECT country,
		   max(Purchases) AS Max_Purchases
	FROM GenreCountryPurchases
	GROUP BY country
)
SELECT gcp.country,
	   gcp.genre_name,
	   gcp.purchases
FROM GenreCountryPurchases AS gcp
JOIN MaxGenrePurchases AS mgp ON mgp.country=gcp.country
AND gcp.Purchases=mgp.Max_Purchases
ORDER BY gcp.country, gcp.genre_name
--11 Escribe una consulta que determine el cliente que más ha gastado en música para cada país.
--Escriba una consulta que devuleva el país junto con el cliente principal y cuanto gastó.
--Para los paises donde se comparte el monto máximo gastado, proporcione todos los clientes que gastaron ese monto.
WITH CustomerSpending AS(
	SELECT customer.country,
	   customer.customer_id,
	   customer.first_name,
	   customer.last_name,
	   sum(invoice_line.unit_price*invoice_line.quantity) AS Total_spent
	FROM customer
	JOIN invoice ON invoice.customer_id=customer.customer_id
	JOIN invoice_line ON invoice_line.invoice_id=invoice.invoice_id
	GROUP BY customer.country, customer.customer_id
	),
	MaxSpendingCountry AS(
	SELECT country,
		   max(Total_spent) AS Max_Total_Spent
	FROM CustomerSpending
	GROUP BY country
	)
SELECT CS.country,
	   CS.customer_id,
	   CS.first_name,
	   CS.last_name,
	   CS.Total_spent
FROM CustomerSpending AS CS
JOIN MaxSpendingCountry AS MSC ON MSC.country=CS.country
AND MSC.Max_Total_Spent=CS.Total_spent