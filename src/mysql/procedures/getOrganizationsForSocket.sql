BEGIN
	DECLARE done TINYINT(1);
	DECLARE organizations, organization JSON;
	DECLARE organizationsCursor CURSOR FOR SELECT organization_json FROM organization_json;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET organizations = JSON_ARRAY();
	OPEN organizationsCursor;
		organizationsLoop: LOOP
			FETCH organizationsCursor INTO organization;
			IF done
				THEN LEAVE organizationsLoop;
			END IF;
			SET organizations = JSON_MERGE(organizations, organization);
			ITERATE organizationsLoop;
		END LOOP;
	CLOSE organizationsCursor;
	UPDATE states SET state_json = JSON_SET(state_json, "$.organizations", organizations) WHERE socket_id = socketID;
END