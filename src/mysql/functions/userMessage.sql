BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE responce JSON DEFAULT JSON_ARRAY();
	DECLARE userID, socketID, messagesLength, clientID, clientSocketID, organizationID, botID INT(11);
	DECLARE chat VARCHAR(128);
	DECLARE messages, newMessage JSON;
	IF validOperation
		THEN BEGIN
			IF LENGTH(message) > 0
				THEN BEGIN 
					SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
					SELECT socket_id INTO socketID FROM sockets WHERE socket_hash = socketHash;
					INSERT INTO messages (dialog_id, user_id, message_text) VALUES (dialogID, userID, message);					
					CALL getDialog(socketID, dialogID);
					SELECT state_json ->> "$.dialog.messages" INTO messages FROM states WHERE socket_id = socketID;
					SET messagesLength = JSON_LENGTH(messages);
					SET newMessage = JSON_EXTRACT(messages, CONCAT("$[", messagesLength - 1, "]"));
					SELECT client_id, bot_id INTO clientID, botID FROM dialogues WHERE dialog_id = dialogID;
					SELECT socket_id INTO clientSocketID FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1 LIMIT 1;
					UPDATE dialogues SET dialog_error = 0 WHERE dialog_id = dialogID;
					SELECT client_telegram_chat INTO chat FROM clients WHERE client_id = clientID;
					CALL getMessagesForSocket(clientSocketID, dialogID);
					IF chat IS NOT NULL
						THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
							"action", "sendToTelegram",
							"data", JSON_OBJECT(
								"bot_id", botID,
								"chats", JSON_ARRAY(
									chat
								),
								"message", message
							)
						));
						ELSE SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messages, 0));
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
				END;
			END IF;
		END;
	END IF;
	RETURN responce;
END