BEGIN
	DECLARE responce, gGroup JSON;
	DECLARE done TINYINT(1);
	DECLARE groupsCursor CURSOR FOR SELECT group_json FROM organization_groups WHERE organization_id = organizationID AND type_id = 6;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN groupsCursor;
		groupsLoop: LOOP
			FETCH groupsCursor INTO gGroup;
			IF done
				THEN LEAVE groupsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, gGroup);
			ITERATE groupsLoop;
		END LOOP;
	CLOSE groupsCursor;
	RETURN responce;
END;