# EduSync: B-Tree Indexing Strategy

## Overview

This document outlines the B-tree indexing strategy implemented in **Step 2** of the EduSync project. B-trees are the default index type in PostgreSQL and are optimal for equality and range queries, which comprise the majority of EduSync's query patterns.

## Why B-Tree Indexes?

**Advantages:**
- Efficient for equality (`=`) and range (`<`, `>`, `BETWEEN`) queries
- Supports `ORDER BY` and `GROUP BY` operations
- Works well with composite indexes (multiple columns)
- Minimal memory overhead
- Self-balancing structure maintains performance at scale

**Trade-offs:**
- Write overhead: Each INSERT/UPDATE/DELETE updates all relevant indexes
- Storage overhead: Indexes consume additional disk space
- Must be maintained (ANALYZE, REINDEX)

## Indexing Strategy by Table

### Students Table

**Primary Indexes:**
| Index Name | Columns | Use Case | Expected Scan Type |
|---|---|---|---|
| `idx_students_email` | Email | Authentication, password reset | Index Scan |
| `idx_students_name` | StudentName | Name-based search/filtering | Index Scan |
| `idx_students_campus` | CampusID | Campus-specific queries | Index Scan |
| `idx_students_active` | IsActive | Active/inactive filtering | Index Scan |
| `idx_students_campus_name` | (CampusID, StudentName) | Campus + name lookup | Index Scan |

### Courses Table

| Index Name | Columns | Use Case |
|---|---|---|
| `idx_courses_name` | CourseName | Course lookup by name |
| `idx_courses_campus` | CampusID | List courses by campus |
| `idx_courses_campus_type` | (CampusID, CourseType) | Catalog search, filtering |

### Registrations Table

| Index Name | Columns | Use Case |
|---|---|---|
| `idx_registration_student` | StudentID | FK lookup: student courses |
| `idx_registration_course` | CourseID | FK lookup: students in course |
| `idx_registration_instructor` | InstructorID | FK lookup: instructor courses |
| `idx_registration_term` | Term | Filter by semester |
| `idx_registration_student_term` | (StudentID, Term) | Student's courses in term |
| `idx_registration_status` | Status | Filter by enrollment status |

### AuditLogs Table

| Index Name | Columns | Use Case |
|---|---|---|
| `idx_auditlogs_timestamp` | Timestamp DESC | Range queries, recent first |
| `idx_auditlogs_user` | UserID | User activity lookup |
| `idx_auditlogs_action` | ActionType | Filter by action type |
| `idx_auditlogs_user_timestamp` | (UserID, Timestamp DESC) | User activity timeline |
| `idx_auditlogs_table_entity` | (TableName, EntityID) | Track specific entity changes |

## Composite Index Design

Composite indexes (multiple columns) are used for common multi-column predicates:

```sql
-- Good candidate for composite index
WHERE CampusID = 1 AND StudentName = 'John Doe'

-- Index: (CampusID, StudentName) enables efficient lookup
```

**Column Order Rule:** Place most selective columns first. In EduSync:
- CampusID is less selective (few campuses, many students per campus)
- StudentName is more selective (unique identifier)
- Yet (CampusID, StudentName) provides filtering benefit when both are in WHERE clause

## Expected Query Performance

### Before Indexes (Sequential Scan)
```
SeqScan on Students  (cost=0.00..1500.00 rows=50000)
```

### After Indexes (Index Scan)
```
IndexScan on Students using idx_students_email
  (cost=0.29..8.30 rows=1)
```

**Performance improvement:** ~180x faster for lookups on indexed columns.

## Monitoring Index Effectiveness

### View Index Sizes
```sql
SELECT schemaname, tablename, indexname, 
       pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_indexes 
JOIN pg_stat_user_indexes ON indexname = relname
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Check Index Usage
```sql
SELECT schemaname, tablename, indexrelname, 
       idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Find Unused Indexes
```sql
SELECT schemaname, tablename, indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

## Index Maintenance

### ANALYZE (Update Statistics)
Run after bulk operations to update query planner statistics:
```sql
ANALYZE;
```

### REINDEX (Rebuild Index)
Run during low-traffic windows to maintain index efficiency:
```sql
REINDEX INDEX CONCURRENTLY idx_students_email;
```

### REINDEX SCHEMA
Rebuild all indexes:
```sql
REINDEX SCHEMA public;
```

## Performance Considerations

1. **Write Performance**: Every INSERT/UPDATE/DELETE now touches 20+ indexes. Monitor write latency.
2. **Storage**: Indexes consume ~30-50% of base table size. Monitor disk usage.
3. **Query Planner**: May not use indexes for queries touching >5% of table rows. EXPLAIN to verify.
4. **Multi-campus Filtering**: CampusID indexes help partition large datasets by tenant.

## Next Steps (Step 3-6)

- **Step 3:** Partitioning - Horizontal scaling by CampusID
- **Step 4:** Transactions & Concurrency - ACID guarantees
- **Step 5:** Deadlock Management - Prevent conflicts
- **Step 6:** Disaster Recovery - Backup and replication

## References

- PostgreSQL B-Tree Index Documentation: https://www.postgresql.org/docs/current/indexes-types.html
- Query Planning: https://www.postgresql.org/docs/current/runtime-config-query.html
- EXPLAIN Output: https://www.postgresql.org/docs/current/sql-explain.html
