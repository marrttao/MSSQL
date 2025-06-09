CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE Students (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Date DATE NOT NULL CHECK (Date <= GETDATE()),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

CREATE TABLE GroupsStudents (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GroupId INT NOT NULL,
    StudentId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id)
);





INSERT INTO Faculties (Name) VALUES (N'Computer Science'), (N'Mathematics');

INSERT INTO Departments (Building, Financing, Name, FacultyId) VALUES
    (1, 120000, N'Software Development', 1),
    (2, 80000, N'Applied Math', 2);

INSERT INTO Curators (Name, Surname) VALUES (N'Anna', N'Petrova'), (N'Ivan', N'Sydorenko');

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
    (N'D221', 5, 1),
    (N'D222', 5, 1),
    (N'M101', 3, 2);

INSERT INTO Students (Name, Rating, Surname) VALUES
    (N'Olga', 5, N'Koval'),
    (N'Max', 4, N'Bondar'),
    (N'Yulia', 3, N'Shevchenko');

INSERT INTO GroupsStudents (GroupId, StudentId) VALUES
    (1, 1), (1, 2), (2, 3);

INSERT INTO Teachers (IsProfessor, Name, Salary, Surname) VALUES
    (1, N'Petro', 2000, N'Kozak'),
    (0, N'Serhii', 1500, N'Vasyliev');

INSERT INTO Subjects (Name) VALUES (N'Databases'), (N'Math');

INSERT INTO Lectures (Date, SubjectId, TeacherId) VALUES
    ('2024-06-03', 1, 1),
    ('2024-06-04', 1, 2),
    ('2024-06-05', 2, 1);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
    (1, 1), (1, 2), (2, 3);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
    (1, 1), (2, 1), (1, 2);




SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;




SELECT g.Name
FROM Groups g
    JOIN Departments d ON g.DepartmentId = d.Id
    JOIN GroupsLectures gl ON g.Id = gl.GroupId
    JOIN Lectures l ON gl.LectureId = l.Id
WHERE g.Year = 5
    AND d.Name = N'Software Development'
    AND DATEPART(week, l.Date) = 1
GROUP BY g.Name
HAVING COUNT(*) > 10;

WITH D221Rating AS (
    SELECT AVG(s.Rating) AS AvgRating
    FROM Groups g
        JOIN GroupsStudents gs ON g.Id = gs.GroupId
        JOIN Students s ON gs.StudentId = s.Id
    WHERE g.Name = N'D221'
)



SELECT g.Name
FROM Groups g
    JOIN GroupsStudents gs ON g.Id = gs.GroupId
    JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Name
HAVING AVG(s.Rating) > (SELECT AvgRating FROM D221Rating);




SELECT Surname, Name
FROM Teachers
WHERE Salary > (SELECT AVG(Salary) FROM Teachers WHERE IsProfessor = 1);




SELECT g.Name
FROM Groups g
    JOIN GroupsCurators gc ON g.Id = gc.GroupId
GROUP BY g.Name
HAVING COUNT(gc.CuratorId) > 1;

WITH Min5Year AS (
    SELECT MIN(AvgRating) AS MinRating
    FROM (
        SELECT AVG(s.Rating) AS AvgRating
        FROM Groups g
            JOIN GroupsStudents gs ON g.Id = gs.GroupId
            JOIN Students s ON gs.StudentId = s.Id
        WHERE g.Year = 5
        GROUP BY g.Id
    ) t
)




SELECT g.Name
FROM Groups g
    JOIN GroupsStudents gs ON g.Id = gs.GroupId
    JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Name
HAVING AVG(s.Rating) < (SELECT MinRating FROM Min5Year);

WITH CSFin AS (
    SELECT SUM(Financing) AS CSFinancing
    FROM Departments d
        JOIN Faculties f ON d.FacultyId = f.Id
    WHERE f.Name = N'Computer Science'
)



SELECT f.Name
FROM Faculties f
    JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Name
HAVING SUM(d.Financing) > (SELECT CSFinancing FROM CSFin);

WITH LectCount AS (
    SELECT s.Name AS Subject, t.Name AS TeacherName, t.Surname, COUNT(*) AS Cnt
    FROM Lectures l
        JOIN Subjects s ON l.SubjectId = s.Id
        JOIN Teachers t ON l.TeacherId = t.Id
    GROUP BY s.Name, t.Name, t.Surname
)
SELECT Subject, TeacherName, Surname
FROM (
    SELECT *, RANK() OVER (PARTITION BY Subject ORDER BY Cnt DESC) AS rnk
    FROM LectCount
) t
WHERE rnk = 1;

SELECT TOP 1 s.Name
FROM Subjects s
    LEFT JOIN Lectures l ON s.Id = l.SubjectId
GROUP BY s.Name
ORDER BY COUNT(l.Id) ASC;

SELECT
    (SELECT COUNT(DISTINCT gs.StudentId)
     FROM Groups g
        JOIN Departments d ON g.DepartmentId = d.Id
        JOIN GroupsStudents gs ON g.Id = gs.GroupId
     WHERE d.Name = N'Software Development') AS StudentCount,
    (SELECT COUNT(DISTINCT l.SubjectId)
     FROM Groups g
        JOIN Departments d ON g.DepartmentId = d.Id
        JOIN GroupsLectures gl ON g.Id = gl.GroupId
        JOIN Lectures l ON gl.LectureId = l.Id
     WHERE d.Name = N'Software Development') AS SubjectCount;
