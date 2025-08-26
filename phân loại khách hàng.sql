create database data_cinema
select * from ticket

-- 1. Recency - Tính số ngày kể từ lần giao dịch gần nhất của mỗi khách hàng
WITH RECENCY AS (
    SELECT 
        customerid, 
        DATEDIFF(DAY, MAX(saledate), '2019-06-15') AS Recency -- Tính số ngày từ lần giao dịch gần nhất đến ngày hiện tại
    FROM dbo.ticket
    GROUP BY customerid
),

-- 2. Frequency - Tính số lần giao dịch của mỗi khách hàng
FREQUENCY AS (
    SELECT 
        customerid, 
        COUNT(*) AS Frequency -- Đếm số lần giao dịch của khách hàng
    FROM dbo.ticket
    GROUP BY customerid
),

-- 3. Monetary - Tính tổng số tiền chi tiêu của mỗi khách hàng
MONETARY AS (
    SELECT 
        customerid, 
        SUM(total) AS Monetary -- Tổng chi tiêu của khách hàng
    FROM dbo.ticket
    GROUP BY customerid
)

-- Kết hợp các bảng Recency, Frequency và Monetary vào một bảng
SELECT R.CUSTOMERID, R.RECENCY, F.FREQUENCY, M.MONETARY,
    CASE 
        WHEN R.RECENCY <= 20 AND F.FREQUENCY >= 8 AND M.MONETARY > 800000 THEN 'VIP'
        WHEN R.RECENCY <= 30 AND F.FREQUENCY BETWEEN 5 AND 7 AND M.MONETARY BETWEEN 500000 AND 800000 THEN N'Khách hàng tiềm năng cao'
        WHEN R.RECENCY <= 90 AND F.FREQUENCY BETWEEN 2 AND 4 AND M.MONETARY BETWEEN 200000 AND 499999 THEN N'Khách hàng tiềm năng'
        ELSE N'Khách hàng cần chú ý'
    END AS CUSTOMER
FROM RECENCY R
JOIN FREQUENCY F ON R.CUSTOMERID = F.CUSTOMERID
JOIN MONETARY M ON R.CUSTOMERID = M.CUSTOMERID
ORDER BY CUSTOMER DESC
     
WITH raw_rfm AS (
    SELECT *,
           CASE 
               WHEN date_diff < 58 THEN '1'
               WHEN date_diff < 146 THEN '2'
               WHEN date_diff < 267 THEN '3'
               ELSE '4'
           END AS R,
           CASE 
               WHEN confirmed_booking > 4 THEN '1'
               WHEN confirmed_booking > 3 THEN '2'
               WHEN confirmed_booking > 2 THEN '3'
               ELSE '4'
           END AS F,
           CASE 
               WHEN total_revenue > 10416 THEN '1'
               WHEN total_revenue > 7054 THEN '2'
               WHEN total_revenue > 4218 THEN '3'
               ELSE '4'
           END AS M
    FROM rfm_base_data
)

