-- Read schema file
.read schema.sql

-- Add new student
INSERT INTO "students"("first_name", "last_name")
VALUES("Dmitrii", "Riabokon");

-- Insert balance for specific student
INSERT INTO "balances"("student_id", "total")
VALUES(
    (SELECT "id" FROM "students" WHERE "first_name" = 'Dmitrii' AND "last_name" = 'Riabokon'),
    500
);

-- Update balance
UPDATE "balances"
SET "total" = "total" + 100
WHERE "student_id" = (
    SELECT "id" FROM "students"
    WHERE "first_name" = 'Dmitrii' AND "last_name" = 'Riabokon'
);

-- View specific student balance
SELECT "total" FROM "balances"
WHERE "student_id" = (
    SELECT "id" FROM "students"
    WHERE "first_name" = 'Dmitrii' AND "last_name" = 'Riabokon'
);

-- View students and their balances using custom view
SELECT *
FROM "students_balances";

-- View transactions
SELECT * FROM "transactions";

-- Insert new teacher
INSERT INTO "teachers" ("first_name", "last_name")
VALUES("Matias", "Sandonato");


-- Insert new lesson into bookings table
INSERT INTO "bookings" ("student_id", "teacher_id", "price", "date")
VALUES (
    (SELECT "id" FROM "students" WHERE "first_name" = 'Dmitrii' AND "last_name" = 'Riabokon'),
    (SELECT "id" FROM "teachers" WHERE "first_name" = 'Matias' AND "last_name" = 'Sandonato'),
    15,
    "2024-01-01"
);

-- Use custom view to show bookings and names together
SELECT * FROM "bookings_with_names";

-- Delete lesson from bookings
DELETE FROM "bookings"
WHERE "student_id" = (SELECT "id" FROM "students" WHERE "first_name" = 'Dmitrii' AND "last_name" = 'Riabokon')
AND "teacher_id" = (SELECT "id" FROM "teachers" WHERE "first_name" = 'Matias' AND "last_name" = 'Sandonato')
AND "price" = 15
AND "date" = "2024-01-01";

-- Check transactions, balance and bookings
SELECT * FROM "transactions";

SELECT * FROM "balances";

SELECT * FROM "bookings";


/* OPTIONAL. Read mock data from csv files
.import --csv --skip 1 students.csv students

.import --csv --skip 1 teachers.csv teachers

.import --csv --skip 1 balances.csv balances
*/
