--  Create Database
CREATE DATABASE Hospital;
GO

USE Hospital;
GO

--  Table: Departments
CREATE TABLE Departments (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    Floor INT NOT NULL CHECK (Floor >= 1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

--  Table: Diseases
CREATE TABLE Diseases (
    Id  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Severity INT NOT NULL CHECK (Severity >= 1) DEFAULT 1
);

--  Table: Doctors
CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Phone CHAR(10) NOT NULL,
    Premium MONEY NOT NULL CHECK (Premium >= 0) DEFAULT 0,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

--  Table: Examinations
CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    EndTime TIME NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    StartTime TIME NOT NULL CHECK (StartTime >= '08:00' AND StartTime <= '18:00'),
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id)
);

--  Table: Wards
CREATE TABLE Wards (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Floor INT NOT NULL CHECK (Floor >= 1),
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

--  Insert Departments
INSERT INTO Departments (Building, Financing, Floor, Name) VALUES
    (1, 10000, 2, N'Cardiology'),
    (3, 13000, 1, N'Neurology'),
    (5, 25000, 3, N'Oncology'),
    (4, 9000, 1, N'Pediatrics'),
    (2, 30000, 2, N'Dermatology'),
    (3, 14000, 2, N'Gastroenterology'),
    (4, 12000, 1, N'Urology'),
    (5, 26000, 2, N'Endocrinology');

--  Insert Diseases
INSERT INTO Diseases (Name, Severity) VALUES
    (N'Flu', 1),
    (N'Cancer', 5),
    (N'COVID-19', 4),
    (N'Pneumonia', 3),
    (N'Migraine', 2),
    (N'Diabetes', 3);

--  Insert Doctors
INSERT INTO Doctors (Name, Phone, Premium, Salary, Surname, DepartmentId) VALUES
    (N'John',  '1234567890', 500, 2000, N'Smith', 1),
    (N'Anna',  '2345678901', 200, 1800, N'Brown', 2),
    (N'Nick',  '3456789012', 100, 1600, N'Nelson', 3),
    (N'Nancy', '4567890123', 300, 1700, N'Norris', 4),
    (N'Paul',  '5678901234', 400, 2200, N'Green', 5);

--  Insert Examinations
INSERT INTO Examinations (DayOfWeek, EndTime, Name, StartTime, DoctorId) VALUES
    (1, '13:00', N'Blood Test', '12:00', 1),
    (2, '14:30', N'X-Ray', '13:00', 2),
    (3, '15:00', N'CT Scan', '14:00', 3),
    (4, '10:00', N'Ultrasound', '09:00', 4),
    (5, '12:30', N'ECG', '11:30', 5),
    (2, '13:30', N'Allergy Test',  '12:30', 1);

--  Insert Wards
INSERT INTO Wards (Building, Floor, Name, DepartmentId) VALUES
    (4, 1, N'Ward A', 4),
    (5, 1, N'Ward B', 3),
    (3, 2, N'Ward C', 2),
    (1, 1, N'Ward D', 1),
    (5, 3, N'Ward E', 3),
    (4, 2, N'Ward F', 4);






SELECT * FROM Wards;


SELECT Surname, Phone FROM Doctors;


SELECT DISTINCT Floor FROM Wards;


SELECT Name AS [Name of Disease], Severity AS [Severity of Disease] FROM Diseases;


SELECT d.Name AS DoctorName, dep.Name AS DepartmentName, e.Name AS ExaminationName
FROM Doctors d, Departments dep, Examinations e
WHERE d.DepartmentId = dep.Id AND e.DoctorId = d.Id;


SELECT Name FROM Departments
WHERE Building = 5 AND Financing < 30000;


SELECT Name FROM Departments
WHERE Building = 3 AND Financing BETWEEN 12000 AND 15000;


SELECT Name FROM Wards
WHERE Building IN (4, 5) AND Floor = 1;


SELECT Name, Building, Financing FROM Departments
WHERE Building IN (3, 6) AND (Financing < 11000 OR Financing > 25000);


SELECT Surname FROM Doctors
WHERE Salary + Premium > 1500;


SELECT Surname FROM Doctors
WHERE Salary / 2 > Premium * 3;


SELECT DISTINCT Name FROM Examinations
WHERE DayOfWeek BETWEEN 1 AND 3
  AND StartTime >= '12:00' AND StartTime <= '15:00';


SELECT Name, Building FROM Departments
WHERE Building IN (1, 3, 8, 10);


SELECT Name FROM Diseases
WHERE Severity NOT IN (1, 2);


SELECT Name FROM Departments
WHERE Building NOT IN (1, 3);


SELECT Name FROM Departments
WHERE Building IN (1, 3);


SELECT Surname FROM Doctors
WHERE Surname LIKE N'N%';


use master
drop database Hospital;