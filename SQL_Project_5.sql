--Question1. Companies with the Most Job Postings
select count(p.job_posting_url) as job_count,
    c.name
from public.postings p
LEFT JOIN companies.company c on c.company_id = p.company_id
GROUP BY c.name
order by job_count DESC
limit 10;

--Question2. Companies with the Highest Salary Offers
select c.name,
    (s.max_salary) as highest_salary
from companies.company c 
join postings p on c.company_id = p.company_id
join job.salary s on p.job_id = s.job_id
where s.max_salary is NOT NULL
order by s.max_salary DESC
limit 10;

--Question3. Companies with the Most Diverse Industries
select c.name,
    count(i.industry) as number_of_industries
from companies.company c 
JOIN companies.com_industry i on c.company_id = i.company_id
GROUP BY i.industry, c.name
ORDER BY number_of_industries DESC

--Question4. Companies with the Most Remote Job Postings
select c.name,
    count(p.Remote_allowed) as remote_jobs
from companies.company c
left join public.postings p on c.company_id = p.company_id
where p.Remote_allowed = true
group by c.name
order by remote_jobs desc

--Question5. Companies with the Fastest Growth in Follower Count
select c.name,
    ec.follower_count
from companies.company c
join companies.employee_counts ec on c.company_id=ec.company_id
order by ec.follower_count desc
limit 10;

--Question6. Job Postings with the Most Applications
select company_name,
    count(application_url) as count_of_app
from postings
group by company_name
having count(application_url) != 0
order by count(application_url) desc
limit 10;

--Question7. Job Postings with the Longest Duration
select company_name,
    title,
    (closed_time - listed_time) as Duration
from postings
where closed_time is NOT NULL

--Question8. Job Postings with the Most Skills Required
select p.company_name,
    p.title,
    count(sk.skill_name) as skill_count
from public.postings p
left join job.Salary s on p.job_id = s.job_id
left join job.job_skills js on js.job_id = s.job_id
left join mapp.skills sk on js.skill_abr = sk.skill_abr
group by p.company_name, p.title
order by skill_count desc

--Question9. Job Postings with the Highest Salary in Each Industry
select 
    p.company_name,
    p.title,
    avg(s.max_salary) as max_sal,
    avg(s.med_salary) as Med_sal,
    avg(s.min_salary) as Min_sal,
    job_posting_url job_posting
    FROM public.postings p
join job.salary s on p.job_id = s.job_id
group by p.company_name, p.title, job_posting_url

--Question10. What is the distribution of minimum, median, and maximum salaries for each experience level?
select p.formatted_experience_level as Experience,
    avg(s.max_salary) as avg_max,
    avg(s.med_salary) as avg_med,
    avg(s.min_salary) as avg_mid
from public.postings p
left join job.salary s on p.job_id = s.job_id
group by p.formatted_experience_level

--Question11. What is the most common compensation type (e.g., salary, bonus) for jobs in each industry?
select ci.industry,
    p.compensation_type,
    count(ci.industry) counts
from public.postings p
left join companies.company c on p.company_id = c.company_id
left join companies.com_industry ci on c.company_id = ci.company_id
group by ci.industry, p.compensation_type
limit 150;

--Question12. Which cities have the highest number of job postings, and what is the average salary in those cities?

SELECT 
    city,
    COUNT(*) AS total_postings,
    ROUND(AVG(med_salary), 2) AS average_salary
FROM (
    SELECT 
        p.job_id,
        c.city,
        p.med_salary
    FROM postings p
    JOIN companies.company c ON p.company_id = c.company_id
    WHERE c.city IS NOT NULL AND p.med_salary IS NOT NULL
) AS city_postings
GROUP BY city
ORDER BY total_postings DESC
LIMIT 10;

--Question13. How does the normalized salary vary across different locations (city, state, country)?
select c.state,
    c.city,
    c.country,
    avg(p.normalized_salary) median_salary
from public.postings p
left join companies.company c on p.company_id = c.company_id
group by c.state, c.city, c.country
order by avg(p.normalized_salary) desc

--Question14. What are the most in-demand skills for each industry?
SELECT 
    i.industry_name,
    s.skill_name,
    COUNT(js.skill_abr) AS skill_demand
FROM job.salary sal
join job.job_industry ji on sal.job_id = ji.job_id
JOIN mapp.industry i ON ji.industry_id = i.industry_id
JOIN job.job_skills js ON sal.job_id = js.job_id
JOIN mapp.skills s ON js.skill_abr = s.skill_abr
GROUP BY i.industry_name, s.skill_name
ORDER BY skill_demand DESC;

--Question15. Which skills are associated with the highest average salary increase compared to jobs without those skills?
WITH SkillSalary AS (
    SELECT 
        js.skill_abr,
        s.skill_name,
        ROUND(AVG(j.med_salary), 2) AS avg_salary_with_skill
    FROM job.job_skills js
    JOIN mapp.skills s ON js.skill_abr = s.skill_abr
    JOIN job.salary j ON js.job_id = j.job_id
    WHERE j.med_salary IS NOT NULL
    GROUP BY js.skill_abr, s.skill_name
), 
NoSkillSalary AS (
    SELECT 
        s.skill_abr,
        s.skill_name,
        ROUND(AVG(j.med_salary), 2) AS avg_salary_without_skill
    FROM mapp.skills s
    JOIN job.salary j ON j.job_id NOT IN (
        SELECT DISTINCT js.job_id FROM job.job_skills js WHERE js.skill_abr = s.skill_abr
    )
    WHERE j.med_salary IS NOT NULL
    GROUP BY s.skill_abr, s.skill_name
)

SELECT 
    ss.skill_name,
    ss.avg_salary_with_skill,
    ns.avg_salary_without_skill,
    ROUND(ss.avg_salary_with_skill - ns.avg_salary_without_skill, 2) AS salary_increase
FROM SkillSalary ss
JOIN NoSkillSalary ns ON ss.skill_abr = ns.skill_abr
ORDER BY salary_increase DESC;