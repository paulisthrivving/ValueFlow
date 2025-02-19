  -- Author: Paul Brown
  -- View Name dim-dates [1.0]
  -- Date Last Update: 18th February, 2025
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out a set number of dates for every day between 2 dates
  -- Project:
  -- ValueFlow
WITH
  _basedates AS (
  SELECT
    *
  FROM
    UNNEST(GENERATE_DATE_ARRAY( DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH), CURRENT_DATE(), INTERVAL 1 DAY )) AS date_day
  ORDER BY
    1 )
SELECT
  date_day,
  DATE_TRUNC(date_day, ISOWEEK)+6 AS week_end_date,
  DATE_TRUNC(date_day, MONTH) AS start_of_month,
  DATE_TRUNC(date_day, ISOWEEK) AS end_last_week,
  DATE_TRUNC(date_day, YEAR) AS start_of_year,
  EXTRACT(isoweek
  FROM
    date_day) AS week_of_year,
  EXTRACT(isoyear
  FROM
    date_day) AS year_number
FROM
  _basedates