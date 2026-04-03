-- =====================================================
-- Лабораторная работа №4
-- Вариант 11
-- Оконные функции
-- =====================================================

-- =====================================================
-- ОБЩИЕ ЗАДАНИЯ (для всех студентов)
-- =====================================================

-- Задание 4.1. Ранжирование сотрудников по стажу
SELECT 
    salesperson_id,
    dealership_id,
    first_name,
    hire_date,
    RANK() OVER (PARTITION BY dealership_id ORDER BY hire_date) AS hire_rank
FROM salespeople
WHERE termination_date IS NULL;

-- Задание 4.2. Анализ динамики заполнения адресов
SELECT 
    date_added::DATE,
    COUNT(CASE WHEN street_address IS NOT NULL THEN 1 END) 
        OVER (ORDER BY date_added::DATE) AS total_addresses_filled
FROM customers
ORDER BY date_added::DATE
LIMIT 50;

-- Задание 4.3. Скользящее среднее продаж (7 дней)
WITH daily_sales AS (
    SELECT 
        sales_transaction_date::DATE AS sale_date,
        SUM(sales_amount) AS daily_sum
    FROM sales
    GROUP BY 1
)
SELECT 
    sale_date,
    daily_sum,
    AVG(daily_sum) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7_days
FROM daily_sales
ORDER BY sale_date;

-- =====================================================
-- ИНДИВИДУАЛЬНЫЕ ЗАДАНИЯ (вариант 11)
-- =====================================================

-- Задание 1. Ранжировать клиентов по длине фамилии внутри каждого города
SELECT 
    customer_id,
    first_name,
    last_name,
    city,
    LENGTH(last_name) AS last_name_length,
    RANK() OVER (PARTITION BY city ORDER BY LENGTH(last_name)) AS length_rank
FROM customers
WHERE city IS NOT NULL
ORDER BY city, length_rank;

-- Задание 2. Разделить сотрудников на 3 группы (NTILE) по дате найма
SELECT 
    salesperson_id,
    first_name,
    last_name,
    hire_date,
    NTILE(3) OVER (ORDER BY hire_date) AS hire_group
FROM salespeople
WHERE hire_date IS NOT NULL
ORDER BY hire_group, hire_date;

-- Задание 3. Накопительная сумма продаж по дням только для канала 'internet'
SELECT 
    sales_transaction_date::DATE AS sale_date,
    SUM(sales_amount) AS daily_sales_internet,
    SUM(SUM(sales_amount)) OVER (ORDER BY sales_transaction_date::DATE) AS running_total
FROM sales
WHERE channel = 'internet'
GROUP BY sales_transaction_date::DATE
ORDER BY sale_date;