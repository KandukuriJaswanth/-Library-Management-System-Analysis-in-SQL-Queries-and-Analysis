/* We are developing a new database, *Library_Database_Analysis*, 
to store information on authors, book copies, book loans, books, borrowers, library branches, and publishers, 
enabling comprehensive management of library data and efficient analysis.
*/

create  database library_database_analysis;
use library_database_analysis;

-- Table: Authors
CREATE TABLE authors (
    book_authors_BookID INT AUTO_INCREMENT PRIMARY KEY, -- Primary key
    book_authors_AuthorName VARCHAR(255)               -- book_authors_AuthorName
);

-- Table: Publishers
CREATE TABLE publishers (
    publisher_PublisherID INT AUTO_INCREMENT PRIMARY KEY,   -- Primary key
    publisher_PublisherName VARCHAR(255),                   -- publisher_PublisherName(variable-length strings)
    publisher_PublisherAddress VARCHAR(255),                 -- publisher_PublisherAddress(variable-length strings)
    publisher_PublisherPhone VARCHAR(20)                     -- publisher_PublisherPhone(variable-length strings)
);

-- Table: Library Branches
CREATE TABLE library_branch (
    library_branch_BranchID INT AUTO_INCREMENT PRIMARY KEY,  -- primary key
    library_branch_BranchName VARCHAR(255),                  -- library_branch_BranchName(variable-length strings)
    library_branch_BranchAddress VARCHAR(255)
);

-- Table: Books
CREATE TABLE books (
    book_BookID INT AUTO_INCREMENT PRIMARY KEY,             -- Primary key
    book_Title VARCHAR(255),                                -- Book title(variable-length strings)
    book_PublisherID INT,                                   -- Foreign key referencing publishers
    book_PublisherName VARCHAR(255),                        -- Publisher name (not normalized)(variable-length strings)
    book_authors_BookID INT,                               -- Foreign key referencing authors
    FOREIGN KEY (book_PublisherID) REFERENCES publishers(publisher_PublisherID)
    ON DELETE CASCADE ON UPDATE CASCADE,                   -- Cascading actions
    FOREIGN KEY (book_authors_BookID) REFERENCES authors(book_authors_BookID)
    ON DELETE CASCADE ON UPDATE CASCADE                    -- Cascading actions
);

ALTER TABLE books
ADD COLUMN book_PublisherName VARCHAR(255);    -- (variable-length strings)



-- Table: Book Copies
CREATE TABLE book_copies (
    book_copies_ID INT AUTO_INCREMENT PRIMARY KEY,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES books(book_BookID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_copies_BranchID) REFERENCES library_branch(library_branch_BranchID)
    ON DELETE CASCADE ON UPDATE CASCADE
);


-- Table: Borrowers
CREATE TABLE borrowers (
    borrower_CardNo INT AUTO_INCREMENT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),            -- borrower_BorrowerName(variable-length strings)
    borrower_BorrowerAddress VARCHAR(255),         -- borrower_BorrowerAddress(variable-length strings)
    borrower_BorrowerPhone VARCHAR(20)             -- borrower_BorrowerPhone(variable-length strings)
);

-- Table: Book Loans
CREATE TABLE book_loans (
    
    book_loans_BookID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    book_loans_BranchID INT NOT NULL,
    book_loans_CardNo INT NOT NULL,
    book_loans_DateOut DATE NOT NULL,
    book_loans_DueDate DATE NOT NULL,
    FOREIGN KEY (book_loans_BookID) REFERENCES books(book_BookID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_loans_BranchID) REFERENCES library_branch(library_branch_BranchID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_loans_CardNo) REFERENCES borrowers(borrower_cardno) ON DELETE CASCADE ON UPDATE CASCADE
);

/* The DESCRIBE command displays the table structure, showing columns, 
   data types, and constraints to verify the schema before data import. 
*/ 

DESCRIBE authors;
DESCRIBE book_copies;
DESCRIBE book_loans;
DESCRIBE books ;
DESCRIBE   borrowers ;
DESCRIBE  library_branch;
DESCRIBE publishers ;

/* Use the SELECT command to retrieve specific columns from a table, 
   enabling targeted data retrieval for analysis or reporting.
*/
select * from  authors;
select * from  book_copies;
select * from  book_loans;
select * from  books ;
select * from    borrowers ;
select * from   library_branch;
select * from  publishers ;

-- Task 
/*
1-How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
*/
/* Comment on the query
This SQL query sums the total number of copies of the book titled 
"The Lost Tribe" available in the "Sharpstown" 
library branch by joining the book_copies, books, and library_branch tables.
*/
SELECT 
    SUM(book_copies.book_copies_No_Of_Copies) AS total_copies  -- Calculate the total number of book copies and alias the result as 'total_copies'
