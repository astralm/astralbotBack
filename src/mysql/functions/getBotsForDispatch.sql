BEGIN
	DECLARE bots, bot JSON DEFAULT JSON_ARRAY();
	DECLARE done TINYINT(1);
	DECLARE botsCursor CURSOR FOR SELECT bot_json FROM bot_json WHERE dispatch_id = dispatchID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN botsCursor;
		botsLoop: LOOP
			FETCH botsCursor INTO bot;
			IF done
				THEN LEAVE botsLoop;
			END IF;
			SET bots = JSON_MERGE(bots, bot);
			ITERATE botsLoop;
		END LOOP;
	CLOSE botsCursor;
	RETURN bots;
END