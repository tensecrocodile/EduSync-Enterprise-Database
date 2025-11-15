# EduSync: Enterprise Academic Database Platform
## Step 1 - Distributed and Scalable Database Architecture

**Project Name:** EduSync: Enterprise Academic Database Platform  
**Stage:** Step 1 - Scalable Multi-Campus Database Design  
**Objective:** Build a normalized, partitionable, enterprise-grade academic database supporting multiple campuses with thousands of concurrent users.

---

## 📋 Project Overview

EduSync is a comprehensive academic management system designed for real-world scalability. This project focuses on **Step 1: Distributed and Scalable Architecture**, which forms the foundation for a production-grade database that can handle:

- **Multiple campuses** across different geographic locations
- **Thousands of concurrent users** during peak registration periods
- **Horizontal scaling** through database partitioning by campus
- **Data integrity and compliance** with audit logging
- **High availability** with replication strategies

---

## ✨ Key Features (Step 1)

✅ **Normalized Database Schema (3NF)**  
✅ **Multi-Campus Architecture with Partitioning**  
✅ **Audit Logging for Compliance**  
✅ **Foreign Key Constraints for Data Integrity**  
✅ **Scalable Design for Enterprise Growth**  

---

## 🏗️ Database Schema

### Core Tables (All Normalized - 3NF)

1. **Campus** - Stores campus locations and metadata
2. **Students** - Student records (partitionable by CampusID)
3. **Instructors** - Faculty records (partitionable by CampusID)
4. **Courses** - Course offerings (partitionable by CampusID)
5. **Registrations** - Course registrations with grades
6. **AuditLogs** - Compliance and security audit trail

### Entity-Relationship Diagram

```
Campus (CampusID, CampusName, Location)
   ├── Students (StudentID, StudentName, Email, CampusID FK)
   ├── Instructors (InstructorID, Name, Phone, CampusID FK)
   └── Courses (CourseID, CourseName, Credits, InstructorID FK, CampusID FK)
         └── Registrations (RegistrationID, StudentID FK, CourseID FK, Term, Grade)

AuditLogs (LogID, TableName, OperationType, Timestamp, UserID, Details)
```

---

## 📁 File Structure

```
EduSync-Enterprise-Database/
├── README.md                          # Project documentation
├── LICENSE                            # MIT License
├── sql/
│   ├── 01_schema.sql                  # Core table definitions (normalized)
│   ├── 02_sample_data.sql             # Sample data for testing
│   ├── 03_partitioning.sql            # Partitioning strategy (PostgreSQL)
│   ├── 04_indexes.sql                 # Indexes for performance (Step 2)
│   └── 05_audit_triggers.sql          # Audit logging triggers (Step 3)
├── docs/
│   ├── ER_DIAGRAM.md                  # Entity-Relationship Diagram
│   ├── ARCHITECTURE.md                # System architecture & design decisions
│   ├── NORMALIZATION.md               # Normalization explanation (1NF, 2NF, 3NF)
│   └── PARTITIONING_STRATEGY.md       # Multi-campus scaling strategy
├── queries/
│   ├── basic_queries.sql              # Sample SELECT queries
│   ├── transaction_examples.sql       # Transaction & concurrency examples
│   └── performance_analysis.sql       # Query performance analysis
└── .gitignore                         # Git ignore rules
```

---

## 🚀 Installation & Setup

### Prerequisites
- PostgreSQL 12+ or MySQL 8+
- SQL client (pgAdmin, MySQL Workbench, or DBeaver)
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/tensecrcocodle/EduSync-Enterprise-Database.git
cd EduSync-Enterprise-Database

# Create database (PostgreSQL)
psql -U postgres -c "CREATE DATABASE edusync_db;"

# Execute schema
psql -U postgres -d edusync_db -f sql/01_schema.sql

