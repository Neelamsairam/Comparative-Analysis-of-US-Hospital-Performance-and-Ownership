use  world;
select * from hospinfo;
##Basic Data Retrieval and Filtering
# Hospital name
SELECT `Hospital Name` ,City FROM hospinfo
where State = "AL";
select * from hospinfo;

# Hopital type and ownership
SELECT `Hospital Type`, `hospital ownership` from hospinfo
where State = "CA";

## Count of Hospitals by State and Ownership
Select State, `Hospital Ownership`, COUNT(*) AS Hospital_Count
FROM hospinfo
GROUP BY State, `Hospital Ownership`
ORDER BY  State, `Hospital Ownership` DESC;
select *  from hospinfo;

##Hospitals Meeting Specific Quality Criteria
SELECT `Hospital Name`, City, State
FROM hospinfo
WHERE `Safety of care national comparison` = 'Above the national Average'
AND `Timeliness of care national comparison` = 'Above the national Average'
ORDER BY State, City;


##Top 10 Counties by Hospital Count (Acute Care)
SELECT `County Name`, State, COUNT(*) AS Acute_Care_Hospitals_Count
FROM hospinfo
WHERE `Hospital Type` = "Acute Care Hospitals"
AND `County Name` IS NOT NULL
GROUP BY `County Name`, State
ORDER BY Acute_Care_Hospitals_Count DESC
LIMIT 10;

##Distinct Hospital Types and Ownership
SELECT distinct`Hospital Type`, `Hospital Ownership`
FROM hospinfo
WHERE `Mortality national comparison` = "Above the national average"
ORDER BY
`Hospital Type`,
`Hospital Ownership`;

##Hospitals with a Name Pattern
##Find and count hospitals whose names include the word "Medical Center" (case-insensitive).
SELECT State, COUNT(*) AS Medical_Center_Count
FROM hospinfo
WHERE
`Hospital Name` LIKE '%MEDICAL CENTER%' OR `Hospital Name` LIKE '%Medical Center%'
GROUP BY
State
ORDER BY MEdical_Center_Count DESC;
select *  from hospinfo;

#Percentage of High Performers by State
    SELECT
    State,
    COUNT(CASE WHEN `Hospital overall rating` IN ('4','5') THEN 1 END) AS High_performance_count,
    COUNT(*) AS Total_Hospitals,
    ROUND(
        (CAST(COUNT(CASE WHEN `Hospital overall rating` IN ('4','5') THEN 1 END) AS REAL) * 100.0 / COUNT(*)),2
    ) AS pct_high_performers
FROM
    hospinfo
WHERE
`Hospital overall rating` <> 'Not Available'
GROUP BY
    State
HAVING
    COUNT(*) >= 5
ORDER BY
    pct_high_performers DESC;
    
##Hospitals with 4-Star Rating but Poor Mortality Score
SELECT
`Hospital Name`, City, State, `Mortality national comparison`
FROM hospinfo
WHERE `Hospital overall rating` = '4'
AND `Mortality national comparison` = 'Below the national average'
ORDER BY State, City ;

SELECT * FROM hospinfo;

##Compare Hospital Rating to National Average(LIST THE HOSPITALS)
SELECT `Hospital Name`, City, `Hospital overall rating`, `Patient experience national comparison`
FROM
hospinfo
WHERE `Hospital overall rating`= '4' AND `Patient experience national comparison`
 IN('Same as the national average', 'Below the national average')
ORDER BY State;
    select * from hospinfo;
    
