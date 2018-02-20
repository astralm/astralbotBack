BEGIN
	DECLARE clientID, dialogID, answerID, organizationID, messageID INT(11);
	DECLARE dialogBotWork TINYINT(1);
	DECLARE answerText TEXT;
	DECLARE notificationText VARCHAR(512);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT client_id INTO clientID FROM client_bot WHERE client_telegram_chat = chat AND bot_id = botID ORDER BY client_id DESC LIMIT 1;
	SELECT organization_id INTO organizationID FROM bots WHERE bot_id = botID;
	SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues WHERE client_id = clientID AND bot_id = botID;
	IF clientID IS NULL
		THEN BEGIN
			INSERT INTO clients (client_name, client_username, organization_id, type_id, client_telegram_chat) values (clientName, clientUsername, organizationID, 5, chat);
			SELECT client_id INTO clientID FROM clients ORDER BY client_id DESC LIMIT 1;
			INSERT INTO dialogues (client_id, bot_id, dialog_active) values (clientID, botID, 1);
			SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues ORDER BY dialog_id DESC LIMIT 1;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "Procedure",
        "data", JSON_OBJECT(
          "query", "dispatchClients",
          "values", JSON_ARRAY(
              organizationID
          )
        )
			));
		END;
	END IF;
	INSERT INTO messages (message_text, dialog_id, message_client) VALUES (messageText, dialogID, 1);
	SELECT message_id INTO messageID FROM messages ORDER BY message_id DESC LIMIT 1;
	IF dialogBotWork
		THEN BEGIN
			SET answerID = getAnswerIdForMessage(messageID);
			IF answerID = 0
				THEN BEGIN 
					UPDATE messages SET message_error = 1 WHERE message_id = messageID;
					SET notificationText = CONCAT("Бот не смог подобрать ответ в сессии ", dialogID, ";
Ссылка на диалог: https://astralbot.ru/#/app/dialog:", dialogID, ";
Ссылка на клиента: https://astralbot.ru/#/app/client:", clientID, ";
Сообщение: 
", messageText);
					SET responce = JSON_MERGE(responce, sendNotification(organizationID, notificationText));
				END;
				ELSE BEGIN
					SELECT answer_text INTO answerText FROM answers WHERE answer_id = answerID;
					INSERT INTO messages (message_text, dialog_id) VALUES (answerText, dialogID);
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "sendToTelegram",
						"data", JSON_OBJECT(
							"bot_id", botID,
							"timeout", 7000,
							"chats", JSON_ARRAY(
								chat
							),
							"message", answerText
						)
					));
				END;
			END IF;
		END;
	END IF;
	SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
    "action", "Procedure",
    "data", JSON_OBJECT(
        "query", "dispatchSessions",
        "values", JSON_ARRAY(
            organizationID
        )
    )
  ));
	RETURN responce;
END;