  -- Author: Paul Brown
  -- View Name: epic_rightsizing[v1.0]
  -- Date Last Update: 5th November, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the rightsizing of epics by story count by project
  -- Project:
  --  ValueFlow
WITH
  _epic_story_count AS (
  SELECT
    parent AS epic_id,
    COUNT(ID) AS story_count,
    team
  FROM
    `ctreportbuilder.abc_ea.abc-master-ct-data`
  WHERE
    stage = 'Done'
    AND NOT parent IS NULL
  GROUP BY
    parent,
    team)
SELECT
  DISTINCT team,
  ROUND(PERCENTILE_CONT(story_count, 0.85) OVER (PARTITION BY team), 0) AS p85_story_count
FROM
  _epic_story_count