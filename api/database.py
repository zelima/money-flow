"""
Database connection and models for Georgian Budget PostgreSQL integration
"""

import logging
import os

from sqlalchemy import (
    DECIMAL,
    Column,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
    create_engine,
    text,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker

logger = logging.getLogger(__name__)

# Database configuration
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://budget_user:budget_pass@localhost:5432/georgian_budget",
)

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Database Models
class Department(Base):
    __tablename__ = "departments"

    id = Column(Integer, primary_key=True, index=True)
    name_english = Column(String(255), unique=True, nullable=False, index=True)
    name_georgian = Column(String(255))
    description = Column(Text)

    # Relationship to sub-departments
    sub_departments = relationship(
        "SubDepartment", back_populates="department", cascade="all, delete-orphan"
    )


class SubDepartment(Base):
    __tablename__ = "sub_departments"

    id = Column(Integer, primary_key=True, index=True)
    department_id = Column(
        Integer,
        ForeignKey("departments.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name_english = Column(String(255), nullable=False)
    name_georgian = Column(String(255))
    description = Column(Text)
    allocation_percentage = Column(DECIMAL(5, 2), nullable=False)
    employee_count = Column(Integer, default=0)
    projects_count = Column(Integer, default=0)

    # Relationships
    department = relationship("Department", back_populates="sub_departments")
    budget_allocations = relationship(
        "SubDepartmentBudget",
        back_populates="sub_department",
        cascade="all, delete-orphan",
    )


class SubDepartmentBudget(Base):
    __tablename__ = "sub_department_budgets"

    id = Column(Integer, primary_key=True, index=True)
    sub_department_id = Column(
        Integer,
        ForeignKey("sub_departments.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    year = Column(Integer, nullable=False, index=True)
    budget_amount = Column(DECIMAL(15, 2), nullable=False)
    notes = Column(Text)

    # Relationship
    sub_department = relationship("SubDepartment", back_populates="budget_allocations")

    # Ensure unique constraint
    __table_args__ = (
        UniqueConstraint("sub_department_id", "year", name="unique_sub_dept_year"),
    )


# Database dependency
def get_db():
    """Get database session - returns None if database unavailable"""
    try:
        db = SessionLocal()
        # Test connection with SQLAlchemy 2.0 compatible syntax
        db.execute(text("SELECT 1"))
        yield db
    except Exception as e:
        logger.warning(f"Database unavailable: {e}")
        yield None
    finally:
        if "db" in locals():
            db.close()


def test_connection():
    """Test database connection"""
    try:
        db = SessionLocal()
        # Simple query to test connection with SQLAlchemy 2.0 syntax
        db.execute(text("SELECT 1")).fetchone()
        db.close()
        logger.info("✅ PostgreSQL database connection successful")
        return True
    except Exception as e:
        logger.error(f"❌ Database connection failed: {e}")
        return False


def get_department_by_name(db, name_english: str):
    """Get department by English name"""
    return db.query(Department).filter(Department.name_english == name_english).first()


def get_sub_departments_by_department(db, department_id: int, year: int = None):
    """
    Get sub-departments for a department, optionally with budget data for a given year
    """
    query = db.query(SubDepartment).filter(SubDepartment.department_id == department_id)

    if year:
        # Join with budget data for the specific year
        query = query.join(
            SubDepartmentBudget,
            (SubDepartment.id == SubDepartmentBudget.sub_department_id)
            & (SubDepartmentBudget.year == year),
            isouter=True,
        )

    return query.all()


def get_budget_drill_down(
    db, department_name: str = None, year: int = None, limit: int = 100
):
    """
    Get budget drill-down data with joins across all tables
    This simulates BigQuery-style analytics queries
    """
    query = (
        db.query(
            Department.name_english.label("department_name"),
            Department.name_georgian.label("department_name_georgian"),
            SubDepartment.name_english.label("sub_department_name"),
            SubDepartment.name_georgian.label("sub_department_name_georgian"),
            SubDepartment.allocation_percentage,
            SubDepartment.employee_count,
            SubDepartment.projects_count,
            SubDepartmentBudget.year,
            SubDepartmentBudget.budget_amount,
            SubDepartmentBudget.notes,
        )
        .select_from(Department)
        .join(SubDepartment, Department.id == SubDepartment.department_id)
        .join(
            SubDepartmentBudget,
            SubDepartment.id == SubDepartmentBudget.sub_department_id,
            isouter=True,
        )
    )

    # Apply filters
    if department_name:
        query = query.filter(Department.name_english.ilike(f"%{department_name}%"))

    if year:
        query = query.filter(SubDepartmentBudget.year == year)

    # Order and limit
    query = query.order_by(
        Department.name_english, SubDepartment.name_english, SubDepartmentBudget.year
    )

    return query.limit(limit).all()
