BEGIN
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	DECLARE done TINYINT(1);
	DECLARE socketsCursor CURSOR FOR SELECT socket_connection_id FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1;
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
							"action", action,
							"data", data
						)
					)
				)
			));
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END;