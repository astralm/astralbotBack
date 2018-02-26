BEGIN
	DECLARE responce, bot JSON;
	DECLARE done TINYINT(1);
	DECLARE botsCursor CURSOR FOR SELECT bot_json FROM bots_json;
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
	RETURN JSON_ARRAY(JSON_OBJECT(
		"action", "connectBots",
		"data", JSON_OBJECT(
			"bots", responce
		)
	));
END;