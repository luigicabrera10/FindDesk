-- FUNCTION: public.reservarresults(timestamp with time zone, integer, integer)

-- DROP FUNCTION IF EXISTS public.reservarresults(timestamp with time zone, integer, integer);

CREATE OR REPLACE FUNCTION public.reservarresults(
	initdate timestamp with time zone,
	duration integer,
	chairsnumber integer)
    RETURNS TABLE(code character varying, chairs integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	DECLARE finishDate TIMESTAMP;
    DECLARE tempRecord record;
    DECLARE bookingMinute TIMESTAMP;
    
BEGIN
    SELECT initDate INTO bookingMinute;
	SELECT initDate + make_interval(mins := duration) INTO finishDate;
    
    CREATE TEMP TABLE IF NOT EXISTS bookedChairsByMinute (
        bookedMinute TIMESTAMP NOT NULL,
    	code VARCHAR ( 13 ) NOT NULL,
        bookedChairs INT NOT NULL
    );

	DELETE FROM bookedChairsByMinute;
	
    for cnt in 0..duration-1 loop
		SELECT initDate + make_interval(mins := cnt) INTO bookingMinute;
        
        	FOR tempRecord IN
    
            SELECT 
            classrooms.code AS code, classrooms.chairs as chairs, 
            bookings.booking_date as booking_date, bookings.duration AS duration, bookings.booked_chairs as booked_chairs
            FROM classrooms JOIN bookings ON (classrooms.code = bookings.code)
            WHERE
            (bookings.booking_date <= initDate AND initDate < bookings.booking_date + make_interval(mins := bookings.duration) )
            OR
            (bookings.booking_date < finishDate AND finishDate <= bookings.booking_date + make_interval(mins := bookings.duration) )
            OR
            (initDate < bookings.booking_date AND bookings.booking_date + make_interval(mins := bookings.duration) < finishDate )

            LOOP
                
                if tempRecord.booking_date <= bookingMinute AND bookingMinute < tempRecord.booking_date + make_interval(mins := tempRecord.duration)
                then
                	INSERT INTO bookedChairsByMinute VALUES (bookingMinute, tempRecord.code, tempRecord.booked_chairs);
                end if;
                
            END LOOP;

   	end loop;
    
	
    RETURN QUERY
	SELECT classrooms.code, coalesce(classrooms.chairs - bookedChairsByClass.maxChairs, classrooms.chairs) FROM 
	classrooms LEFT JOIN
	(
      	SELECT sub.bookedCode AS finalCode, MAX(sub.s)::int AS maxChairs FROM
    	(
        	SELECT bookedChairsByMinute.bookedMinute AS bookedMinute, bookedChairsByMinute.code as bookedCode, SUM(bookedChairsByMinute.bookedChairs) AS s 
          	FROM bookedChairsByMinute
    		GROUP BY bookedMinute, bookedCode
        ) AS sub
      	GROUP BY finalCode
	) AS bookedChairsByClass
	ON (classrooms.code = bookedChairsByClass.finalCode)
	WHERE 
	coalesce(classrooms.chairs - bookedChairsByClass.maxChairs, classrooms.chairs) >= chairsNumber
    ORDER BY classrooms.code;
	
END; 
$BODY$;

ALTER FUNCTION public.reservarresults(timestamp with time zone, integer, integer)
    OWNER TO northsoldier;
