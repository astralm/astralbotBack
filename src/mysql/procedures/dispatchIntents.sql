BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command, groups JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 6 AND state_json ->> "$.bot.bot_id" = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SET groups = getIntentsGroups(organizationID);
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getIntentsForSocket(socketID, botID, command);
			SET responce = JSON_MERGE(responce, command);
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"intentsGroups", groups
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END;