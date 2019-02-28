-- Find which length and width columns are most predictive of class
-- connect as ml_test

-- drop, create and load data table
@load_iris_data.sql

-- remove objects this script will create (clean up previous runs)
DROP TABLE iris_predict_result PURGE;
DROP TABLE iris_explain_result PURGE;
DROP TABLE iris_class_backup PURGE;

-- these commands are just formatting to make SQL*Plus output look nice
col attribute_name for a30
col attribute_subname for a30
set timing on echo on linesize 100 pagesize 50 serveroutput on

-- this call builds a table storing the "explanatory value" of each column (attribute)
BEGIN
  DBMS_PREDICTIVE_ANALYTICS.EXPLAIN (
    data_table_name => 'IRIS',
    explain_column_name => 'CLASS',
    result_table_name => 'IRIS_EXPLAIN_RESULT'
  );
END;
/

-- look at the results
SELECT * FROM iris_explain_result ORDER BY rank;

-- lets pretend that we don't know the "class" for a few of these rows, then see if Oracle can
-- come up with a model that "predicts" them correctly.

-- save off class data into a new table
CREATE TABLE iris_class_backup
AS 
SELECT observation_id, class
  FROM iris
/

-- take a random 10% of rows and make the class NULL.  We will later try to "predict" these.
UPDATE iris
   SET class = NULL
 WHERE rowid IN (SELECT r
                   FROM (SELECT rowid r
                           FROM iris
                          ORDER BY dbms_random.value  --"shuffle" the table
                        )
                  WHERE rownum < 16  -- now take the first 15 rows, which is 10% of table
                )
/

COMMIT
/

-- now build a model
DECLARE
  lv_accuracy_out NUMBER;
BEGIN
  DBMS_PREDICTIVE_ANALYTICS.PREDICT (
    accuracy            => lv_accuracy_out,
    data_table_name     => 'IRIS',                --where the data lives.   This can be a view with joins of app tables.
    case_id_column_name => 'OBSERVATION_ID',      --unique identifier of the input set
    target_column_name  => 'CLASS',               --column to predict (the target)
    result_table_name   => 'IRIS_PREDICT_RESULT'  --create this table to hold the results
  );

  DBMS_OUTPUT.PUT_LINE('Accuracy returned is ' || to_char(lv_accuracy_out));

END;
/

set echo off

-- check how the model performed at predicting the NULL class rows.
-- each time I run this, its done pretty well.
  WITH results
    AS (SELECT d.observation_id, d.class,
               b.class AS original_class,
               p.prediction AS predicted_class, p.probability
          FROM iris d,
               iris_class_backup b,
               iris_predict_result p
         WHERE d.observation_id = p.observation_id
           AND d.observation_id = b.observation_id
       )
SELECT group_label, group_count, 
       ROUND(100 * ratio_to_report(group_count) OVER (), 3) AS pct
  FROM (SELECT group_label, count(*) AS group_count
          FROM (SELECT CASE
                         WHEN class IS NOT NULL THEN 'training set'
                         WHEN class IS NULL AND predicted_class = original_class then 'test set - hit'
                         WHEN class IS NULL AND predicted_class <> original_class then 'test set - miss'
                       END group_label
                  FROM results
               )
         GROUP BY group_label
       )
 ORDER BY 2 DESC
/

