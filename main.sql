-- 1. Create tables

CREATE TABLE Departments (
         Id INT IDENTITY(1,1) PRIMARY KEY,
         Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Doctors (
     Id INT IDENTITY(1,1) PRIMARY KEY,
     Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
     Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
     Salary MONEY NOT NULL CHECK (Salary > 0),
     Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Specializations (
             Id INT IDENTITY(1,1) PRIMARY KEY,
             Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE DoctorsSpecializations (
                    Id INT IDENTITY(1,1) PRIMARY KEY,
                    DoctorId INT NOT NULL,
                    SpecializationId INT NOT NULL,
                    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
                    FOREIGN KEY (SpecializationId) REFERENCES Specializations(Id)
);

CREATE TABLE Sponsors (
      Id INT IDENTITY(1,1) PRIMARY KEY,
      Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Donations (
       Id INT IDENTITY(1,1) PRIMARY KEY,
       Amount MONEY NOT NULL CHECK (Amount > 0),
       Date DATE NOT NULL DEFAULT GETDATE() CHECK (Date <= GETDATE()),
       DepartmentId INT NOT NULL,
       SponsorId INT NOT NULL,
       FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
       FOREIGN KEY (SponsorId) REFERENCES Sponsors(Id)
);

CREATE TABLE Vacations (
       Id INT IDENTITY(1,1) PRIMARY KEY,
       EndDate DATE NOT NULL,
       StartDate DATE NOT NULL,
       DoctorId INT NOT NULL,
       FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
       CHECK (EndDate > StartDate)
);

CREATE TABLE Wards (
   Id INT IDENTITY(1,1) PRIMARY KEY,
   Name NVARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
   DepartmentId INT NOT NULL,
   FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

-- Additional tables for queries
CREATE TABLE Diseases (
      Id INT IDENTITY(1,1) PRIMARY KEY,
      Name NVARCHAR(100) NOT NULL,
      Severity INT NOT NULL,
      IsContagious BIT NOT NULL
);

CREATE TABLE Examinations (
          Id INT IDENTITY(1,1) PRIMARY KEY,
          DoctorId INT NOT NULL,
          WardId INT NOT NULL,
          DiseaseId INT NOT NULL,
          ExamDate DATE NOT NULL,
          Weekday INT NOT NULL, -- 1=Monday, ..., 7=Sunday
          FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
          FOREIGN KEY (WardId) REFERENCES Wards(Id),
          FOREIGN KEY (DiseaseId) REFERENCES Diseases(Id)
);

-- 2. Insert sample data

INSERT INTO Departments (Name) VALUES
       (N'Intensive Treatment'),
       (N'Cardiology'),
       (N'Neurology');

INSERT INTO Doctors (Name, Premium, Salary, Surname) VALUES
     (N'Helen', 5000, 30000, N'Williams'),
     (N'John', 0, 25000, N'Smith'),
     (N'Anna', 2000, 27000, N'Brown');

INSERT INTO Specializations (Name) VALUES
       (N'Cardiologist'),
       (N'Neurologist'),
       (N'Therapist');

INSERT INTO DoctorsSpecializations (DoctorId, SpecializationId) VALUES
        (1, 3),
        (2, 1),
        (3, 2);

INSERT INTO Sponsors (Name) VALUES
    (N'Umbrella Corporation'),
    (N'Wayne Enterprises');

INSERT INTO Donations (Amount, Date, DepartmentId, SponsorId) VALUES
      (150000, DATEADD(DAY, -10, GETDATE()), 1, 1),
      (50000, DATEADD(DAY, -40, GETDATE()), 2, 2),
      (120000, DATEADD(DAY, -20, GETDATE()), 2, 1);

INSERT INTO Vacations (EndDate, StartDate, DoctorId) VALUES
    ('2024-07-10', '2024-07-01', 3);

INSERT INTO Wards (Name, DepartmentId) VALUES
       (N'Ward A', 1),
       (N'Ward B', 2),
       (N'Ward C', 1);

INSERT INTO Diseases (Name, Severity, IsContagious) VALUES
       (N'Flu', 2, 1),
       (N'Heart Attack', 5, 0),
       (N'Migraine', 3, 0),
       (N'COVID-19', 4, 1);

INSERT INTO Examinations (DoctorId, WardId, DiseaseId, ExamDate, Weekday) VALUES
       (1, 1, 1, DATEADD(DAY, -5, GETDATE()), 2),
       (2, 2, 2, DATEADD(DAY, -3, GETDATE()), 3),
       (1, 3, 4, DATEADD(DAY, -10, GETDATE()), 5),
       (3, 2, 3, DATEADD(DAY, -100, GETDATE()), 6);

SELECT D.Name + N' ' + D.Surname AS FullName, S.Name AS Specialization
FROM Doctors D
         JOIN DoctorsSpecializations DS ON D.Id = DS.DoctorId
         JOIN Specializations S ON DS.SpecializationId = S.Id;

SELECT Surname, (Salary + Premium) AS TotalSalary
FROM Doctors
WHERE Id NOT IN (
    SELECT DoctorId
    FROM Vacations
    WHERE GETDATE() BETWEEN StartDate AND EndDate
);

SELECT W.Name
FROM Wards W
         JOIN Departments D ON W.DepartmentId = D.Id
WHERE D.Name = N'Intensive Treatment';

SELECT DISTINCT D.Name
FROM Donations DN
         JOIN Departments D ON DN.DepartmentId = D.Id
         JOIN Sponsors S ON DN.SponsorId = S.Id
WHERE S.Name = N'Umbrella Corporation';

SELECT Dept.Name AS Department, S.Name AS Sponsor, DN.Amount, DN.Date
FROM Donations DN
         JOIN Departments Dept ON DN.DepartmentId = Dept.Id
         JOIN Sponsors S ON DN.SponsorId = S.Id
WHERE DN.Date >= DATEADD(MONTH, -1, GETDATE());

SELECT DISTINCT D.Surname, Dept.Name AS Department
FROM Examinations E
         JOIN Doctors D ON E.DoctorId = D.Id
         JOIN Wards W ON E.WardId = W.Id
         JOIN Departments Dept ON W.DepartmentId = Dept.Id
WHERE E.Weekday BETWEEN 1 AND 5;

SELECT DISTINCT W.Name AS Ward, Dept.Name AS Department
FROM Examinations E
         JOIN Doctors D ON E.DoctorId = D.Id
         JOIN Wards W ON E.WardId = W.Id
         JOIN Departments Dept ON W.DepartmentId = Dept.Id
WHERE D.Name = N'Helen' AND D.Surname = N'Williams';

SELECT DISTINCT Dept.Name AS Department, Doc.Name + N' ' + Doc.Surname AS Doctor
FROM Donations DN
         JOIN Departments Dept ON DN.DepartmentId = Dept.Id
         JOIN Wards W ON W.DepartmentId = Dept.Id
         JOIN Examinations E ON E.WardId = W.Id
         JOIN Doctors Doc ON Doc.Id = E.DoctorId
WHERE DN.Amount > 100000;

SELECT DISTINCT Dept.Name
FROM Doctors D
         JOIN Examinations E ON D.Id = E.DoctorId
         JOIN Wards W ON E.WardId = W.Id
         JOIN Departments Dept ON W.DepartmentId = Dept.Id
WHERE D.Premium = 0;

SELECT DISTINCT S.Name
FROM Specializations S
         JOIN DoctorsSpecializations DS ON S.Id = DS.SpecializationId
         JOIN Doctors D ON DS.DoctorId = D.Id
         JOIN Examinations E ON D.Id = E.DoctorId
         JOIN Diseases DI ON E.DiseaseId = DI.Id
WHERE DI.Severity > 3;


SELECT DISTINCT Dept.Name AS Department, DI.Name AS Disease
FROM Examinations E
         JOIN Wards W ON E.WardId = W.Id
         JOIN Departments Dept ON W.DepartmentId = Dept.Id
         JOIN Diseases DI ON E.DiseaseId = DI.Id
WHERE E.ExamDate >= DATEADD(MONTH, -6, GETDATE());


SELECT DISTINCT Dept.Name AS Department, W.Name AS Ward
FROM Examinations E
         JOIN Wards W ON E.WardId = W.Id
         JOIN Departments Dept ON W.DepartmentId = Dept.Id
         JOIN Diseases DI ON E.DiseaseId = DI.Id
WHERE DI.IsContagious = 1;

