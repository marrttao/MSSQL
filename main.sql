CREATE TABLE Teachers (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Assistants (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Deans (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Heads (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Faculties (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    DeanId INT NOT NULL UNIQUE,
    FOREIGN KEY (DeanId) REFERENCES Deans(Id)
);

CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    FacultyId INT NOT NULL,
    HeadId INT NOT NULL UNIQUE,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id),
    FOREIGN KEY (HeadId) REFERENCES Heads(Id)
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

CREATE TABLE LectureRooms (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Subjects (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Lectures (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
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

CREATE TABLE Schedules (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Class INT NOT NULL CHECK (Class BETWEEN 1 AND 8),
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    Week INT NOT NULL CHECK (Week BETWEEN 1 AND 52),
    LectureId INT NOT NULL,
    LectureRoomId INT NOT NULL,
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    FOREIGN KEY (LectureRoomId) REFERENCES LectureRooms(Id)
);

CREATE TABLE Students (
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0),
    GroupId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);



INSERT INTO Teachers (Name, Surname) VALUES (N'Edward', N'Hopper');
INSERT INTO Teachers (Name, Surname) VALUES (N'Alex', N'Carmack');
INSERT INTO Teachers (Name, Surname) VALUES (N'John', N'Smith');
INSERT INTO Teachers (Name, Surname) VALUES (N'Linda', N'Brown');
INSERT INTO Teachers (Name, Surname) VALUES (N'Olga', N'Petrova');

INSERT INTO Deans (TeacherId) VALUES (1);
INSERT INTO Heads (TeacherId) VALUES (1);
INSERT INTO Assistants (TeacherId) VALUES (3);
INSERT INTO Curators (TeacherId) VALUES (4);

INSERT INTO Faculties (Building, Name, DeanId) VALUES (1, N'Computer Science', 1);

INSERT INTO Departments (Building, Name, FacultyId, HeadId) VALUES (1, N'Software Development', 1, 1);

INSERT INTO Groups (Name, Year, DepartmentId) VALUES (N'F505', 5, 1);
INSERT INTO Groups (Name, Year, DepartmentId) VALUES (N'F404', 4, 1);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES (1, 1);

INSERT INTO Students (Name, Surname, GroupId) VALUES (N'Anna', N'Lee', 1);

INSERT INTO LectureRooms (Building, Name) VALUES (1, N'A311');
INSERT INTO LectureRooms (Building, Name) VALUES (1, N'A104');
INSERT INTO LectureRooms (Building, Name) VALUES (6, N'A311');
INSERT INTO LectureRooms (Building, Name) VALUES (6, N'A104');
INSERT INTO LectureRooms (Building, Name) VALUES (2, N'B201');

INSERT INTO Subjects (Name) VALUES (N'Art History');
INSERT INTO Subjects (Name) VALUES (N'Programming');
INSERT INTO Subjects (Name) VALUES (N'Math');

INSERT INTO Lectures (SubjectId, TeacherId) VALUES (1, 1);
INSERT INTO Lectures (SubjectId, TeacherId) VALUES (2, 2);
INSERT INTO Lectures (SubjectId, TeacherId) VALUES (2, 3);
INSERT INTO Lectures (SubjectId, TeacherId) VALUES (3, 4);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES (1, 1);
INSERT INTO GroupsLectures (GroupId, LectureId) VALUES (1, 2);
INSERT INTO GroupsLectures (GroupId, LectureId) VALUES (2, 3);

INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES (3, 3, 2, 1, 1);
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES (3, 3, 2, 2, 2);
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES (1, 1, 1, 1, 1);
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES (2, 2, 1, 3, 5);
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES (4, 4, 2, 4, 3);
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES (5, 5, 2, 4, 4);



SELECT DISTINCT lr.Name
FROM Lectures l
    JOIN Teachers t ON l.TeacherId = t.Id
    JOIN Schedules s ON s.LectureId = l.Id
    JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE t.Name = N'Edward' AND t.Surname = N'Hopper';



SELECT DISTINCT t.Surname
FROM Assistants a
    JOIN Teachers t ON a.TeacherId = t.Id
    JOIN Lectures l ON l.TeacherId = t.Id
    JOIN GroupsLectures gl ON gl.LectureId = l.Id
    JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = N'F505';



SELECT DISTINCT s.Name
FROM Lectures l
    JOIN Teachers t ON l.TeacherId = t.Id
    JOIN Subjects s ON s.Id = l.SubjectId
    JOIN GroupsLectures gl ON gl.LectureId = l.Id
    JOIN Groups g ON g.Id = gl.GroupId
WHERE t.Name = N'Alex' AND t.Surname = N'Carmack' AND g.Year = 5;



SELECT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT l.TeacherId
    FROM Lectures l
        JOIN Schedules s ON s.LectureId = l.Id
    WHERE s.DayOfWeek = 1
);



SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT s.LectureRoomId
    FROM Schedules s
    WHERE s.DayOfWeek = 3 AND s.Week = 2 AND s.Class = 3
);



SELECT DISTINCT t.Name, t.Surname
FROM Teachers t
    JOIN Lectures l ON l.TeacherId = t.Id
    JOIN Departments d ON d.FacultyId = (SELECT Id FROM Faculties WHERE Name = N'Computer Science')
WHERE t.Id NOT IN (
    SELECT cu.TeacherId
    FROM Curators cu
        JOIN GroupsCurators gc ON gc.CuratorId = cu.Id
        JOIN Groups g ON g.Id = gc.GroupId
    WHERE g.DepartmentId = (SELECT Id FROM Departments WHERE Name = N'Software Development')
);



SELECT DISTINCT Building FROM Faculties
UNION
SELECT DISTINCT Building FROM Departments
UNION
SELECT DISTINCT Building FROM LectureRooms;



SELECT t.Name, t.Surname, 'Dean' AS Role FROM Teachers t JOIN Deans d ON d.TeacherId = t.Id
UNION ALL
SELECT t.Name, t.Surname, 'Head' FROM Teachers t JOIN Heads h ON h.TeacherId = t.Id
UNION ALL
SELECT t.Name, t.Surname, 'Teacher' FROM Teachers t
UNION ALL
SELECT t.Name, t.Surname, 'Curator' FROM Teachers t JOIN Curators c ON c.TeacherId = t.Id
UNION ALL
SELECT t.Name, t.Surname, 'Assistant' FROM Teachers t JOIN Assistants a ON a.TeacherId = t.Id
ORDER BY Role;



SELECT DISTINCT s.DayOfWeek
FROM Schedules s
    JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE lr.Name IN (N'A311', N'A104') AND lr.Building = 6;
