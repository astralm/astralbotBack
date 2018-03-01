BEGIN
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_connection_id FROM web_push_sockets WHERE organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO connectionID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "notification",
							"data", JSON_OBJECT(
								"page_id", pageID,
								"item_id", itemID,
								"body", body,
								"requireInteraction", requireInteraction,
								"title", title,
								"onclick", onclick
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