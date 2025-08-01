-- Advanced SQL Project -- Spotify Dataset
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--import the dataset after cleaning 
Select * from spotify;

--EDA --
SELECT count(*) from spotify;

SELECT count(DISTINCT artist) from spotify;

SELECT count(DISTINCT album) from spotify;

SELECT  DISTINCT album_type from spotify;

SELECT MAX(duration_min) from spotify;

SELECT Min(duration_min) from spotify;

select * from spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

-- ---------------------------- --
--DATA ANALYSIS -- EASY CATEGORY
-- ---------------------------- --

-- Q1 :Retrieve the names of all tracks that have more than 1 billion streams.--
Select track from spotify
where stream > 1000000000;

-- Q2:List all albums along with their respective artists.--
select album,artist 
from spotify;

-- Q3: Get the total number of comments for tracks where licensed = TRUE.--
Select Sum(comments) as total_comments
from spotify
where licensed = 'true';

--Count the total number of tracks by each artist.--
select artist,
 count(*) as total_no_track
 from spotify
 GROUP BY artist 
 ORDER BY 2 DESC

 ----------------------------------------------------------
 --MEDIAN LEVEL--
 ----------------------------------------------------------
-- Q1: Calculate the average danceability of tracks in each album.--
select album,
   avg(danceability) as danceability_avg
from spotify
GROUP BY 1
   ORDER BY 2 DESC
-- Q2: List all tracks along with their views and likes where official_video = TRUE--
select track,
sum(views) as total_views,
sum(likes) as total_likes
from spotify
where official_video = 'true'
GROUP BY 1
   ORDER BY 2 DESC

-- Q3: Retrieve the track names that have been streamed on Spotify more than YouTube.--
select * from
(select track,
 COALESCE (SUM(case when most_played_on ='Youtube' then stream end),0) as streamed_on_youtube,
 COALESCE(SUM(case when most_played_on ='Spotify' then stream end),0) as streamed_on_spotify
 from spotify
 GROUP BY 1 
 ) as t1
 where streamed_on_spotify > streamed_on_youtube
 AND streamed_on_youtube <>0

----------------------------------------------------------------------------------------
-- Advanced level--
----------------------------------------------------------------------------------------

-- Q1: Find the top 3 most-viewed tracks for each artist using window functions.--
--each artists and total view for each track
--track with highest view for each artist (we need top)
--dense rank
--Cte and filder rank <=3

with ranking_artist
AS
(SELECT 
    artist,
	track,
	SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM  ranking_artist
WHERE rank <=3

-- Q2: Write a query to find tracks where the liveness score is above the average.--
SELECT artist,
       track,
	   liveness
	   FROM spotify
WHERE liveness > (SELECT AVG (liveness) FROM spotify) 

--Q3: Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.--
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC

----------------------------------------------------------------------------------------
-- QUERY OPTIMIZATION--
----------------------------------------------------------------------------------------
SELECT
     artist,
	 track,
	 views
FROM spotify
WHERE artist ='Gorillaz'
     AND
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 15
