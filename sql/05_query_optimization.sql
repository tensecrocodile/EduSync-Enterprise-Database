-- ============================================================================
-- EduSync: Query Optimization Examples
-- Step 2: Common Query Patterns with EXPLAIN Analysis
-- ============================================================================
-- Purpose: Showcase optimized query patterns and demonstrate query plan analysis
--          using EXPLAIN to verify index usage.
-- ============================================================================

-- ============================================================================
-- COMMON QUERY PATTERNS
-- ============================================================================

-- 1. Student Authentication Lookup (Email Index)
-- Use Case: User login, password reset, email verification
EXPLAIN (ANALYZE, BUFFERS)
SELECT StudentID, Email, StudentName, IsActive
FROM Students
WHERE Email = 'john.doe@university.edu';
-- Expected: Index Scan on idx_students_email

-- 2. Find Students by Campus (CampusID Index)
-- Use Case: Campus-specific reports, enrollment lists
EXPLAIN (ANALYZE, BUFFERS)
SELECT StudentID, StudentName, Email
FROM Students
WHERE CampusID = 1
ORDER BY StudentName
LIMIT 50;
-- Expected: Index Scan on idx_students_campus + Sort

-- 3. Student Registrations by Course (FK + JOIN)
-- Use Case: View all students in a course, grade entry
EXPLAIN (ANALYZE, BUFFERS)
SELECT s.StudentName, s.Email, r.Status, r.RegistrationDate
FROM Students s
INNER JOIN Registrations r ON s.StudentID = r.StudentID
WHERE r.CourseID = 42
  AND r.Term = 'Fall2024'
  AND r.Status = 'Enrolled';
-- Expected: Index Scan on idx_registration_course + idx_registration_status

-- 4. Find Courses by Campus and Type (Composite Index)
-- Use Case: Course catalog search, department course listings
EXPLAIN (ANALYZE, BUFFERS)
SELECT CourseID, CourseName, CourseType, Credits
FROM Courses
WHERE CampusID = 2
  AND CourseType = 'Core'
ORDER BY CourseName;
-- Expected: Index Scan on idx_courses_campus_type

-- 5. Student Registrations by Term (Composite Index)
-- Use Case: Get all courses for student in semester
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.CourseName, r.Status, r.RegistrationDate, r.Grade
FROM Registrations r
INNER JOIN Courses c ON r.CourseID = c.CourseID
WHERE r.StudentID = 101
  AND r.Term = 'Spring2024'
ORDER BY c.CourseName;
-- Expected: Index Scan on idx_registration_student_term

-- 6. Audit Logs - User Activity Timeline (Composite + DESC)
-- Use Case: User action history, compliance audits
EXPLAIN (ANALYZE, BUFFERS)
SELECT Timestamp, ActionType, TableName, EntityID, OldValue, NewValue
FROM AuditLogs
WHERE UserID = 5
  AND Timestamp >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY Timestamp DESC
LIMIT 100;
-- Expected: Index Scan on idx_auditlogs_user_timestamp (DESC order)

-- 7. Find Instructors by Campus and Department
-- Use Case: Department roster, instructor lookup
EXPLAIN (ANALYZE, BUFFERS)
SELECT InstructorID, Name, Email, Department
FROM Instructors
WHERE CampusID = 1
  AND Department = 'Computer Science'
ORDER BY Name;
-- Expected: Sequential Scan (multiple filters, may not be indexed)

-- 8. Range Query - Registrations by Status
-- Use Case: Report all active registrations
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) as active_registrations,
       AVG(EXTRACT(YEAR FROM RegistrationDate)) as avg_year
FROM Registrations
WHERE Status IN ('Enrolled', 'Active')
  AND Term LIKE 'Fall%';
-- Expected: Index Scan on idx_registration_status + aggregation

-- ============================================================================
-- QUERY OPTIMIZATION BEST PRACTICES
-- ============================================================================

-- 1. Always use EXPLAIN ANALYZE for significant queries
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM Students WHERE Email = 'test@example.com';

-- 2. Check for Index Scans instead of Sequential Scans
-- Look for Index Scan or Index Only Scan in output
-- Sequential Scan means the index is not being used

-- 3. Monitor query execution time
EXPLAIN (ANALYZE, TIMING)
SELECT COUNT(*) FROM Registrations WHERE Status = 'Enrolled';

-- 4. Use BUFFERS to see memory usage
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM Courses WHERE CampusID = 1;

-- ============================================================================
-- KEY METRICS FROM EXPLAIN OUTPUT
-- ============================================================================
-- Seq Scan:        Full table scan (expensive for large tables)
-- Index Scan:      Uses index, then filters rows
-- Index Only Scan: All data in index, fastest option
-- Bitmap Scan:     Combines multiple index scans
-- Rows:            Estimated vs Actual differences indicate stale stats
-- Buffers:         Shared Hit (cache), Read (disk I/O)
-- Planning/Exec:   Milliseconds spent on query

-- ============================================================================
-- END OF QUERY OPTIMIZATION EXAMPLES
-- ============================================================================
