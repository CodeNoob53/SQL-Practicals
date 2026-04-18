-- ===============================
-- Практична робота 5: DQL команди
-- Schema: publishing | MySQL 8.0+
-- ===============================

USE publishing;

-- ───────────────────────────────
-- Задача 1. Прості вибірки
-- ───────────────────────────────

SELECT * FROM authors;

SELECT Name, Country FROM authors WHERE Country = 'Ukraine';

SELECT Title, Genre, PublishYear FROM books ORDER BY PublishYear DESC;

-- ───────────────────────────────
-- Задача 2. Зв'язки між таблицями (JOIN)
-- ───────────────────────────────

SELECT a.Name AS Author, b.Title AS Book
FROM authors a
JOIN authorbook ab ON a.AuthorID = ab.AuthorID
JOIN books b       ON b.BookID   = ab.BookID;

-- ───────────────────────────────
-- Задача 3. Фільтрація і сортування
-- ───────────────────────────────

SELECT Title, Genre, PublishYear
FROM books
WHERE Genre = 'Technology'
ORDER BY PublishYear DESC;

-- ───────────────────────────────
-- Задача 4. Агрегація і групування
-- ───────────────────────────────

SELECT b.Genre, COUNT(*) AS BooksCount
FROM books b
GROUP BY b.Genre
ORDER BY BooksCount DESC;

-- ───────────────────────────────
-- Задача 5. HAVING (фільтр по агрегату)
-- ───────────────────────────────

SELECT b.Title, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.Title
HAVING Revenue > 1000
ORDER BY Revenue DESC;

-- ───────────────────────────────
-- Задача 6. Вкладені запити
-- ───────────────────────────────

SELECT b.Title
FROM books b
WHERE b.BookID IN (
  SELECT BookID FROM orderitem
);

-- ───────────────────────────────
-- Задача 7. Використання EXISTS
-- ───────────────────────────────

SELECT a.Name
FROM authors a
WHERE EXISTS (
  SELECT 1
  FROM authorbook ab
  JOIN orderitem oi ON oi.BookID = ab.BookID
  WHERE ab.AuthorID = a.AuthorID
);

-- ───────────────────────────────
-- Задача 8. Аналітичні (віконні) функції
-- ───────────────────────────────

WITH sales AS (
  SELECT b.Title, b.Genre,
         SUM(oi.Quantity * oi.UnitPrice) AS Revenue
  FROM orderitem oi
  JOIN books b ON b.BookID = oi.BookID
  GROUP BY b.Title, b.Genre
)
SELECT *,
       RANK() OVER (PARTITION BY Genre ORDER BY Revenue DESC) AS GenreRank
FROM sales;

-- ───────────────────────────────
-- Задача 9. Базові вибірки
-- ───────────────────────────────

SELECT EmployeeID, Name, Role, Email FROM employees;

SELECT AuthorID, Name, Email, Country FROM authors;

SELECT BookID, Title, Genre, ISBN, PublishYear FROM books;

-- ───────────────────────────────
-- Задача 10. Фільтрація й сортування
-- ───────────────────────────────

-- Книги жанру Technology від новіших до старіших
SELECT Title, Genre, PublishYear
FROM books
WHERE Genre = 'Technology'
ORDER BY PublishYear DESC;

-- Автори з України
SELECT Name, Email
FROM authors
WHERE Country = 'Ukraine'
ORDER BY Name;

-- ───────────────────────────────
-- Задача 11. JOIN: автори ↔ книги (головний автор)
-- ───────────────────────────────

SELECT b.BookID, b.Title, a.AuthorID, a.Name AS Author
FROM authorbook ab
JOIN authors a ON a.AuthorID = ab.AuthorID
JOIN books b   ON b.BookID   = ab.BookID
WHERE ab.AuthorOrder = 1
ORDER BY b.Title;

-- ───────────────────────────────
-- Задача 12. JOIN: співробітники ↔ книги
-- ───────────────────────────────

SELECT e.Name AS Employee, b.Title AS Book, eb.Task
FROM employeebook eb
JOIN employees e ON e.EmployeeID = eb.EmployeeID
JOIN books b     ON b.BookID     = eb.BookID
ORDER BY e.Name, b.Title;

-- ───────────────────────────────
-- Задача 13. Замовлення з позиціями та сумами
-- ───────────────────────────────

