# DataEngineeringCaseStudy_20240209
Case study for data engineering roles. Azure, SQL, data modelling, MDM


Imagine it is early December 2023 and you have received a request from your manager, that the store managers need a report / dataset which will enable them to answer the following questions: a) Assuming similar sales patterns to last year, how many of each product items do I need to keep on stock for the 2023 Christmas holiday period (Fri Dec 15th 2023 to Sun Jan 7th 2024)? b) As the Christmas holiday period progresses, on a daily basis, how will I be able to identify which products I have over- or under- stocked for?

Datasets: 3 datasets:
1.	Large Transaction Data (Millions of records), refreshed Hourly. Source: On-premise SFTP folder
2.	Product Data Source: Azure Synapse Analytics DB
3.	Calendar Data Source: Excel file provided by the Business

There are five questions for this case study:
1. How would you bring these datasets together into a data warehouse? Feel free to put together a diagram flow to illustrate your thinking.
2. How would you clean the data and make it ready for analysis?
3. How would you merge and summarize the data to help answer the business question? You are encouraged to write out a simple query in SQL, R, Python or any other type of code or language. 4. How would you optimize this database query for better performance? How would you troubleshoot performance issues?
5. What considerations would you put in place to ensure data accuracy and clear data versioning?
