-- ============================================================
-- EduSync: Basic Query Examples
-- ============================================================

-- Query 1: Get all students from a specific campus with their courses
SELECT 
    s.StudentName,
    c.CourseName,
    r.Grade,
    cam.CampusName
FROM Students s
JOIN Registrations r ON s.StudentID = r.StudentID
JOIN Courses c ON r.CourseID = c.CourseID
JOIN Campus cam ON s.CampusID = cam.CampusID
WHERE s.CampusID = 1
ORDER BY s.StudentName, c.CourseName;

-- Query 2: Find instructor with most courses
SELECT 
    i.Name,
    cam.CampusName,
    COUNT(c.CourseID) AS CourseCount
FROM Instructors i
LEFT JOIN Courses c ON i.InstructorID = c.InstructorID
JOIN Campus cam ON i.CampusID = cam.CampusID
GROUP BY i.InstructorID, i.Name, cam.CampusName
ORDER BY CourseCount DESC;

-- Query 3: Campus enrollment statistics
SELECT 
    cam.CampusName,
    COUNT(DISTINCT s.StudentID) AS TotalStudents,
    COUNT(DISTINCT c.CourseID) AS TotalCourses,
    COUNT(DISTINCT i.InstructorID) AS TotalInstructors
FROM Campus cam
LEFT JOIN Students s ON cam.CampusID = s.CampusID
LEFT JOIN Courses c ON cam.CampusID = c.CampusID
LEFT JOIN Instructors i ON cam.CampusID = i.CampusID
GROUP BY cam.CampusID, cam.CampusName;

-- Query 4: Grade distribution for courses
SELECT 
    c.CourseName,
    r.Grade,
    COUNT(*) AS StudentCount
FROM Courses c
JOIN Registrations r ON c.CourseID = r.CourseID
GROUP BY c.CourseID, c.CourseName, r.Grade
ORDER BY c.CourseName, r.Grade;

-- Query 5: Students not enrolled in any course
SELECT 
    s.StudentName,
    s.Email,
    cam.CampusName
FROM Students s
JOIN Campus cam ON s.CampusID = cam.CampusID
WHERE s.StudentID NOT IN (SELECT DISTINCT StudentID FROM Registrations);

-- ============================================================
-- End of Query Examples
-- ============================================================
