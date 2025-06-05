CREATE TABLE Departments (
         Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
         Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
         Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Faculties (
       Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
       Dean NVARCHAR(MAX) NOT NULL CHECK (LEN(Dean) > 0),
       Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5)
);

CREATE TABLE Teachers (
      Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
      EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
      IsAssistant BIT NOT NULL DEFAULT 0,
      IsProfessor BIT NOT NULL DEFAULT 0,
      Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
      Position NVARCHAR(MAX) NOT NULL CHECK (LEN(Position) > 0),
      Premium MONEY NOT NULL CHECK (Premium >= 0) DEFAULT 0,
      Salary MONEY NOT NULL CHECK (Salary > 0),
      Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);



-- Departments
INSERT INTO Departments (Financing, Name) VALUES (10000, N'Mathematics');
INSERT INTO Departments (Financing, Name) VALUES (30000, N'Software Development');
INSERT INTO Departments (Financing, Name) VALUES (9000, N'Physics');

-- Faculties
INSERT INTO Faculties (Dean, Name) VALUES (N'John Smith', N'Computer Science');
INSERT INTO Faculties (Dean, Name) VALUES (N'Anna Brown', N'Engineering');
INSERT INTO Faculties (Dean, Name) VALUES (N'Michael Green', N'Physics');

-- Groups
INSERT INTO Groups (Name, Rating, Year) VALUES (N'CS-01', 4, 5);
INSERT INTO Groups (Name, Rating, Year) VALUES (N'EN-02', 2, 3);
INSERT INTO Groups (Name, Rating, Year) VALUES (N'PH-03', 3, 5);

-- Teachers
INSERT INTO Teachers (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES ('1995-05-10', 1, 0, N'Olga', N'Assistant', 200, 500, N'Petrova');
INSERT INTO Teachers (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES ('2001-09-01', 0, 1, N'Ivan', N'Professor', 300, 1200, N'Ivanov');
INSERT INTO Teachers (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES ('1990-01-02', 0, 0, N'Sergey', N'Lecturer', 100, 800, N'Sidorov');
INSERT INTO Teachers (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES ('1998-03-15', 1, 0, N'Elena', N'Assistant', 180, 540, N'Kuznetsova');
INSERT INTO Teachers (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES ('2010-07-20', 0, 1, N'Pavel', N'Professor', 400, 1300, N'Petrov');




SELECT Name, Financing, Id FROM Departments ORDER BY Id DESC;

SELECT Name AS [Group Name], Rating AS [Group Rating] FROM Groups;

SELECT Surname,
       (Salary * 100.0 / NULLIF(Premium, 0)) AS [Salary to Premium %],
       (Salary * 100.0 / NULLIF(Salary + Premium, 0)) AS [Salary to Total %]
FROM Teachers;

SELECT 'The dean of faculty ' + Name + ' is ' + Dean + '.' AS [Info] FROM Faculties;

SELECT Surname FROM Teachers WHERE IsProfessor = 1 AND Salary > 1050;

SELECT Name FROM Departments WHERE Financing < 11000 OR Financing > 25000;

SELECT Name FROM Faculties WHERE Name <> N'Computer Science';

SELECT Surname, Position FROM Teachers WHERE IsProfessor = 0;

SELECT Surname, Position, Salary, Premium
FROM Teachers
WHERE IsAssistant = 1 AND Premium BETWEEN 160 AND 550;

SELECT Surname, Salary FROM Teachers WHERE IsAssistant = 1;

SELECT Surname, Position FROM Teachers WHERE EmploymentDate < '2000-01-01';

SELECT Name AS [Name of Department]
FROM Departments
WHERE Name < N'Software Development';

SELECT Surname
FROM Teachers
WHERE IsAssistant = 1 AND (Salary + Premium) <= 1200;

SELECT Name
FROM Groups
WHERE Year = 5 AND Rating BETWEEN 2 AND 4;

SELECT Surname
FROM Teachers
WHERE IsAssistant = 1 AND (Salary < 550 OR Premium < 200);



 -- delete all tables
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Groups;
DROP TABLE IF EXISTS Faculties;
DROP TABLE IF EXISTS Departments;
