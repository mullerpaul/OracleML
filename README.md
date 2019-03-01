# Machine Learning in Oracle DB
In Oracle Enterprise Edition versions 12c and later, features in the "Advanced Analyitics" option will allow us to create and train machine learning models against existing data, and then use the the models to make predictions about new data using SQL.
I will create a proof of concept (POC) to show this in action.

Here are some links about the advanced Analytics option:
+ https://www.oracle.com/technetwork/database/options/advanced-analytics/overview/index.html
+ https://blogs.oracle.com/datamining/a-simple-guide-to-oracle%E2%80%99s-machine-learning-and-advanced-analytics

### How to use this POC
1. First run setup.sql as a DBA privileged user to create a schema which will hold the test data and the model objects.  In real usage, this would be a microservice schema with read access on FO and CWS data. The script will create a schema called ml_test. Note that there is one interesting system privilege this user needs in order to create ML models - the CREATE MINING MODEL priv.  This is granted in the script.
2. Run predictive_analytics.sql as your new ml_test user.  This loads a well-known Machine Learning dataset into a new table in the schema.  Again, in real usage this would not be necessary as we'd be using existing FO and CWS data.  It then uses the dbms_predictive_analytics package to determine which columns have explanatory power over the classification.  After that, it removes the classification from some of the rows and tries the model building feature of the package.  Finally, we compare the predicted classifications to the classifications we saved off and then erased to see how the model performed.
3. The model created in step 2 was a transient model - only existing for the duration of the call.  In our case, we probably want to create a model every so often (every month?) and then that model to predict values for incoming data during that month.  To do this, we need a persistant model - and we create those with the dbms_data_mining package.  Run persistant_models.sql to see a model being created and then used to predict the classification for new data. The best part is that we can use SQL or PL/SQL to see what the model predicts for a given set of new data!


