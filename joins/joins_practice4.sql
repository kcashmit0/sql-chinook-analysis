
-- Topic: 5+ table JOINs with complex business logic

-- =============================================
-- QUERY 1: Customer purchase history with full track details
-- =============================================
-- Business Question: Show complete purchase journey for top customers

SELECT 
    c.FirstName,
    c.LastName,
    c.Country,
    i.InvoiceDate,
    t.Name AS track_name,
    al.Title AS album,
    ar.Name AS artist,
    g.Name AS genre,
    il.UnitPrice,
    il.Quantity,
    (il.UnitPrice * il.Quantity) AS line_total
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
INNER JOIN Genre g ON t.GenreId = g.GenreId
WHERE c.CustomerId IN (5, 6, 7)  -- Top customers
ORDER BY i.InvoiceDate DESC
LIMIT 50;


-- =============================================
-- QUERY 2: Employee performance - customers, sales, genre preferences
-- =============================================
-- Business Question: Which sales reps sell which genres to which countries?

SELECT 
    e.FirstName AS employee_name,
    e.LastName AS employee_lastname,
    c.Country,
    g.Name AS genre,
    COUNT(DISTINCT c.CustomerId) AS customers,
    COUNT(il.InvoiceLineId) AS tracks_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM Employee e
INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
WHERE e.Title LIKE '%Sales%'
GROUP BY e.FirstName, e.LastName, c.Country, g.Name
ORDER BY revenue DESC
LIMIT 20;


-- =============================================
-- QUERY 3: Playlist complexity analysis
-- =============================================
-- Business Question: Which playlists have the most variety?

SELECT 
    p.Name AS playlist_name,
    COUNT(DISTINCT t.TrackId) AS total_tracks,
    COUNT(DISTINCT g.GenreId) AS genres_count,
    COUNT(DISTINCT ar.ArtistId) AS artists_count,
    ROUND(SUM(t.Milliseconds) / 3600000.0, 2) AS total_hours,
    ROUND(AVG(t.Milliseconds) / 60000.0, 2) AS avg_track_minutes
FROM Playlist p
INNER JOIN PlaylistTrack pt ON p.PlaylistId = pt.PlaylistId
INNER JOIN Track t ON pt.TrackId = t.TrackId
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY p.Name
HAVING total_tracks > 10
ORDER BY genres_count DESC, artists_count DESC;


-- =============================================
-- QUERY 4: Cross-country genre preferences
-- =============================================
-- Business Question: What music does each country buy?

SELECT 
    c.Country,
    g.Name AS top_genre,
    COUNT(il.InvoiceLineId) AS purchases,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue,
    ROUND(AVG(il.UnitPrice), 2) AS avg_price
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY c.Country, g.Name
HAVING purchases > 5
ORDER BY c.Country, revenue DESC;


-- =============================================
-- QUERY 5: Artist revenue breakdown by media format
-- =============================================
-- Business Question: Which artists earn most from each media type?

SELECT 
    ar.Name AS artist,
    mt.Name AS media_type,
    COUNT(DISTINCT al.AlbumId) AS albums,
    COUNT(DISTINCT t.TrackId) AS tracks,
    COUNT(il.InvoiceLineId) AS times_purchased,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM Artist ar
INNER JOIN Album al ON ar.ArtistId = al.ArtistId
INNER JOIN Track t ON al.AlbumId = t.AlbumId
INNER JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY ar.Name, mt.Name
HAVING total_revenue > 0
ORDER BY total_revenue DESC
LIMIT 30;


-- =============================================
-- QUERY 6: Customer lifetime value with music preferences
-- =============================================
-- Business Question: Who spends most and what do they listen to?

SELECT 
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Country,
    COUNT(DISTINCT i.InvoiceId) AS total_orders,
    COUNT(DISTINCT t.TrackId) AS unique_tracks,
    COUNT(DISTINCT g.GenreId) AS genres_explored,
    ROUND(SUM(i.Total), 2) AS lifetime_value,
    ROUND(AVG(i.Total), 2) AS avg_order_value,
    (SELECT g2.Name 
     FROM InvoiceLine il2
     INNER JOIN Track t2 ON il2.TrackId = t2.TrackId
     INNER JOIN Genre g2 ON t2.GenreId = g2.GenreId
     INNER JOIN Invoice i2 ON il2.InvoiceId = i2.InvoiceId
     WHERE i2.CustomerId = c.CustomerId
     GROUP BY g2.Name
     ORDER BY COUNT(*) DESC
     LIMIT 1) AS favorite_genre
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
HAVING lifetime_value > 38
ORDER BY lifetime_value DESC;