-- Selecting the crunchbase companies table
SELECT * 
FROM tutorial.crunchbase_companies

-- Selecting the crunchbase acquisitions table
SELECT * 
FROM tutorial.crunchbase_acquisitions

-- Selecting the crunchbase investments table
SELECT * 
FROM tutorial.crunchbase_investments

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
--unique acquired companies by state. Do not include results for which there is no state data, 
--and order by the number of acquired companies from highest to lowest
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
