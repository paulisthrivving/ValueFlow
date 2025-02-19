  -- Author: Paul Brown
  -- View Name: feature_rightsizing[v1.0]
  -- Date Last Update: 5th November, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Work out the rightsizing of features by epics count by project
  -- Project:
  --  ValueFlow
WITH _base AS (
  SELECT parent, COUNT(parent) AS epic_count, project 
  FROM `ctreportbuilder.abc_ea.raw_format_epics`
  WHERE parent IS NOT NULL AND done IS NOT NULL
  AND NOT parent IN ('DRB-2201', 'DRB-3095')
  GROUP BY parent, project
),
_percentiles AS (
  SELECT 
    project,
    ROUND(PERCENTILE_CONT(epic_count, 0.85) OVER (PARTITION BY project),0) AS p85_epic_count
  FROM _base
)

SELECT DISTINCT
  CASE PROJECT
    WHEN 'EA' THEN 'EA Business Intelligence'
    WHEN 'EFPA' THEN 'Enterprise Financial Planning and Analysis'
    WHEN 'DP' THEN 'EA - People & Productivity'
    WHEN 'DAP' THEN 'Analytics Hub & EA Platform'
    WHEN 'AAEI' THEN 'EA Agility'
    WHEN 'DFE' THEN 'EA Branch Ops'
    WHEN 'CFA' THEN 'EA Credit, Finance & Accounting'
    WHEN 'EDE' THEN 'EA Data Enablement'
    WHEN 'EI' THEN 'EA Merchandising'
    WHEN 'EDM' THEN 'EA Sales & Marketing'
    WHEN 'EDW' THEN 'EDW'
    ELSE 'Unknown'
END
  AS team, 
p85_epic_count 
FROM _percentiles
ORDER BY team;