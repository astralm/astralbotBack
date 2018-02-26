BEGIN
	DECLARE responce, bot JSON;
	DECLARE done TINYINT(1);
	DECLARE botsCursor CURSOR FOR SELECT bot_json FROM organization_bots WHERE organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN botsCursor;
		botsLoop: LOOP
			FETCH botsCursor INTO bot;
			IF done
				THEN LEAVE botsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, bot);
			ITERATE botsLoop;
		END LOOP;
	CLOSE botsCursor;
	RETURN responce;
END;