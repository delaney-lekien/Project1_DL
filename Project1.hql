-- Project1 Script

CREATE DATABASE project1;
SHOW DATABASES;
USE project1;

-------Question 1--------------------

CREATE TABLE january20 (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' '
	TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/jan20data' INTO TABLE january20;

SELECT page_title, SUM(count_views) AS Views
FROM january20
WHERE domain_code LIKE 'en'
GROUP BY page_title
ORDER BY Views DESC
LIMIT 10; 

SELECT * FROM january20;

DROP TABLE january20;
--------------------------------------------------Question 2-----------------------------------------------------------

-- create table from data of december clickstreams
CREATE TABLE internaldata (
	prev STRING,
	curr STRING,
	type STRING,
	n INT )
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t';

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/decinternal' INTO TABLE internaldata;

SELECT * FROM internaldata;

-- filter by link
-- add all repeating prev titles together
CREATE TABLE addInternalData AS
SELECT prev, type, SUM(n) AS sumclickstream
FROM internaldata
WHERE type = 'link'
GROUP BY prev, type;

SELECT * FROM addInternalData;

-- Create table from sampling of December Human Traffic (page views)

CREATE TABLE decpageviews (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT
) 	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

SELECT * FROM decpageviews;

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/decpageviews' INTO TABLE decpageviews;

-- Make a big assumtion here since I cannot download and run all the hours and days for the pageview data for the month of December.
-- Multiply the of one days worth of pageview data by 31, for days in the month of December. 
-- This is making the assumption that each pageview would be see the same amount of times.
-- Very big assumption. 
CREATE TABLE combinedDecPageViews AS
SELECT page_title, SUM(count_views * 31)  AS combined_count_views
FROM decpageviews
WHERE domain_code LIKE 'en'
GROUP BY page_title;

SELECT * FROM combinedDecPageViews;

-- Combine two reduced tables where the page titles match
CREATE TABLE decinternal AS 
SELECT prev, sumclickstream, combined_count_views
FROM  addInternalData
INNER JOIN  combinedDecPageViews
ON prev = page_title
ORDER BY sumclickstream DESC;

SELECT * FROM decinternal;

-- With both tables combined divide the results of Clickstream data and Page views to create the percentage
-- Decided to filter for combined_count_views above 50,000 because the numbers if one page only got one view on December 1st were throwing everything off.
CREATE TABLE finalFraction AS
SELECT prev, sumclickstream, combined_count_views, ROUND(sumclickstream/combined_count_views, 2) AS percentage
FROM decinternal
GROUP BY prev, sumclickstream, combined_count_views 
HAVING combined_count_views > 100000
ORDER BY percentage DESC;

SELECT * FROM finalFraction;

-- For debugging
DROP TABLE addInternalData;
DROP TABLE combinedDecPageviews;
DROP TABLE finalFraction;
DROP TABLE decinternal;
DROP TABLE decpageviews;
DROP TABLE internaldata;

--------------------------------------Question 3---------------------------------------

-- Checking for where Hotel California starts

SELECT * FROM internaldata;

-- Creating a December clickstream data table with the starting point Hotel_California and the ending point curr value
CREATE TABLE addInternalDataHC AS
SELECT prev, curr, type, SUM(n) AS sumclickstream
FROM internaldata
WHERE type = 'link' AND prev LIKE 'Hotel_California%'
GROUP BY prev, curr, type;

SELECT * FROM addInternalDataHC;

-- Combining this December Clickstream - Hotel California verison with December page views table from Question 2

CREATE TABLE decinternalHC AS 
SELECT prev, curr, sumclickstream, CombinedDecPageViews.combined_count_views AS total_pageviews
FROM  addInternalDataHC
INNER JOIN  combinedDecPageViews
ON prev = page_title
ORDER BY sumclickstream DESC;

SELECT * FROM decinternalHC;

-- Defining the fraction with Hotel California addition

CREATE TABLE finalFractionHC AS
SELECT prev, curr, sumclickstream, total_pageviews, ROUND((sumclickstream/total_pageviews), 2) AS percentage
FROM decinternalHC
ORDER BY percentage DESC;

SELECT * FROM finalFractionHC;

-- Continuing the chain from Filter_bubble to find the next page in the series.

CREATE TABLE addInternalDataGF AS
SELECT prev, curr, type, SUM(n) AS sumclickstream
FROM internaldata
WHERE type = 'link' AND prev LIKE 'Filter_bubble'
GROUP BY prev, curr, type;

SELECT * FROM addInternalDataGF;

-- Combining next chain with December page view data

CREATE TABLE decinternalGF AS 
SELECT prev, curr, sumclickstream, CombinedDecPageViews.combined_count_views AS total_pageviews
FROM  addInternalDataGF
INNER JOIN  combinedDecPageViews
ON prev = page_title
ORDER BY sumclickstream DESC;

SELECT * FROM decinternalGF;

-- Getting fraction for chain starting with Filter_bubble 

CREATE TABLE finalFractionGF AS
SELECT prev, curr, sumclickstream, total_pageviews, ROUND((sumclickstream/total_pageviews), 2) AS percentage
FROM decinternalGF
ORDER BY percentage DESC;

SELECT * FROM finalFractionGF;

-- Combining the two fractions together to get the chain

CREATE TABLE finalseries AS 
SELECT finalFractionHC.prev AS first_article, finalFractionGF.prev AS second_article, finalFractionGF.curr, ROUND((finalFractionHC.percentage*finalFractionGF.percentage), 2) AS total_percent
FROM  finalFractionHC
INNER JOIN  finalFractionGF
ON finalFractionHC.curr = finalFractionGF.prev
ORDER BY total_percent DESC;

SELECT * FROM finalseries;


DROP TABLE finalseries;
DROP TABLE finalFractionGF;
DROP TABLE decinternalGF;
DROP TABLE addInternalDataGF;
DROP TABLE addInternalDataHC;
DROP TABLE finalfractionHC;
DROP TABLE decinternalHC;
--------------------------------------Question 4----------------------------------------------

-- Create table from data when American's are assumed to be asleep, 20:00 - 1:00 UTC, or 1am - 5am EST
CREATE TABLE asleep (
	domain_code_ut STRING,
	page_title_ut STRING,
	count_views_ut INT,
	total_response_size_ut INT )
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' '
	TBLPROPERTIES("skip.header.line.count"="1");

SELECT * FROM asleep;

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/asleephours' INTO TABLE asleep;

-- Create a table that gets rid of repeat page titles for alseep hours
-- and filters for only English wikipedia pages
CREATE TABLE asleepCombined AS
SELECT page_title_ut, SUM(count_views_ut) AS pageviews_asleep
FROM asleep
WHERE domain_code_ut LIKE 'en'  
GROUP BY page_title_ut;

SELECT * FROM asleepCombined;


-- Create table from data when American's are assumed to be awake, 14:00 - 18:00, or 7pm - 11pm EST
CREATE TABLE awake (
	domain_code_am STRING,
	page_title_am STRING,
	count_views_am INT,
	total_response_size_am INT )
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' '
	TBLPROPERTIES("skip.header.line.count"="1");

SELECT * FROM awake;

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/awakehours' INTO TABLE awake;

-- Create a table that gets rid of repeat page titles for awake hours
-- and filters for only English wikipedia pages
CREATE TABLE awakeCombined AS
SELECT page_title_am, SUM(count_views_am) AS pageviews_awake
FROM awake
WHERE domain_code_am LIKE 'en' 
GROUP BY page_title_am;

SELECT * FROM awakeCombined;


-- Inner Join tables to compare pageviews for awake and asleep adding in the difference to see popularity for awake
CREATE TABLE combinedHours AS 
SELECT page_title_am, pageviews_awake, pageviews_asleep, (pageviews_awake-pageviews_asleep) AS popularity
FROM  awakeCombined
INNER JOIN  asleepCombined
ON page_title_am = page_title_ut
ORDER BY popularity DESC;

SELECT * FROM combinedHours;

DROP TABLE asleepCombined;
DROP TABLE awakeCombined;
DROP TABLE combinedHours;
DROP TABLE asleep;
DROP TABLE awake;

-----------------------------Question 5------------------------------------

CREATE TABLE rawHistoryData (
	wiki_db STRING,
	event_entity STRING,
	event_type STRING,
	event_timestamp STRING,
	event_comment STRING,
	event_user_id BIGINT,
	event_user_text_historical STRING,
	event_user_text STRING,
	event_user_blocks_historical STRING,
	event_user_blocks STRING,
	event_user_groups_historical STRING,
	event_user_groups STRING,
	event_user_is_bot_by_historical STRING,
	event_user_is_bot_by STRING,
	event_user_is_created_by_self BOOLEAN,
	event_user_is_created_by_system BOOLEAN,	
	event_user_is_created_by_peer BOOLEAN,
	event_user_is_anonymous BOOLEAN,
	event_user_registration_timestamp STRING,
	event_user_creation_timestamp STRING,
	event_user_first_edit_timestamp STRING,
	event_user_revision_count BIGINT,
	event_user_seconds_since_previous_revision BIGINT,
	page_id BIGINT,
	page_title_historical STRING,
	page_title STRING,
	page_namespace_historical INT,
	page_namespace_is_content_historical BOOLEAN,
	page_namespace INT,
	page_namespace_is_content BOOLEAN,
	page_is_redirect BOOLEAN,
	page_is_deleted BOOLEAN,
	page_creation_timestamp STRING,
	page_first_edit_timestamp STRING,
	page_revision_count BIGINT,
	page_seconds_since_previous_revision BIGINT,
	user_id BIGINT,
	user_text_historical STRING,
	user_text STRING,
	user_blocks_historical STRING,
	user_blocks STRING,
	user_groups_historical STRING,
	user_groups STRING,
	user_is_bot_by_historical STRING,
	user_is_bot_by STRING,
	user_is_created_by_self BOOLEAN,
	user_is_created_by_system BOOLEAN,
	user_is_created_by_peer BOOLEAN,
	user_is_anonymous BOOLEAN,
	user_registration_timestamp STRING,
	user_creation_timestamp STRING,
	user_first_edit_timestamp STRING,
	revision_id BIGINT,
	revision_parent_id BIGINT,
	revision_minor_edit BOOLEAN,
	revision_deleted_parts STRING,
	revision_deleted_parts_are_suppressed BOOLEAN,
	revision_text_bytes BIGINT,
	revision_text_bytes_diff BIGINT,
	revision_text_sha1 STRING,
	revision_content_model STRING,
	revision_content_format STRING,
	revision_is_deleted_by_page_deletion BOOLEAN,
	revision_deleted_by_page_deletion_timestamp STRING,
	revision_is_identity_reverted BOOLEAN,
	revision_first_identity_reverting_revision_id BIGINT,
	revision_seconds_to_identity_revert BIGINT,
	revision_is_identity_revert BIGINT,
	revision_is_from_before_page_creation BOOLEAN,
	revision_tags STRING
	)   ROW FORMAT DELIMITED
		FIELDS TERMINATED BY '\t'
		TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/revision' INTO TABLE rawhistorydata;

SELECT * FROM rawhistorydata;

-- page views data 
CREATE TABLE pageviewsDec (
	domain_code STRING,
	page_title_views STRING,
	count_views INT,
	total_response_size INT )
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' '
	TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/home/delaneylekien/project1/decpageviews' INTO TABLE pageviewsDec;

SELECT * FROM pageviewsdec;

-- Multiply the of one days worth of pageview data by 31, for days in the month of December.
CREATE TABLE pageviewsdeccompiled AS
SELECT page_title_views, SUM(count_views * 31) AS total_views
FROM pageviewsdec
WHERE domain_code LIKE 'en'
GROUP BY page_title_views;

SELECT * FROM pageviewsdeccompiled;

-- This is how I verified the revisions_seconds_to_identity_revert column matched up to the Timestamps in the Event_Timestamp columnn

CREATE TABLE vandalizedData AS
SELECT event_entity, event_type, event_timestamp, event_user_id,  
page_title, revision_is_identity_reverted, total_views, ROUND((revision_seconds_to_identity_revert/60), 2) AS Average_Minutes
FROM rawhistorydata
INNER JOIN pageviewsdeccompiled
ON page_title = page_title_views
WHERE revision_is_identity_reverted = true;

SELECT * FROM vandalizedData;

-- Average the total minutes of pages staying vandalized. 
CREATE TABLE vandalizedDataClean AS
SELECT COUNT(page_title) AS total_pages, ROUND(AVG(average_minutes), 2) AS total_minutes, SUM(total_views) AS total_viewsdec
FROM vandalizedData;

SELECT * FROM vandalizedDataClean;

SELECT total_pages, total_viewsdec, total_minutes, ROUND(((total_viewsdec * total_minutes)/44640)/total_pages) AS Average_Vandalized_Views
FROM vandalizedDataClean;

-- Total pages is the total amount of unique pages that have been reverted in the month of December 
-- Total viewsDec is the total amount of views on potentially vandalized wikipages in the month of Decemeber 
-- Total Minutes is the average amount of minutes a vandalized webpage is up before being reverted 
-- Average Vandalized Views is the potential views a vandalized webpage could get before it is reverted 
-- Then we get presenetd with two fractions: minutes in a month/total views in december, and average minutes up for vandalized page/how many pageviews could happen
-- The 44640 number is the total minutes in a month with 31 days. 
-- I then decided to divide the missing amount of pagesviews for vandalized pages by the total_pages decpageviews had to get a very rough 
-- estimate of how many views it could see. 

-- Assumptions: This is assuming that everyone viewing pages in December are evenly looking vandalized pages


DROP TABLE pageviewsdeccompiled;
DROP TABLE vandalizedDataClean;
DROP TABLE vandalizedData;
DROP TABLE final_minutes;
DROP TABLE averageDecPageviews;
DROP TABLE pageviewsdec;
DROP TABLE rawhistorydata;
DROP TABLE final_minutes;
DROP TABLE rawhistorydata;

----------------------- Question 6 -----------------------

-- What are the number of unique users that have deleted a page in Wikipedia, and how many times did they do it
CREATE TABLE deleteunique AS
SELECT event_user_id, COUNT(event_user_id) AS times_deleted
FROM rawhistorydata
WHERE event_type = 'delete' 
GROUP BY event_user_id;

SELECT * FROM deleteunique;

SELECT event_user_id, page_title
FROM rawhistorydata 
WHERE event_type = 'delete' AND event_user_id = '290472';

DROP TABLE deleteunique;

