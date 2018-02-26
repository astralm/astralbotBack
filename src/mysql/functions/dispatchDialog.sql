BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE responce, dialog JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 9 AND state_json ->> "$.dialog.dialog_id" = dialogID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			CALL getDialog(socketID, dialogID);
			SELECT state_json ->> "$.dialog" INTO dialog FROM states WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"dialog", dialog
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