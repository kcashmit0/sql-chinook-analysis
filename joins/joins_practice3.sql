
-- QUERY 1: Customer ranking by country
-- =============================================
-- Business Question: Who are the top 3 customers in each country?

SELECT 
    Country,
    FirstName,
    LastName,
    total_spent,
    country_rank
FROM (
    SELECT 
        c.Country,
        c.FirstName,
        c.LastName,
        ROUND(SUM(i.Total), 2) AS total_spent,
        RANK() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS country_rank
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.Country, c.FirstName, c.LastName
) ranked
WHERE country_rank <= 3
ORDER BY Country, country_rank;


-- =============================================
-- QUERY 2: Running total of sales by employee
-- =============================================
-- Business Question: Track cumulative sales performance over time

SELECT 
    e.FirstName,
    e.LastName,
    DATE(i.InvoiceDate) AS sale_date,
    ROUND(SUM(i.Total), 2) AS daily_sales,
    ROUND(SUM(SUM(i.Total)) OVER (
        PARTITION BY e.EmployeeId 
        ORDER BY DATE(i.InvoiceDate)
    ), 2) AS running_total
FROM Employee e
INNER JOIN Customer c ON e.EmployeeId = c.SupportRepId
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE e.Title LIKE '%Sales%'
GROUP BY e.EmployeeId, e.FirstName, e.LastName, DATE(i.InvoiceDate)
ORDER BY e.LastName, sale_date
LIMIT 50;


-- =============================================
-- QUERY 3: Genre performance with percentage of total
-- =============================================
-- Business Question: What % of revenue does each genre represent?

WITH GenreRevenue AS (
    SELECT 
        g.Name AS genre,
        ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
    FROM Genre g
    INNER JOIN Track t ON g.GenreId = t.GenreId
    INNER JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY g.Name
),
TotalRevenue AS (
    SELECT SUM(revenue) AS total FROM GenreRevenue
)
SELECT 
    gr.genre,
    gr.revenue,
    ROUND((gr.revenue / tr.total) * 100, 2) AS percentage_of_total,
    ROUND(SUM(gr.revenue) OVER (ORDER BY gr.revenue DESC), 2) AS cumulative_revenue
FROM GenreRevenue gr
CROSS JOIN TotalRevenue tr
ORDER BY gr.revenue DESC;


-- =============================================
-- QUERY 4: Month-over-month sales growth by country
-- =============================================
-- Business Question: Which countries show growing sales trends?

WITH MonthlySales AS (
    SELECT 
        c.Country,
        DATE_FORMAT(i.InvoiceDate, '%Y-%m') AS month,
        ROUND(SUM(i.Total), 2) AS monthly_revenue
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.Country, DATE_FORMAT(i.InvoiceDate, '%Y-%m')
)
SELECT 
    Country,
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (PARTITION BY Country ORDER BY month) AS prev_month,
    ROUND(monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY Country ORDER BY month), 2) AS growth
FROM MonthlySales
WHERE Country IN ('USA', 'Canada', 'Brazil', 'Germany', 'France')
ORDER BY Country, month
LIMIT 50;


-- =============================================
-- QUERY 5: Top performing tracks with artist context
-- =============================================
-- Business Question: Best-sellers with competitive analysis

WITH TrackSales AS (
    SELECT 
        t.TrackId,
        t.Name AS track_name,
        ar.Name AS artist_name,
        g.Name AS genre,
        COUNT(il.InvoiceLineId) AS times_sold,
        ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
    FROM Track t
    INNER JOIN Album al ON t.AlbumId = al.AlbumId
    INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
    INNER JOIN Genre g ON t.GenreId = g.GenreId
    INNER JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY t.TrackId, t.Name, ar.Name, g.Name
)
SELECT 
    track_name,
    artist_name,
    genre,
    times_sold,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS overall_rank,
    RANK() OVER (PARTITION BY genre ORDER BY revenue DESC) AS genre_rank
FROM TrackSales
ORDER BY revenue DESC
LIMIT 30;


-- =============================================
-- QUERY 6: Customer cohort analysis
-- =============================================
-- Business Question: Do customers from different periods behave differently?

WITH CustomerFirstPurchase AS (
    SELECT 
        c.CustomerId,
        c.FirstName,
        c.LastName,
        MIN(i.InvoiceDate) AS first_purchase_date,
        DATE_FORMAT(MIN(i.InvoiceDate), '%Y-%m') AS cohort_month
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
)
SELECT 
    cfp.cohort_month,
    COUNT(DISTINCT cfp.CustomerId) AS customers_in_cohort,
    COUNT(DISTINCT i.InvoiceId) AS total_purchases,
    ROUND(AVG(i.Total), 2) AS avg_purchase_value,
    ROUND(SUM(i.Total), 2) AS cohort_revenue
FROM CustomerFirstPurchase cfp
INNER JOIN Invoice i ON cfp.CustomerId = i.CustomerId
GROUP BY cfp.cohort_month
ORDER BY cfp.cohort_month;