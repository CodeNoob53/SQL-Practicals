-- ===============================
-- Практична робота 6: Складні SQL вирази
-- Тригери для таблиці Contracts
-- Schema: publishing | MySQL 8.0+
-- ===============================

USE publishing;

-- ───────────────────────────────
-- Задача 1. Тригер BEFORE INSERT
-- trg_contracts_bi
-- ───────────────────────────────

DROP TRIGGER IF EXISTS trg_contracts_bi;

DELIMITER $$

CREATE TRIGGER trg_contracts_bi
BEFORE INSERT ON Contracts
FOR EACH ROW
BEGIN
  -- 1. Рівно один з AuthorID/EmployeeID має бути NOT NULL
  IF (NEW.AuthorID IS NULL AND NEW.EmployeeID IS NULL)
  OR (NEW.AuthorID IS NOT NULL AND NEW.EmployeeID IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Exactly one of AuthorID or EmployeeID must be set';
  END IF;

  -- 2. ContractType має відповідати власнику
  IF (NEW.AuthorID IS NOT NULL AND NEW.ContractType <> 'Author')
  OR (NEW.EmployeeID IS NOT NULL AND NEW.ContractType <> 'Employee') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'ContractType must match owner (Author/Employee)';
  END IF;

  -- 3. EndDate не може бути раніше StartDate
  IF NEW.EndDate IS NOT NULL AND NEW.EndDate < NEW.StartDate THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'EndDate must be >= StartDate';
  END IF;
END$$

DELIMITER ;

-- ───────────────────────────────
-- Задача 2. Тригер BEFORE UPDATE
-- trg_contracts_bu
-- ───────────────────────────────

DROP TRIGGER IF EXISTS trg_contracts_bu;

DELIMITER $$

CREATE TRIGGER trg_contracts_bu
BEFORE UPDATE ON Contracts
FOR EACH ROW
BEGIN
  -- 1. Рівно один з AuthorID/EmployeeID має бути NOT NULL
  IF (NEW.AuthorID IS NULL AND NEW.EmployeeID IS NULL)
  OR (NEW.AuthorID IS NOT NULL AND NEW.EmployeeID IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Exactly one of AuthorID or EmployeeID must be set';
  END IF;

  -- 2. ContractType має відповідати власнику
  IF (NEW.AuthorID IS NOT NULL AND NEW.ContractType <> 'Author')
  OR (NEW.EmployeeID IS NOT NULL AND NEW.ContractType <> 'Employee') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'ContractType must match owner (Author/Employee)';
  END IF;

  -- 3. EndDate не може бути раніше StartDate
  IF NEW.EndDate IS NOT NULL AND NEW.EndDate < NEW.StartDate THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'EndDate must be >= StartDate';
  END IF;
END$$

DELIMITER ;

-- ───────────────────────────────
-- Задача 3. Перевірка роботи тригерів
-- ───────────────────────────────

-- ✅ Коректна вставка — має виконатись успішно
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
VALUES (1, NULL, 'Author', '2025-06-01', '2025-12-31');

-- ❌ Помилка 1: два власники одночасно
-- Очікується: 'Exactly one of AuthorID or EmployeeID must be set'
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate)
VALUES (1, 1, 'Author', '2025-06-01');

-- ❌ Помилка 2: неправильний тип контракту
-- AuthorID заповнений, але ContractType = 'Employee'
-- Очікується: 'ContractType must match owner (Author/Employee)'
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate)
VALUES (1, NULL, 'Employee', '2025-06-01');

-- ❌ Помилка 3: некоректні дати (EndDate < StartDate)
-- Очікується: 'EndDate must be >= StartDate'
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
VALUES (1, NULL, 'Author', '2025-12-01', '2025-01-01');

-- ───────────────────────────────
-- Задача 4. Аналітична перевірка
-- ───────────────────────────────

-- Перевірити актуальні контракти після коректної вставки
SELECT ContractID, ContractType, AuthorID, EmployeeID, StartDate, EndDate
FROM Contracts
ORDER BY StartDate DESC;