FROM 
    book_copies                                              -- From the 'book_copies' table
JOIN 
    books ON book_copies_No_Of_Copies = book_copies_ID       -- Join the 'books' table on matching book IDs between 'books' and 'book_copies'
JOIN 
    library_branch ON book_copies_BranchID = library_branch_BranchID  -- Join the 'library_branch' table on matching branch IDs between 'book_copies' and 'library_branch'
WHERE 
    book_Title = 'the lost tribe'                            -- Filter for the book with the title 'the lost tribe'
    AND library_branch_BranchName = 'sharpstown';            -- Filter for the library branch with the name 'Sharpstown'
 
-- 2- How many copies of the book titled "The Lost Tribe" are owned by each library branch?
/*  The query retrieves the total number of copies of "The Lost Tribe" available at each library branch by 
joining the book_copies, books, and library_branch tables and grouping by branch names.
*/
SELECT 
    lb.library_branch_BranchName,           -- Select the name of the library branch from the 'library_branch' table
    SUM(bc.book_copies_No_Of_Copies) AS total_copies  -- Calculate the total number of book copies available in that branch, aliasing it as 'total_copies'
FROM 
    book_copies bc                          -- From the 'book_copies' table, aliased as 'bc'
JOIN 
    books b ON bc.book_copies_BookID = b.book_BookID  -- Join the 'books' table, matching book IDs between 'book_copies' and 'books'
JOIN 
    library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID  -- Join the 'library_branch' table, matching branch IDs between 'book_copies' and 'library_branch'
WHERE 
    b.book_Title = 'The Lost Tribe'         -- Filter for book records where the title is 'The Lost Tribe'
GROUP BY 
    lb.library_branch_BranchName;           -- Group the results by the branch name to aggregate the total copies per branch

-- 3 Retrieve the names of all borrowers who do not have any books checked out.
/* To retrieve names of borrowers without checked-out books, use a LEFT JOIN or subquery. 
The queries identify borrowers whose CardNo is not present in the book_loans table, 
effectively filtering those without active loans.
*/
SELECT 
    borrower_BorrowerName  -- Select the name of the borrower from the 'borrowers' table
FROM 
    borrowers              -- From the 'borrowers' table
WHERE 
    borrower_CardNo NOT IN (SELECT book_loans_CardNo FROM book_loans);  -- Filter for borrowers whose CardNo is not found in the 'book_loans' table

/* 4 For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18,
 retrieve the book title, the borrower's name, and the borrower's address. 
 */
 
 /*The below SQL queries are used to standardize date formats and handle invalid or missing dates in a Book_Loans table.
 The STR_TO_DATE() function converts string dates to a proper DATE format, while CURDATE() 
 fills in missing or incorrect dates with the current date. This ensures consistent, accurate data.
 */
UPDATE Book_Loans
SET Book_Loans_DateOut = STR_TO_DATE(Book_Loans_DateOut, '%Y-%m-%d')
WHERE Book_Loans_DateOut IS NOT NULL;

-- 2. Update the 'Book_Loans_DueDate' column to convert strings to valid date format
UPDATE Book_Loans
SET Book_Loans_DueDate = STR_TO_DATE(Book_Loans_DueDate, '%Y-%m-%d')
WHERE Book_Loans_DueDate IS NOT NULL;

-- 3. Handle any missing or incorrect dates by setting them to today's date (optional)
UPDATE Book_Loans
SET Book_Loans_DueDate = CURDATE()
WHERE Book_Loans_DueDate IS NULL OR Book_Loans_DueDate = '0001-03-18';

-- You can do the same for the 'Book_Loans_DateOut' column if required:
UPDATE Book_Loans
SET Book_Loans_DateOut = CURDATE()
WHERE Book_Loans_DateOut IS NULL OR Book_Loans_DateOut = '0001-03-18';

-- Select to verify the updates
select * from book_loans;
/* In below  SQL query retrieves details of books loaned from the 'Sharpstown' library branch, 
including book ID, card number, branch name, and 
due date by joining the book loans and library branch tables.
*/
WITH LoanedBooks AS (                   -- Begin a Common Table Expression (CTE) named 'LoanedBooks'
    SELECT 
        BL.book_loans_BookID,           -- Select the Book ID from the 'book_loans' table
        BL.book_loans_CardNo,           -- Select the Card Number from the 'book_loans' table (borrower ID)
        LB.library_branch_BranchName,    -- Select the Branch Name from the 'library_branch' table
        BL.book_loans_DueDate            -- Select the Due Date from the 'book_loans' table
    FROM 
        book_loans BL                   -- From the 'book_loans' table, aliased as 'BL'
    JOIN 
        library_branch LB ON BL.book_loans_BranchID = LB.library_branch_BranchID  -- Join with 'library_branch' based on Branch ID
    WHERE 
        LB.library_branch_BranchName = 'Sharpstown'  -- Filter for loans from the 'Sharpstown' branch
)
SELECT *                                -- Select all columns from the CTE 'LoanedBooks'
FROM LoanedBooks;                       -- Retrieve data from the 'LoanedBooks' CTE

