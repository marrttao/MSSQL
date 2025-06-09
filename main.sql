-- Departments table
CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

-- Doctors table
CREATE TABLE Doctors (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

-- Examinations table
CREATE TABLE Examinations (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

-- Sponsors table
CREATE TABLE Sponsors (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

-- Wards table
CREATE TABLE Wards (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

-- DoctorsExaminations table
CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    StartTime TIME NOT NULL CHECK (StartTime >= '08:00' AND StartTime <= '18:00'),
    EndTime TIME NOT NULL CHECK (EndTime > StartTime),
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    FOREIGN KEY (WardId) REFERENCES Wards(Id)
);

-- Donations table
CREATE TABLE Donations (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Amount MONEY NOT NULL CHECK (Amount > 0),
    Date DATE NOT NULL DEFAULT GETDATE() CHECK (Date <= GETDATE()),
    DepartmentId INT NOT NULL,
    SponsorId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (SponsorId) REFERENCES Sponsors(Id)
);




INSERT INTO Departments (Building, Name) VALUES
    (1, 'Cardiology'),
    (1, 'Neurology'),
    (2, 'Gastroenterology'),
    (2, 'General Surgery'),
    (3, 'Microbiology'),
    (4, 'Oncology');

INSERT INTO Doctors (Name, Premium, Salary, Surname) VALUES
    ('Thomas', 100, 2000, 'Gerada'),
    ('Anthony', 50, 1800, 'Davis'),
    ('Joshua', 200, 2500, 'Bell'),
    ('Maria', 0, 1700, 'Smith'),
    ('Elena', 150, 2200, 'Ivanova');

INSERT INTO Examinations (Name) VALUES
    ('ECG'),
    ('MRI'),
    ('Blood Test'),
    ('Endoscopy'),
    ('Surgery');

INSERT INTO Sponsors (Name) VALUES
    ('Red Cross'),
    ('Health Fund'),
    ('Charity Plus'),
    ('MedSupport');

INSERT INTO Wards (Name, Places, DepartmentId) VALUES
    ('Ward A', 10, 1),
    ('Ward B', 8, 2),
    ('Ward C', 12, 3),
    ('Ward D', 6, 4),
    ('Ward E', 15, 5),
    ('Ward F', 7, 6);

INSERT INTO DoctorsExaminations (StartTime, EndTime, DoctorId, ExaminationId, WardId) VALUES
    ('09:00', '10:00', 1, 1, 1),
    ('13:00', '14:00', 3, 2, 2),
    ('12:30', '13:30', 5, 3, 3),
    ('11:00', '12:00', 2, 4, 4),
    ('14:00', '15:00', 3, 5, 5),
    ('10:00', '11:00', 4, 1, 6);

INSERT INTO Donations (Amount, Date, DepartmentId, SponsorId) VALUES
    (500, '2024-06-01', 1, 1),
    (200, '2024-06-02', 2, 2),
    (100, '2024-06-03', 3, 3),
    (300, '2024-06-04', 4, 1),
    (400, '2024-06-05', 5, 2),
    (600, '2024-06-06', 6, 4),
    (150, '2024-06-07', 3, 1);



SELECT Name FROM Departments
WHERE Building = (SELECT Building FROM Departments WHERE Name = 'Cardiology');




SELECT Name FROM Departments
WHERE Building IN (
    SELECT Building FROM Departments WHERE Name IN ('Gastroenterology', 'General Surgery')
);




SELECT d.Name
FROM Departments d
    JOIN Donations dn ON d.Id = dn.DepartmentId
GROUP BY d.Name
HAVING SUM(dn.Amount) = (
    SELECT MIN(total) FROM (
        SELECT SUM(Amount) AS total
        FROM Donations
        GROUP BY DepartmentId
    ) t
);




SELECT Surname FROM Doctors
WHERE Salary > (
    SELECT Salary FROM Doctors WHERE Name = 'Thomas' AND Surname = 'Gerada'
);

SELECT w.Name FROM Wards w
WHERE w.Places > (
    SELECT AVG(Places) FROM Wards
    WHERE DepartmentId = (SELECT Id FROM Departments WHERE Name = 'Microbiology')
);





SELECT Name + ' ' + Surname AS FullName FROM Doctors
WHERE (Salary + Premium) > (
    SELECT Salary FROM Doctors WHERE Name = 'Anthony' AND Surname = 'Davis'
) + 100;




SELECT DISTINCT d.Name
FROM Departments d
    JOIN Wards w ON d.Id = w.DepartmentId
    JOIN DoctorsExaminations de ON w.Id = de.WardId
    JOIN Doctors doc ON de.DoctorId = doc.Id
WHERE doc.Name = 'Joshua' AND doc.Surname = 'Bell';





SELECT s.Name FROM Sponsors s
WHERE s.Id NOT IN (
    SELECT SponsorId FROM Donations
    WHERE DepartmentId IN (
        SELECT Id FROM Departments WHERE Name IN ('Neurology', 'Oncology')
    )
);



SELECT DISTINCT d.Surname
FROM Doctors d
    JOIN DoctorsExaminations de ON d.Id = de.DoctorId
WHERE de.StartTime < '15:00' AND de.EndTime > '12:00';
