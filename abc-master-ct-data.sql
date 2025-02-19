  -- Author: Paul Brown
  -- View Name: abc-master-ct-data
  -- Date Last Update: 19th February, 2025 [v1.1]
  -- Parameters:
  --  None
  -- Query Description:
  --  Base table for all reporting for EA
  -- Project:
  -- ValueFlow
SELECT
  id,
  title,
  to_do,
  In_Progress AS started,
  done,
  issue_type,
  CASE
    WHEN NOT done IS NULL AND (resolution = 'Done' OR resolution IS NULL OR resolution = 'In Production') THEN 'Done'
    WHEN NOT done IS NULL THEN 'Canceled'
    WHEN NOT In_Progress IS NULL THEN 'Development in Progress'
    WHEN NOT to_do IS NULL THEN 'To Do'
END
  AS stage,
  resolution,
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
  CASE
    WHEN Issue_Type = 'Bug' AND resolution IN ('Canceled', "Won't Do", "Rejected", "Cannot Reproduce", 'Duplicate') THEN 'False'
    WHEN Issue_Type = 'Bug' THEN 'Failure'
    WHEN Issue_Type = 'Story' AND resolution IN ('Canceled', "Won't Do", "Rejected", "Cannot Reproduce", 'Duplicate') THEN 'False'
    ELSE 'Value'
END
  AS demand_type,
  CAST(story_points AS INT64) AS story_points,
  COALESCE(DATE_DIFF(PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)), PARSE_DATE('%Y-%m-%d', CAST(In_Progress AS STRING)), DAY)+1,0) AS cycle_time,
  COALESCE(DATE_DIFF(PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)), PARSE_DATE('%Y-%m-%d', CAST(to_do AS STRING)), DAY)+1,0) AS lead_time,
  CASE
    WHEN NOT done IS NULL THEN COALESCE(DATE_DIFF(PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)), PARSE_DATE('%Y-%m-%d', CAST(In_Progress AS STRING)), DAY)+1,0)
    WHEN NOT In_Progress IS NULL THEN DATE_DIFF(CURRENT_DATE, PARSE_DATE('%Y-%m-%d', CAST(In_Progress AS STRING)), DAY)
    ELSE 0
END
  AS work_item_age,
  done_datetime,
  parent,
  last_sprint
FROM
  `ctreportbuilder.abc_ea.raw_format`