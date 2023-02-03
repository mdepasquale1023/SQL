--Simplyfying the Deforestation project--

--View Creation
DROP VIEW IF EXISTS forestation; CREATE VIEW Forestation AS
SELECT 
f.country_code, 
f.country_name, 
f.year, 
f.forest_area_sqkm, (total_area_sq_mi*2.59) AS total_area_sqkm, r.region, r.income_group, 
((Sum(forest_area_sqkm) / Sum(total_area_sq_mi2.59))100) percentage_forest
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code AND f.year = l.year
JOIN regions r
ON r.country_code = f.country_code
GROUP BY 
f.country_code, 
f.country_name, 
f.year, 
f.forest_area_sqkm, 
r.region, 
r.income_group, 
total_area_sq_mi*2.59

--Simplified 
DROP 
  VIEW IF EXISTS forestation;
CREATE VIEW Forestation AS 
SELECT 
  f.country_code, 
  f.country_name, 
  f.year, 
  f.forest_area_sqkm, 
  l.total_area_sq_mi * 2.59 AS total_area_sqkm, 
  r.region, 
  r.income_group, 
  (
    SUM(forest_area_sqkm) / (
      SUM(l.total_area_sq_mi) * 2.59
    )
  ) * 100 AS percentage_forest 
FROM 
  forest_area f 
  JOIN land_area l ON f.country_code = l.country_code 
  AND f.year = l.year 
  JOIN regions r ON r.country_code = f.country_code 
GROUP BY 
  f.country_code, 
  f.forest_area_sqkm, 
  f.country_name, 
  f.year, 
  r.region, 
  r.income_group, 
  l.total_area_sq_mi
 

--1.a.What was the total forest area (in sq km) of the world in 1990? 
--Please keep in mind that you can use the country record denoted as “World" in the region table.

--original query
SELECT year, country_name AS country, SUM(forest_area_sqkm) AS total_forest_area_sqkm FROM forestation f
WHERE country_name = 'World' AND year = 1990
GROUP BY year, country_name

--simplified 
SELECT 
  year, 
  'World' AS country, 
  SUM(forest_area_sqkm) AS total_forest_area_sqkm 
FROM 
  forestation f 
WHERE 
  country_name = 'World' 
  AND year = 1990 
GROUP BY 
  year


--1.b. What was the total forest area (in sq km) of the world in 2016? 
--Please keep in mind that you can use the country record in the table is denoted as “World.”

--original query
SELECT year, country_name AS country, SUM(forest_area_sqkm) AS total_forest_area_sqkm 
FROM forestation f
WHERE country_name = 'World' AND year = 2016
GROUP BY year, country_name

--simplified
SELECT 
  year, 
  'World' AS country, 
  SUM(forest_area_sqkm) AS total_forest_area_sqkm 
FROM 
  forestation f 
WHERE 
  country_name = 'World' 
  AND year = 2016 
GROUP BY 
  year


--1.c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?

--original query
SELECT ( (SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
FROM forestation f
WHERE country_name = 'World' AND year = 1990) - (SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
FROM forestation f
WHERE country_name = 'World' AND year = 2016)) AS difference
FROM forestation
LIMIT 1

--simplified
SELECT 
  SUM(forest_area_sqkm) AS total_forest_area_sqkm 
FROM 
  forestation 
WHERE 
  country_name = 'World' 
  AND year IN (1990, 2016) 
GROUP BY 
  year 
HAVING 
  year = 1990 
  OR year = 2016 
ORDER BY 
  year 
LIMIT 
  2;

--find the difference between the two rows in the output.

--1.d. What was the percent change in forest area of the world between 1990 and 2016?

--original query
SELECT ((((SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm FROM forestation f
WHERE country_name = 'World' AND year = 1990) -
(SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
FROM forestation f
WHERE country_name = 'World' AND year = 2016))/
( (SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
FROM forestation f
WHERE country_name = 'World' AND year = 1990)))*100) AS percent_decrease

--simplified 
SELECT 
  (
    (
      SUM(
        CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END
      ) - SUM(
        CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END
      )
    ) / SUM(
      CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END
    ) * 100
  ) AS percent_decrease 
FROM 
  forestation 
WHERE 
  country_name = 'World';


--1.e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

--original query
SELECT country_name, SUM(total_area_sqkm) AS total_area_sqkm
FROM forestation
WHERE year = 2016 AND total_area_sqkm IS NOT NULL AND total_area_sqkm BETWEEN 1200000 AND 1324449
GROUP BY country_name, total_area_sqkm
ORDER BY total_area_sqkm DESC
LIMIT 1

