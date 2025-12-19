-- QUERY 1: Find customers who bought from multiple genres
-- =============================================
-- Business Question: Who are our most diverse music buyers?

SELECT 
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Country,
    COUNT(DISTINCT g.GenreId) AS genres_purchased,
    GROUP_CONCAT(DISTINCT g.Name ORDER BY g.Name SEPARATOR ', ') AS genre_list,
    COUNT(DISTINCT i.InvoiceId) AS total_orders,
    ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
HAVING genres_purchased >= 5
ORDER BY genres_purchased DESC, total_spent DESC;


-- =============================================
-- QUERY 2: Artists with no sales (despite having tracks)
-- =============================================
-- Business Question: Which artists should we promote more?

SELECT 
    ar.ArtistId,
    ar.Name AS artist_name,
    COUNT(DISTINCT al.AlbumId) AS albums_available,
    COUNT(DISTINCT t.TrackId) AS tracks_available
FROM Artist ar
INNER JOIN Album al ON ar.ArtistId = al.ArtistId
INNER JOIN Track t ON al.AlbumId = t.AlbumId
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
WHERE il.InvoiceLineId IS NULL
GROUP BY ar.ArtistId, ar.Name
ORDER BY tracks_available DESC
LIMIT 20;


-- =============================================
-- QUERY 3: Compare customer spending to country average
-- =============================================
-- Business Question: Who are the high-value customers in each market?

SELECT 
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Country,
    ROUND(SUM(i.Total), 2) AS customer_total,
    ROUND(AVG(SUM(i.Total)) OVER (PARTITION BY c.Country), 2) AS country_avg,
    ROUND(SUM(i.Total) - AVG(SUM(i.Total)) OVER (PARTITION BY c.Country), 2) AS diff_from_avg,
    CASE 
        WHEN SUM(i.Total) > AVG(SUM(i.Total)) OVER (PARTITION BY c.Country) THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY c.Country, customer_total DESC;
