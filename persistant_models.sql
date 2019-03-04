-- Create and use a persistant model
-- connect as ml_test

-- drop, create and load data table
@load_iris_data.sql

-- remove objects this script will create (clean up previous runs)
BEGIN
  dbms_data_mining.drop_model (
    model_name => 'PAUL_MODEL'
  );
END;
/

-- these commands are just formatting to make SQL*Plus output look nice
col object_name for a20
col name for a20
col subobject_name for a20
col target_attribute for a20
set timing on echo on linesize 110 pagesize 50 serveroutput on long 1000

-- The examples shown before used the dbms_predictive_analytics packge, which seems to 
-- create transient models.  To have a persistant model, it appears that one must
-- use the dbms_data_mining packge. 

-- In this example, we will create a classification model for the iris dataset
-- and then use it to make predictions on new data.

-- first make the persistant model using the IRIS table.
BEGIN
  dbms_data_mining.create_model (
    model_name => 'PAUL_MODEL',
    mining_function => 'CLASSIFICATION',
    data_table_name => 'IRIS',
    case_id_column_name => 'OBSERVATION_ID',
    target_column_name => 'CLASS'
  );
END;
/

-- we can see the model object and its attributes in the schema 
-- with queries against a few data dictionary views
SELECT object_name, subobject_name, object_type, status, TO_CHAR(created, 'YYYY-Mon-DD hh24:mi:ss') AS created_time
  FROM user_objects
 WHERE object_name like 'PAUL%'
/
SELECT name, function_name, algorithm_name, target_attribute 
  FROM dm_user_models
/

-- The end goal of all this data mining and machine learning is to predict 
-- attributes about new data given patterns in old data.  So how do we do that?
-- Here is one way - a simple SQL query against dual.
-- I think one would probably just want the prediction; but I've included the details 
-- and probability functions here as well.
SELECT PREDICTION(
         paul_model USING
         5 AS sepal_length,
         3 AS sepal_width,
         4 AS petal_length,
         .5 AS petal_width) AS predicted_class,
       --PREDICTION_COST(      -- cost function requires a cost matrix which tells 
         --paul_model USING    -- oracle the bias to use in order to avoid the most
         --5 AS sepal_length,  -- harmful kinds of misclassifications.  I'm not going into that now.
         --3 AS sepal_width,
         --4 AS petal_length,
         --.5 AS petal_width) AS prediction_cost,
       PREDICTION_DETAILS(
         paul_model USING
         5 AS sepal_length,
         3 AS sepal_width,
         4 AS petal_length,
         .5 AS petal_width) AS prediction_details,
       PREDICTION_PROBABILITY(
         paul_model USING
         5 AS sepal_length,
         3 AS sepal_width,
         4 AS petal_length,
         .5 AS petal_width) AS prediction_probability
  FROM dual
/

-- we can also bury this inside a function, which would perhaps be an
-- easier way for applications to call this
CREATE OR REPLACE FUNCTION iris_predict (
  fi_sepal_length NUMBER,
  fi_sepal_width  NUMBER,
  fi_petal_length NUMBER,
  fi_petal_width  NUMBER)
RETURN VARCHAR2
AS
  lv_output VARCHAR2(20);
BEGIN
  SELECT prediction(paul_model USING
    fi_sepal_length AS sepal_length,
    fi_sepal_width  AS sepal_width,
    fi_petal_length AS petal_length,
    fi_petal_width  AS petal_width) AS predicted_class
  INTO lv_output
  FROM dual;
  RETURN lv_output;
END iris_predict;
/

-- now use the function
SELECT iris_predict(5,2,1,1.1) FROM dual
/

