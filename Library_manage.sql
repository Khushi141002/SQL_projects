use Library;

show tables;

select * from library.authors;

-- Problem 1: Comprehensive Library Report

-- 1. Books Not Loaned Out in the Last 6 Months

/* select * from books
left join loans 
on books.BookId = loans.BookID; */

select books.BookId, Title, LoanDate, FirstName, LastName
from books
left join authors
on authors.AuthorID = books.AuthorID
left join loans
on loans.BookID = books.BookID where LoanDate <= date_sub(curdate(),interval 6 month) ;

select curdate();



-- 2. Top Members by Number of Books Borrowed in the Last Year

select loans.MemberID,FirstName,
count(*) as borrowed_score
from members
inner join loans
on members.MemberID = loans.MemberID
where LoanDate between '2024-01-01' and '2025-01-01'
group by loans.MemberID 
order by borrowed_score desc limit 10;



-- 3. Overdue Books Report 


select LoanDate,ReturnDate,DueDate from loans;

select books.BookID as OverDue_Books,
Title,
loans.MemberID,
concat(FirstName,' ',LastName) as person_name, 
DueDate, 
datediff(DueDate,ReturnDate) as diffrence
from books
inner join loans
on books.BookID = loans.BookID
inner join members
on members.MemberID = loans.MemberID
where date(LoanDate) < date(DueDate);




-- 4. Top 3 Most Borrowed Categories

select * from books;
select * from loans;

select CategoryName, count(CategoryName) as Most_borrowed_ID
from books
join categories
on categories.CategoryName = books.Genre
join loans 
on loans.BookID = books.BookID
group by CategoryName
order by Most_borrowed_ID desc
limit 3;


-- 5. Are there any books Belonging to Multiple Categories

select genre from books;
select * from bookcategories;

select Genre, books.BookID, Title , count(*) as count_category
from books
join  bookcategories
on  bookcategories.BookID = books.BookID
group by books.BookID
having count_category >1;



-- Problem 2: Advanced Library Data Analysis

-- 6. Average Number of Days Books Are Kept

/* Approach : group by avg days of books,
books table left join loan table ,
loan date, return date it will be days */

select  books.BookID,
books.Title,
round(AVG(DATEDIFF(ReturnDate, LoanDate)),2) as avg_of_kept,
SUM(DATEDIFF(ReturnDate, LoanDate)) AS total_days
from books
inner join loans
on books.BookID = loans.BookID
group by books.BookID, books.Title
order by total_days desc;



-- 7. Members with Reservations but No Loans in the Last Year

/* approach : table members , reservations , loans
inner join tables(book,members, reservations), left join (reservation , loan)
*/

select members.MemberID,
Title as book_name,
ReservationDate,
LoanDate
from books
inner join reservations
on books.BookID = reservations.BookID
inner join members
on members.MemberID = reservations.MemberID
left join loans
on loans.BookID = books.BookID
where LoanDate < date_sub('2025-05-22', Interval 1 year) and LoanDate is null;

select LoanDate from loans where LoanDate is null;




-- 8. Percentage of Books Loaned Out per Category

/* approach : tables(books,bookscategorie,vcategorie,loans)
group by , loandate of categorie
inner join(all) */

select count(LoanDate) as Count_Loaned_cat from loans;

select CategoryName,
(100*count(LoanID))/50 as Count_Loaned_cat
from bookcategories
inner join books
on books.BookID = bookcategories.BookID
inner join categories
on categories.CategoryID = bookcategories.CategoryID
inner join loans
on loans.BookID = books.BookID
group by categories.CategoryID,CategoryName;


-- 9. Total Number of Loans and Reservations Per Member

/* approach : tables (members,reservations, loans)
group by loanID of memberID
inner join */

select members.MemberID,
concat(Firstname,' ',LastName),
sum(LoanID) as Total_loans,
sum(ReservationID) as Total_reservations
from members
inner join reservations
on reservations.MemberID = members.MemberID
inner join loans
on loans.MemberID = reservations.MemberID
inner join books
on books.BookID = loans.BookID
group by members.MemberID
order by total_reservations desc;



-- 10. Find Members Who Borrowed Books by the Same Author More Than Once

/* approach : tables (loans, members , authors)
inner join 
group bookid of authors
*/

select members.MemberID,
concat(members.FirstName,' ',members.LastName) as member_name,
concat(authors.FirstName,' ',authors.LastName) as member_name,
sum(authors.AuthorID)
from members
inner join loans
on loans.MemberID = members.MemberID
inner join books
on books.BookID = loans.BookID
inner join authors 
on authors.AuthorID = books.AuthorID
group by members.MemberID , authors.AuthorID having count(*)>1;

-- no one member have borrowed books from same authors multiple time ..... 



-- 11. List Members Who Have Both Borrowed and Reserved the Same Book

/* approach : tables (mebers, book, borrowed , reserved )
inner join
group by loandid,reservedid of members
*/

select members.MemberID,
concat(members.FirstName,' ',members.LastName) as member_name,
loans.BookID ,
Title,
LoanID,ReservationID
from members
inner join loans
on loans.MemberID = members.MemberID
inner join reservations 
on reservations.BookID = loans.BookID
inner join books
on books.BookID = loans.BookID;




-- 12. Books Loaned and Never Returned
 /* approach : tables(books,loans,members)
 left join */

select books.BookID, 
 loans.LoanID,
 Title as Not_returned,
 LoanDate
 from loans
 left join books
 on loans.BookID = books.BookID
 where ReturnDate is null;

 select count(*) from loans where ReturnDate is null;



-- 13. Authors with the Most Borrowed Books

/* approach : tables (authors,books,loans)
inner join
group by loanid as per authorid and name */


select authors.AuthorID,
concat(FirstName, ' ' , LastName) as author_full_name,
count(LoanID) as Totle_loaned_books
from authors
inner join books
on books.BookID = authors.AuthorID
inner join loans
on loans.BookId = books.BookID
group by authors.AuthorID 
order by Totle_loaned_books desc;



-- 14. Books Borrowed by Members Who Joined in the Last 6 Months

/* approach : tables (books,loans,members)
left join */

select books.BookID,
Title ,
loans.LoanID,
members.MemberID,
concat(FirstName, ' ' , LastName) as last_6month_member,
MembershipStartDate
from books
left join loans
on loans.BookID = books.BookID
left join members 
on members.MemberID = loans.MemberID
where MembershipStartDate between '2023-01-01' and '2023-06-01';


















