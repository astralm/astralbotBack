BEGIN
	DECLARE userID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
	IF userID IS NOT NULL
		THEN BEGIN
			UPDATE users SET user_telegram_chat = chat, user_telegram_username = username, user_telegram_notification = 1 WHERE user_id = userID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendTelegramNotification",
				"data", JSON_OBJECT(
					"chats", JSON_ARRAY(
						chat
					),
					"message", "Авторизация чата прошла успешно. Для того чтобы выключить оповещения отправьте команду /unbindme, а для их включения /bindme."
				)
			));
		END;
		ELSE BEGIN
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendTelegramNotification",
				"data", JSON_OBJECT(
					"chats", JSON_ARRAY(
						chat
					),
					"message", "Авторизация не произошла. Пользователь не найден. Попробуйте заново скопировать код авторизации из раздела 'профиль' - https://astralbot.ru/#/app/profile"
				)
			));
		END;
	END IF;
	RETURN responce;
END;