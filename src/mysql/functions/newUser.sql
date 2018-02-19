BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validRootOperation(userHash, socketHash);
  DECLARE userID, newUserID, socketID INT(11);
  DECLARE connectionID VARCHAR(128);
  DECLARE userPassword VARCHAR(32);
  DECLARE responce, users JSON;
  SET responce = JSON_ARRAY();
  IF validOperation = 1
  	THEN 
      	SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
      	SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
      	INSERT INTO users (user_name, user_email, user_creator, organization_id) VALUES (userName, userEmail, userID, organizationID);
        SELECT user_password INTO userPassword FROM users ORDER BY user_id DESC LIMIT 1;
      	UPDATE states SET state_json = JSON_SET(state_json, "$.page", 12) WHERE socket_id = socketID;
      	SET responce = JSON_MERGE(responce, JSON_ARRAY(
      		JSON_OBJECT(
      			"action", "Procedure",
      			"data", JSON_OBJECT(
      				"query", "dispatchUsers",
      				"values", JSON_ARRAY(
      					organizationID
      				)
      			)
      		),
      		JSON_OBJECT(
      			"action", "sendToSocket",
      			"data", JSON_OBJECT(
      				"socket", connectionID,
      				"data", JSON_ARRAY(
      					JSON_OBJECT(
      						"action", "changePage",
      						"data", JSON_OBJECT(
      							"page", "app/administrators"
      						)
      					)
      				)
      			)
      		),
          JSON_OBJECT(
            "action", "Email",
            "data", JSON_OBJECT(
              "emails", JSON_ARRAY(
                userEmail
              ),
              "subject", "Добро пожаловать в astralbot",
              "text", CONCAT("Вы были приглашены в систему https://astralbot.ru .

Ваш пароль для входа: ", userPassword, " . 

Пароль можно сменить в разделе 'Профиль'")
            )
          )
      	));
  END IF;
  RETURN responce;
END