##State-Level Performance Scoring and Ranking (Comprehensive CTE)
WITH HospitalPerformanceScores AS (
    SELECT
        State,
        -- Score for Mortality: 3 (Above), 2 (Same), 1 (Below), 0 (Not Available)
        CASE `Mortality national comparison`
            WHEN 'Above the national average' THEN 3
            WHEN 'Same as the national average' THEN 2
            WHEN 'Below the national average' THEN 1
            ELSE 0
        END AS Mortality_Score,

        -- Score for Safety of Care: 3 (Above), 2 (Same), 1 (Below), 0 (Not Available)
        CASE `Safety of care national comparison`
            WHEN 'Above the national average' THEN 3
            WHEN 'Same as the national average' THEN 2
            WHEN 'Below the national average' THEN 1
            ELSE 0
        END AS Safety_Score,

        -- Score for Readmission: 3 (Above), 2 (Same), 1 (Below), 0 (Not Available)
        CASE `Readmission national comparison`
            WHEN 'Above the national average' THEN 3
            WHEN 'Same as the national average' THEN 2
            WHEN 'Below the national average' THEN 1
            ELSE 0
        END AS Readmission_Score
    FROM
        hospinfo
    WHERE
        -- Filter out hospitals with 'Not Available' for ALL three metrics
        "Mortality national comparison" <> 'Not Available'
        OR "Safety of care national comparison" <> 'Not Available'
        OR "Readmission national comparison" <> 'Not Available'
)
-- Main query to aggregate the scores and rank the states
SELECT
    State,
    COUNT(*) AS Hospitals_Count,
    -- CORRECTION: Use ROUND() for precision instead of NUMERIC(10, 2)
    ROUND(
        AVG(CAST(Mortality_Score + Safety_Score + Readmission_Score AS REAL)),
        2
    ) AS Average_Composite_Score
FROM
    HospitalPerformanceScores
GROUP BY
    State
HAVING
    COUNT(*) >= 20 -- Ensure a meaningful sample size
ORDER BY
    Average_Composite_Score DESC;
    
## Top  States for Timeliness of Care
SELECT State,
COUNT(CASE WHEN `Timeliness of care national comparison` = 'Above the national average' THEN 1 END ) AS Above_Avg_Count,
COUNT(*) AS Total_Hospitals,
ROUND(
(CAST(COUNT(CASE WHEN `Timeliness of care national comparison`= 'Above the national average' THEN 1 END) AS REAL) * 100.0 / COUNT(*)),
2
) AS Pct_Above_Average
FROM hospinfo
GROUP BY
State
HAVING
COUNT(*)>=10
order by
Pct_Above_Average DESC
Limit 10;

##Identify Non-Reporting Hospitals by State
SELECT State, 
Count(*) as Non_Reporting_Hospitals
From hospinfo
WHere `Hospital overall rating` ='Not Available' OR `Hospital overall rating footnote` IS NOT NULL
Group BY State
HAving
Count(*)>= 5
Order by
 Non_Reporting_Hospitals DESC;
 
 
Select
State,
    `Hospital Name`,
    City,
    `Hospital overall rating`,
    `Hospital overall rating footnote`
FROM
    hospinfo
WHERE
    -- Filter 1: Identify non-reporting hospitals
    (`Hospital overall rating` = 'Not Available' OR "Hospital overall rating footnote" IS NOT NULL)
    AND
    -- Filter 2: Select only the top states identified from Query 1
    State IN ('TX', 'CA', 'KS')
ORDER BY
    State,
    `Hospital Name`;
    
    ##Average Star Rating for Government-Owned Hospitals by Type
    SELECT
    `Hospital Type`,
    COUNT(*) AS hospital_count,
    ROUND(AVG(CAST(`Hospital overall rating` AS REAL)),
    2
    )AS Average_overall_rating
    FROM hospinfo
    Where
    `Hospital overall rating`<> 'Not Available'
    AND `Hospital Ownership` like "Government%"
    GROUP BY `Hospital Type`
    Having COunt(*) >= 5
    order by
    Average_overall_rating DESC;

##States Where Most Hospitals Meet EHR (ELECTRONIC HEALTH RECORDS) Criteria
Select
Count(CASE WHEN `Meets criteria for meaningful use of EHRs` = 'True' THEN 1 END) AS EHR_Compliance_Count,
COUNT(*) AS Total_Hospitals,
ROUND(
(CAST(COUNT(CASE WHEN `Meets criteria for meaningful use of EHRs` =   'True' THEN 1 END) AS REAL)* 100.0/ COUNT(*)),2
) AS Pct_EHR_Compliant
FROM hospinfo
GROUP BY State
Having count(*)>= 10
ORDER BY Pct_EHR_Compliant DESC;

select * from hospinfo;





