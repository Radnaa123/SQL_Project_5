CREATE SCHEMA IF NOT EXISTS companies;
CREATE TABLE companies.company (
    company_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    company_size INT,
    state VARCHAR(50),
    country VARCHAR(10),
    city VARCHAR(200),
    zip_code VARCHAR(200),
    address VARCHAR(255),
    url VARCHAR(500)
);

CREATE TABLE companies.com_industry (
    company_id INT REFERENCES companies.company(company_id) ON DELETE CASCADE,
    industry VARCHAR(255) NOT NULL,
    PRIMARY KEY (company_id, industry)
);

CREATE TABLE companies.com_speciality (
    company_id INT,
    speciality VARCHAR(2000) NOT NULL,
    PRIMARY KEY (company_id, speciality),
    FOREIGN KEY (company_id) REFERENCES companies.company(company_id) ON DELETE CASCADE
);

CREATE TABLE companies.employee_counts (
    company_id INT,
    employee_count INT,
    follower_count INT,
    time_recorded BIGINT,
    FOREIGN KEY (company_id) REFERENCES companies.company(company_id) ON DELETE CASCADE
);

CREATE SCHEMA IF NOT EXISTS job;
CREATE TABLE job.salary (
    salary_id INT,
    job_id BIGINT PRIMARY KEY,
    max_salary NUMERIC,
    med_salary NUMERIC,
    min_salary NUMERIC,
    pay_period VARCHAR(50),
    currency VARCHAR(10),
    compensation_type VARCHAR(50)
);

CREATE TABLE job.benefits (
    job_id BIGINT,
    inferred_type INT,
    description VARCHAR(255),
	FOREIGN KEY (job_id) REFERENCES job.salary(job_id) ON DELETE CASCADE
);

CREATE TABLE job.job_skills (
    job_id BIGINT,
    skill_abr VARCHAR(10),
    PRIMARY KEY (job_id, skill_abr),  -- Composite primary key to ensure uniqueness for each combination
    FOREIGN KEY (job_id) REFERENCES job.salary(job_id) ON DELETE CASCADE,
	FOREIGN KEY (skill_abr) REFERENCES mapp.skills(skill_abr) ON DELETE CASCADE
);

CREATE TABLE job.job_industry (
    job_id BIGINT,
    industry_id INT,
    PRIMARY KEY (job_id, industry_id),
    FOREIGN KEY (job_id) REFERENCES job.salary(job_id) ON DELETE CASCADE,
    FOREIGN KEY (industry_id) REFERENCES mapp.industry(industry_id) ON DELETE CASCADE
);

CREATE SCHEMA mapp;
CREATE TABLE mapp.industry (
    industry_id INT PRIMARY KEY,
    industry_name VARCHAR(255)
);

CREATE TABLE mapp.skills (
    skill_abr VARCHAR(10) PRIMARY KEY,
    skill_name VARCHAR(255) NOT NULL
);

CREATE TABLE postings (
    job_id BIGINT,
    company_name VARCHAR(1000),
    title VARCHAR(1000),
    description TEXT,
    max_salary DECIMAL(15, 2),
    pay_period VARCHAR(50),
    location VARCHAR(1000),
    company_id INT,
    views INT,
    med_salary DECIMAL(15, 2),
    min_salary DECIMAL(15, 2),
    formatted_work_type VARCHAR(100),
    applies INT,
    original_listed_time BIGINT,
    remote_allowed BOOLEAN,
    job_posting_url VARCHAR(1000),
    application_url VARCHAR(1000),
    application_type VARCHAR(50),
    expiry BIGINT,
    closed_time BIGINT,
    formatted_experience_level VARCHAR(50),
    skills_desc TEXT,
    listed_time BIGINT,
    posting_domain VARCHAR(100),
    sponsored BOOLEAN,
    work_type VARCHAR(50),
    currency VARCHAR(10),
    compensation_type VARCHAR(50),
    normalized_salary DECIMAL(15, 2),
    zip_code VARCHAR(20),
    fips INT,

    FOREIGN KEY (job_id) 
        REFERENCES job.salary(job_id) 
        ON DELETE CASCADE,

    FOREIGN KEY (company_id) 
        REFERENCES companies.company(company_id) 
        ON DELETE CASCADE
);

DELETE FROM companies.employee_counts
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM companies.employee_counts
    GROUP BY company_id, time_recorded
);

ALTER TABLE companies.employee_counts
ADD PRIMARY KEY (company_id, time_recorded);

DELETE FROM job.benefits
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM job.benefits
    GROUP BY job_id, inferred_type
);

ALTER TABLE job.benefits
ADD PRIMARY KEY (job_id, inferred_type);

ALTER TABLE job.salary 
ADD CONSTRAINT unique_salary_job UNIQUE (job_id);