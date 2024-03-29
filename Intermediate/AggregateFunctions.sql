--Joshua Abbott
--10/29/2018

USE student2550;

GO

PRINT '1. Create a query that returns the average cost for all courses. (Round to two places, and alias the column heading).'
SELECT ROUND(AVG(cost), 2) AS 'Average Course Cost'
FROM course;

PRINT '2. Create a query that returns the total number of Students that registered during February 2007. Alias the column as "February 2007 Registrations".'
SELECT COUNT(student_id) AS 'February 2007 Registrations'
FROM student
WHERE Registration_date LIKE '%2007-02%';

PRINT '3. Create a query that returns the average, highest and lowest final exam scores for Section 147. Display the average exam score with 2 decimal places.'
SELECT 
	ROUND(AVG(numeric_grade), 2) AS 'Average Score', 
	MAX(numeric_grade) AS 'Highest Score', 
	MIN(numeric_grade) AS 'Lowest Score'
FROM grade
WHERE section_id = 147;

PRINT '4. List the city, state and �number of zip codes� (alias) for all cities with more than two zip codes. Arrange by state and city.'
SELECT city, state, COUNT(zip) AS 'Number of zip codes'
FROM zipcode
GROUP BY city, state
HAVING COUNT(zip) > 2
ORDER BY state, city;

PRINT '5. Provide a list of Sections and the number of students enrolled in each section for students who enrolled on 2/21/2007. Sort from highest to lowest on the number of students enrolled.'
SELECT section_id, COUNT(student_id) AS 'Number of students'
FROM enrollment
WHERE enroll_date = '02/21/2007'
GROUP BY section_id
ORDER BY 'Number of students' DESC;

PRINT '6. Create a query listing the student ID and Average Grade for all students in Section 86. Sort your list on the student ID and display all of the average grades with 2 decimal places.'
SELECT student_id, ROUND(AVG(numeric_grade), 2) AS 'Average Grade'
FROM grade
WHERE section_id = 86
GROUP BY student_id;

PRINT '7. Create a query to determine the number of sections in which student ID 250 is enrolled. Your output should contain the student ID and the number of sections (alias) enrolled.'
SELECT student_id, COUNT(section_id) AS 'Number of sections'
FROM enrollment
WHERE student_id = 250
GROUP BY student_id;

PRINT '8. List the section ID and lowest quiz score (GRADE_TYPE_CODE="QZ") for all sections where the low score is greater than a B (greater than 80). Arrange by section id.'
SELECT section_id, MIN(numeric_grade) AS 'Lowest Quiz Score'
FROM grade
WHERE grade_type_code = 'QZ'
GROUP BY section_id
HAVING MIN(numeric_grade) > 80;

PRINT '9. List the names of Employers having more than 5 student employees. Your output should contain the employer name and the number of student employees. Arrange the output on the number of employees from lowest to highest.'
SELECT employer, COUNT(student_id) AS 'Number of Student Employees'
FROM student
GROUP BY employer
HAVING COUNT(student_id) > 5;

PRINT '10. List the section ID, number of participation grades (GRADE_TYPE_CODE="PA") and lowest participation grade for all sections with more than 15 participation grades. Arrange by section id.'
SELECT section_id, COUNT(grade_type_code) AS 'Number of Participation Grades', min(numeric_grade) 'Lowest Participation Grade'
FROM grade
WHERE grade_type_code = 'PA'
GROUP BY section_id
HAVING COUNT(grade_type_code) > 15;

PRINT '11. List the first and last name and phone number for students that live in Newark, NJ. Sort on last name and first name.'
SELECT first_name, last_name, phone
FROM student
	JOIN zipcode ON student.zip = zipcode.zip
WHERE state = 'NJ' AND city = 'Newark'
ORDER BY last_name, first_name;

PRINT '12. For all 300 level courses (300-399), list the course number, prerequisite course number and prerequisite course description. Sort by course number.'
SELECT c1.course_no, c1.prerequisite, c2.description AS 'Prerequisit Description'
from course c1
	join course c2 ON c1.prerequisite = c2.course_no
