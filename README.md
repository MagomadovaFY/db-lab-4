# Лабораторная работа №4

## Вариант 11

### Тема: Оконные функции (ROW_NUMBER, RANK, NTILE, LAG, LEAD, оконные агрегаты)

---

## ОБЩИЕ ЗАДАНИЯ

### Задание 4.1. Ранжирование сотрудников по стажу

**Условие:**  
Оценить сотрудников в каждом дилерском центре на основе даты их найма.

**SQL-запрос:**
```sql
SELECT 
    salesperson_id,
    dealership_id,
    first_name,
    hire_date,
    RANK() OVER (PARTITION BY dealership_id ORDER BY hire_date) AS hire_rank
FROM salespeople
WHERE termination_date IS NULL;
```
**Пояснение:**
PARTITION BY делит сотрудников по дилерским центрам. ORDER BY hire_date сортирует по дате найма. RANK присваивает ранг (1 — самый старый сотрудник).

### Задание 4.2. Анализ динамики заполнения адресов
**Условие:**
Посмотреть накопительный итог количества клиентов, заполнивших street_address, в разбивке по датам регистрации.

**SQL-запрос:**
```sql
SELECT 
    date_added::DATE,
    COUNT(CASE WHEN street_address IS NOT NULL THEN 1 END) 
        OVER (ORDER BY date_added::DATE) AS total_addresses_filled
FROM customers
ORDER BY date_added::DATE
LIMIT 50;
```
**Пояснение:**
CASE внутри COUNT считает только те строки, где адрес заполнен. OVER с ORDER BY создаёт накопительный итог.

### Задание 4.3. Скользящее среднее продаж (7 дней)
Условие:
Рассчитать 7-дневное скользящее среднее суммы продаж.

**SQL-запрос:**
```sql
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
```
**Пояснение:**
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW задаёт окно: текущая строка и 6 предыдущих. AVG вычисляет среднее по этому окну.

# ИНДИВИДУАЛЬНЫЕ ЗАДАНИЯ (вариант 11)
### Задание 1. Ранжирование клиентов по длине фамилии внутри города
**Условие:**
Ранжировать клиентов по длине их фамилии внутри каждого города.

**SQL-запрос:**
```sql
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
```
**Пояснение:**
LENGTH(last_name) вычисляет длину фамилии. PARTITION BY city группирует по городам. RANK ранжирует внутри каждой группы по длине фамилии.

### Задание 2. Разделение сотрудников на 3 группы по дате найма
**Условие:**
Разделить сотрудников на 3 равные группы (NTILE) по дате найма.

**SQL-запрос:**
```sql
SELECT 
    salesperson_id,
    first_name,
    last_name,
    hire_date,
    NTILE(3) OVER (ORDER BY hire_date) AS hire_group
FROM salespeople
WHERE hire_date IS NOT NULL
ORDER BY hire_group, hire_date;
```
**Пояснение:**
NTILE(3) разбивает всех сотрудников на 3 группы примерно равного размера. Группа 1 — самые старые сотрудники, группа 3 — самые новые.

### Задание 3. Накопительная сумма продаж по дням (только 'internet')
**Условие:**
Посчитать накопительную сумму продаж по дням только для канала 'internet'.

**SQL-запрос:**
```sql
SELECT 
    sales_transaction_date::DATE AS sale_date,
    SUM(sales_amount) AS daily_sales_internet,
    SUM(SUM(sales_amount)) OVER (ORDER BY sales_transaction_date::DATE) AS running_total
FROM sales
WHERE channel = 'internet'
GROUP BY sales_transaction_date::DATE
ORDER BY sale_date;
```
**Пояснение:**
WHERE channel = 'internet' фильтрует только интернет-продажи. Внешний SUM с OVER создаёт накопительный итог по дням.
