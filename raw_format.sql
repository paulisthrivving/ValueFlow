CREATE TABLE `ctreportbuilder.abc_ea.raw_format`
(
  ID STRING,
  Link STRING,
  Title STRING,
  To_Do DATE,
  In_Progress DATE,
  Done DATE,
  Issue_Type STRING,
  Priority STRING,
  Fix_versions STRING,
  Components STRING,
  Assignee STRING,
  Reporter STRING,
  Project STRING,
  Resolution STRING,
  Labels STRING,
  Blocked_Days STRING,
  Blocked BOOL,
  Story_Points FLOAT64,
  Last_sprint STRING,
  Parent STRING,
  done_datetime TIMESTAMP
);