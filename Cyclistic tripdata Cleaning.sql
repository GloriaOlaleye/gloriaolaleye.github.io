--I combined the 12 months data below from April,2022 to March 2023. I used a temp table for this.


Drop Table If exists CyclisticTripdata
Create Table CyclisticTripdata
(
ride_id nvarchar(50),
rideable_type nvarchar(50),
started_at datetime2(7),
ended_at datetime2(7),
start_station_name nvarchar(100),
start_station_id nvarchar(50),
end_station_name nvarchar(100),
end_station_id nvarchar(50),
start_lat float,
start_lng float,
end_lat float,
end_lng float,
member_casual nvarchar(50),
)

insert into CyclisticTripdata
SELECT *
      from April2022
	  UNION ALL
	  SELECT *
      from May2022
	  UNION ALL
	  SELECT *
      from June2022
	  UNION ALL
	  SELECT *
      from July2022
	  UNION ALL
	  SELECT *
      from August2022
	  UNION ALL
	  SELECT *
      from Sept2022
	  UNION ALL
	  SELECT *
      from Oct2022
	  UNION ALL
	  SELECT *
      from Nov2022
	  UNION ALL
	  SELECT *
      from Dec2022
	  UNION ALL
	  SELECT *
      from Jan2023
	  UNION ALL
	  SELECT *
      from Feb2023
	  UNION ALL
	  SELECT *
      from March2023


--i removed rows with ride time less than a minutes or grater than a day

SELECT *
FROM CyclisticTripdata
WHERE DATEDIFF(MINUTE, started_at,ended_at) <= 1 OR DATEDIFF(MINUTE, started_at,ended_at) >= 1440

DELETE FROM CyclisticTripdata
WHERE DATEDIFF(MINUTE, started_at,ended_at) <= 1 OR DATEDIFF(MINUTE, started_at,ended_at) >= 1440

----i removed rows which have start_station_name, start_station_id, end_station_name, end_station_id as NULL

select rideable_type, count(rideable_type) as num_of_rides
from CyclisticTripdata
group by (rideable_type)


SELECT rideable_type, count(*) as num_of_rides
FROM CyclisticTripdata
WHERE start_station_name IS NULL AND start_station_id IS NULL OR
    end_station_name IS NULL AND end_station_id IS NULL
group by (rideable_type)

DELETE FROM CyclisticTripdata
WHERE start_station_name IS NULL AND start_station_id IS NULL OR
    end_station_name IS NULL AND end_station_id IS NULL


----i removed for rows which have  end_lat, end_lng  as NULL

SELECT *
FROM CyclisticTripdata
WHERE start_lat IS NULL OR
 start_lng IS NULL OR
 end_lat IS NULL OR
 end_lng IS NULL

DELETE FROM CyclisticTripdata
WHERE start_lat IS NULL OR
 start_lng IS NULL OR
 end_lat IS NULL OR
 end_lng IS NULL

--i trimmed off the leading spaces within the station names

UPDATE CyclisticTripdata
SET start_station_name = Trim(start_station_name),
    end_station_name = trim(end_station_name)

--i created a new temp table for the cleaned data with which the ananlysis will be carried out

Drop Table If exists CyclisticTripdataCleaned
Create Table CyclisticTripdataCleaned
(
ride_id nvarchar(50),
ride_type nvarchar(50),
started_at datetime2(7),
ended_at datetime2(7),
start_station_name nvarchar(100),
end_station_name nvarchar(100),
Day_of_week nvarchar(50),
Months nvarchar(50),
Year_value int,
ride_time_minutes int,
start_lat float,
start_lng float,
end_lat float,
end_lng float,
member_type nvarchar(50),
)
Insert into CyclisticTripdataCleaned
SELECT ride_id,
       rideable_type as ride_type,
       started_at,
       ended_at,
	   start_station_name,
	   end_station_name,
	   DATENAME(WEEKDAY, started_at) AS Day_of_week,
       DATENAME(MONTH, started_at) AS Month,
       YEAR(started_at) AS year_value,
	   DATEDIFF(MINUTE, started_at,ended_at) AS ride_time_minutes,
	   start_lat,
       start_lng,
       end_lat,
       end_lng,
	   member_casual as member_type
      FROM CyclisticTripdata

select *
from CyclisticTripdataCleaned

--removing duplicates


with rownumcte as(
select *,
       ROW_NUMBER() over (
	   partition by ride_type,
	                started_at,
                    ended_at,
                    start_station_name,
                    end_station_name,
                    start_lat,start_lng,  
                    end_lat,end_lng,
                    member_type
                    order by 
			 ride_id
		         ) row_num
from CyclisticTripdataCleaned
--order by ride_id, member_type
)
delete
from rownumcte
where row_num > 1

----After cleaning the data, we are left with 4,381,192 rows	

------------------ANALYSIS--------------------

--Ride types used by rider

SELECT ride_type, member_type, count(ride_id) AS Total_rides
FROM CyclisticTripdataCleaned
GROUP BY ride_type, member_type
ORDER BY member_type, Total_rides


---number of rides per month 

SELECT member_type, Months, count(ride_id) AS Total_rides
FROM CyclisticTripdataCleaned
GROUP BY member_type, Months
ORDER BY member_type

---number of rides per day of week

SELECT day_of_week, member_type, count(ride_id) AS Total_rides
FROM CyclisticTripdataCleaned
GROUP BY day_of_week, member_type
ORDER BY member_type

SELECT DATEPART(HOUR, started_at) hour_of_day,member_type, count(ride_id) as Total_rides
FROM CyclisticTripdataCleaned
GROUP BY started_at, member_type


SELECT member_type, DATEPART(HOUR, started_at) AS hour_of_day, COUNT(ride_id) AS total_trips
FROM CyclisticTripdataCleaned
GROUP BY DATEPART(HOUR, started_at), member_type
ORDER BY member_type

----Average ride length per month

SELECT months,
       member_type, 
      ROUND(AVG(ride_time_minutes), 0) AS Average_ride_time_minutes
FROM CyclisticTripdataCleaned
GROUP BY months, member_type
order by months

----Average ride length per day of week

SELECT Day_of_week,
       member_type, 
      ROUND(AVG(ride_time_minutes), 0) AS Average_ride_time_minutes
FROM CyclisticTripdataCleaned
GROUP BY Day_of_week, member_type
order by Day_of_week


----Average ride length per hour

SELECT  DATEPART(HOUR, started_at) AS hour_of_day,
       member_type, 
      ROUND(AVG(ride_time_minutes), 0) AS Average_ride_time_minutes
FROM CyclisticTripdataCleaned
GROUP BY  DATEPART(HOUR, started_at), member_type
order by  DATEPART(HOUR, started_at)


----Starting station for both member type
SELECT start_station_name, member_type,
       AVG(start_lat) AS start_lat,
      AVG(start_lng) AS start_lng,
      count(ride_id) AS num_of_rides
FROM CyclisticTripdataCleaned 
GROUP BY start_station_name, member_type



----Ending station for both member type


SELECT end_station_name, member_type,
       AVG(end_lat) AS end_lat,
      AVG(end_lng) AS end_lng,
      count(ride_id) AS num_of_rides
      FROM CyclisticTripdataCleaned 
      GROUP BY end_station_name, member_type




