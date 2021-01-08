create view suspected_rides as
    select * from vehicle_location_histories
    where city = 'new york' AND
    long BETWEEN 40.5 and 40.6 AND
    lat between -74.997 and -74.9968 and
    "timestamp"::date = '2020-06-23'::date
    order by long
    
select distinct 
        r.vehicle_id, 
        u.name as "owner name",
        u.address, 
        v.status
from suspected_rides as sr
join rides as r on r.id = sr.ride_id
join vehicles as v on v.id = r.vehicle_id
join users as u on u.id = v.owner_id
order by u.name

----
create view suspected_rider_names as
    select distinct 
            split_part(u.name, ' ', 1) as "first_name",
            split_part(u.name, ' ', 2) as "last_name"
    from suspected_rides as sr
    join rides as r on r.id = sr.ride_id
    join users as u on u.id = r.rider_id

----
-- create extension dblink;

SELECT DISTINCT
        concat(t1.first_name, ' ', t1.last_name) as "employee",
        concat(u.first_name, ' ', u.last_name) as "rider"
FROM 
    dblink(
        'host=localhost user=postgres password=postgres dbname=movr_employees', 
        'SELECT first_name, last_name FROM employees;') 
AS t1(first_name Name, last_name name) 
join suspected_rider_names as u on t1.last_name = u.last_name
order by "rider"