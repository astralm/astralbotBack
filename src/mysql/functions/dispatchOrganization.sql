BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, organization JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND (state_json ->> "$.page" = 20 OR state_json ->> "$.page" = 21) AND state_json ->> "$.organization.organization_id" = viewOrganizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			CALL getOrganizationForSocket(socketID, viewOrganizationID);
			SELECT state_json ->> "$.viewOrganization" INTO organization FROM states WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"viewOrganization", organization
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