WHERE c1.course_no >= 300 AND c1.course_no < 400 AND c1.prerequisite IS NOT NULL;

PRINT '13. List the course number and description for all 100-level courses taught by Charles Lowry. Arrange the list in order of course number.'
SELECT course.course_no, description
FROM course
	JOIN section ON course.course_no = section.course_no
	JOIN instructor ON section.instructor_id = instructor.instructor_id
WHERE course.course_no >= 100 
	AND course.course_no < 200 
	AND instructor.first_name = 'Charles'
	AND instructor.last_name = 'Lowry'
ORDER BY course.course_no;

PRINT '14. List the grade type code, description and number per section of all grades in course 144. Arrange by description.'
SELECT grade_type_code, description, number_per_section
FROM course
	JOIN section ON course.course_no = section.course_no
	JOIN grade_type_weight ON section.section_id = grade_type_weight.section_id
WHERE course.course_no = 144
ORDER BY description;

PRINT '15. Provide an alphabetic list of students (by the Students� Full Name � with last name first) who have an overall grade average of 93 or higher. The results should be sorted on Students� Full name (showing last name first).'
SELECT last_name + ', ' + first_name AS 'Student name', AVG(numeric_grade)
FROM student
	JOIN grade ON student.student_id = grade.student_id
WHERE numeric_grade IS NOT NULL
GROUP BY last_name, first_name
HAVING AVG(numeric_grade) >= 93 
ORDER BY 'Student name';

PRINT '16. List the names and address (including city and state) for all faculty who have taught less than 10 course sections.'
SELECT last_name + ', ' + first_name AS 'Instructor name', street_address, zipcode.zip, city, state
FROM instructor
	JOIN zipcode ON instructor.zip = zipcode.zip
	JOIN section ON instructor.instructor_id = section.instructor_id
GROUP BY first_name, last_name, street_address, zipcode.zip, city, state
HAVING COUNT(section_ID) < 10;

PRINT '17. List the course number and number of students enrolled in courses that do not have a prerequisite. Sort the list by number of students enrolled from highest to lowest.'
SELECT course.course_no, COUNT(student_id) AS 'Number of Students'
FROM course
	JOIN section ON course.course_no = section.course_no
	JOIN enrollment ON section.section_id = enrollment.section_id
WHERE course.prerequisite IS NULL
GROUP BY course.course_no
ORDER BY 'Number of Students' DESC;

PRINT '18. Provide an alphabetic list of students (first and last names) their enrollment date(s), and count of their enrollment(s) for that date, who are from Flushing, NY and who enrolled prior to February 7, 2007.'
SELECT last_name + ', ' + first_name AS 'Student name', enroll_date, COUNT(enroll_date) AS 'Number of Enrollments'
FROM student
	JOIN enrollment ON student.student_id = enrollment.student_id
	JOIN zipcode ON student.zip = zipcode.zip
WHERE enroll_date < '2007-02-07'
	AND state = 'NY'
	AND city = 'Flushing'
GROUP BY first_name, last_name, enroll_date
ORDER BY 'Student name';

PRINT '19. Provide a listing of course numbers, descriptions, and formatted (with $) costs, that include projects (Grade_type_code = "PJ") as a part of their grading criteria.'
SELECT DISTINCT course.course_no, description, '$' + CAST(cost AS VARCHAR(10)) AS 'Costs'
FROM course
	JOIN section ON course.course_no = section.course_no
	JOIN grade ON section.section_id = grade.section_id
WHERE grade_type_code = 'PJ';

PRINT '20. List the highest grade on the final exam (Grade_type_code = "FI") that was given to a student in course 145.'
SELECT MAX(numeric_grade) AS 'Highest grade'
FROM grade
	JOIN section ON grade.section_id = section.section_id
WHERE course_no = 145 AND grade_type_code = 'FI';