# Insert sample data
psql -U postgres -d edusync_db -f sql/02_sample_data.sql
```

---

## 📊 Normalization Applied

All tables follow **Third Normal Form (3NF)**:

✅ **No repeating groups** (1NF - Atomic values only)  
✅ **No partial dependencies** (2NF - Non-key columns depend on whole primary key)  
✅ **No transitive dependencies** (3NF - Non-key attributes depend only on keys)  

### Example: Before & After Normalization

**Before (Unnormalized):**
```
StudentID | Name | CampusName | CampusLocation | CourseID | CourseName
```

**After (Normalized to 3NF):**
- Campus table: CampusID, CampusName, Location
- Students table: StudentID, Name, CampusID (FK)
- Courses table: CourseID, CourseName, InstructorID (FK), CampusID (FK)
- Registrations table: StudentID (FK), CourseID (FK), Term, Grade

---

## 🔀 Partitioning Strategy

For **PostgreSQL**, tables are partitionable by `CampusID` for horizontal scaling:

```sql
CREATE TABLE Students (...) PARTITION BY LIST (CampusID);
CREATE TABLE Students_Delhi PARTITION OF Students FOR VALUES IN (1);
CREATE TABLE Students_Mumbai PARTITION OF Students FOR VALUES IN (2);
```

**Benefits:**
- Independent scaling per campus
- Faster queries on campus-specific data
- Easier backups and recovery per location
- Better resource management

---

## 🔐 Audit Logging for Compliance

Every INSERT, UPDATE, DELETE is logged via triggers for **GDPR/FERPA compliance**:

```sql
INSERT INTO AuditLogs (TableName, OperationType, Timestamp, UserID, Details)
VALUES ('Students', 'UPDATE', NOW(), 1, 'Changed email address');
```

**Features:**
- Immutable append-only audit trail
- Tracks all data changes with timestamps
- User attribution for accountability
- Critical for regulatory compliance

---

## 📝 Sample Queries

### Get all students from a campus with their courses
```sql
SELECT s.StudentName, c.CourseName, r.Grade
FROM Students s
JOIN Registrations r ON s.StudentID = r.StudentID
JOIN Courses c ON r.CourseID = c.CourseID
WHERE s.CampusID = 1
ORDER BY s.StudentName;
```

### Find instructor with most courses
```sql
SELECT i.Name, COUNT(c.CourseID) AS CourseCount
FROM Instructors i
LEFT JOIN Courses c ON i.InstructorID = c.InstructorID
GROUP BY i.InstructorID, i.Name
ORDER BY CourseCount DESC;
```

### Campus enrollment statistics
```sql
SELECT 
    c.CampusName,
    COUNT(DISTINCT s.StudentID) AS TotalStudents,
    COUNT(DISTINCT co.CourseID) AS TotalCourses,
    COUNT(DISTINCT i.InstructorID) AS TotalInstructors
FROM Campus c
LEFT JOIN Students s ON c.CampusID = s.CampusID
LEFT JOIN Courses co ON c.CampusID = co.CampusID
LEFT JOIN Instructors i ON c.CampusID = i.CampusID
GROUP BY c.CampusID, c.CampusName;
```

---

## 🔄 Upcoming Steps

- **Step 2:** Indexing & Query Optimization (B-tree, Hash, Partial indexes)
- **Step 3:** Transactions, ACID Properties & Concurrency Control (READ COMMITTED, SERIALIZABLE)
- **Step 4:** Deadlock Detection & Management (Wait-for graph, victim selection)
- **Step 5:** Data Warehousing & BI Integration (ETL, PowerBI dashboards)
- **Step 6:** REST API & Modern Application Layer (Python Flask/FastAPI)

---

## 📈 Performance Considerations

| Challenge | Solution |
|-----------|----------|
| Slow student lookups | Index on Email, StudentName |
| Slow course searches | Index on CourseName, CampusID |
| High concurrent load | Partitioning by CampusID + Read replicas |
| Data compliance | Audit logging with append-only logs |
| Query performance | Query plans analysis with EXPLAIN |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/step2-indexing`)
3. Commit changes (`git commit -m "Add Step 2 indexing strategy"`)
4. Push to branch (`git push origin feature/step2-indexing`)
5. Open a Pull Request

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🎯 Use Case: Real-World Academic Institution

This database supports:
- ✅ Multi-campus universities with thousands of students
- ✅ Automated student enrollment and course registration
- ✅ Grade management and transcript generation
- ✅ Faculty workload distribution
- ✅ Compliance with FERPA (Family Educational Rights and Privacy Act)
- ✅ Real-time reporting and analytics

---

## 📞 Contact & Support

For questions or feedback:
- Open an [Issue](https://github.com/tensecrcocodle/EduSync-Enterprise-Database/issues)
- Check [Discussions](https://github.com/tensecrcocodle/EduSync-Enterprise-Database/discussions)

**Repository:** [EduSync on GitHub](https://github.com/tensecrcocodle/EduSync-Enterprise-Database)  
**Last Updated:** November 2025

---

### 🌟 Show your support
If you find this project helpful, please star ⭐ the repository!
