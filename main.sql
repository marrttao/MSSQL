CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Doctors (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Examinations (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Wards (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY PRIMARY KEY,
    StartTime TIME NOT NULL CHECK (StartTime >= '08:00' AND StartTime <= '18:00'),
    EndTime TIME NOT NULL CHECK (EndTime > StartTime),
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    FOREIGN KEY (WardId) REFERENCES Wards(Id)
);

-- Departments
INSERT INTO Departments (Building, Name) VALUES
    (1, N'Cardiology'),
    (2, N'Neurology'),
    (3, N'Surgery'),
    (4, N'Pediatrics'),
    (5, N'Oncology');

-- Wards
INSERT INTO Wards (Name, Places, DepartmentId) VALUES
    (N'WardA', 12, 1),
    (N'WardB', 8, 1),
    (N'WardC', 15, 2),
    (N'WardD', 20, 2),
    (N'WardE', 5, 3),
    (N'WardF', 25, 3),
    (N'WardG', 30, 4),
    (N'WardH', 10, 4),
    (N'WardI', 7, 5),
    (N'WardJ', 18, 5);

-- Doctors
INSERT INTO Doctors (Name, Premium, Salary, Surname) VALUES
    (N'Ivan', 500, 5000, N'Petrov'),
    (N'Olga', 0, 6000, N'Sidorova'),
    (N'Anna', 200, 5500, N'Ivanova'),
    (N'Pavel', 1000, 7000, N'Smirnov'),
    (N'Elena', 300, 6500, N'Kuznetsova'),
    (N'Andrey', 0, 4800, N'Popov'),
    (N'Maria', 700, 7200, N'Volkova'),
    (N'Viktor', 400, 5100, N'Lebedev');

-- Examinations
INSERT INTO Examinations (Name) VALUES
    (N'ECG'),
    (N'MRI'),
    (N'X-Ray'),
    (N'Ultrasound'),
    (N'Blood Test');

-- DoctorsExaminations
INSERT INTO DoctorsExaminations (StartTime, EndTime, DoctorId, ExaminationId, WardId) VALUES
    ('09:00', '10:00', 1, 1, 1),
    ('10:00', '11:00', 2, 2, 2),
    ('11:00', '12:00', 3, 3, 3),
    ('12:00', '13:00', 4, 4, 4),
    ('13:00', '14:00', 5, 5, 5),
    ('14:00', '15:00', 6, 1, 6),
    ('15:00', '16:00', 7, 2, 7),
    ('16:00', '17:00', 8, 3, 8),
    ('09:00', '10:00', 1, 4, 9),
    ('10:00', '11:00', 2, 5, 10),
    ('11:00', '12:00', 3, 1, 1),
    ('12:00', '13:00', 4, 2, 2),
    ('13:00', '14:00', 5, 3, 3),
    ('14:00', '15:00', 6, 4, 4),
    ('15:00', '16:00', 7, 5, 5);

SELECT COUNT(*) AS WardsWithMoreThan10Places
FROM Wards
WHERE Places > 10;

SELECT d.Building, COUNT(w.Id) AS WardCount
FROM Departments d
    JOIN Wards w ON w.DepartmentId = d.Id
GROUP BY d.Building;

SELECT d.Name AS DepartmentName, COUNT(w.Id) AS WardCount
FROM Departments d
    JOIN Wards w ON w.DepartmentId = d.Id
GROUP BY d.Name;

SELECT d.Name AS DepartmentName, SUM(doc.Premium) AS TotalPremium
FROM Departments d
    JOIN Wards w ON w.DepartmentId = d.Id
    JOIN DoctorsExaminations de ON de.WardId = w.Id
    JOIN Doctors doc ON doc.Id = de.DoctorId
GROUP BY d.Name;

SELECT d.Name AS DepartmentName
FROM Departments d
    JOIN Wards w ON w.DepartmentId = d.Id
    JOIN DoctorsExaminations de ON de.WardId = w.Id
GROUP BY d.Name
HAVING COUNT(DISTINCT de.DoctorId) >= 5;

SELECT COUNT(*) AS DoctorCount, SUM(Salary + Premium) AS TotalSalary
FROM Doctors;

SELECT AVG(Salary + Premium) AS AverageSalary
FROM Doctors;

SELECT Name
FROM Wards
WHERE Places = (SELECT MIN(Places) FROM Wards);

SELECT d.Building, SUM(w.Places) AS TotalPlaces
FROM Departments d
    JOIN Wards w ON w.DepartmentId = d.Id
WHERE d.Building = 1 AND w.Places > 10
GROUP BY d.Building
HAVING SUM(w.Places) > 100;
