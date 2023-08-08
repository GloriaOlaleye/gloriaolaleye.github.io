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


Select *
from CyclisticTripdata

--The query returned a total of 5,829,084 rows

--The following are the data exploration processes carried out on the combined table
----I checked the length for the column ride_id and all the values are unique

select len(ride_id), count(ride_id)
from CyclisticTripdata
group by len(ride_id)

SELECT COUNT (DISTINCT ride_id)
from CyclisticTripdata

select *
from CyclisticTripdata
where len(ride_id) < 16

--This query returned 5,828,894 rows with 16 characters, 143 rows with 11 characters, 24 rows with 8 characters, 17 rows with 10 charaters and 6 rows with 9 characters
--All of the ride_id are distinct.

select rideable_type, count(rideable_type) as num_of_rides
from CyclisticTripdata
group by (rideable_type)

---there are 3 rideable types, electric_bikes, classic_bikes and docked_bikes.
--i checked for rows with ride time less than a minutes or grater than a day

SELECT *
FROM CyclisticTripdata
WHERE DATEDIFF(MINUTE, started_at,ended_at) <= 1 OR DATEDIFF(MINUTE, started_at,ended_at) >= 1440

--this returned 180,776 rows

select rideable_type, count(rideable_type) as num_of_rides
from CyclisticTripdata
group by (rideable_type)

SELECT rideable_type, count(*) as num_of_rides
FROM CyclisticTripdata
WHERE start_station_name IS NULL AND start_station_id IS NULL OR
    end_station_name IS NULL AND end_station_id IS NULL 
GROUP BY rideable_type

----i checked for rows which have start_station_name, start_station_id, end_station_name, end_station_id as NULL

SELECT *
FROM CyclisticTripdata
WHERE start_lat IS NULL OR
 start_lng IS NULL OR
 end_lat IS NULL OR
 end_lng IS NULL

----i checked for rows which have  end_lat, end_lng  as NULL and this returned 6,396 rows.
 --i checked the member_casual column as well


SELECT COUNT (DISTINCT member_casual)
from CyclisticTripdata

--this column contains 2 distinct values; casual and members