--simplified
SELECT 
  country_name, 
  SUM(total_area_sqkm) AS total_area_sqkm 
FROM 
  forestation 
WHERE 
  year = 2016 
  AND total_area_sqkm IS NOT NULL 
  AND total_area_sqkm BETWEEN 1200000 
  AND 1324449 
GROUP BY 
  country_name 
ORDER BY 
  SUM(total_area_sqkm) DESC 
LIMIT 
  1

--2.a. What was the percent forest of the entire world in 2016? 
--Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

--Original query 

--World 2016
SELECT country_name, ROUND(CAST(percentage_forest AS Numeric), 2) AS percent_forest FROM forestation
WHERE country_name = 'World' AND year = 2016
--highest 2016
SELECT region, ROUND(CAST((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS NUMERIC), 2) AS percentage_forest
FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY percentage_forest DESC
LIMIT 1
--lowest 2016
SELECT region, ROUND(CAST((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS NUMERIC), 2) AS percentage_forest
FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY percentage_forest
LIMIT 1

--simplified, combined query 
SELECT 
  country_name, 
  ROUND(
    CAST(percentage_forest AS NUMERIC), 
    2
  ) AS percent_forest, 
  region, 
  (
    SELECT 
      ROUND(
        CAST(
          (
            SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
          )* 100 AS NUMERIC
        ), 
        2
      ) AS percentage_forest 
    FROM 
      forestation 
    WHERE 
      year = 2016 
      AND region = f.region 
    GROUP BY 
      region 
    ORDER BY 
      percentage_forest DESC 
    LIMIT 
      1
  ) AS highest_percent_forest_by_region, 
  (
    SELECT 
      ROUND(
        CAST(
          (
            SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
          )* 100 AS NUMERIC
        ), 
        2
      ) AS percentage_forest 
    FROM 
      forestation 
    WHERE 
      year = 2016 
      AND region = f.region 
    GROUP BY 
      region 
    ORDER BY 
      percentage_forest 
    LIMIT 
      1
  ) AS lowest_percent_forest_by_region 
FROM 
  forestation f 
WHERE 
  country_name = 'World' 
  AND year = 2016;



--2.b.What was the percent forest of the entire world in 1990? 
--Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

--original query

--World 1990
SELECT country_name, ROUND(CAST(percentage_forest AS NUMERIC), 2) AS percent_forest
FROM forestation
WHERE country_name = 'World' AND year = 1990
--highest 1990
SELECT region, ROUND(CAST((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS NUMERIC), 2) AS percentage_forest
FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY percentage_forest DESC LIMIT 1
--lowest 1990
SELECT region, ROUND(CAST((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100 AS NUMERIC), 2) AS percentage_forest
FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY percentage_forest
LIMIT 1


--simplified, combined query
SELECT 
  country_name, 
  ROUND(
    CAST(percentage_forest AS NUMERIC), 
    2
  ) AS percent_forest, 
  (
    SELECT 
      region 
    FROM 
      (
        SELECT 
          region, 
          ROUND(
            CAST(
              (
                SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
              )* 100 AS NUMERIC
            ), 
            2
          ) AS percentage_forest 
        FROM 
          forestation 
        WHERE 
          year = 1990 
        GROUP BY 
          region 
        ORDER BY 
          percentage_forest DESC 
        LIMIT 
          1
      ) sub_highest
  ) AS highest_region, 
  (
    SELECT 
      region 
    FROM 
      (
        SELECT 
          region, 
          ROUND(
            CAST(
              (
                SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
              )* 100 AS NUMERIC
            ), 
            2
          ) AS percentage_forest 
        FROM 
          forestation 
        WHERE 
          year = 1990 
        GROUP BY 
          region 
        ORDER BY 
          percentage_forest 
        LIMIT 
          1
      ) sub_lowest
  ) AS lowest_region 
FROM 
  forestation 
WHERE 
  country_name = 'World' 
  AND year = 1990


--2.c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?

--table 1990

--original query is simple
SELECT 
  region, 
  ROUND(
    CAST(
      (
        SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
      )* 100 AS NUMERIC
    ), 
    2
  ) AS percentage_forest 
FROM 
  forestation 
WHERE 
  year = 1990 
GROUP BY 
  region 
ORDER BY 
  percentage_forest DESC;


--table 2016

--original query is simple
SELECT 
  region, 
  ROUND(
    CAST(
      (
        SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
      )* 100 AS NUMERIC
    ), 
    2
  ) AS percentage_forest 
FROM 
  forestation 
WHERE 
  year = 2016 
GROUP BY 
  region 
ORDER BY 
  percentage_forest DESC;


--3.A Success Stories

--increased total forest area

--original query
WITH T1 AS
(SELECT country_name, SUM(forest_area_sqkm) AS forest_area_90 FROM forestation
WHERE year = 1990 AND country_name <> 'World' AND forest_area_sqkm IS NOT NULL Group BY country_name, forest_area_sqkm),
T2 AS
(SELECT country_name, SUM(forest_area_sqkm) AS forest_area_16
FROM forestation
WHERE year = 2016 AND country_name <> 'World' AND forest_area_sqkm IS NOT NULL GROUP BY country_name, forest_area_sqkm)
SELECT f.country_name, (f.forest_area_90 - t.forest_area_16) AS forest_change
FROM T1 f
JOIN T2 t
ON f.country_name = t.country_name
ORDER BY forest_change

--simplified query
WITH success_story AS (
  SELECT 
    country_name, 
    SUM(forest_area_sqkm) AS forest_area_90, 
    SUM(
      CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END
    ) AS forest_area_16 
  FROM 
    forestation 
  WHERE 
    year IN (1990, 2016) 
    AND country_name <> 'World' 
    AND forest_area_sqkm IS NOT NULL 
  GROUP BY 
    country_name
) 
SELECT 
  country_name, 
  (forest_area_90 - forest_area_16) AS forest_change 
FROM 
  success_story 
ORDER BY 
  forest_change;


--increased total forest area percentage 

--original query is simple enough
WITH T1 AS (
  SELECT 
    country_name, 
    (
      SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
    )* 100 AS forest_percent_1 
  FROM 
    forestation 
  WHERE 
    year = 1990 
    AND country_name <> 'World' 
    AND forest_area_sqkm IS NOT NULL 
  Group BY 
    country_name, 
    forest_area_sqkm
), 
T2 AS (
  SELECT 
    country_name, 
    (
      SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
    )* 100 AS forest_percent_2 
  FROM 
    forestation 
  WHERE 
    year = 2016 
    AND country_name <> 'World' 
    AND forest_area_sqkm IS NOT NULL 
  GROUP BY 
    country_name, 
    forest_area_sqkm
) 
SELECT 
  f.country_name, 
  ROUND(
    CAST(
      (
        (
          f.forest_percent_1 - t.forest_percent_2
        )/(f.forest_percent_1)
      )* 100 AS NUMERIC
    ), 
    2
  ) AS percent_change 
FROM 
  T1 f 
  JOIN T2 t ON f.country_name = t.country_name 
ORDER BY 
  percent_change

--3.a Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
--What was the difference in forest area for each?

--original query
WITH T1 AS
(SELECT country_name, region, SUM(forest_area_sqkm) AS forest_area_90 FROM forestation
WHERE year = 1990 AND country_name <> 'World' AND forest_area_sqkm IS NOT NULL Group BY country_name, region, forest_area_sqkm),
T2 AS
(SELECT country_name, region, SUM(forest_area_sqkm) AS forest_area_16
FROM forestation
WHERE year = 2016 AND country_name <> 'World' AND forest_area_sqkm IS NOT NULL GROUP BY country_name, region, forest_area_sqkm)
SELECT f.country_name, f.region, (f.forest_area_90 - t.forest_area_16) AS forest_change FROM T1 f
JOIN T2 t
ON f.country_name = t.country_name
ORDER BY forest_change DESC
LIMIT 5


--simplified query
SELECT 
  country_name, 
  region, 
  SUM(forest_area_sqkm) AS forest_area_90, 
  SUM(
    CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END
  ) AS forest_area_16, 
  (
    SUM(
      CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END
    ) - SUM(
      CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END
    )
  ) AS forest_change 
FROM 
  forestation 
WHERE 
  year IN (1990, 2016) 
  AND country_name <> 'World' 
  AND forest_area_sqkm IS NOT NULL 
GROUP BY 
  country_name, 
  region 
ORDER BY 
  forest_change DESC 
LIMIT 
  5


--3.b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 
--What was the percent change to 2 decimal places for each?

--original query is simple enough
WITH T1 AS (
  SELECT 
    country_name, 
    region, 
    (
      SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
    )* 100 AS forest_percent_1 
  FROM 
    forestation 
  WHERE 
    year = 1990 
    AND country_name <> 'World' 
    AND forest_area_sqkm IS NOT NULL 
  Group BY 
    country_name, 
    region, 
    forest_area_sqkm
), 
T2 AS (
  SELECT 
    country_name, 
    region, 
    (
      SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
    )* 100 AS forest_percent_2 
  FROM 
    forestation 
  WHERE 
    year = 2016 
    AND country_name <> 'World' 
    AND forest_area_sqkm IS NOT NULL 
  GROUP BY 
    country_name, 
    region, 
    forest_area_sqkm
) 
SELECT 
  f.country_name, 
  f.region, 
  ROUND(
    CAST(
      (
        (
          f.forest_percent_1 - t.forest_percent_2
        )/(f.forest_percent_1)
      )* 100 AS NUMERIC
    ), 
    2
  ) AS percent_change 
FROM 
  T1 f 
  JOIN T2 t ON f.country_name = t.country_name 
WHERE 
  f.forest_percent_1 IS NOT NULL 
  AND t.forest_percent_2 IS NOT NULL 
ORDER BY 
  percent_change DESC 
LIMIT 
  5


--3.c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

--original query is simple enough
WITH T1 AS (
  SELECT 
    country_name, 
    year, 
    (
      SUM(forest_area_sqkm)/ SUM(total_area_sqkm)
    )* 100 AS forest_percent 
  FROM 
    forestation 
  WHERE 
    year = 2016 
  GROUP BY 
    country_name, 
    year, 
    forest_area_sqkm
) 
SELECT 
  DISTINCT(quartiles), 
  COUNT(country_name) OVER(PARTITION BY quartiles) 
FROM 
  (
    SELECT 
      country_name, 
      CASE WHEN forest_percent < 25 THEN '0-25' WHEN forest_percent >= 25 
      AND forest_percent < 50 THEN '25-50' WHEN forest_percent >= 50 
      AND forest_percent < 75 THEN '50-75' ELSE '75-100' END AS quartiles 
    FROM 
      T1 
    WHERE 
      forest_percent IS NOT NULL 
      AND year = 2016
  ) AS sub


--3.d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

--original query
WITH T2 AS
(WITH T1 AS
(SELECT country_name, region, year,
(SUM(forest_area_sqkm) / SUM(total_area_sqkm))*100 forest_percent FROM forestation
WHERE year = 2016
GROUP BY country_name, region,
year,
forest_area_sqkm) SELECT Distinct(quartiles), count(country_name)Over(PARTITION BY quartiles), country_name, region,
forest_percent
FROM
(SELECT country_name, region,
forest_percent,
CASE
WHEN forest_percent<=25 THEN '0-25' WHEN forest_percent>25
AND forest_percent<=50 THEN '25-50' WHEN forest_percent>50
AND forest_percent<=75 THEN '50-75' ELSE '75-100'
END AS quartiles
FROM T1
WHERE forest_percent IS NOT NULL
AND YEAR = 2016) AS sub)
SELECT country_name, region,
quartiles,
Round(CAST(forest_percent AS NUMERIC), 2) forest_percent FROM T2
WHERE quartiles = '75-100' ORDER BY forest_percent DESC

--simplified query
WITH T1 AS (
  SELECT 
    country_name, 
    region, 
    year, 
    (
      SUM(forest_area_sqkm) / SUM(total_area_sqkm)
    ) * 100 AS forest_percent 
  FROM 
    forestation 
  WHERE 
    year = 2016 
  GROUP BY 
    country_name, 
    region, 
    year, 
    forest_area_sqkm
) 
SELECT 
  DISTINCT(quartiles), 
  country_name, 
  region, 
  ROUND(
    CAST(forest_percent AS NUMERIC), 
    2
  ) AS forest_percent 
FROM 
  (
    SELECT 
      country_name, 
      region, 
      forest_percent, 
      CASE WHEN forest_percent <= 25 THEN '0-25' WHEN forest_percent > 25 
      AND forest_percent <= 50 THEN '25-50' WHEN forest_percent > 50 
      AND forest_percent <= 75 THEN '50-75' ELSE '75-100' END AS quartiles 
    FROM 
      T1 
    WHERE 
      forest_percent IS NOT NULL 
      AND year = 2016
  ) AS sub 
WHERE 
  quartiles = '75-100' 
ORDER BY 
  forest_percent DESC