-- 5) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
SELECT * FROM book_loans;
SELECT * FROM library_branch;
/* In below  SQL query retrieves all columns (SELECT *) from the book_loans (BL) 
and library_branch (LB) tables by joining them on the matching
 BranchID fields (book_loans_BranchID and library_branch_BranchID). 
 The purpose is to combine related data from both tables.
*/
SELECT *                                  -- Select all columns from the resulting dataset
FROM 
    book_loans BL                         -- From the 'book_loans' table, aliased as 'BL'
JOIN 
    library_branch LB                     -- Join with the 'library_branch' table, aliased as 'LB'
ON 
    BL.book_loans_BranchID = LB.library_branch_BranchID;  -- Join condition: match 'book_loans_BranchID' from 'book_loans' with 'library_branch_BranchID' from 'library_branch'

/*This SQL query retrieves each library branch's name and the total number of books loaned.
 It joins the book_loans and library_branch tables based on BranchID,
 grouping results by branch to count loans per branch.
*/
SELECT 
    b.library_branch_BranchName,                    -- Select the branch name
    COUNT(l.book_loans_LoanID) AS total_books_loaned  -- Count the total books loaned
FROM 
    book_loans l                                     -- From the book_loans table
JOIN 
    library_branch b ON l.book_loans_BranchID = b.library_branch_BranchID  -- Join on BranchID
GROUP BY 
    b.library_branch_BranchName;                     -- Group by branch name

-- Retrieve the names, addresses, and number of books checked out
--  for all borrowers who have more than five books checked out.
select * from borrowers;
select * from book_loans;
/*In below  SQL query retrieves the names and addresses of borrowers who have checked out more than five books.
 It uses a subquery to count book loans per borrower (CardNo), 
 joining results with the borrowers table to display relevant details.
*/
SELECT 
    b.borrower_BorrowerName,                         -- Retrieve the borrower's name
    b.borrower_BorrowerAddress,                      -- Retrieve the borrower's address
    checkout_counts.total_books_checked_out          -- Retrieve the number of books checked out
FROM 
    borrowers b                                      -- From the borrowers table
JOIN 
    (SELECT 
         bl.book_loans_CardNo,                      -- Use the correct column for borrower CardNo
         COUNT(bl.book_loans_LoanID) AS total_books_checked_out  -- Count the number of books checked out
     FROM 
         book_loans bl                               -- From the book_loans table
     GROUP BY 
         bl.book_loans_CardNo                        -- Group by borrower card number
     HAVING 
         COUNT(bl.book_loans_LoanID) > 5) AS checkout_counts -- Filter for borrowers with more than 5 books checked out
ON 
    b.borrower_CardNo = checkout_counts.book_loans_CardNo;  -- Join on the correct card number

-- For each book authored by "Stephen King", retrieve the title and 
-- the number of copies owned by the library branch whose name is "Central".
select * from books;
select * from book_copies;
select * from library_branch;
select * from authors;
/*The provided SQL query retrieves the titles and number of copies for books authored by "Stephen King." 
It joins the books, authors, book_copies, and library_branch tables based on 
their relationships to filter and display relevant data. This helps identify available 
titles by the author in the library's collection.
*/
SELECT 
    b.book_Title,                         -- Select the title of the book from the 'books' table
    bc.book_copies_No_Of_Copies           -- Select the number of copies available from the 'book_copies' table
FROM 
    books b                               -- From the 'books' table, aliased as 'b'
JOIN 
    authors a ON b.book_BookID = a.book_authors_BookID  -- Join the 'authors' table, matching book IDs between 'books' and 'authors'
JOIN 
    book_copies bc ON b.book_BookID = bc.book_copies_ID   -- Join the 'book_copies' table, matching book IDs between 'books' and 'book_copies'
JOIN 
    library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID  -- Join the 'library_branch' table, matching branch IDs between 'book_copies' and 'library_branch'
WHERE 
    a.book_authors_AuthorName = 'Stephen King';  -- Filter for books authored by 'Stephen King'