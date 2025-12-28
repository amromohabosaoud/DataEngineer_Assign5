run the requirment file
pip install -r requirements.txt

1- Create Schema and Tables
psql -h localhost -p 5433 -U postgres -d dwh -f query_script/create_db.sql

2- Load Data by ETL
python3 etl_script/etl_script.py

3- Run dwh_querying.sql for EX:3 DWH querying
psql -h localhost -p 5433 -U postgres -d dwh -f query_script/dwh_querying.sql

4- Run customer_segmentation_analysis.sql for EX:4 DWH Querying Customer Segmentation and Analytics
psql -h localhost -p 5433 -U postgres -d dwh -f query_script/customer_segmentation_analysis.sql

5- Run article_portofolio_analytics.sql for EX:5 DWH Querying Article Portfolio Analytics
psql -h localhost -p 5433 -U postgres -d dwh -f query_script/article_portofolio_analytics.sql
