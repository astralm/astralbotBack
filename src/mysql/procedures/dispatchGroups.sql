BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 30 AND state_json ->> "$.bot.bot_id" = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getGroupsForSocket(socketID, botID, command);
			SET responce = JSON_MERGE(responce, command);
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END;