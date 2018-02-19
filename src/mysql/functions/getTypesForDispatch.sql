BEGIN
	DECLARE typeID INT(11);
	DECLARE types JSON DEFAULT JSON_ARRAY();
	DECLARE done TINYINT(1);
	DECLARE typesCursor CURSOR FOR SELECT type_id FROM dispatch_types WHERE dispatch_id = dispatchID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN typesCursor;
		typesLoop: LOOP
			FETCH typesCursor INTO typeID;
			IF done
				THEN LEAVE typesLoop;
			END IF;
			SET types = JSON_MERGE(types, CONCAT("",typeID));
			ITERATE typesLoop;
		END LOOP;
	CLOSE typesCursor;
	RETURN types;
END