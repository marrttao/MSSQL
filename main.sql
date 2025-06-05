-- 1. Create tables

CREATE TABLE Faculties (
       Id INT IDENTITY PRIMARY KEY NOT NULL,
       Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
       Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Departments (
         Id INT IDENTITY PRIMARY KEY NOT NULL,
         Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
         Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
         FacultyId INT NOT NULL,
         FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Curators (
      Id INT IDENTITY PRIMARY KEY NOT NULL,
      Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
      Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Groups (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
            Id INT IDENTITY PRIMARY KEY NOT NULL,
            CuratorId INT NOT NULL,
            GroupId INT NOT NULL,
            FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
            FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Subjects (
      Id INT IDENTITY PRIMARY KEY NOT NULL,
      Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Teachers (
      Id INT IDENTITY PRIMARY KEY NOT NULL,
      Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
      Salary MONEY NOT NULL CHECK (Salary > 0),
      Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Lectures (
      Id INT IDENTITY PRIMARY KEY NOT NULL,
      LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LEN(LectureRoom) > 0),
      SubjectId INT NOT NULL,
      TeacherId INT NOT NULL,
      FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
      FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
            Id INT IDENTITY PRIMARY KEY NOT NULL,
            GroupId INT NOT NULL,
            LectureId INT NOT NULL,
            FOREIGN KEY (GroupId) REFERENCES Groups(Id),
            FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

-- 2. Insert sample data

INSERT INTO Faculties (Name, Financing) VALUES
    (N'Комп''ютерні науки', 10000),
    (N'Математика', 8000);

INSERT INTO Departments (Name, Financing, FacultyId) VALUES
    (N'Інформатика', 12000, 1),
    (N'Прикладна математика', 7000, 2);

INSERT INTO Curators (Name, Surname) VALUES
    (N'Олег', N'Коваленко'),
    (N'Ірина', N'Шевченко');

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
    (N'P107', 3, 1),
    (N'M201', 5, 2);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
    (1, 1),
    (2, 2);

INSERT INTO Subjects (Name) VALUES
    (N'Теорія баз даних'),
    (N'Математичний аналіз');

INSERT INTO Teachers (Name, Surname, Salary) VALUES
    (N'Samantha', N'Adams', 5000),
    (N'John', N'Smith', 4500);

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId) VALUES
    (N'B103', 1, 1),
    (N'C201', 2, 2);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
    (1, 1),
    (2, 2);

-- 3. Queries

SELECT T.Name, T.Surname, G.Name AS GroupName
FROM Teachers T
CROSS JOIN Groups G;

SELECT F.Name
FROM Faculties F
WHERE EXISTS (
    SELECT 1 FROM Departments D
    WHERE D.FacultyId = F.Id AND D.Financing > F.Financing
);

SELECT C.Surname, G.Name AS GroupName
FROM GroupsCurators GC
         JOIN Curators C ON GC.CuratorId = C.Id
         JOIN Groups G ON GC.GroupId = G.Id;

SELECT DISTINCT T.Surname
FROM Groups G
         JOIN GroupsLectures GL ON G.Id = GL.GroupId
         JOIN Lectures L ON GL.LectureId = L.Id
         JOIN Teachers T ON L.TeacherId = T.Id
WHERE G.Name = N'P107';

SELECT DISTINCT T.Surname, F.Name AS FacultyName
FROM Teachers T
         JOIN Lectures L ON T.Id = L.TeacherId
         JOIN GroupsLectures GL ON L.Id = GL.LectureId
         JOIN Groups G ON GL.GroupId = G.Id
         JOIN Departments D ON G.DepartmentId = D.Id
         JOIN Faculties F ON D.FacultyId = F.Id;

SELECT D.Name AS DepartmentName, G.Name AS GroupName
FROM Departments D
         JOIN Groups G ON G.DepartmentId = D.Id;

SELECT DISTINCT S.Name
FROM Teachers T
         JOIN Lectures L ON T.Id = L.TeacherId
         JOIN Subjects S ON L.SubjectId = S.Id
WHERE T.Name = N'Samantha' AND T.Surname = N'Adams';

SELECT DISTINCT D.Name
FROM Subjects S
         JOIN Lectures L ON S.Id = L.SubjectId
         JOIN GroupsLectures GL ON L.Id = GL.LectureId
         JOIN Groups G ON GL.GroupId = G.Id
         JOIN Departments D ON G.DepartmentId = D.Id
WHERE S.Name = N'Теорія баз даних';

SELECT G.Name
FROM Groups G
         JOIN Departments D ON G.DepartmentId = D.Id
         JOIN Faculties F ON D.FacultyId = F.Id
WHERE F.Name = N'Комп''ютерні науки';

SELECT G.Name AS GroupName, F.Name AS FacultyName
FROM Groups G
JOIN Departments D ON G.DepartmentId = D.Id
JOIN Faculties F ON D.FacultyId = F.Id
WHERE G.Year = 5;

SELECT T.Surname, S.Name AS SubjectName, G.Name AS GroupName
FROM Lectures L
JOIN Teachers T ON L.TeacherId = T.Id
JOIN Subjects S ON L.SubjectId = S.Id
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
WHERE L.LectureRoom = N'B103';
