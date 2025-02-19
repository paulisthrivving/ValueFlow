  -- Author: Paul Brown
  -- View Name: story_rightsizing [1.0]
  -- Date Last Update: 17th August, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out right size by team at the 85th percentile
  -- Project:
  -- ValueFlow
SELECT DISTINCT
  team,
  PERCENTILE_CONT(cycle_time, 0.85) OVER (PARTITION BY team) AS ct_85th
FROM 
  `ctreportbuilder.abc_ea.abc-master-ct-data`
WHERE 
  stage = 'Done'
GROUP BY 
  team, cycle_time