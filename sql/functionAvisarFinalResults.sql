

CREATE OR REPLACE FUNCTION public.avisarfinalresults(
	initdate timestamp with time zone,
	limitdate timestamp with time zone,
	duration integer,
	minchairs integer)
	
    RETURNS TABLE(code character varying, chairsnumber integer, minTime timestamp without time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
    DECLARE tempRecord record;
	DECLARE actualCode VARCHAR ( 13 );
	DECLARE minstart TIMESTAMP;
	DECLARE actualChairs INT;
    DECLARE find BOOL;
BEGIN
    SELECT '0000' INTO actualCode;
	SELECT 0 INTO actualChairs;
	SELECT limitdate INTO minstart;
	SELECT False INTO find;
	
    CREATE TEMP TABLE IF NOT EXISTS results (
    	code VARCHAR ( 13 ) NOT NULL,
        bookedChairs INT NOT NULL,
		bookedMinute TIMESTAMP NOT NULL
    );

	DELETE FROM results;
	
    FOR tempRecord IN
	SELECT preresults.code AS code, preresults.chairs AS chairs, preresults.minTime AS minTime
	FROM avisarresults(initdate, limitdate, duration, minchairs) as preresults
	LOOP
		--RAISE NOTICE 'Code: %   --   DATE: %', tempRecord.code, tempRecord.minTime;
		
		IF getChairs(tempRecord.code) < minchairs THEN 
			SELECT True INTO find;
		END IF;
		
		/* Cambio de codigo + Nulos no se cruzan, directo a la respuesta*/
		IF tempRecord.minTime IS NULL THEN 
			
			--RAISE NOTICE 'IF (NULL)';
			
			IF actualCode != '0000' AND EXTRACT(epoch FROM (limitdate - minstart))/60 >= duration-1 AND NOT find THEN
				INSERT INTO results VALUES (actualcode, actualChairs, minstart); /* Anterior record*/
			END IF;
		
			SELECT '0000' INTO actualCode;
			SELECT False INTO find;
			SELECT getChairs(actualcode) INTO actualChairs;
			SELECT limitdate INTO minstart;
			IF getChairs(tempRecord.code) >= minchairs THEN
				INSERT INTO results VALUES (tempRecord.code, tempRecord.chairs, initdate);
			END IF;
		
		/* Cambio de codigo, se reinicia initdate al inicio o inicio + 1 */
		ELSIF actualCode != tempRecord.code THEN	
			
			--RAISE NOTICE 'ELSIF (CHANGE CODE)';
			/* Caso el ultimo cruce del anterior codigo de tiempo a la clase */
			IF EXTRACT(epoch FROM (limitdate - minstart))/60 >= duration AND NOT find THEN
				INSERT INTO results VALUES (actualcode, actualChairs, minstart); /* Anterior record*/
			END IF;
			
			/* Actualizar code */
			SELECT tempRecord.code INTO actualCode;
			SELECT tempRecord.chairs INTO actualChairs;
			SELECT False INTO find;
			
			/* Actualizar minstart */
			IF tempRecord.chairs >= minchairs THEN
				SELECT initdate INTO minstart;
			ELSE
				SELECT initdate + make_interval(mins := 1) INTO minstart;
				SELECT getChairs(actualcode) INTO actualChairs;
			END IF;
			
		ELSIF NOT find THEN/* Mismo codigo */
		
			--RAISE NOTICE 'ELSE (SAME CODE)';
			--RAISE NOTICE 'Mins: %', EXTRACT(epoch FROM (tempRecord.mintime - minstart))/60;
			--RAISE NOTICE 'Charis BEFORE: %', actualChairs;
			
			/* Se reinicia mintime al siguiente minuto si es necesario*/
			IF tempRecord.chairs < minchairs THEN
				SELECT tempRecord.mintime + make_interval(mins := 1) INTO minstart;
				SELECT getChairs(actualcode) INTO actualChairs;
			ELSIF actualchairs > tempRecord.chairs THEN
				SELECT tempRecord.chairs INTO actualChairs;
				--RAISE NOTICE 'Charis UPDATE: %', tempRecord.chairs;
			END IF;
			
			/* Se comprueba que hasta el nuevo cruce, haya pasado lo requerido para reservar*/
			IF EXTRACT(epoch FROM (tempRecord.mintime - minstart))/60 >= duration-1 THEN
				--RAISE NOTICE 'INSERTED!';
				INSERT INTO results VALUES (tempRecord.code, actualchairs, minstart);
				SELECT True INTO find;
			END IF;
			
		END IF;

	END LOOP;
	
	IF actualCode != '0000' AND EXTRACT(epoch FROM (limitdate - minstart))/60 >= duration-1 AND NOT find THEN
		INSERT INTO results VALUES (actualcode, actualChairs, minstart); /* Anterior record*/
	END IF;
	
    RETURN QUERY 
	SELECT * FROM results ORDER BY code;
	
END; 
$BODY$;

--SELECT * FROM avisarFinalResults(to_timestamp('2023-6-18 9:00', 'YYYY-MM-DD HH24:MI') , to_timestamp('2023-6-18 18:30', 'YYYY-MM-DD HH24:MI') , 61, 20);

SELECT * FROM avisarFinalResults(to_timestamp('2023-06-18 11:51', 'YYYY-MM-DD HH24:MI') , to_timestamp('2023-06-18 21:00', 'YYYY-MM-DD HH24:MI') , 15, 5);
 

