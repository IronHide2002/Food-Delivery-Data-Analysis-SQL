-- Query all data from the sales, product, goldusers_signup, and users tables
SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

-- 1. Calculate the total amount spent by each customer
SELECT s.userid, SUM(p.price) AS total_amt_spent
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY s.userid;

-- 2. Count the number of distinct days each customer visited the service
SELECT userid, COUNT(DISTINCT created_date) AS distinct_days
FROM sales 
GROUP BY userid;

-- 3. Find the first product purchased by each customer
SELECT *
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
    FROM sales
) s
WHERE rnk = 1;

-- 4. Identify the most purchased product overall and count how many times it was purchased by each customer
SELECT userid, COUNT(product_id) AS cnt 
FROM sales 
WHERE product_id = (
    SELECT product_id 
    FROM sales 
    GROUP BY product_id 
    ORDER BY COUNT(product_id) DESC
    LIMIT 1
) 
GROUP BY userid;

-- 5. Find the most popular product for each customer
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk
    FROM (
        SELECT userid, product_id, COUNT(product_id) AS cnt 
        FROM sales
        GROUP BY userid, product_id
    ) s
) s1
WHERE rnk = 1;

-- 6. Determine the first product purchased after becoming a gold member
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date >= gold_signup_date
    ) s
) s1
WHERE rnk = 1;

-- 7. Find the product purchased just before becoming a gold member
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date < gold_signup_date
    ) s
) s1
WHERE rnk = 1;

-- 8. Calculate total orders and amount spent by each customer before becoming a gold member
SELECT userid, COUNT(created_date) AS cnt, SUM(price) AS amt 
FROM (
    SELECT c.*, p.price 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date <= gold_signup_date
    ) c
    JOIN product p ON c.product_id = p.product_id
) c1
GROUP BY userid;

-- 9. Calculate points collected by each customer and identify which product gave the most points
SELECT userid, SUM(total_points)*2.5 AS cashback_earned, SUM(total_points) AS pts_earned 
FROM (
    SELECT e.*, amt/points AS total_points 
    FROM (
        SELECT d.*, 
        CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt 
            FROM (
                SELECT s.*, p.price 
                FROM sales s
                JOIN product p ON s.product_id = p.product_id
            ) c 
            GROUP BY userid, product_id
            ORDER BY userid
        ) d
    ) e
) f
GROUP BY userid;

-- Calculate points earned by each product and find the product with the most points
SELECT product_id, SUM(total_points) AS pts_earned 
FROM (
    SELECT e.*, amt/points AS total_points 
    FROM (
        SELECT d.*, 
        CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt 
            FROM (
                SELECT s.*, p.price 
                FROM sales s
                JOIN product p ON s.product_id = p.product_id
            ) c 
            GROUP BY userid, product_id
            ORDER BY userid
        ) d
    ) e
) f
GROUP BY product_id
ORDER BY pts_earned DESC
LIMIT 1;

-- 10. Calculate points earned by customers in their first year as a gold member
SELECT c.*, p.price * 0.5 AS total_pts_earned
FROM (
    SELECT s.userid, created_date, product_id, gold_signup_date 
    FROM sales s 
    JOIN goldusers_signup g ON s.userid = g.userid 
    WHERE created_date >= gold_signup_date
    AND created_date <= DATE_ADD(gold_signup_date, INTERVAL 1 YEAR)
) c
JOIN product p ON c.product_id = p.product_id;

-- 11. Rank all transactions for each customer
SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
FROM sales;

-- 12. Rank transactions only when the customer is a gold member, marking others as "NA"
SELECT c.*, 
CASE 
    WHEN gold_signup_date IS NULL THEN 'NA' 
    ELSE RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) 
END AS ranking
FROM (
    SELECT s.userid, created_date, product_id, gold_signup_date 
    FROM sales s 
    LEFT JOIN goldusers_signup g ON s.userid = g.userid 
    WHERE created_date >= gold_signup_date
) c;
-- Query all data from the sales, product, goldusers_signup, and users tables
SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

