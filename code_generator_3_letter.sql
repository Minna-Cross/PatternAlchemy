/*
  This SQL query generates all possible 3-letter code patterns using letters A to Z (26 letters), creating a comprehensive reference list of potential codes.

  Process:
  1. Generates a sequence of letters from A to Z using a recursive CTE.
  2. Constructs every possible combination of 3-letter codes where letters can repeat, utilizing joins within the recursive CTE.
  3. Assigns a unique sequential ID to each generated code pattern for easy tracking and reference.

  Use Case:
  - Useful for validating if a particular 3-letter code is already in use by comparing against a predefined list of codes.
  - Facilitates the creation of a complete reference list for testing.

  Output:
  - Provides a table with each possible 3-letter code pattern and a unique identifier. This allows for straightforward validation, tracking, and analysis.

  Considerations:
  - Ensure the query performance and scalability when extending to more letters or longer patterns.
  - Validate the generated data to ensure all possible patterns are included and there are no duplicates.
*/


WITH RECURSIVE alphabet AS (
    SELECT CHR(65 + 0) AS letter, 1 AS pos
    UNION ALL
    SELECT CHR(65 + pos), pos + 1
    FROM alphabet
    WHERE pos < 26
),
pattern AS (
    SELECT
        a1.letter AS l1,
        a2.letter AS l2,
        a3.letter AS l3
    FROM alphabet a1
    JOIN alphabet a2
    ON a2.pos <= a1.pos
    JOIN alphabet a3
    ON a3.pos <= a2.pos
),
numbered_patterns AS (
    SELECT
        CONCAT(l1, l2, l3) AS code_pattern,
        ROW_NUMBER() OVER (ORDER BY CONCAT(l1, l2, l3)) AS id
    FROM pattern
)

SELECT id, code_pattern
FROM numbered_patterns
ORDER BY id;
