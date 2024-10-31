-- Data Cleaning Project
SELECT *
FROM layoffs;
-- 	   1. Remove Duplicates
--     2. Standardize data
--     3. Null values or blank values
--     4. Remove any columns
-- Copying the database and creating a new database before you begin cleaning 

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- CHECKING FOR DUPLICATE VALUES
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
where row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

SET SQL_SAFE_UPDATES = 0;


DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- STANDARDIZING DATA (Fixing issues with your data) 
SELECT company, TRIM(company)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- location
SELECT DISTINCT(country), TRIM(TRAILING '.' from country)
from layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' from country)
WHERE country LIKE 'United States%';

SELECT DISTINCT(country)
from layoffs_staging2;

-- date column (converting it to datetime)
SELECT `date`
from layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

SELECT *
FROM layoffs_staging2;

-- WOorking with null and blank values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- LOOKING AT THE INDUSTRY COLUMN. To populate this, it is important to identify the null rows in the table. This is done with a self join
-- However, we first convert blank to null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '' )
AND t2.industry IS NOT NULL;

-- THIS WILL BE POPULATED USING UPDATE
UPDATE layoffs_staging2 t1
join layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '' )
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
;
-- REMOVING UNWANTED ROWS AND COLUMNS
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- DROPPING THE ROW COLUMN
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;
