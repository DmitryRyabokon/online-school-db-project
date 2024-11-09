-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- TABLES

-- Represent students
CREATE TABLE "students" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Represent teachers
CREATE TABLE "teachers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Represent balance of each student
CREATE TABLE "balances" (
    "id" INTEGER,
    "student_id" INTEGER,
    "total" DECIMAL NOT NULL CHECK ("total" >= 0),
    PRIMARY KEY("id"),
    FOREIGN KEY("student_id") REFERENCES "students"("id")
);

-- Represent bookings of the lessons
CREATE TABLE "bookings" (
    "id" INTEGER,
    "student_id" INTEGER,
    "teacher_id" INTEGER,
    "price" DECIMAL NOT NULL,
    "date" DATETIME NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("student_id") REFERENCES "students"("id"),
    FOREIGN KEY("teacher_id") REFERENCES "teachers"("id")
);

-- Represent the transaction of lessons bookings
CREATE TABLE "transactions" (
    "id" INTEGER,
    "student_id" INTEGER,
    "amount" DECIMAL NOT NULL,
    "type" TEXT NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("student_id") REFERENCES "students"("id")
);

--TRIGGERS

-- Create trigger on bookings table to insert rows into transactions table automatically
CREATE TRIGGER "after_booking_insert_transaction_update_balances"
AFTER INSERT ON "bookings"
FOR EACH ROW
BEGIN
    INSERT INTO "transactions"("student_id", "amount", "type", "timestamp")
    VALUES(NEW."student_id", -NEW.price, 'debit', CURRENT_TIMESTAMP);

    UPDATE "balances"
    SET "total" = "total" - NEW."price"
    WHERE "student_id" = NEW."student_id";
END;

-- Create triggers on balaces to insert transactions when students adds money to their balance
CREATE TRIGGER "after_updating_balances_insert_transaction"
AFTER UPDATE ON "balances"
FOR EACH ROW
WHEN NEW."total" > OLD."total"
    AND (
        SELECT COUNT(*)
        FROM "transactions"
        WHERE "student_id" = NEW."student_id"
        AND "amount" = (NEW."total" - OLD."total")
        AND "timestamp" > datetime('now', '-1 second')
    ) = 0
BEGIN
    INSERT INTO "transactions"("student_id", "amount", "type", "timestamp")
    VALUES(
        NEW."student_id",
        NEW."total" - OLD."total",
        'credit',
        CURRENT_TIMESTAMP
    );
END;

-- Trigger to automate transactions when new ballance was inserted
CREATE TRIGGER "after_inserting_balances_insert_transaction"
AFTER INSERT ON "balances"
FOR EACH ROW
BEGIN
    INSERT INTO "transactions"("student_id", "amount", "type", "timestamp")
    VALUES(
        NEW."student_id",
        NEW."total",
        'credit',
        CURRENT_TIMESTAMP
    );
END;

CREATE TRIGGER "after_delete_on_bookings_update_balances_insert_transactions"
AFTER DELETE ON "bookings"
FOR EACH ROW
BEGIN
    INSERT INTO "transactions"("student_id", "amount", "type", "timestamp")
    VALUES(OLD."student_id", OLD.price, 'credit', CURRENT_TIMESTAMP);

    UPDATE "balances"
    SET "total" = "total" + OLD."price"
    WHERE "student_id" = OLD."student_id";
END;

-- VIEWS

-- Create view to retrieve students and their balances
CREATE VIEW "students_balances" AS
SELECT "students"."id" AS "student_id", "students"."first_name", "students"."last_name", "balances"."total"
FROM "students"
JOIN "balances" ON "students"."id" = "balances"."student_id";

-- Create view to show students' and teachers' names with bookings
CREATE VIEW "bookings_with_names" AS
SELECT
    "students"."first_name" AS "student_first_name",
    "students"."last_name" AS "student_last_name",
    "teachers"."first_name" AS "teacher_first_name",
    "teachers"."last_name" AS "teacher_last_name",
    "bookings"."price" AS "lesson price",
    "bookings"."date" AS "lesson_date"
FROM "students"
JOIN "bookings" ON "bookings"."student_id" = "students"."id"
JOIN "teachers" ON "teachers"."id" = "bookings"."teacher_id";

-- INDEXES

-- Create indexes to speed common searches
CREATE INDEX "student_name_search" ON "students" ("first_name", "last_name");
CREATE INDEX "student_balance_search" ON "balances" ("total");
