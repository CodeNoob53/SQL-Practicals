-- ===============================
-- Практична робота 4: DDL та DML
-- Schema: publishing | MySQL 8.0+
-- ===============================

DROP DATABASE IF EXISTS publishing;

CREATE DATABASE publishing
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE publishing;

-- ===============================
-- DDL: Створення таблиць
-- ===============================

CREATE TABLE Authors (
  AuthorID   INT AUTO_INCREMENT PRIMARY KEY,
  Name       VARCHAR(200) NOT NULL,
  Email      VARCHAR(255) UNIQUE,
  Phone      VARCHAR(50),
  Country    VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE Employees (
  EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
  Name       VARCHAR(200) NOT NULL,
  Role       ENUM('Editor','Proofreader','Translator','Designer') NOT NULL,
  Email      VARCHAR(255) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Books (
  BookID      INT AUTO_INCREMENT PRIMARY KEY,
  Title       VARCHAR(300) NOT NULL,
  Genre       VARCHAR(100),
  ISBN        VARCHAR(32) NOT NULL,
  PublishYear YEAR,
  CONSTRAINT uq_books_isbn UNIQUE (ISBN)
) ENGINE=InnoDB;

CREATE TABLE Orders (
  OrderID    INT AUTO_INCREMENT PRIMARY KEY,
  OrderDate  DATE NOT NULL,
  ClientName VARCHAR(200) NOT NULL,
  Status     ENUM('New','InProgress','Completed','Canceled') NOT NULL DEFAULT 'New'
) ENGINE=InnoDB;

-- Контракт належить або автору, або співробітнику (рівно одному)
CREATE TABLE Contracts (
  ContractID   INT AUTO_INCREMENT PRIMARY KEY,
  AuthorID     INT NULL,
  EmployeeID   INT NULL,
  ContractType ENUM('Author','Employee') NOT NULL,
  StartDate    DATE NOT NULL,
  EndDate      DATE NULL,
  CONSTRAINT fk_contract_author   FOREIGN KEY (AuthorID)   REFERENCES Authors(AuthorID)   ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_contract_employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX ix_contract_author   (AuthorID),
  INDEX ix_contract_employee (EmployeeID)
) ENGINE=InnoDB;

CREATE TABLE AuthorBook (
  AuthorID    INT NOT NULL,
  BookID      INT NOT NULL,
  AuthorOrder INT NULL,
  PRIMARY KEY (AuthorID, BookID),
  CONSTRAINT fk_ab_author FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ab_book   FOREIGN KEY (BookID)   REFERENCES Books(BookID)     ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE EmployeeBook (
  EmployeeID INT  NOT NULL,
  BookID     INT  NOT NULL,
  Task       ENUM('Edit','Proofread','Translate','Design') NOT NULL,
  PRIMARY KEY (EmployeeID, BookID),
  CONSTRAINT fk_eb_employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_eb_book     FOREIGN KEY (BookID)     REFERENCES Books(BookID)          ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE OrderItem (
  OrderItemID INT            AUTO_INCREMENT PRIMARY KEY,
  OrderID     INT            NOT NULL,
  BookID      INT            NOT NULL,
  Quantity    INT            NOT NULL,
  UnitPrice   DECIMAL(10,2)  NOT NULL,
  CONSTRAINT fk_oi_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_oi_book  FOREIGN KEY (BookID)  REFERENCES Books(BookID)   ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX ix_oi_order (OrderID),
  INDEX ix_oi_book  (BookID),
  CONSTRAINT chk_oi_qty   CHECK (Quantity  >= 1),
  CONSTRAINT chk_oi_price CHECK (UnitPrice >= 0)
) ENGINE=InnoDB;

-- ===============================
-- DML: INSERT — по 10 записів
-- ===============================

START TRANSACTION;

INSERT INTO Authors (Name, Email, Phone, Country) VALUES
  ('Ірина Савчук',   'iryna.savchuk@ex.com',  '+380501111111', 'Ukraine'),
  ('Олег Петренко',  'oleg.petrenko@ex.com',  '+380671111112', 'Ukraine'),
  ('Maria Rossi',    'm.rossi@ex.com',         '+39061111111',  'Italy'),
  ('Jean Martin',    'jean.martin@ex.com',     '+33111111111',  'France'),
  ('Anna Müller',    'anna.mueller@ex.com',    '+41441111111',  'Switzerland'),
  ('Lukas Steiner',  'lukas.steiner@ex.com',   '+41441111112',  'Switzerland'),
  ('Sofia Garcia',   'sofia.garcia@ex.com',    '+34911111111',  'Spain'),
  ('Noah Johnson',   'noah.johnson@ex.com',    '+12025550111',  'USA'),
  ('Akira Tanaka',   'akira.tanaka@ex.com',    '+81311111111',  'Japan'),
  ('Eva Novak',      'eva.novak@ex.com',       '+42021111111',  'Czechia');

INSERT INTO Employees (Name, Role, Email) VALUES
  ('Alice Novak',       'Editor',      'alice@pub.ch'),
  ('Bohdan Petrenko',   'Proofreader', 'bohdan@pub.ch'),
  ('Chloe Martin',      'Translator',  'chloe@pub.ch'),
  ('Dmytro Savchuk',    'Designer',    'dmytro@pub.ch'),
  ('Emma Rossi',        'Editor',      'emma@pub.ch'),
  ('Felix Weber',       'Proofreader', 'felix@pub.ch'),
  ('Hanna Kovalenko',   'Translator',  'hanna@pub.ch'),
  ('Ivan Horak',        'Designer',    'ivan@pub.ch'),
  ('Julia Novakova',    'Editor',      'julia@pub.ch'),
  ('Karl Meier',        'Proofreader', 'karl@pub.ch');

INSERT INTO Books (Title, Genre, ISBN, PublishYear) VALUES
  ('Python для початківців', 'Навчальна',   '978-0-100000-001', 2023),
  ('SQL на практиці',        'Навчальна',   '978-0-100000-002', 2024),
  ('Data Analytics 101',     'Навчальна',   '978-0-100000-003', 2025),
  ('Story Craft',            'Fiction',     '978-0-100000-004', 2022),
  ('Mountains & Lakes',      'Travel',      '978-0-100000-005', 2021),
  ('AI for Editors',         'Technology',  '978-0-100000-006', 2025),
  ('Clean Data',             'Non-Fiction', '978-0-100000-007', 2020),
  ('Sci-Fi Tales',           'Sci-Fi',      '978-0-100000-008', 2019),
  ('Business Blue',          'Business',    '978-0-100000-009', 2024),
  ('Creative SQL',           'Technology',  '978-0-100000-010', 2023);

INSERT INTO Orders (OrderDate, ClientName, Status) VALUES
  ('2025-01-10', 'TechBooks GmbH', 'New'),
  ('2025-01-15', 'EduLab SA',      'Completed'),
  ('2025-02-01', 'DataWorks AG',   'InProgress'),
  ('2025-02-18', 'Libra LLC',      'Completed'),
  ('2025-03-03', 'Orion Labs',     'New'),
  ('2025-03-20', 'Pixel Media',    'InProgress'),
  ('2025-04-05', 'QuickLearn',     'Completed'),
  ('2025-04-22', 'Read&Co',        'New'),
  ('2025-05-09', 'Star Books',     'Completed'),
  ('2025-05-25', 'Nova Print',     'Canceled');

COMMIT;

-- Асоціативні таблиці
START TRANSACTION;

INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='iryna.savchuk@ex.com'  AND b.ISBN='978-0-100000-001';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='oleg.petrenko@ex.com'  AND b.ISBN='978-0-100000-002';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='m.rossi@ex.com'        AND b.ISBN='978-0-100000-003';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='jean.martin@ex.com'    AND b.ISBN='978-0-100000-004';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='anna.mueller@ex.com'   AND b.ISBN='978-0-100000-005';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='lukas.steiner@ex.com'  AND b.ISBN='978-0-100000-006';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='sofia.garcia@ex.com'   AND b.ISBN='978-0-100000-007';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='noah.johnson@ex.com'   AND b.ISBN='978-0-100000-008';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='akira.tanaka@ex.com'   AND b.ISBN='978-0-100000-009';
INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder)
  SELECT a.AuthorID, b.BookID, 1 FROM Authors a JOIN Books b
  WHERE a.Email='eva.novak@ex.com'      AND b.ISBN='978-0-100000-010';

INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Edit'      FROM Employees e JOIN Books b WHERE e.Email='alice@pub.ch'  AND b.ISBN='978-0-100000-001';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Proofread' FROM Employees e JOIN Books b WHERE e.Email='bohdan@pub.ch' AND b.ISBN='978-0-100000-002';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Translate' FROM Employees e JOIN Books b WHERE e.Email='chloe@pub.ch'  AND b.ISBN='978-0-100000-003';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Design'    FROM Employees e JOIN Books b WHERE e.Email='dmytro@pub.ch' AND b.ISBN='978-0-100000-004';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Edit'      FROM Employees e JOIN Books b WHERE e.Email='emma@pub.ch'   AND b.ISBN='978-0-100000-005';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Proofread' FROM Employees e JOIN Books b WHERE e.Email='felix@pub.ch'  AND b.ISBN='978-0-100000-006';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Translate' FROM Employees e JOIN Books b WHERE e.Email='hanna@pub.ch'  AND b.ISBN='978-0-100000-007';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Design'    FROM Employees e JOIN Books b WHERE e.Email='ivan@pub.ch'   AND b.ISBN='978-0-100000-008';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Edit'      FROM Employees e JOIN Books b WHERE e.Email='julia@pub.ch'  AND b.ISBN='978-0-100000-009';
INSERT INTO EmployeeBook (EmployeeID, BookID, Task)
  SELECT e.EmployeeID, b.BookID, 'Proofread' FROM Employees e JOIN Books b WHERE e.Email='karl@pub.ch'   AND b.ISBN='978-0-100000-010';

INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT a.AuthorID, NULL, 'Author', '2025-01-01', '2025-12-31' FROM Authors a WHERE a.Email='iryna.savchuk@ex.com';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT a.AuthorID, NULL, 'Author', '2025-02-01', NULL         FROM Authors a WHERE a.Email='m.rossi@ex.com';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT a.AuthorID, NULL, 'Author', '2025-03-01', NULL         FROM Authors a WHERE a.Email='anna.mueller@ex.com';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT a.AuthorID, NULL, 'Author', '2025-03-15', '2026-03-15' FROM Authors a WHERE a.Email='akira.tanaka@ex.com';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT a.AuthorID, NULL, 'Author', '2025-04-01', NULL         FROM Authors a WHERE a.Email='eva.novak@ex.com';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT NULL, e.EmployeeID, 'Employee', '2025-01-10', NULL         FROM Employees e WHERE e.Email='alice@pub.ch';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT NULL, e.EmployeeID, 'Employee', '2025-02-10', '2025-12-31' FROM Employees e WHERE e.Email='bohdan@pub.ch';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT NULL, e.EmployeeID, 'Employee', '2025-03-05', NULL         FROM Employees e WHERE e.Email='chloe@pub.ch';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT NULL, e.EmployeeID, 'Employee', '2025-03-20', NULL         FROM Employees e WHERE e.Email='emma@pub.ch';
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
  SELECT NULL, e.EmployeeID, 'Employee', '2025-04-15', NULL         FROM Employees e WHERE e.Email='karl@pub.ch';

INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 3, 49.90 FROM Orders o JOIN Books b WHERE o.ClientName='TechBooks GmbH' AND b.ISBN='978-0-100000-001';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 2, 59.00 FROM Orders o JOIN Books b WHERE o.ClientName='EduLab SA'      AND b.ISBN='978-0-100000-002';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 1, 39.50 FROM Orders o JOIN Books b WHERE o.ClientName='DataWorks AG'   AND b.ISBN='978-0-100000-003';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 5, 29.90 FROM Orders o JOIN Books b WHERE o.ClientName='Libra LLC'      AND b.ISBN='978-0-100000-004';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 4, 54.00 FROM Orders o JOIN Books b WHERE o.ClientName='Orion Labs'     AND b.ISBN='978-0-100000-005';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 3, 46.00 FROM Orders o JOIN Books b WHERE o.ClientName='Pixel Media'    AND b.ISBN='978-0-100000-006';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 2, 32.00 FROM Orders o JOIN Books b WHERE o.ClientName='QuickLearn'     AND b.ISBN='978-0-100000-007';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 6, 52.50 FROM Orders o JOIN Books b WHERE o.ClientName='Read&Co'        AND b.ISBN='978-0-100000-008';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 2, 28.90 FROM Orders o JOIN Books b WHERE o.ClientName='Star Books'     AND b.ISBN='978-0-100000-009';
INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice)
  SELECT o.OrderID, b.BookID, 7, 44.00 FROM Orders o JOIN Books b WHERE o.ClientName='Nova Print'     AND b.ISBN='978-0-100000-010';

COMMIT;

-- ===============================
-- DML: UPDATE
-- ===============================

-- Оновити статус замовлення TechBooks GmbH на InProgress
UPDATE Orders
SET Status = 'InProgress'
WHERE ClientName = 'TechBooks GmbH';

-- Оновити email автора
UPDATE Authors
SET Email = 'i.savchuk.new@ex.com'
WHERE Email = 'iryna.savchuk@ex.com';

-- Підвищити ціну всіх книг жанру Technology на 10%
UPDATE OrderItem oi
JOIN Books b ON oi.BookID = b.BookID
SET oi.UnitPrice = ROUND(oi.UnitPrice * 1.10, 2)
WHERE b.Genre = 'Technology';

-- ===============================
-- DML: DELETE
-- ===============================

-- Видалити скасоване замовлення (OrderItem видалиться каскадно)
DELETE FROM Orders
WHERE ClientName = 'Nova Print' AND Status = 'Canceled';

-- ===============================
-- DML: SELECT + JOIN
-- ===============================

-- Всі автори та їх книги
SELECT a.Name AS Author, b.Title AS Book, b.Genre, b.PublishYear
FROM Authors a
JOIN AuthorBook ab ON a.AuthorID = ab.AuthorID
JOIN Books b       ON b.BookID   = ab.BookID
ORDER BY a.Name;

-- Замовлення з позиціями та загальною сумою
SELECT o.ClientName, o.OrderDate, o.Status,
       b.Title, oi.Quantity, oi.UnitPrice,
       (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM Orders o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Books b      ON b.BookID  = oi.BookID
ORDER BY o.OrderDate;

-- Співробітники та книги над якими працювали
SELECT e.Name AS Employee, e.Role, b.Title AS Book, eb.Task
FROM Employees e
JOIN EmployeeBook eb ON e.EmployeeID = eb.EmployeeID
JOIN Books b         ON b.BookID     = eb.BookID;

-- Контракти: хто підписав (автор або співробітник)
SELECT c.ContractID, c.ContractType,
       a.Name AS AuthorName,
       e.Name AS EmployeeName,
       c.StartDate, c.EndDate
FROM Contracts c
LEFT JOIN Authors   a ON c.AuthorID   = a.AuthorID
LEFT JOIN Employees e ON c.EmployeeID = e.EmployeeID;

-- ===============================
-- Перевірка кількості записів
-- ===============================

SELECT 'Authors'     AS tbl, COUNT(*) AS cnt FROM Authors
UNION ALL SELECT 'Employees',   COUNT(*) FROM Employees
UNION ALL SELECT 'Books',       COUNT(*) FROM Books
UNION ALL SELECT 'Orders',      COUNT(*) FROM Orders
UNION ALL SELECT 'AuthorBook',  COUNT(*) FROM AuthorBook
UNION ALL SELECT 'EmployeeBook',COUNT(*) FROM EmployeeBook
UNION ALL SELECT 'Contracts',   COUNT(*) FROM Contracts
UNION ALL SELECT 'OrderItem',   COUNT(*) FROM OrderItem;
