CREATE OR REPLACE FUNCTION public.getChairs(classcode VARCHAR ( 13 ))
    RETURNS INT
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE

	AS $BODY$
		DECLARE res INT;
	BEGIN
		SELECT classrooms.chairs FROM classrooms WHERE classrooms.code = classcode LIMIT 1 INTO res;
	RETURN res;
END; 
$BODY$;

SELECT getChairs('N113');