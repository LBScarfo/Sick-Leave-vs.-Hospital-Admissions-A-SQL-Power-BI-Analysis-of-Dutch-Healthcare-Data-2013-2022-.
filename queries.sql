-- Create DATABASE zorg_analyse
USE zorg_analyse;

-- Create the 'correlatie' table by joining the 'ziekenhuis_opnamen' and 'ziekteverzuim_percentage' tables,
-- selecting only rows where 'bedrijfskenmerken_sbi_2008' equals '861 Ziekenhuizen'.

CREATE TABLE correlatie AS
SELECT v.perioden, v.percentage_ziekteverzuim, o.total_opnamen
FROM ziekteverzuim_percentage v
JOIN ziekenhuis_opnamen o
  ON v.perioden = o.perioden
WHERE v.bedrijfskenmerken_sbi_2008 = '861 Ziekenhuizen';

-- Calculating the Pearson correlation coefficient manually using aggregate functions
-- between sick leave percentage and total hospital admissions in the 'correlatie' table,
-- since the built-in CORR() function was not available.

SELECT 
  (SUM((percentage_ziekteverzuim - avg_x) * (total_opnamen - avg_y)) /
   SQRT(SUM(POW(percentage_ziekteverzuim - avg_x, 2)) * SUM(POW(total_opnamen - avg_y, 2)))) AS pearson_correlation
FROM (
  SELECT 
    percentage_ziekteverzuim,
    total_opnamen,
    (SELECT AVG(percentage_ziekteverzuim) FROM correlatie) AS avg_x,
    (SELECT AVG(total_opnamen) FROM correlatie) AS avg_y
  FROM correlatie
) sub;

-- The Pearson correlation coefficient between sick leave percentage and total hospital admissions was approximately -0.73, 
-- indicating a strong negative correlation.
-- Since there is a negative correlation between sick leave percentage and total hospital admissions,
-- I will verify the correlation between sick leave and each type of admission separately:
-- clinical admissions and day admissions.
-- To do this, I need to include these two columns by creating a new joined table.

DROP TABLE IF EXISTS correlatie;

CREATE TABLE correlatie AS
SELECT 
  v.perioden,
  v.percentage_ziekteverzuim,
  o.total_opnamen,
  o.klinische_opnamen,
  o.dagopnamen
FROM ziekteverzuim_percentage v
JOIN ziekenhuis_opnamen o
  ON v.perioden = o.perioden
WHERE v.bedrijfskenmerken_sbi_2008 = '861 Ziekenhuizen';

-- I will verify the correlation between sick leave and clinical admission

SELECT 
  (SUM((percentage_ziekteverzuim - avg_x) * (klinische_opnamen - avg_y)) /
   SQRT(SUM(POW(percentage_ziekteverzuim - avg_x, 2)) * SUM(POW(klinische_opnamen - avg_y, 2)))) AS pearson_correlation
FROM (
  SELECT 
    percentage_ziekteverzuim,
    klinische_opnamen,
    (SELECT AVG(percentage_ziekteverzuim) FROM correlatie) AS avg_x,
    (SELECT AVG(klinische_opnamen) FROM correlatie) AS avg_y
  FROM correlatie
) sub;

-- The Pearson correlation coefficient between sick leave percentage and clinical admissions was approximately -0.85, 
-- I will verify the correlation between sick leave and day admissions

SELECT 
  (SUM((percentage_ziekteverzuim - avg_x) * (dagopnamen - avg_y)) /
   SQRT(SUM(POW(percentage_ziekteverzuim - avg_x, 2)) * SUM(POW(dagopnamen - avg_y, 2)))) AS pearson_correlation
FROM (
  SELECT 
    percentage_ziekteverzuim,
    dagopnamen,
    (SELECT AVG(percentage_ziekteverzuim) FROM correlatie) AS avg_x,
    (SELECT AVG(dagopnamen) FROM correlatie) AS avg_y
  FROM correlatie
) sub;

-- The Pearson correlation coefficient between sick leave percentage and total day admissions was approximately -0.51, 


