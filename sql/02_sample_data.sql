-- ============================================================
-- EduSync: Sample Data for Testing
-- ============================================================

-- Insert Campus Data
INSERT INTO Campus (CampusID, CampusName, Location) VALUES
(1, 'Delhi Campus', 'New Delhi, India'),
(2, 'Mumbai Campus', 'Mumbai, India'),
(3, 'Bangalore Campus', 'Bangalore, India');

-- Insert Students Data
INSERT INTO Students (StudentID, StudentName, Email, CampusID) VALUES
(1, 'Alice Sharma', 'alice@edusync.com', 1),
(2, 'Brian Kumar', 'brian@edusync.com', 1),
(3, 'Carla Singh', 'carla@edusync.com', 2),
(4, 'David Patel', 'david@edusync.com', 2),
(5, 'Emma Reddy', 'emma@edusync.com', 3),
(6, 'Frank Nair', 'frank@edusync.com', 3);

-- Insert Instructors Data
INSERT INTO Instructors (InstructorID, Name, Phone, CampusID) VALUES
(1, 'Dr. Bob Wilson', '9876543210', 1),
(2, 'Dr. Carol White', '9876543211', 1),
(3, 'Dr. David Brown', '9876543212', 2),
(4, 'Dr. Eve Black', '9876543213', 3);

-- Insert Courses Data
INSERT INTO Courses (CourseID, CourseName, Credits, InstructorID, CampusID) VALUES
(101, 'Mathematics 101', 3, 1, 1),
(102, 'Physics 101', 4, 2, 1),
(103, 'Computer Science 101', 3, 3, 2),
(104, 'Chemistry 101', 4, 4, 3),
(105, 'Biology 101', 3, 1, 1);

-- Insert Registrations Data
INSERT INTO Registrations (StudentID, CourseID, Term, Grade) VALUES
(1, 101, 'Fall 2024', 'A'),
(1, 102, 'Fall 2024', 'B+'),
(2, 101, 'Fall 2024', 'A-'),
(3, 103, 'Fall 2024', 'B'),
(4, 103, 'Fall 2024', 'A'),
(5, 104, 'Fall 2024', 'B+'),
(6, 105, 'Fall 2024', 'A');

-- ============================================================
-- Sample Data Inserted Successfully
-- ============================================================
