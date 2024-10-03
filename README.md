# PatternAlchemy (SQL)

## Overview

PatternAlchemy is a collection of SQL-based solutions that apply advanced techniques in **recursive CTEs**, **pattern generation**, and **business logic**. This repository demonstrates how SQL can be used to craft both real-world business applications (like **business calendar logic**) and technical pattern-generation projects (such as **3-letter codes** and **prime numbers**).

The name PatternAlchemy reflects the process of creating structured, dynamic patterns with precision, blending business logic with data generation techniques.

Projects include:
- **Business Calendar Logic**: A business-critical solution for managing business days for SLA compliance, financial reporting, and billing
- **3-Letter Code Pattern Generator**: A demonstration of recursive SQL for generating all possible combinations useful for validation, reference creation, and system testing
- **Prime Number Generator**: Recursive logic to generate prime numbers for optimization (i.e. data partitioning, hashing, optimization strategies) or mathematical purposes

---

### Project 1: Proprietary Business Calendar Logic (SQL)

#### Why This Project Matters

This solution addresses the need for **accurate business day calculations** in industries where **financial reporting**, **billing**, and **SLA tracking** depend on stable, reliable business calendars. By integrating with existing financial and operational data, this project ensures:

- Precise **client invoicing** and **billing cycles** that reflect only business days.
- Compliance with **service-level agreements** by excluding weekends and holidays from SLA calculations.
- Optimized resource scheduling and workforce management for operational efficiency.

#### Key Skills Demonstrated

- **Recursive CTEs**: Proficient use of recursive queries to generate dynamic date ranges (365 days in the past and future), showcasing advanced query design and optimization.
  
- **Business Day Logic**: Identification of business days (weekdays vs. weekends) and holidays, supporting accurate working day counts for financial processes and billing cycles.

- **Date Manipulation**: Expertise with SQL functions like `DATEADD`, `DATE_FROM_PARTS`, and `EXTRACT` to compute:
  - Day of the week
  - Holiday detection
  - Week of the year, quarter, and season
  - Leap year identification

#### Overview

This project demonstrates advanced SQL skills by implementing a **Recursive Date Calendar** that handles business day logic, holiday detection, and service-level calculations. The solution is designed to support **financial reporting**, **client billing**, and **service-level agreement (SLA) tracking**, offering stable business day counts across multiple years. The calendar integrates fixed and variable holidays, making it ideal for business-critical processes.

**Note**: Certain portions of the code, especially those related to **my proprietary logic** and holiday calculations, have been **obfuscated** to protect the unique methodology I've developed. The obfuscated sections are crucial to maintaining the privacy of my intellectual property. However, the overall structure and key SQL techniques are preserved to demonstrate the complexity and scalability of the solution.

**Use Cases**: Calendar logic is designed to be **joined with financial, operational, and SLA data**, providing consistent business day calculations for reporting, invoicing, resource/capacity planning, and performance tracking.

##### Fixed-Date Holidays

| Holiday          | Date         |
|------------------|--------------|
| New Year's Day   | January 1    |
| Juneteenth       | June 19      |
| Independence Day | July 4       |
| Veterans Day     | November 11  |
| Christmas Eve    | December 24  |
| Christmas Day    | December 25  |
| New Year's Eve   | December 31  |

##### Variable-Date Holidays

| Holiday                   | Date                          |
|---------------------------|-------------------------------|
| MLK Day                   | Third Monday in January       |
| Presidents' Day           | Third Monday in February      |
| Memorial Day              | Last Monday in May            |
| Labor Day                 | First Monday in September     |
| Indigenous Peoples' Day   | Second Monday in October      |
| Thanksgiving              | Fourth Thursday in November   |

---

### Project 2: 3-Letter Code Pattern Generator

#### Overview

This project generates all possible 3-letter code patterns using letters from A to Z, creating a reference list of potential codes and assigning a unique identifier to each code. This solution can be adapted to generate longer patterns by modifying the recursive query logic, making it flexible for use cases that require different code lengths or complexity.

### Key Skills Demonstrated

- **Recursive CTEs**: Efficient recursive queries that generate the full set of possible combinations
- **Pattern Generation**: Creation of comprehensive, dynamic, and scalable patterns for testing and system validation purposes
- **Unique Identifiers**: Each generated code is assigned a unique identifier for easy tracking and referencing

---

### Project 3: Prime Number Generator

#### Overview

This project generates all prime numbers between 2 and 100 using recursive logic to eliminate non-prime numbers by checking divisibility. This solution is useful in scenarios where prime numbers are required for optimization, partitioning, or hashing purposes.

### Key Skills Demonstrated

- **Recursive CTEs**: Recursive SQL queries that efficiently generate a sequence of numbers and identify prime numbers by filtering out non-primes
- **Prime Number Logic**: Demonstrates how SQL can be used for mathematical computation and validation of prime numbers
- **Scalability**: The solution can easily be adapted to handle larger ranges of numbers

### Use Cases

- **Optimization**: Use prime numbers in hashing algorithms, data partitioning strategies, or other optimization tasks
- **Dynamic Range**: Adaptable for generating primes within different ranges by adjusting the logic in the query, making it versatile for various scenarios

---


## Contact

For any inquiries or to discuss these project further:

- **LinkedIn**: [LinkedIn Profile](https://www.linkedin.com/in/minna-cross/)
