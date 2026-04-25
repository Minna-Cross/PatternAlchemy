/* 
  This SQL query generates all prime numbers from 2 to 100. 

  Process:
  1. Generates a sequence of numbers from 2 to 100.
  2. Identifies prime numbers by checking divisibility of each number.
  3. Outputs a list of prime numbers that can be used in various applications.

  Output:
  - A table of prime numbers that can be incorporated into hashing algorithms, partitioning strategies, or other optimization techniques.

  Code Reuse:
  - You can integrate this query into larger systems to generate prime numbers as needed.
  - Adapt the query to generate primes within different ranges by modifying the `WHERE` clause.
  - Use the logic for prime generation in various scenarios such as data partitioning, hashing functions, or optimization tasks.

*/

WITH RECURSIVE numbers AS (
  SELECT 2 AS num
  UNION ALL
  SELECT num + 1 FROM numbers WHERE num < 100
),
primes AS (
  SELECT p.num
  FROM numbers p
  WHERE NOT EXISTS (
    SELECT 1 FROM numbers d
    WHERE d.num BETWEEN 2 AND FLOOR(SQRT(p.num))
      AND p.num % d.num = 0
  )
)
SELECT num AS prime FROM primes ORDER BY prime;
