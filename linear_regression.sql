-- First make up some data pairs.  We'll use a linear equation and add some noise.
-- The linear regression functions _should_ be able to figure out what linear equation we used!
DROP TABLE points PURGE
/
CREATE TABLE points
  (point_id NUMBER NOT NULL,
   x        NUMBER,
   y        NUMBER)
/
INSERT INTO points
SELECT rownum as point_id,
       ROUND((3 * mod(rownum, 50)) + 60 + 58 * DBMS_RANDOM.value) as X,
       ROUND((4 * mod(rownum, 50)) + 100 + 110 * DBMS_RANDOM.value) as Y
  FROM all_objects
 WHERE rownum < 101
/
COMMIT
/

-- export data for graphing in Excel
--set lines 110 pages 300 trimspool on feedback off heading off
--spool data.csv
--select 'x,y' as data from dual
--union all
--select to_char(x) || ',' || to_char(y) as data from points
--/
--spool off

SET timing on heading on
-- now that we have some pretty linear data, see if we can find the equation of the best-fit line.
-- it took me a long time to realize that the first argument is meant to be the dependent variable (the y)
-- and the second argument is meant to be the dependent variable (the x).  I had them reversed and my numbers
-- were linear; but did NOT match!!
SELECT regr_intercept(y,x) AS y_intercept,
       regr_slope(y,x)     AS slope,
       regr_count(y,x)     AS points_used,
       regr_r2(y,x)        AS r_squared
  FROM points
/

-- when i imported the data to excel, I also created a second series using the slope and y intercept
-- found above.  When I plotted that line, it looked great!  Also, the numbers exactly matched the 
-- best-fit line created by Excel.

