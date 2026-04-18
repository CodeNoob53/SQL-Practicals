-- ===============================
-- Практична робота 8: Додаткові вбудовані SQL функції
-- Schema: publishing | MySQL 8.0+
-- ===============================

USE publishing;

-- ───────────────────────────────
-- Задача 1. Робота з текстовими функціями
-- ───────────────────────────────

-- Повне ім'я автора у верхньому регістрі
SELECT UPPER(Name) AS AuthorNameUpper
FROM Authors;

-- Формування електронного підпису працівника: "Ім'я <email>"
SELECT CONCAT(Name, ' <', Email, '>') AS Signature
FROM Employees;

-- Пошук співробітників, чий email містить домен 'pub.ch'
SELECT Name, Email
FROM Employees
WHERE Email LIKE '%pub.ch%';

-- Визначення довжини назви книги
SELECT Title, LENGTH(Title) AS TitleLength
FROM Books;

-- ───────────────────────────────
-- Задача 2. Робота з числовими функціями
-- ───────────────────────────────

-- Розрахунок загального доходу по кожному замовленню
SELECT OrderID, ROUND(SUM(Quantity * UnitPrice), 2) AS TotalRevenue
FROM OrderItem
GROUP BY OrderID;

-- Оцінка середньої ціни книги у продажах
SELECT ROUND(AVG(UnitPrice), 2) AS AvgBookPrice
FROM OrderItem;

-- Визначення, які позиції замовлень мають непарну кількість
SELECT OrderItemID, Quantity, MOD(Quantity, 2) AS IsOdd
FROM OrderItem;

-- ───────────────────────────────
-- Задача 3. Робота з часовими функціями
-- ───────────────────────────────

-- Поточна дата
SELECT CURDATE() AS Today;

-- Замовлення, які зроблено більше ніж 100 днів тому
SELECT OrderID, OrderDate, DATEDIFF(CURDATE(), OrderDate) AS DaysAgo
FROM Orders
WHERE DATEDIFF(CURDATE(), OrderDate) > 100;

-- Рік і місяць створення контракту
SELECT ContractID, YEAR(StartDate) AS YearStart, MONTH(StartDate) AS MonthStart
FROM Contracts;

-- ───────────────────────────────
-- Задача 4. Логічні та умовні функції
-- ───────────────────────────────

-- Визначити статус контракту
SELECT ContractID,
       IF(EndDate IS NULL, 'Active', 'Closed') AS ContractStatus
FROM Contracts;

-- Категоризація книг за роком видання
SELECT Title, PublishYear,
       CASE
         WHEN PublishYear >= 2025 THEN 'Нові видання'
         WHEN PublishYear BETWEEN 2020 AND 2024 THEN 'Сучасні'
         ELSE 'Архів'
       END AS Category
FROM Books;

-- ───────────────────────────────
-- Задача 5. Службові функції
-- ───────────────────────────────

-- Додаємо колонку Phone (NULL за замовчуванням) для демонстрації IFNULL
ALTER TABLE Authors ADD COLUMN Phone VARCHAR(20) DEFAULT NULL;

-- Заміна NULL значень
SELECT Name, IFNULL(Phone, '— не вказано —') AS PhoneDisplay
FROM Authors;

-- Порівняння даних: перевірка коректності email
SELECT Name, Email,
       IF(Email LIKE '%@%', 'Valid email', 'Invalid email') AS CheckEmail
FROM Employees;