-- Деталізація позицій
SELECT o.OrderID, o.OrderDate, o.ClientName,
       b.Title, oi.Quantity, oi.UnitPrice,
       (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM orders o
JOIN orderitem oi ON oi.OrderID = o.OrderID
JOIN books b      ON b.BookID   = oi.BookID
ORDER BY o.OrderDate DESC, o.OrderID;

-- Підсумок по замовленню
SELECT o.OrderID, o.OrderDate, o.ClientName,
       SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM orders o
JOIN orderitem oi ON oi.OrderID = o.OrderID
GROUP BY o.OrderID, o.OrderDate, o.ClientName
ORDER BY o.OrderDate DESC;

-- ───────────────────────────────
-- Задача 14. Агрегації та рейтинги
-- ───────────────────────────────

-- Топ-автори за кількістю книжок
SELECT a.AuthorID, a.Name, COUNT(*) AS BooksCount
FROM authorbook ab
JOIN authors a ON a.AuthorID = ab.AuthorID
GROUP BY a.AuthorID, a.Name
ORDER BY BooksCount DESC, a.Name;

-- Продажі за книжками
SELECT b.BookID, b.Title,
       SUM(oi.Quantity)                AS QtySold,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.BookID, b.Title
ORDER BY Revenue DESC;

-- ───────────────────────────────
-- Задача 15. HAVING (виручка понад 300)
-- ───────────────────────────────

SELECT b.Title,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.Title
HAVING Revenue > 300
ORDER BY Revenue DESC;

-- ───────────────────────────────
-- Задача 16. Підзапити та EXISTS
-- ───────────────────────────────

-- Автори, чиї книги не замовляли
SELECT a.AuthorID, a.Name
FROM authors a
WHERE NOT EXISTS (
  SELECT 1
  FROM authorbook ab
  JOIN orderitem oi ON oi.BookID = ab.BookID
  WHERE ab.AuthorID = a.AuthorID
);

-- ───────────────────────────────
-- Задача 17. Фільтри по датах та статусах
-- ───────────────────────────────

SELECT OrderID, OrderDate, ClientName, Status
FROM orders
WHERE OrderDate BETWEEN '2025-05-01' AND '2025-05-31'
  AND Status IN ('New', 'Completed')
ORDER BY OrderDate DESC;

-- ───────────────────────────────
-- Задача 18. Контракти: автори та співробітники
-- ───────────────────────────────

SELECT c.ContractID,
       a.Name AS Author,
       e.Name AS Employee,
       c.ContractType,
       c.StartDate,
       c.EndDate
FROM contracts c
LEFT JOIN authors   a ON a.AuthorID   = c.AuthorID
LEFT JOIN employees e ON e.EmployeeID = c.EmployeeID
ORDER BY c.StartDate DESC, c.ContractID;

-- ───────────────────────────────
-- Задача 19. Віконні функції: ранжування продажів
-- ───────────────────────────────

WITH sales AS (
  SELECT b.BookID, b.Title, b.Genre,
         SUM(oi.Quantity * oi.UnitPrice) AS Revenue
  FROM orderitem oi
  JOIN books b ON b.BookID = oi.BookID
  GROUP BY b.BookID, b.Title, b.Genre
)
SELECT *,
       DENSE_RANK() OVER (PARTITION BY Genre ORDER BY Revenue DESC) AS GenreRank
FROM sales
ORDER BY Genre, GenreRank;

-- ───────────────────────────────
-- ⭐️ Додаткові завдання
-- ───────────────────────────────

-- Книги з продажами вище середніх
SELECT b.Title,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.BookID, b.Title
HAVING Revenue > (
  SELECT AVG(total)
  FROM (
    SELECT SUM(Quantity * UnitPrice) AS total
    FROM orderitem
    GROUP BY BookID
  ) t
)
ORDER BY Revenue DESC;

-- Автор з найбільшим сумарним доходом
SELECT a.Name,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM authors a
JOIN authorbook ab ON ab.AuthorID = a.AuthorID
JOIN orderitem oi  ON oi.BookID   = ab.BookID
GROUP BY a.AuthorID, a.Name
ORDER BY TotalRevenue DESC
LIMIT 1;

-- Кількість замовлень у кожного клієнта
SELECT ClientName, COUNT(*) AS OrderCount
FROM orders
GROUP BY ClientName
ORDER BY OrderCount DESC;

-- Активні контракти (EndDate ще не настала або NULL)
SELECT c.ContractID, c.ContractType,
       a.Name AS Author, e.Name AS Employee,
       c.StartDate, c.EndDate
FROM contracts c
LEFT JOIN authors   a ON a.AuthorID   = c.AuthorID
LEFT JOIN employees e ON e.EmployeeID = c.EmployeeID
WHERE c.EndDate IS NULL OR c.EndDate >= CURDATE()
ORDER BY c.StartDate;

-- 5 найпопулярніших жанрів за кількістю проданих екземплярів
SELECT b.Genre,
       SUM(oi.Quantity) AS TotalSold
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.Genre
ORDER BY TotalSold DESC
LIMIT 5;
