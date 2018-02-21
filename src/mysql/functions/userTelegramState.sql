BEGIN
	DECLARE responce JSON;
	DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_telegram_chat = chat);
	DECLARE page, socketID INT(11);
	DECLARE connectionID varchar(128);
	DECLARE message VARCHAR(226);
	DECLARE done TINYINT(1);
	DECLARE socketsCursor CURSOR FOR SELECT socket_id, socket_connection_id FROM user_sockets_connection WHERE user_id = userID AND socket_connection = 1;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	IF userID IS NOT NULL
		THEN BEGIN
			UPDATE users SET user_telegram_notification = state WHERE user_telegram_chat = chat;
			IF state
				THEN SET message = "Оповещения включены";
				ELSE SET message = "Оповещения выключены";
			END IF;
			OPEN socketsCursor;
				socketsLoop: LOOP
					FETCH socketsCursor INTO socketID, connectionID;
					IF done 
						THEN LEAVE socketsLoop;
					END IF;
					SELECT state_json ->> "$.page" INTO page FROM states WHERE socket_id = socketID;
					UPDATE states SET state_json = JSON_SET(state_json, "$.user.telegram_notification", state) WHERE socket_id = socketID;
					IF page = 13
						THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
							"action", "sendToSocket",
							"data", JSON_OBJECT(
								"socket", connectionID,
								"data", JSON_ARRAY(
									JSON_OBJECT(
										"action", "mergeDeep",
										"data", JSON_OBJECT(
											"user", JSON_OBJECT(
												"telegram_notification", state
											)
										)
									)
								)
							)
						));
					END IF;
					ITERATE socketsLoop;
				END LOOP;
			CLOSE socketsCursor;
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