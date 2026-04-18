-- ===============================
-- Практична робота 7: Вкладені запити. Повторне використання коду
-- Schema: publishing | MySQL 8.0+
-- ===============================

USE publishing;

-- ───────────────────────────────
-- Задача 1. Автори, чиї книги не замовляли (NOT EXISTS)
-- ───────────────────────────────

-- Додаємо тестового автора без замовлень для демонстрації
INSERT INTO Authors (Name, Email, Country)
VALUES ('Тестовий Автор', 'test.author@ex.com', 'Ukraine');

INSERT INTO Books (Title, Genre, ISBN, PublishYear)
VALUES ('Книга без замовлень', 'Fiction', '978-0-999999-001', 2024);

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM Authors a JOIN Books b
WHERE a.Email = 'test.author@ex.com' AND b.ISBN = '978-0-999999-001';

-- Запит: автори, чиї книги жодного разу не замовляли
SELECT a.AuthorID, a.Name
FROM Authors a
WHERE NOT EXISTS (
  SELECT 1
  FROM AuthorBook ab
  JOIN OrderItem oi ON oi.BookID = ab.BookID
  WHERE ab.AuthorID = a.AuthorID
);

-- ───────────────────────────────
-- Задача 2. Книги з продажами вище середнього (HAVING + підзапит)
-- ───────────────────────────────

SELECT b.Title,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM OrderItem oi
JOIN Books b ON b.BookID = oi.BookID
GROUP BY b.Title
HAVING Revenue > (
  SELECT AVG(Quantity * UnitPrice) FROM OrderItem
)
ORDER BY Revenue DESC;

-- ───────────────────────────────
-- Задача 3. Рейтинг книг у межах жанру (CTE + віконна функція)
-- ───────────────────────────────

WITH sales AS (
  SELECT b.Title, b.Genre,
         SUM(oi.Quantity * oi.UnitPrice) AS Revenue
  FROM Books b
  JOIN OrderItem oi ON oi.BookID = b.BookID
  GROUP BY b.Title, b.Genre
)
SELECT Title, Genre, Revenue,
       RANK() OVER (PARTITION BY Genre ORDER BY Revenue DESC) AS GenreRank
FROM sales
ORDER BY Genre, GenreRank;

-- ───────────────────────────────
-- Задача 4. Повторне використання коду (VIEW)
-- ───────────────────────────────

-- Створюємо VIEW для підрахунку продажів по книгах
CREATE OR REPLACE VIEW v_book_sales AS
SELECT b.BookID, b.Title,
       COALESCE(SUM(oi.Quantity * oi.UnitPrice), 0) AS Revenue
FROM Books b
LEFT JOIN OrderItem oi ON oi.BookID = b.BookID
GROUP BY b.BookID, b.Title;

-- Використовуємо VIEW
SELECT * FROM v_book_sales ORDER BY Revenue DESC;

-- Додатково: використовуємо VIEW як підзапит — топ книги вище середнього
SELECT Title, Revenue
FROM v_book_sales
WHERE Revenue > (SELECT AVG(Revenue) FROM v_book_sales WHERE Revenue > 0)
ORDER BY Revenue DESC;
