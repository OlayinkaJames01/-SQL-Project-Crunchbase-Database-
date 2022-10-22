-- Selecting the crunchbase companies table
SELECT * 
FROM tutorial.crunchbase_companies

-- Selecting the crunchbase acquisitions table
SELECT * 
FROM tutorial.crunchbase_acquisitions

-- Selecting the first part crunchbase investments table
SELECT * 
FROM tutorial.crunchbase_investments_part1

-- Selecting the second part crunchbase investments table
SELECT * 
FROM tutorial.crunchbase_investments_part2


-- Selecting the combined crunchbase investments table
SELECT * 
FROM tutorial.crunchbase_investments

-- Tables to understand date format manipulation
SELECT *
FROM tutorial.crunchbase_companies_clean_date

SELECT *
FROM tutorial.crunchbase_acquisitions_clean_date

/*  
Write a query that performs an inner join between the tutorial.crunchbase_acquisitions table 
and the tutorial.crunchbase_companies table, but instead of listing individual rows, 
count the number of non-null rows in each table.
*/

SELECT COUNT()
FROM tutorial.crunchbase_acquisitions acq
LEFT JOIN tutorial.crunchbase_companies com
  ON acq.company_permalink = com.permalink
/*  
Count the number of unique companies (don't double-count companies) and 
unique acquired companies by state. Do not include results for which there is no state data, 
and order by the number of acquired companies from highest to lowest
*/

SELECT CASE WHEN companies.state_code IS NULL THEN 'No State Code'
            ELSE companies.state_code END AS companies_state,
       COUNT(DISTINCT companies.permalink) AS unique_companies,
       COUNT(DISTINCT acquisitions.company_permalink) AS unique_companies_acquired
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
 WHERE companies.state_code IS NOT NULL
 GROUP BY 1
 ORDER BY 3 DESC
/*
Write a query that shows a company's name, "status" (found in the Companies table), 
and the number of unique investors in that company. Order by the number of investors from most to fewest. 
Limit to only companies in the state of New York.
*/ 

SELECT companies.name AS company_name,
       companies.status,
       COUNT(DISTINCT investments.investor_name) AS unqiue_investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments investments
    ON companies.permalink = investments.company_permalink
 WHERE companies.state_code = 'NY'
 GROUP BY 1,2
 ORDER BY 3 DESC

/*
Write a query that lists investors based on the number of companies in which they are invested. 
--Include a row for companies with no investor, and order from most companies to least
*/

SELECT CASE WHEN investments.investor_name IS NULL THEN 'No Investor'
            ELSE investments.investor_name END AS Investor,
       COUNT(DISTINCT companies.name) AS unqiue_investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments investments
    ON companies.permalink = investments.company_permalink
GROUP BY 1
ORDER BY 2 DESC

/*
Write a query that joins companies table and investments table using a FULL JOIN. 
Count up the number of rows that are matched/unmatched
*/


SELECT COUNT(CASE WHEN companies.permalink IS NOT NULL AND investments.company_permalink IS NULL
                  THEN companies.permalink ELSE NULL END) AS companies_table_notnull_only,
       COUNT(CASE WHEN companies.permalink IS NOT NULL AND investments.company_permalink IS NOT NULL
                  THEN companies.permalink ELSE NULL END) AS both_tables_notnull,
       COUNT(CASE WHEN companies.permalink IS NULL AND investments.company_permalink IS NOT NULL
                  THEN investments.company_permalink ELSE NULL END) AS investments_table_notnull_only
  FROM tutorial.crunchbase_companies companies
  FULL JOIN tutorial.crunchbase_investments investments
    ON companies.permalink = investments.company_permalink
    
/*
Write a query that appends the two crunchbase_investments datasets above (including duplicate values). 
Filter the first dataset to only companies with names that start with the letter "T", 
and filter the second to companies with names starting with "M" (both not case-sensitive).
Only include the company_permalink, company_name, and investor_name columns.
*/
       
SELECT company_permalink company_name, investor_name
FROM tutorial.crunchbase_investments_part1
WHERE company_name ILIKE 't%'
UNION ALL
SELECT company_permalink company_name, investor_name
FROM tutorial.crunchbase_investments_part2
WHERE company_name ILIKE 'm%'

/*
Write a query that shows 3 columns. The first indicates which dataset (part 1 or 2) the data comes from, 
the second shows company status, and the third is a count of the number of investors.
*/


SELECT 'investments_part1' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part1 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2

 UNION ALL
 
 SELECT 'investments_part2' AS dataset_name,
       companies.status,
       COUNT(DISTINCT investments.investor_permalink) AS investors
  FROM tutorial.crunchbase_companies companies
  LEFT JOIN tutorial.crunchbase_investments_part2 investments
    ON companies.permalink = investments.company_permalink
 GROUP BY 1,2

-- Working with crazy date and manipulation
-- The difference between the date founded and the date acquired

SELECT companies.permalink,
       companies.founded_at_clean,
       acquisitions.acquired_at_cleaned,
       acquisitions.acquired_at_cleaned -
         companies.founded_at_clean::timestamp AS time_to_acquisition
  FROM tutorial.crunchbase_companies_clean_date companies
  JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 
 
 -- Adding 1 week to the founded date of the company
SELECT companies.permalink,
       companies.founded_at_clean,
       companies.founded_at_clean::timestamp +
         INTERVAL '1 week' AS plus_one_week
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL
 
 
 -- The difference between the date the company was founded and today
 SELECT companies.permalink,
       companies.founded_at_clean,
       NOW() - companies.founded_at_clean::timestamp AS founded_time_ago
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL
