CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Diseases (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Wards (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE NOT NULL DEFAULT GETDATE() CHECK (Date <= GETDATE()),
    DiseaseId INT NOT NULL,
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    FOREIGN KEY (DiseaseId) REFERENCES Diseases(Id),
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    FOREIGN KEY (WardId) REFERENCES Wards(Id)
);

CREATE TABLE Inters (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DoctorId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);

CREATE TABLE Professors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DoctorId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);




INSERT INTO Departments (Building, Financing, Name) VALUES
    (5, 25000, N'Ophthalmology'),
    (5, 30000, N'Physiotherapy'),
    (3, 10000, N'Cardiology'),
    (2, 5000, N'Neurology');

INSERT INTO Diseases (Name) VALUES
    (N'Glaucoma'),
    (N'Cataract'),
    (N'Arrhythmia'),
    (N'Migraine');

INSERT INTO Doctors (Name, Salary, Surname) VALUES
    (N'John', 3000, N'Smith'),
    (N'Anna', 3500, N'Brown'),
    (N'Peter', 4000, N'Johnson'),
    (N'Linda', 2500, N'Williams');

INSERT INTO Examinations (Name) VALUES
    (N'Eye Test'),
    (N'Physio Session'),
    (N'ECG'),
    (N'Brain MRI');

INSERT INTO Wards (Name, Places, DepartmentId) VALUES
    (N'Ward A', 5, 1),
    (N'Ward B', 20, 1),
    (N'Ward C', 4, 2),
    (N'Ward D', 6, 2),
    (N'Ward E', 3, 3);

INSERT INTO DoctorsExaminations (Date, DiseaseId, DoctorId, ExaminationId, WardId) VALUES
    (GETDATE(), 1, 1, 1, 1),
    (GETDATE(), 2, 2, 1, 2),
    (DATEADD(DAY, -3, GETDATE()), 3, 3, 3, 5),
    (DATEADD(DAY, -10, GETDATE()), 4, 4, 4, 3),
    (GETDATE(), 1, 2, 2, 4);

INSERT INTO Inters (DoctorId) VALUES (1), (4);

INSERT INTO Professors (DoctorId) VALUES (2), (3);




SELECT w.Name, w.Places
FROM Wards w
    JOIN Departments d ON w.DepartmentId = d.Id
WHERE d.Building = 5 AND w.Places >= 5
    AND EXISTS (
        SELECT 1 FROM Wards w2
            JOIN Departments d2 ON w2.DepartmentId = d2.Id
        WHERE d2.Building = 5 AND w2.Places > 15
    );



SELECT DISTINCT d.Name
FROM Departments d
    JOIN Wards w ON w.DepartmentId = d.Id
    JOIN DoctorsExaminations de ON de.WardId = w.Id
WHERE de.Date >= DATEADD(DAY, -7, GETDATE());



SELECT di.Name
FROM Diseases di
    LEFT JOIN DoctorsExaminations de ON de.DiseaseId = di.Id
WHERE de.Id IS NULL;



SELECT CONCAT(Name, N' ', Surname) AS FullName
FROM Doctors
WHERE Id NOT IN (SELECT DoctorId FROM DoctorsExaminations);



SELECT d.Name
FROM Departments d
    LEFT JOIN Wards w ON w.DepartmentId = d.Id
    LEFT JOIN DoctorsExaminations de ON de.WardId = w.Id
WHERE de.Id IS NULL;



SELECT d.Surname
FROM Doctors d
    JOIN Inters i ON i.DoctorId = d.Id;



SELECT d.Surname
FROM Doctors d
    JOIN Inters i ON i.DoctorId = d.Id
WHERE d.Salary > (SELECT MIN(Salary) FROM Doctors WHERE Id <> d.Id);



SELECT w.Name
FROM Wards w
WHERE w.Places > ALL (
    SELECT w2.Places
    FROM Wards w2
        JOIN Departments d2 ON w2.DepartmentId = d2.Id
    WHERE d2.Building = 3
);



SELECT DISTINCT d.Surname
FROM Doctors d
    JOIN DoctorsExaminations de ON de.DoctorId = d.Id
    JOIN Wards w ON de.WardId = w.Id
    JOIN Departments dep ON w.DepartmentId = dep.Id
WHERE dep.Name IN (N'Ophthalmology', N'Physiotherapy');



SELECT DISTINCT dep.Name
FROM Departments dep
    JOIN Wards w ON w.DepartmentId = dep.Id
    JOIN DoctorsExaminations de ON de.WardId = w.Id
WHERE de.DoctorId IN (SELECT DoctorId FROM Inters)
    AND de.DoctorId IN (SELECT DoctorId FROM Professors);



SELECT DISTINCT CONCAT(d.Name, N' ', d.Surname) AS FullName, dep.Name AS Department
FROM Doctors d
    JOIN DoctorsExaminations de ON de.DoctorId = d.Id
    JOIN Wards w ON de.WardId = w.Id
    JOIN Departments dep ON w.DepartmentId = dep.Id
WHERE dep.Financing > 20000;



SELECT TOP 1 dep.Name
FROM Doctors d
    JOIN DoctorsExaminations de ON de.DoctorId = d.Id
    JOIN Wards w ON de.WardId = w.Id
    JOIN Departments dep ON w.DepartmentId = dep.Id
ORDER BY d.Salary DESC;



SELECT di.Name, COUNT(de.Id) AS ExaminationCount
FROM Diseases di
    LEFT JOIN DoctorsExaminations de ON de.DiseaseId = di.Id
GROUP BY di.Name;
