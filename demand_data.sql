  -- Author: Paul Brown
  -- View Name: demand_data [v1.1]
  -- Date Last Update: 17th September, 2024
  -- Parameters:
  --  None
  -- Query Description:
  --  Return all the records. their demand and sub-demand types having concatenated the issue_key field
  -- Project:
  --  Value Flow
SELECT
  id AS issue_key,
  title,
  team,
  issue_type,
  stage,
  PARSE_DATE('%Y-%m-%d', CAST(Done AS STRING)) AS done_date,
  work_item_age,
  cycle_time,
  demand_type,
  CASE
    WHEN REGEXP_CONTAINS(LOWER(title), 'spike') THEN CONCAT(Demand_Type,' - Spike')
    WHEN REGEXP_CONTAINS(LOWER(title), 'non prod') THEN CONCAT(Demand_Type,' - Non-Prod')
    WHEN REGEXP_CONTAINS(LOWER(title), 'uat support') THEN CONCAT(Demand_Type,' - UAT Support')
    WHEN REGEXP_CONTAINS(LOWER(title), 'discovery') THEN CONCAT(Demand_Type,' - Discovery')
    WHEN REGEXP_CONTAINS(LOWER(title), '\\btech debt\\b|\\btd\\b') THEN CONCAT(Demand_Type,' - Technical Debt')
    WHEN REGEXP_CONTAINS(LOWER(title), 'automation') THEN CONCAT(Demand_Type,' - Automation')
    WHEN REGEXP_CONTAINS(LOWER(title), 'deploy') THEN CONCAT(Demand_Type,' - Deployment')
    WHEN REGEXP_CONTAINS(LOWER(title), 'design') THEN CONCAT(Demand_Type,' - Design')
    ELSE CONCAT(Demand_Type,' - Other')
END
  AS sub_demand_type
FROM
  `ctreportbuilder.abc_ea.abc-master-ct-data`