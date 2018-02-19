BEGIN
	DECLARE messagesArray, dialog, message JSON;
	DECLARE done TINYINT(1) DEFAULT 0;
	DECLARE connectionID VARCHAR(128) DEFAULT (SELECT socket_connection_id FROM sockets WHERE socket_id = socketID);
	DECLARE messagesCursor CURSOR FOR SELECT message_json FROM message_json WHERE dialog_id = dialogID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET messagesArray = JSON_ARRAY();
	OPEN messagesCursor;
		messagesLoop: LOOP
			FETCH messagesCursor INTO message;
			IF done = 1
				THEN LEAVE messagesLoop;
			END IF;
			SET messagesArray = JSON_MERGE(messagesArray, message);
			ITERATE messagesLoop;
		END LOOP;
	CLOSE messagesCursor;
	SELECT JSON_SET(dialog_json, "$.messages", messagesArray) INTO dialog FROM dialog_json WHERE dialog_id = dialogID;
	UPDATE states SET state_json = JSON_SET(state_json, "$.dialog", dialog) WHERE socket_id = socketID;
END