BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 28 AND state_json ->> "$.intent.intent_id" = intentID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, getIntentForSocket(socketID, intentID));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END;