# Wikipedia Data Analysis 

## Project Description

This project focused on using big data tools in order to answer given questions about datasets from Wikipedia. 

1. Which English wikipedia article got the most traffic on January 20, 2021?
2. What English wikipedia article has the largest fraction of its readers follow an internal link to another wikipedia article?
3. What series of wikipedia articles, starting with [Hotel California](https://en.wikipedia.org/wiki/Hotel_California), keeps the largest fraction of its readers clicking on internal links?  This is similar to (2), but you should continue the analysis past the first article.  There are multiple ways you can count this fraction, be careful to be clear about the method you find most appropriate.
4. Find an example of an English wikipedia article that is relatively more popular in the Americas than elsewhere.  There is no location data associated with the wikipedia pageviews data, but there are timestamps.  You'll need to make some assumptions about internet usage over the hours of the day.
5. Analyze how many users will see the average vandalized wikipedia page before the offending edit is reversed.
6. Run an analysis you find interesting on the wikipedia datasets we're using.

## Technologies Used
* Scala 2.13
* YARN
* HDFS
* Hive 
* Git + Github
## Features
* Hql that creates tables and loads data from an external.
* Queries that take the data and run specific analyses. 
## Getting Started
   
> Must have Yarn and HDFS daemons in order to run commands. 
> This project uses Linux and HDFS in order to store and communicate with the DBeaver Database to run queries. 

## Usage
> In order to run this program you will need to download Wikimedia analytics and place them inside of the respective folders to be read into the database. 

## Links for data used
- [Pageviews Filtered to Human Traffic](https://dumps.wikimedia.org/other/pageviews/readme.html)
- https://wikitech.wikimedia.org/wiki/Analytics/Data_Lake/Traffic/Pageviews
- [Page Revision and User History](https://dumps.wikimedia.org/other/mediawiki_history/readme.html)
- https://wikitech.wikimedia.org/wiki/Analytics/Data_Lake/Edits/Mediawiki_history_dumps#Technical_Documentation
- [Monthly Clickstream](https://dumps.wikimedia.org/other/clickstream/readme.html)
- https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream
