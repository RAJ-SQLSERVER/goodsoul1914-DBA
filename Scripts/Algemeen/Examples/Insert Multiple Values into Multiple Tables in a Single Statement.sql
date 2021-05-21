-------------------------------------------------------------------------------
-- How to Insert Multiple Values into Multiple Tables in a Single Statement
-------------------------------------------------------------------------------

USE Playground
GO

-- Creating two tables
CREATE TABLE Table1
(
    ID1 INT,
    Col1 VARCHAR(100)
);
GO

CREATE TABLE Table2
(
    ID2 INT,
    Col2 VARCHAR(100)
);
GO

-- Inserting into two tables together
INSERT INTO Table1
(
    ID1,
    Col1
)
OUTPUT inserted.ID1,
       inserted.Col1
INTO Table2
VALUES
(1, 'Col'),
(2, 'Col2');
GO

--Selecting from both the tables
SELECT *
FROM Table1;
GO

SELECT *
FROM Table2;
GO

-- Clean up
DROP TABLE Table1;
GO
DROP TABLE Table2;
GO