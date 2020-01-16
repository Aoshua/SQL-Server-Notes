--Joshua Abbott
--10/22/2018

USE student2550;

GO

PRINT '1. List the salutation and names (first and last name) of all instructors in alphabetical order (last name then first name).'
SELECT last_name, first_name
FROM instructor
ORDER BY last_name;

PRINT 'Provide a list of distinct locations that have been used to teach sections of courses. Arrange the list in order of location.'
SELECT DISTINCT location
FROM section
ORDER BY location;

PRINT '3. List the first and last names of Instructors with a first name starting with “T”. Sort them in alphabetical order.'
SELECT last_name, first_name
FROM instructor
WHERE first_name LIKE 'T%'
ORDER BY first_name;

PRINT '4. List the phone number, full name (as one column) and employer for all students with a last name of “Torres”. Sort by Employer'
SELECT phone, first_name + ' ' + last_name AS 'Full name', employer
FROM student
WHERE last_name LIKE '%Torres%'
ORDER BY employer;

PRINT '5. List the course number and course description of all courses that have a prerequisite of course 350. Arrange in order of course number.'
SELECT course_no, description
FROM course
WHERE prerequisite LIKE '%350%'
ORDER BY course_no;

 PRINT '6. List the course number, description and cost for all 200 level courses (200-299) costing less than $1100. Arrange by course number. Format and add a "$" in front of the COST.'
 SELECT course_no, description, '$' + CAST(cost AS VARCHAR(10)) --ten incase more money than expected
 FROM course
 WHERE (course_no BETWEEN 200 AND 299) AND (cost < 1100)
 ORDER BY course_no;

 PRINT '7. List the course number, section id and location for all 100 level courses (100 through 199) that are taught in room L214 or L509. Order by location and course number.'
 SELECT course_no, section_id, location
 FROM section
 WHERE (course_no BETWEEN 100 AND 199) AND (location = 'L214' OR location = 'L509')
 ORDER BY location, course_no; 

 PRINT '8. List the course number and section id for classes with a capacity of 12 or 15 (use the IN clause). Order the list by course number and section id.'
 SELECT course_no, section_id 
 FROM section
 WHERE capacity IN (12,15)
 ORDER BY course_no, section_id;

 PRINT '9. List the student id and grade for all of the midterm exam scores (MT) in section 141. Arrange the list by student id and grade.'
 SELECT student_id, numeric_grade
 FROM grade
 WHERE grade_type_code = 'MT' AND section_id = 141
 ORDER BY student_id, numeric_grade;

 PRINT '10. List the course number and description for all 300 level courses that have a prerequisite, arranged on course description.'
 SELECT course_no, description
 FROM course
 WHERE (course_no BETWEEN 300 AND 399) AND prerequisite IS NOT NULL
 ORDER BY description;

 PRINT '11. Provide an alphabetical list of the full name and phone number of all students that work for "New York Culture" (the full name should be displayed as one column with an alias of "Student Name")'
 SELECT first_name + last_name AS 'Student Name', phone
 FROM student
 WHERE employer = 'New York Culture'
 ORDER BY first_name;

 PRINT '12. Provide a list of student employers that are corporations (have "Co." in their name). List each employer only once and arrange the list alphabetical order.'
 SELECT DISTINCT employer
 FROM student
 WHERE employer LIKE '%co.%'
 ORDER BY employer;

 PRINT '13. Provide an alphabetical list of students in area code 617. List student name in the format <last name (all upper case)>, <first initial>. ( Example, SMITH, J. ) followed by the phone number.'
 SELECT UPPER(last_name) + ', ' + LEFT(first_name, 1) + '.' AS 'Student Name', phone
 FROM student
 WHERE phone LIKE '%617%'
 ORDER BY last_name;

 PRINT '14. List the name and address of all instructors without a zip code.'
 SELECT last_name + ' ' + first_name, street_address
 FROM instructor
 WHERE zip IS NULL
 ORDER BY last_name;

 PRINT '15. Provide a list of zip codes for Jackson Heights, NY. Sort on zip.'
 SELECT zip
 FROM zipcode
 WHERE city LIKE '%Jackson Heights%'
 ORDER BY zip;

 PRINT '16. List the course number and location for all courses taught in a classroom that ends in the number 10. Arrange the list on location.'
 SELECT course_no, location
 FROM section
 WHERE location LIKE '%10'
 ORDER BY location;

 PRINT '17. Provide a list containing full state name, state abbreviation and city from the zip code table for MA, OH, PR and WV. (You will need to use the CASE expression). MA is Massachusetts, OH is Ohio, PR is Puerto Rico and WV is West Virginia. Sort by state.'
 SELECT state, city,
 CASE state
	WHEN 'MA' THEN 'Massachussets'
	WHEN 'OH' THEN 'Ohio'
	WHEN 'PR' THEN 'Puerto Rico'
	WHEN 'WV' THEN 'West Virginia'
 END AS 'Full state Name'
 FROM zipcode
 WHERE state = 'MA' OR state = 'OH' OR state = 'PR' OR state = 'WV'
 ORDER BY state;

 PRINT '18. Create a listing containing single column address (salutation, first name, last name, address, zip) as "Instructor Address" for each instructor in zip code 10015. Sort the list in alphabetical order.'
 SELECT (salutation + '. ' + first_name + ' ' + last_name + ', ' + street_address + ', ' + zip) AS 'Instructor Address'
 FROM instructor
 WHERE zip = '10015'
 ORDER BY salutation;

 PRINT '19. List the student id and quiz score for each student in section 152. List the scores from highest to lowest.'
 SELECT student_id, numeric_grade
 FROM grade
 WHERE section_id = 152 AND grade_type_code = 'QZ'
 ORDER BY numeric_grade;

 PRINT '20. List the student ID, final exam (FI) score and exam result ("PASS" or "FAIL") for all students in section 156. A final score of 85 or higher is required to pass. Arrange the list by student ID.'
 SELECT student_id, numeric_grade, 
 CASE 
	WHEN numeric_grade >= 85 THEN 'PASS'
	WHEN numeric_grade < 84 THEN 'FAIL'
 END AS 'Exam Results'
 FROM grade
 WHERE section_id = 156
 ORDER BY  student_id;

 PRINT '21. List the first name, last name and phone number for all students that registered on 2/13/2007. Arrange the list in order of last name and first name.'
 SELECT first_name, last_name, phone
 FROM student
 WHERE registration_date = '2/13/2007'
 ORDER BY last_name, first_name;

 PRINT '22. List course number, section ID and start date for all sections located in L509. Arrange by start date.'
 SELECT course_no, section_id, start_date_time
 FROM section
 WHERE location = 'L509'
 ORDER BY start_date_time;

 PRINT '23. List the course number, section ID, start date, instructor ID and capacity for all courses with a start date in July 2007. Arrange the list by start date and course number.'
 SELECT course_no, section_id, start_date_time, capacity
 FROM section
 WHERE start_date_time LIKE '2007-07%'
 ORDER BY start_date_time, course_no;

 PRINT '24. List Student ID, Section ID and final grade for all students who have a final grade and enrolled in January 2007.'
 SELECT student_id, section_id, final_grade 
 FROM enrollment
 WHERE (final_grade IS NOT NULL) AND enroll_date LIKE '2007-01%'

PRINT '25. Provide a list of course numbers and locations for sections being taught in the even numbered rooms located in building L.'
SELECT course_no, location
FROM section
WHERE CAST(SUBSTRING(location, 2,4) AS INT) % 2 = 0 AND location LIKE 'L%';
