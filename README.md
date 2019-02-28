# Machine Learning in Oracle DB
In Oracle Enterprise Edition versions 12c and later, features in the "Advanced Analyitics" option will allow us to create and train machine learning models against existing data, and then use the the models to make predictions about new data using SQL.
I will create a proof of concept (POC) to show this in action.

Here are some links about the advanced Analytics option:
+ https://www.oracle.com/technetwork/database/options/advanced-analytics/overview/index.html
+ https://blogs.oracle.com/datamining/a-simple-guide-to-oracle%E2%80%99s-machine-learning-and-advanced-analytics

### How to use this POC
1. First create a schema to hold the test data and the model objects.  In real usage, this would be a microservice schema with read access on FO and CWS data.  In this case, we create a schema called ml_test.
2. Run predictive_analytics.sql as your new ml_test user.  This loads a well-known Machine Learning dataset into a new table in the schema.  Again, in real usage this would not be necessary as we'd be using existing FO and CWS data.  It then uses the dbms_predictive_analytics package to determine which columns have explanatory power over the classification.  After that, it removes the classification from some of the rows and tries the model building feature of the package.  Finally, we compare the predicted classifications to the classifications we saved off and then erased to see how the model performed.




