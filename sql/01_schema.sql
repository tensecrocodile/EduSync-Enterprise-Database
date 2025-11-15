-- ============================================================
-- EduSync: Enterprise Academic Database Platform
-- Step 1: Normalized, Scalable Database Schema
-- ============================================================

-- Create Campus Table
CREATE TABLE Campus (
    CampusID INT PRIMARY KEY,
    CampusName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL
);

-- Create Students Table (Normalized, Partitionable)
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    CampusID INT NOT NULL,
    FOREIGN KEY (CampusID) REFERENCES Campus(CampusID)
);

-- Create Instructors Table (Normalized, Partitionable)
CREATE TABLE Instructors (
    InstructorID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    CampusID INT NOT NULL,
    FOREIGN KEY (CampusID) REFERENCES Campus(CampusID)
);

-- Create Courses Table (Normalized, Partitionable)
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT NOT NULL,
    InstructorID INT NOT NULL,
    CampusID INT NOT NULL,
    FOREIGN KEY (InstructorID) REFERENCES Instructors(InstructorID),
    FOREIGN KEY (CampusID) REFERENCES Campus(CampusID)
);

-- Create Registrations Table (Normalized)
CREATE TABLE Registrations (
    RegistrationID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Term VARCHAR(20) NOT NULL,
    Grade VARCHAR(5),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    UNIQUE KEY unique_registration (StudentID, CourseID, Term)
);

-- Create AuditLogs Table (For Compliance)
CREATE TABLE AuditLogs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    TableName VARCHAR(50) NOT NULL,
    OperationType VARCHAR(20) NOT NULL,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UserID INT,
    Details TEXT
);

-- ============================================================
-- Schema Complete - All tables in 3NF
-- ============================================================
