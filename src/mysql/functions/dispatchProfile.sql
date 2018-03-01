BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, profile JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 13 AND state_json ->> "$.user.id" = userID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SELECT profile_json INTO profile FROM profile_json WHERE user_id = userID;
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.user", profile) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"user", profile
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END;