-- 1. Calculate the total amount spent by each customer
SELECT s.userid, SUM(p.price) AS total_amt_spent
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY s.userid;

-- 2. Count the number of distinct days each customer visited the service
SELECT userid, COUNT(DISTINCT created_date) AS distinct_days
FROM sales 
GROUP BY userid;

-- 3. Find the first product purchased by each customer
SELECT *
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
    FROM sales
) s
WHERE rnk = 1;

-- 4. Identify the most purchased product overall and count how many times it was purchased by each customer
SELECT userid, COUNT(product_id) AS cnt 
FROM sales 
WHERE product_id = (
    SELECT product_id 
    FROM sales 
    GROUP BY product_id 
    ORDER BY COUNT(product_id) DESC
    LIMIT 1
) 
GROUP BY userid;

-- 5. Find the most popular product for each customer
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk
    FROM (
        SELECT userid, product_id, COUNT(product_id) AS cnt 
        FROM sales
        GROUP BY userid, product_id
    ) s
) s1
WHERE rnk = 1;

-- 6. Determine the first product purchased after becoming a gold member
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date >= gold_signup_date
    ) s
) s1
WHERE rnk = 1;

-- 7. Find the product purchased just before becoming a gold member
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date < gold_signup_date
    ) s
) s1
WHERE rnk = 1;

-- 8. Calculate total orders and amount spent by each customer before becoming a gold member
SELECT userid, COUNT(created_date) AS cnt, SUM(price) AS amt 
FROM (
    SELECT c.*, p.price 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date <= gold_signup_date
    ) c
    JOIN product p ON c.product_id = p.product_id
) c1
GROUP BY userid;

-- 9. Calculate points collected by each customer and identify which product gave the most points
SELECT userid, SUM(total_points)*2.5 AS cashback_earned, SUM(total_points) AS pts_earned 
FROM (
    SELECT e.*, amt/points AS total_points 
    FROM (
        SELECT d.*, 
        CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt 
            FROM (
                SELECT s.*, p.price 
                FROM sales s
                JOIN product p ON s.product_id = p.product_id
            ) c 
            GROUP BY userid, product_id
            ORDER BY userid
        ) d
    ) e
) f
GROUP BY userid;

-- Calculate points earned by each product and find the product with the most points
SELECT product_id, SUM(total_points) AS pts_earned 
FROM (
    SELECT e.*, amt/points AS total_points 
    FROM (
        SELECT d.*, 
        CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt 
            FROM (
                SELECT s.*, p.price 
                FROM sales s
                JOIN product p ON s.product_id = p.product_id
            ) c 
            GROUP BY userid, product_id
            ORDER BY userid
        ) d
    ) e
) f
GROUP BY product_id
ORDER BY pts_earned DESC
LIMIT 1;

-- 10. Calculate points earned by customers in their first year as a gold member
SELECT c.*, p.price * 0.5 AS total_pts_earned
FROM (
    SELECT s.userid, created_date, product_id, gold_signup_date 
    FROM sales s 
    JOIN goldusers_signup g ON s.userid = g.userid 
    WHERE created_date >= gold_signup_date
    AND created_date <= DATE_ADD(gold_signup_date, INTERVAL 1 YEAR)
) c
JOIN product p ON c.product_id = p.product_id;

-- 11. Rank all transactions for each customer
SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
FROM sales;

-- 12. Rank transactions only when the customer is a gold member, marking others as "NA"
SELECT c.*, 
CASE 
    WHEN gold_signup_date IS NULL THEN 'NA' 
    ELSE RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) 
END AS ranking
FROM (
    SELECT s.userid, created_date, product_id, gold_signup_date 
    FROM sales s 
    LEFT JOIN goldusers_signup g ON s.userid = g.userid 
    WHERE created_date >= gold_signup_date
) c;
-- Query all data from the sales, product, goldusers_signup, and users tables
SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

-- 1. Calculate the total amount spent by each customer
SELECT s.userid, SUM(p.price) AS total_amt_spent
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY s.userid;

