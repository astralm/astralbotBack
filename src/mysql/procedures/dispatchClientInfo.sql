BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, client JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND (state_json ->> "$.page" = 11 OR state_json ->> "$.page" = 19) AND state_json ->> "$.client.client_id" = clientID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT client_json INTO client FROM clients_json WHERE organization_id = organizationID AND client_id = clientID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"client", client
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