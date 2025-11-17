-- ============================================================================
-- EduSync: B-Tree Indexing Strategy
-- Step 2: Indexing and Query Optimization
-- ============================================================================
-- Purpose: Create B-tree indexes on frequently queried columns for optimal
--          lookup performance, range queries, and JOIN operations.
--
-- Index Strategy:
--   1. Single-column indexes on common filter/search columns
--   2. Composite indexes for multi-column predicates
--   3. Indexes on foreign keys for JOIN optimization
--   4. Indexes on audit/timestamp columns for range queries
-- ============================================================================

-- ============================================================================
-- STUDENTS TABLE INDEXES
-- ============================================================================
-- Email lookups are frequent (authentication, password resets)
CREATE INDEX idx_students_email ON Students USING btree (Email);
COMMENT ON INDEX idx_students_email IS 'Search by email for authentication';

-- Student name searches/filtering
CREATE INDEX idx_students_name ON Students USING btree (StudentName);
COMMENT ON INDEX idx_students_name IS 'Search and filter by student name';

-- Multi-campus filtering
CREATE INDEX idx_students_campus ON Students USING btree (CampusID);
COMMENT ON INDEX idx_students_campus IS 'Filter students by campus';

-- Composite index for campus + name filtering
CREATE INDEX idx_students_campus_name ON Students USING btree (CampusID, StudentName);
COMMENT ON INDEX idx_students_campus_name IS 'Composite: campus + name filtering';

-- Active student filtering
CREATE INDEX idx_students_active ON Students USING btree (IsActive);
COMMENT ON INDEX idx_students_active IS 'Filter active/inactive students';

-- ============================================================================
-- COURSES TABLE INDEXES
-- ============================================================================
CREATE INDEX idx_courses_name ON Courses USING btree (CourseName);
COMMENT ON INDEX idx_courses_name IS 'Search by course name';

CREATE INDEX idx_courses_campus ON Courses USING btree (CampusID);
COMMENT ON INDEX idx_courses_campus IS 'List courses by campus';

CREATE INDEX idx_courses_campus_type ON Courses USING btree (CampusID, CourseType);
COMMENT ON INDEX idx_courses_campus_type IS 'Composite: campus + course type';

-- ============================================================================
-- REGISTRATIONS TABLE INDEXES
-- ============================================================================
-- Foreign key lookups for JOIN performance
CREATE INDEX idx_registration_student ON Registrations USING btree (StudentID);
COMMENT ON INDEX idx_registration_student IS 'FK lookup: student registrations';

CREATE INDEX idx_registration_course ON Registrations USING btree (CourseID);
COMMENT ON INDEX idx_registration_course IS 'FK lookup: course registrations';

CREATE INDEX idx_registration_instructor ON Registrations USING btree (InstructorID);
COMMENT ON INDEX idx_registration_instructor IS 'FK lookup: instructor courses';

CREATE INDEX idx_registration_term ON Registrations USING btree (Term);
COMMENT ON INDEX idx_registration_term IS 'Filter registrations by term';

CREATE INDEX idx_registration_student_term ON Registrations USING btree (StudentID, Term);
COMMENT ON INDEX idx_registration_student_term IS 'Composite: student + term lookup';

CREATE INDEX idx_registration_status ON Registrations USING btree (Status);
COMMENT ON INDEX idx_registration_status IS 'Filter by registration status';

-- ============================================================================
-- INSTRUCTORS TABLE INDEXES
-- ============================================================================
CREATE INDEX idx_instructors_name ON Instructors USING btree (Name);
COMMENT ON INDEX idx_instructors_name IS 'Search instructors by name';

CREATE INDEX idx_instructors_campus ON Instructors USING btree (CampusID);
COMMENT ON INDEX idx_instructors_campus IS 'List instructors by campus';

CREATE INDEX idx_instructors_department ON Instructors USING btree (Department);
COMMENT ON INDEX idx_instructors_department IS 'Filter instructors by department';

-- ============================================================================
-- AUDITLOGS TABLE INDEXES
-- ============================================================================
-- Timestamp range queries (finding events in date range)
CREATE INDEX idx_auditlogs_timestamp ON AuditLogs USING btree (Timestamp DESC);
COMMENT ON INDEX idx_auditlogs_timestamp IS 'Range queries on timestamps (DESC for recent first)';

-- User activity lookup
CREATE INDEX idx_auditlogs_user ON AuditLogs USING btree (UserID);
COMMENT ON INDEX idx_auditlogs_user IS 'Filter audit logs by user';

-- Action type filtering
CREATE INDEX idx_auditlogs_action ON AuditLogs USING btree (ActionType);
COMMENT ON INDEX idx_auditlogs_action IS 'Filter logs by action type';

-- Composite for user + timestamp (user activity timeline)
CREATE INDEX idx_auditlogs_user_timestamp ON AuditLogs USING btree (UserID, Timestamp DESC);
COMMENT ON INDEX idx_auditlogs_user_timestamp IS 'Composite: user activity timeline';

-- Table and entity tracking
CREATE INDEX idx_auditlogs_table_entity ON AuditLogs USING btree (TableName, EntityID);
COMMENT ON INDEX idx_auditlogs_table_entity IS 'Composite: track specific entity changes';

-- ============================================================================
-- GRADES TABLE INDEXES
-- ============================================================================
CREATE INDEX idx_grades_student ON Grades USING btree (StudentID);
COMMENT ON INDEX idx_grades_student IS 'FK lookup: student grades';

CREATE INDEX idx_grades_course ON Grades USING btree (CourseID);
COMMENT ON INDEX idx_grades_course IS 'FK lookup: course grades';

-- ============================================================================
-- PERFORMANCE MONITORING QUERIES
-- ============================================================================
-- View index sizes:
-- SELECT schemaname, tablename, indexname, pg_size_pretty(pg_relation_size(indexrelid))
-- FROM pg_indexes JOIN pg_stat_user_indexes ON indexname = relname
-- ORDER BY pg_relation_size(indexrelid) DESC;
--
-- Check index usage:
-- SELECT schemaname, tablename, indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
-- FROM pg_stat_user_indexes
-- ORDER BY idx_scan DESC;

-- Find missing indexes (table scans without index usage):
-- SELECT schemaname, tablename, seq_scan, idx_scan, seq_tup_read, idx_tup_fetch
-- FROM pg_stat_user_tables
-- WHERE seq_scan > idx_scan AND seq_scan > 1000
-- ORDER BY seq_scan DESC;

-- ============================================================================
-- INDEX MAINTENANCE
-- ============================================================================
-- Regularly run ANALYZE to update statistics for query planner:
-- ANALYZE;
--
-- Periodically REINDEX to maintain index efficiency:
-- REINDEX INDEX CONCURRENTLY idx_students_email;
--
-- Or rebuild all indexes:
-- REINDEX SCHEMA public;
