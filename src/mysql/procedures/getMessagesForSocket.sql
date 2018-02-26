BEGIN
	DECLARE messages, message JSON;
	DECLARE done TINYINT(1);
	DECLARE messagesCursor CURSOR FOR SELECT message_json FROM message_json WHERE dialog_id = dialogID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN messagesCursor;
		SET messages = JSON_ARRAY();
		messagesLoop: LOOP
			FETCH messagesCursor INTO message;
			IF done
				THEN LEAVE messagesLoop;
			END IF;
			SET messages = JSON_MERGE(messages, message);
			ITERATE messagesLoop;
		END LOOP;
	CLOSE messagesCursor;
	UPDATE states SET state_json = JSON_SET(state_json, "$.messages", messages) WHERE socket_id = socketID;
END