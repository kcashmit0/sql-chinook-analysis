-- Topic: Connecting Artists and Albums

-- =============================================
-- QUERY 1: Show albums with their artist names
-- =============================================
-- Business Question: What albums do we have and who made them?

SELECT 
    Artist.Name AS artist_name,
    Album.Title AS album_title
FROM Album
INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId
LIMIT 10;

-- =============================================
-- QUERY 2: Count albums per artist
-- =============================================
-- Business Question: Which artists have the most albums?

SELECT 
    Artist.Name AS artist_name,
    COUNT(Album.AlbumId) AS album_count
FROM Artist
INNER JOIN Album ON Artist.ArtistId = Album.ArtistId
GROUP BY Artist.Name
ORDER BY album_count DESC
LIMIT 10;

-- =============================================
-- QUERY 3: Tracks with album and artist info
-- =============================================
-- Business Question: Show track details with full context

SELECT 
    Track.Name AS track_name,
    Album.Title AS album_title,
    Artist.Name AS artist_name,
    Track.Milliseconds / 60000 AS duration_minutes
FROM Track
INNER JOIN Album ON Track.AlbumId = Album.AlbumId
INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId
LIMIT 20;

-- =============================================
-- QUERY 4: Customer purchases with invoice details
-- =============================================
-- Business Question: Who are our customers and what did they buy?

SELECT 
    Customer.FirstName,
    Customer.LastName,
    Customer.Country,
    Invoice.InvoiceDate,
    Invoice.Total AS purchase_amount
FROM Customer
INNER JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
ORDER BY Invoice.Total DESC
LIMIT 15;

-- QUERY 5: Track sales - which songs sold most?
-- =============================================
-- Business Question: What are our best-selling tracks?

SELECT 
    Track.Name AS track_name,
    Artist.Name AS artist_name,
    COUNT(InvoiceLine.InvoiceLineId) AS times_purchased,
    ROUND(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity), 2) AS total_revenue
FROM Track
INNER JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId
INNER JOIN Album ON Track.AlbumId = Album.AlbumId
INNER JOIN Artist ON Album.ArtistId = Artist.ArtistId
GROUP BY Track.Name, Artist.Name
ORDER BY times_purchased DESC
LIMIT 20;