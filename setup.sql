-- Run this as SYS

-- First ensure you are in a 12c or later database
SELECT * FROM v$version;

-- Next create a user to hold our sample data and model objects
CREATE USER ml_test
IDENTIFIED BY test
DEFAULT TABLESPACE users
QUOTA 20m ON users
/

GRANT create session, create table, create view, create procedure
   TO ml_test
/

