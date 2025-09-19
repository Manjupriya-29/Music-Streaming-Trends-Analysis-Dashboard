--- CREATE DATABASE & TABLE
CREATE DATABASE music_streaming_analysis;
USE music_streaming_analysis;
CREATE TABLE streaming_data (
    User_ID VARCHAR(255),
    Age INT,
    Country VARCHAR(255),
    Streaming_Platform VARCHAR(255),
    Top_Genre VARCHAR(255),
    Minutes_Streamed_Per_Day INT,
    Number_of_Songs_Liked INT,
    Most_Played_Artist VARCHAR(255),
    Subscription_Type VARCHAR(255),
    Listening_Time VARCHAR(255),
    Discover_Weekly_Engagement FLOAT,
    Repeat_Song_Rate FLOAT);
    
-- 1. PLATFORM MARKET SHARE

SELECT Streaming_Platform, COUNT(User_ID) AS User_Count,
    ROUND((COUNT(User_ID) * 100.0 / (SELECT COUNT(*) FROM streaming_data)), 2) 
AS Market_Share_Percent
FROM streaming_data
GROUP BY Streaming_Platform
ORDER BY User_Count DESC;

-- 2. PREMIUM VS. FREE USERS

SELECT Streaming_Platform, Subscription_Type,
    COUNT(User_ID) AS User_Count,
    ROUND(
        (COUNT(User_ID) * 100.0 / SUM(COUNT(User_ID)) OVER (PARTITION BY                        Streaming_Platform)), 2) AS Percentage_Within_Platform
FROM streaming_data
GROUP BY Streaming_Platform, Subscription_Type
ORDER BY Streaming_Platform, Subscription_Type;

-- 3.	Premium vs. Free Engagement

SELECT Streaming_Platform, Subscription_Type,
    COUNT(User_ID) AS User_Count,
    ROUND(AVG(Minutes_Streamed_Per_Day), 2) AS Avg_Daily_Minutes
FROM streaming_data
GROUP BY Streaming_Platform, Subscription_Type
ORDER BY Streaming_Platform, Subscription_Type;

-- 4. TOP COUNTRIES PER PLATFORM

-- 4.	Top Countries per platform
WITH PlatformCountryRanks AS (
    SELECT 
        Streaming_Platform, Country,
        COUNT(User_ID) AS User_Count,
        ROW_NUMBER() OVER (
            PARTITION BY Streaming_Platform 
            ORDER BY COUNT(User_ID) DESC) AS Country_Rank
    FROM streaming_data
    GROUP BY Streaming_Platform, Country)
SELECT 
    Streaming_Platform, Country, User_Count, Country_Rank    
FROM PlatformCountryRanks
WHERE Country_Rank <= 3
ORDER BY Streaming_Platform, Country_Rank;

-- 5.AGE DISTRIBUTION:
SELECT
      CASE
              WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS Age_Group, COUNT(User_ID) AS User_Count
FROM streaming_data
GROUP BY Age_Group
ORDER BY 
    CASE
        WHEN Age_Group = 'Under 18' THEN 1
        WHEN Age_Group = '18-24' THEN 2
        WHEN Age_Group = '25-34' THEN 3
        WHEN Age_Group = '35-44' THEN 4
        WHEN Age_Group = '45-54' THEN 5
        ELSE 6
    END;

-- 6.	Platform Popularity by Age Group

SELECT 
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS Age_Group, Streaming_Platform,
    COUNT(User_ID) AS User_Count
FROM streaming_data
GROUP BY Age_Group, Streaming_Platform
ORDER BY Age_Group, User_Count DESC;

-- 7.	Average Listening Time by Age

SELECT 
    Age,
    ROUND(AVG(Minutes_Streamed_Per_Day), 2) AS Avg_Daily_Minutes
FROM streaming_data
GROUP BY Age
ORDER BY Age;

-- 8.	Preferred Listening Time of Day

SELECT 
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS Age_Group, Listening_Time,
    COUNT(User_ID) AS User_Count
FROM streaming_data
GROUP BY 
    Age_Group,
    Listening_Time
ORDER BY 
    Age_Group,
    User_Count DESC;

-- 9.	Top 10 Most Played Artists

SELECT Most_Played_Artist, COUNT(User_ID) AS Number_of_Fans
FROM streaming_data
GROUP BY Most_Played_Artist
ORDER BY Number_of_Fans DESC 
LIMIT 10;

-- 10.Top Genres by Country

WITH RankedGenres AS (
    SELECT Country, Top_Genre,
        COUNT(User_ID) AS Listener_Count,
        ROW_NUMBER() OVER (
            PARTITION BY Country 
            ORDER BY COUNT(User_ID) DESC) AS Genre_Rank
    FROM streaming_data
    GROUP BY Country, Top_Genre)
SELECT 
    Country, Top_Genre, Listener_Count
FROM RankedGenres
WHERE Genre_Rank = 1
ORDER BY Listener_Count DESC;

-- 11.Discovery Engagement by Platform

SELECT 
    Streaming_Platform,
    ROUND(AVG(Discover_Weekly_Engagement), 2) AS Avg_Discovery_Engagement
FROM streaming_data
GROUP BY Streaming_Platform
ORDER BY Avg_Discovery_Engagement DESC;

