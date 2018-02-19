BEGIN
	DECLARE responce JSON;
	DECLARE userID INT(11);
	DECLARE message VARCHAR(226);
	SET responce = JSON_ARRAY();
	SELECT user_id INTO userID FROM users WHERE user_telegram_chat = chat;
	IF userID IS NOT NULL
		THEN BEGIN
			UPDATE users SET user_telegram_notification = state WHERE user_telegram_chat = chat;
			IF state
				THEN SET message = "Оповещения включены";
				ELSE SET message = "Оповещения выключены";
			END IF;
		END;
		ELSE SET message = "Вы не авторизовали свой телеграм в системе astralbot. Для этого перейдите в раздел 'профиль' и скопируйте ключ авторизации для телеграм. После отправьте ключ в этот чат. Ссылка на ваш профиль https://astralbot.ru/#/app/profile";
	END IF;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendTelegramNotification",
		"data", JSON_OBJECT(
			"chats", JSON_ARRAY(
				chat
			),
			"message", message
		)
	));
	RETURN responce;
END