BEGIN
	DECLARE telegramUsers, responce JSON;
	DECLARE chat VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE telegramUsersCursor CURSOR FOR SELECT user_telegram_chat FROM users WHERE user_telegram_notification = 1 AND organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET telegramUsers = JSON_ARRAY();
	SET responce = JSON_ARRAY();
	OPEN telegramUsersCursor;
		telegramUsersLoop: LOOP
			FETCH telegramUsersCursor INTO chat;
			IF done
				THEN LEAVE telegramUsersLoop;
			END IF;
			SET telegramUsers = JSON_MERGE(telegramUsers, chat);
			ITERATE telegramUsersLoop;
		END LOOP;
	CLOSE telegramUsersCursor;
	IF JSON_LENGTH(telegramUsers) > 0
		THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
			"action", "sendTelegramNotification",
			"data", JSON_OBJECT(
				"chats", telegramUsers,
				"message", messageText
			)
		));
	END IF;
	RETURN responce;
END;