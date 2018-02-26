BEGIN
	DECLARE userPassword VARCHAR(32);
	DECLARE connectionID VARCHAR(128);
	DECLARE message VARCHAR(52);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT user_password INTO userPassword FROM users WHERE user_email = userEmail;
	SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_hash = socketHash;
	IF userPassword IS NOT NULL
		THEN BEGIN
			SET message = "Сообщение с паролем будет направленно на вашу почту.";
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "Email",
				"data", JSON_OBJECT(
					"emails", JSON_ARRAY(
						userEmail
					),
					"subject", "Востановление пароля",
					"text", CONCAT("Ваш пароль: ", userPassword)
				)
			));
		END;
		ELSE SET message = "Пользователь с таким email не найден.";
	END IF;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendToSocket",
		"data", JSON_OBJECT(
			"socket", connectionID,
			"data", JSON_ARRAY(
				JSON_OBJECT(
					"action", "merge",
					"data", JSON_OBJECT(
						"forgotPasswordMessage", message
					)
				),
				JSON_OBJECT(
					"action", "changePage",
					"data", JSON_OBJECT(
						"page", "confirm-email"
					)
				)
			)
		)
	));
	RETURN responce;
END