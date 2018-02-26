BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done, organizationWidgetsWork TINYINT(1);
	DECLARE responce, dispatches JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 22;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SELECT organization_widgets_work INTO organizationWidgetsWork FROM organizations WHERE organization_id = organizationID;
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.organization.organization_widgets_work", organizationWidgetsWork) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"organization", JSON_OBJECT(
									"organization_widgets_work", organizationWidgetsWork
								)
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