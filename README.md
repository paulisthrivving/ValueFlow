# Enterprise Analytics SQL Repository

This repository contains a collection of SQL scripts used for analyzing and managing flow metrics, demand data, responsiveness, rightsizing, and correlations within enterprise analytics systems. These scripts are designed for use in **BigQuery** and support insights into key performance indicators for teams working with flow-based processes.

## 📌 **Contents**

### **1. SQL Scripts**
Below is a list of the SQL scripts included in this repository:

- **abc-master-ct-data.sql** - This SQL query creates a base view for all enterprise analytics (EA) reporting. It standardizes issue tracking data by mapping project names, categorizing demand types, and calculating key flow metrics such as cycle time, lead time, and work item age.
- **abc-master-ct-data.sql** - Establishes the base table for all enterprise analytics reporting, standardizing work item categorization, team mapping, and key flow metrics such as cycle time, lead time, and work item age.
- **balanced_demand_data.sql** - Computes throughput (work completed) and arrival rate (work started) on a daily and weekly basis, helping teams analyze demand vs. delivery capacity.
- **balanced_quality_data.sql** - Tracks the proportion of completed work categorized as defects or rework, allowing teams to monitor quality trends and reduce failure demand.
- **balanced_responsiveness.sql** - Measures the system’s responsiveness by tracking cycle time trends, ensuring work items move efficiently from start to completion.
- **balanced_wia.sql** - Evaluates work item age across different workflow stages, helping teams identify aging work and potential flow inefficiencies.
- **correlation_data.sql** - Aggregates historical work data to uncover correlations between key flow metrics, supporting deeper analysis of process performance.
- **correlation_numbers.sql** - Computes statistical correlations between cycle time, throughput, WIP, and other metrics to identify key process drivers.
- **correlation_summary.sql** - Summarizes correlation analysis findings, highlighting the most significant relationships between flow metrics.
- **demand_data.sql** - Breaks down work items into different demand categories (e.g., value vs. failure demand) to help teams understand where their efforts are focused.
- **dim-dates.sql** - Provides a standardized date dimension for aligning work item data with calendar weeks, months, and quarters.
- **epic_rightsizing.sql** - Analyzes epic size distribution to determine whether epics are appropriately scoped for flow efficiency.
- **feature_rightsizing.sql** - Evaluates feature size relative to historical completion patterns, ensuring features are right-sized for predictability.
- **flow_debt_by_week.sql** - Tracks flow debt over time by comparing actual cycle time to predicted cycle time, identifying process inefficiencies.
- **flow_distribution_by_type.sql** - Categorizes work items by type (e.g., stories, bugs, support) to visualize the composition of work flowing through the system.
- **rolling_sle.sql** - Monitors changes in service level expectations (SLE) over time to assess whether teams are maintaining predictable delivery performance.
- **net_flow_data.sql** - Computes net flow (difference between work started and work completed) to determine whether teams are operating in a sustainable manner.
- **raw_format.sql** - Stores unprocessed work item data before transformation into structured analytics reports.
- **story_rightsizing.sql** - Analyzes story size trends to ensure work items are appropriately sized for flow efficiency.
- **system_variability.sql** - Measures variability in cycle time and throughput, helping teams understand how predictable their system is.
- **throughput_date.sql** - Tracks throughput (work completed per time period) to monitor delivery performance over time.
- **wia_that_madeit.sql** - Identifies work items that exceeded the 70th percentile of work item age but still finished within the 85th percentile, helping assess flow recovery.
- **wip_data.sql** - Captures work-in-progress (WIP) trends over time, supporting WIP limit policies and flow efficiency analysis.

## ⚡ **How to Use These SQL Scripts**
1. Open **Google BigQuery** and select the appropriate dataset.
2. Run the desired SQL script in the **BigQuery Query Editor**.
3. Review the results and use them for analysis.
4. Modify the scripts as needed for custom insights.

## 💡 **Contributing**
If you have additional scripts or enhancements, feel free to submit a **pull request** or open an **issue** for discussion.

## 📄 **License**
This repository is licensed under MIT License. 

---