-- 2. Count the number of distinct days each customer visited the service
SELECT userid, COUNT(DISTINCT created_date) AS distinct_days
FROM sales 
GROUP BY userid;

-- 3. Find the first product purchased by each customer
SELECT *
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
    FROM sales
) s
WHERE rnk = 1;

-- 4. Identify the most purchased product overall and count how many times it was purchased by each customer
SELECT userid, COUNT(product_id) AS cnt 
FROM sales 
WHERE product_id = (
    SELECT product_id 
    FROM sales 
    GROUP BY product_id 
    ORDER BY COUNT(product_id) DESC
    LIMIT 1
) 
GROUP BY userid;

-- 5. Find the most popular product for each customer
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk
    FROM (
        SELECT userid, product_id, COUNT(product_id) AS cnt 
        FROM sales
        GROUP BY userid, product_id
    ) s
) s1
WHERE rnk = 1;

-- 6. Determine the first product purchased after becoming a gold member
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date >= gold_signup_date
    ) s
) s1
WHERE rnk = 1;

-- 7. Find the product purchased just before becoming a gold member
SELECT * 
FROM (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date < gold_signup_date
    ) s
) s1
WHERE rnk = 1;

-- 8. Calculate total orders and amount spent by each customer before becoming a gold member
SELECT userid, COUNT(created_date) AS cnt, SUM(price) AS amt 
FROM (
    SELECT c.*, p.price 
    FROM (
        SELECT s.userid, created_date, product_id, gold_signup_date 
        FROM sales s 
        JOIN goldusers_signup g ON s.userid = g.userid 
        WHERE created_date <= gold_signup_date
    ) c
    JOIN product p ON c.product_id = p.product_id
) c1
GROUP BY userid;

-- 9. Calculate points collected by each customer and identify which product gave the most points
SELECT userid, SUM(total_points)*2.5 AS cashback_earned, SUM(total_points) AS pts_earned 
FROM (
    SELECT e.*, amt/points AS total_points 
    FROM (
        SELECT d.*, 
        CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt 
            FROM (
                SELECT s.*, p.price 
                FROM sales s
                JOIN product p ON s.product_id = p.product_id
            ) c 
            GROUP BY userid, product_id
            ORDER BY userid
        ) d
    ) e
) f
GROUP BY userid;

-- Calculate points earned by each product and find the product with the most points
SELECT product_id, SUM(total_points) AS pts_earned 
FROM (
    SELECT e.*, amt/points AS total_points 
    FROM (
        SELECT d.*, 
        CASE 
            WHEN product_id = 1 THEN 5 
            WHEN product_id = 2 THEN 2 
            WHEN product_id = 3 THEN 5 
            ELSE 0 
        END AS points 
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt 
            FROM (
                SELECT s.*, p.price 
                FROM sales s
                JOIN product p ON s.product_id = p.product_id
            ) c 
            GROUP BY userid, product_id
            ORDER BY userid
        ) d
    ) e
) f
GROUP BY product_id
ORDER BY pts_earned DESC
LIMIT 1;

-- 10. Calculate points earned by customers in their first year as a gold member
SELECT c.*, p.price * 0.5 AS total_pts_earned
FROM (
    SELECT s.userid, created_date, product_id, gold_signup_date 
    FROM sales s 
    JOIN goldusers_signup g ON s.userid = g.userid 
    WHERE created_date >= gold_signup_date
    AND created_date <= DATE_ADD(gold_signup_date, INTERVAL 1 YEAR)
) c
JOIN product p ON c.product_id = p.product_id;

-- 11. Rank all transactions for each customer
SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
FROM sales;

-- 12. Rank transactions only when the customer is a gold member, marking others as "NA"
SELECT c.*, 
CASE 
    WHEN gold_signup_date IS NULL THEN 'NA' 
    ELSE RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) 
END AS ranking
FROM (
    SELECT s.userid, created_date, product_id, gold_signup_date 
    FROM sales s 
    LEFT JOIN goldusers_signup g ON s.userid = g.userid 
    WHERE created_date >= gold_signup_date
) c;
