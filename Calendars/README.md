# Business Calendar Logic (SQL)

## Why This Project Matters

This solution addresses the need for **accurate business day calculations** in industries where **financial reporting**, **billing**, and **SLA tracking** depend on stable, reliable business calendars. By integrating with existing financial and operational data, this project ensures:

- Precise **client invoicing** and **billing cycles** that reflect only business days.
- Compliance with **service-level agreements** by excluding weekends and holidays from SLA calculations.
- Optimized resource scheduling and workforce management for operational efficiency.

## Key Skills Demonstrated

- **Recursive CTEs**: Proficient use of recursive queries to generate dynamic date ranges (365 days in the past and future), showcasing advanced query design and optimization.
  
- **Business Day Logic**: Identification of business days (weekdays vs. weekends) and holidays, supporting accurate working day counts for financial processes and billing cycles.

- **Date Manipulation**: Expertise with SQL functions like `DATEADD`, `DATE_FROM_PARTS`, and `EXTRACT` to compute:
  - Day of the week
  - Holiday detection
  - Week of the year, quarter, and season
  - Leap year identification

## Overview

This project demonstrates advanced SQL skills by implementing a **Recursive Date Calendar** that handles business day logic, holiday detection, and service-level calculations. The solution is designed to support **financial reporting**, **client billing**, and **service-level agreement (SLA) tracking**, offering stable business day counts across multiple years. The calendar integrates fixed and variable holidays, making it ideal for business-critical processes.

**Note**: Certain portions of the code, especially those related to **my proprietary business logic** and holiday calculations, have been **obfuscated** to protect the unique methodology I've developed. The obfuscated sections are crucial to maintaining the privacy of my intellectual property. However, the overall structure and key SQL techniques are preserved to demonstrate the complexity and scalability of the solution.

**Use Cases**: Calendar logic is designed to be **joined with financial, operational, and SLA data**, providing consistent business day calculations for reporting, invoicing, resource/capacity planning, and performance tracking.

## Fixed-Date Holidays

| Holiday          | Date         |
|------------------|--------------|
| New Year's Day   | January 1    |
| Juneteenth       | June 19      |
| Independence Day | July 4       |
| Veterans Day     | November 11  |
| Christmas Eve    | December 24  |
| Christmas Day    | December 25  |
| New Year's Eve   | December 31  |

## Variable-Date Holidays

| Holiday                   | Date                          |
|---------------------------|-------------------------------|
| MLK Day                   | Third Monday in January       |
| Presidents' Day           | Third Monday in February      |
| Memorial Day              | Last Monday in May            |
| Labor Day                 | First Monday in September     |
| Indigenous Peoples' Day   | Second Monday in October      |
| Thanksgiving              | Fourth Thursday in November   |

## Contact

For any inquiries or to discuss this project further:

- **LinkedIn**: [LinkedIn Profile](https://www.linkedin.com/in/minna-cross/)
