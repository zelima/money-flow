-- Georgian Budget Sub-Departments Database Schema

-- Create departments table (matches main GitHub data)
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name_english VARCHAR(255) NOT NULL UNIQUE,
    name_georgian VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sub-departments table
CREATE TABLE sub_departments (
    id SERIAL PRIMARY KEY,
    department_id INTEGER REFERENCES departments(id) ON DELETE CASCADE,
    name_english VARCHAR(255) NOT NULL,
    name_georgian VARCHAR(255),
    description TEXT,
    allocation_percentage DECIMAL(5,2) NOT NULL CHECK (allocation_percentage > 0 AND allocation_percentage <= 100),
    employee_count INTEGER DEFAULT 0,
    projects_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create budget allocations table for historical sub-department data
CREATE TABLE sub_department_budgets (
    id SERIAL PRIMARY KEY,
    sub_department_id INTEGER REFERENCES sub_departments(id) ON DELETE CASCADE,
    year INTEGER NOT NULL CHECK (year >= 2000 AND year <= 2030),
    budget_amount DECIMAL(15,2) NOT NULL CHECK (budget_amount >= 0),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sub_department_id, year)
);

-- Create indexes for better performance
CREATE INDEX idx_departments_name_english ON departments(name_english);
CREATE INDEX idx_sub_departments_dept_id ON sub_departments(department_id);
CREATE INDEX idx_sub_department_budgets_year ON sub_department_budgets(year);
CREATE INDEX idx_sub_department_budgets_sub_dept_id ON sub_department_budgets(sub_department_id);

-- Create a view for easy drill-down queries
CREATE VIEW budget_drill_down AS
SELECT
    d.name_english as department_name,
    d.name_georgian as department_name_georgian,
    sd.name_english as sub_department_name,
    sd.name_georgian as sub_department_name_georgian,
    sd.allocation_percentage,
    sd.employee_count,
    sd.projects_count,
    sdb.year,
    sdb.budget_amount,
    sdb.notes
FROM departments d
JOIN sub_departments sd ON d.id = sd.department_id
LEFT JOIN sub_department_budgets sdb ON sd.id = sdb.sub_department_id
ORDER BY d.name_english, sd.name_english, sdb.year;
