# Portfolio Project 1: Nashville Housing
### This is my first self-directed portfolio project, where I took a raw dataset containing Nashville housing data found online and conducted an analysis on it with SQL, a bit of Python and Tableau!
#### Questions I sought to answer with my analysis:
#### 1. Which month had the highest average home sale value?
#### 2. Which month of the year are most homes typically sold in?
#### 3. What percentage of homes sold had 3 bedrooms? 4 bedrooms?
#### 4. What year were most of the homes sold built in?
#### 5. Is there a relationship between the year built and sale price? Between land use type and sale price?
#### I set up a MySQL Server on my personal computer, and since there is a known error with uploading CSVs with certain collation types to the MySQL server on Macbook, I used Numbers on my Macbook to convert the csv to a format I was able to import into the server successfully. All sql database functions performed in the "data cleaning and queries" were performed using the MySQL extension in VS Code.
#### I attempted to pull in zip code and latitude/longitude information using geocoder modules in Python to visualize home sales on a map, but opted not to as doing so for the ~26,000 row dataset would take over 3.5 hours. In the future I will select/scrape data that contains this information ahead of time.
#### Since Tableau Public doesn't allow direct connections to servers, I exported each of my queries as CSVs. I then used that data to build and deploy a Tableau dashboard to visualize the data and answer the above questions.
