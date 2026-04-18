CREATE TABLE `Authors` (
  `AuthorID` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(100) UNIQUE,
  `Phone` varchar(20),
  `Country` varchar(50)
);

CREATE TABLE `Books` (
  `BookID` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `Title` varchar(200) NOT NULL,
  `Genre` ENUM ('fiction', 'non_fiction', 'science', 'history', 'biography', 'children', 'poetry', 'other'),
  `ISBN` varchar(20) UNIQUE NOT NULL,
  `PublishYear` year
);

CREATE TABLE `Employees` (
  `EmployeeID` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Role` ENUM ('editor', 'proofreader', 'translator', 'marketing', 'manager'),
  `Email` varchar(100) UNIQUE
);

CREATE TABLE `Contracts` (
  `ContractID` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `PersonID` int NOT NULL,
  `PersonType` ENUM ('author', 'employee') NOT NULL,
  `ContractType` ENUM ('author_contract', 'employee_contract', 'freelance'),
  `StartDate` date NOT NULL,
  `EndDate` date COMMENT 'CHECK EndDate >= StartDate'
);

CREATE TABLE `AuthorBook` (
  `AuthorID` int NOT NULL,
  `BookID` int NOT NULL,
  `Contribution` varchar(50),
  PRIMARY KEY (`AuthorID`, `BookID`)
);

CREATE TABLE `EmployeeBook` (
  `EmployeeID` int NOT NULL,
  `BookID` int NOT NULL,
  `WorkRole` ENUM ('editor', 'proofreader', 'translator', 'marketing', 'manager'),
  PRIMARY KEY (`EmployeeID`, `BookID`)
);

CREATE TABLE `Orders` (
  `OrderID` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `OrderDate` date NOT NULL,
  `ClientName` varchar(100) NOT NULL,
  `Status` ENUM ('new', 'in_progress', 'done', 'cancelled') NOT NULL DEFAULT 'new'
);

CREATE TABLE `OrderItem` (
  `OrderItemID` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `OrderID` int NOT NULL,
  `BookID` int NOT NULL,
  `Quantity` int NOT NULL COMMENT 'CHECK > 0',
  `Price` decimal(10,2) NOT NULL COMMENT 'CHECK > 0'
);

ALTER TABLE `AuthorBook` ADD FOREIGN KEY (`AuthorID`) REFERENCES `Authors` (`AuthorID`);

ALTER TABLE `AuthorBook` ADD FOREIGN KEY (`BookID`) REFERENCES `Books` (`BookID`);

ALTER TABLE `EmployeeBook` ADD FOREIGN KEY (`EmployeeID`) REFERENCES `Employees` (`EmployeeID`);

ALTER TABLE `EmployeeBook` ADD FOREIGN KEY (`BookID`) REFERENCES `Books` (`BookID`);

ALTER TABLE `OrderItem` ADD FOREIGN KEY (`OrderID`) REFERENCES `Orders` (`OrderID`);

ALTER TABLE `OrderItem` ADD FOREIGN KEY (`BookID`) REFERENCES `Books` (`BookID`);

ALTER TABLE `Contracts` ADD FOREIGN KEY (`PersonID`) REFERENCES `Authors` (`AuthorID`);

ALTER TABLE `Contracts` ADD FOREIGN KEY (`PersonID`) REFERENCES `Employees` (`EmployeeID`);
