-- QUERY 1: Complete purchase history with all details
-- =============================================
-- Business Question: Show every purchase with customer, track, artist, and genre info

SELECT 
    Customer.FirstName,
    Customer.LastName,
    Invoice.InvoiceDate,
    Track.Name AS track_name,
    Artist.Name AS artist_name,
    Genre.Name AS genre,
    InvoiceLine.UnitPrice,
    InvoiceLine.Quantity,
    (InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS line_total
FROM Customer
INNER JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
INNER JOIN InvoiceLine ON Invoice.InvoiceId = InvoiceLine.InvoiceId
INNER JOIN Track ON InvoiceLine.TrackId = Track.TrackId
INNER JOIN Album ON Track.AlbumId = Album.AlbumId
INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId
INNER JOIN Genre ON Track.GenreId = Genre.GenreId
ORDER BY Invoice.InvoiceDate DESC
LIMIT 50;


-- =============================================
-- QUERY 2: Playlist analysis with track details
-- =============================================
-- Business Question: What tracks are in each playlist?

SELECT 
    Playlist.Name AS playlist_name,
    Track.Name AS track_name,
    Artist.Name AS artist_name,
    Album.Title AS album_title,
    Genre.Name AS genre,
    ROUND(Track.Milliseconds / 60000.0, 2) AS duration_minutes
FROM Playlist
INNER JOIN PlaylistTrack ON Playlist.PlaylistId = PlaylistTrack.PlaylistId
INNER JOIN Track ON PlaylistTrack.TrackId = Track.TrackId
INNER JOIN Album ON Track.AlbumId = Album.AlbumId
INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId
INNER JOIN Genre ON Track.GenreId = Genre.GenreId
LIMIT 100;


-- =============================================
-- QUERY 3: Employee territories and customer sales
-- =============================================
-- Business Question: Which employees manage customers in which countries?

SELECT 
    Employee.FirstName AS rep_first_name,
    Employee.LastName AS rep_last_name,
    Customer.Country,
    COUNT(DISTINCT Customer.CustomerId) AS customers_in_country,
    COUNT(Invoice.InvoiceId) AS total_sales,
    ROUND(SUM(Invoice.Total), 2) AS country_revenue
FROM Employee
INNER JOIN Customer ON Employee.EmployeeId = Customer.SupportRepId
INNER JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
GROUP BY Employee.EmployeeId, Employee.FirstName, Employee.LastName, Customer.Country
ORDER BY country_revenue DESC;


-- =============================================
-- QUERY 4: Genre sales by country
-- =============================================
-- Business Question: What music genres are popular in each country?

SELECT 
    Customer.Country,
    Genre.Name AS genre,
    COUNT(InvoiceLine.InvoiceLineId) AS tracks_sold,
    ROUND(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity), 2) AS revenue
FROM Customer
INNER JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
INNER JOIN InvoiceLine ON Invoice.InvoiceId = InvoiceLine.InvoiceId
INNER JOIN Track ON InvoiceLine.TrackId = Track.TrackId
INNER JOIN Genre ON Track.GenreId = Genre.GenreId
GROUP BY Customer.Country, Genre.Name
ORDER BY Customer.Country, revenue DESC;


-- =============================================
-- QUERY 5: Customer lifetime value with favorite genre
-- =============================================
-- Business Question: Who are our best customers and what do they like?

SELECT 
    Customer.FirstName,
    Customer.LastName,
    Customer.Country,
    COUNT(DISTINCT Invoice.InvoiceId) AS total_purchases,
    ROUND(SUM(Invoice.Total), 2) AS lifetime_value,
    (SELECT Genre.Name 
     FROM InvoiceLine il
     INNER JOIN Track t ON il.TrackId = t.TrackId
     INNER JOIN Genre ON t.GenreId = Genre.GenreId
     INNER JOIN Invoice i ON il.InvoiceId = i.InvoiceId
     WHERE i.CustomerId = Customer.CustomerId
     GROUP BY Genre.Name
     ORDER BY COUNT(*) DESC
     LIMIT 1) AS favorite_genre
FROM Customer
INNER JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
GROUP BY Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Country
HAVING lifetime_value > 35
ORDER BY lifetime_value DESC;


-- =============================================
-- QUERY 6: Media type sales performance
-- =============================================
-- Business Question: Which media formats (MP3, AAC, etc.) sell best?

SELECT 
    MediaType.Name AS media_format,
    COUNT(DISTINCT Track.TrackId) AS total_tracks,
    COUNT(InvoiceLine.InvoiceLineId) AS times_sold,
    ROUND(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity), 2) AS total_revenue
FROM MediaType
INNER JOIN Track ON MediaType.MediaTypeId = Track.MediaTypeId
LEFT JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId
GROUP BY MediaType.Name
ORDER BY total_revenue DESC;