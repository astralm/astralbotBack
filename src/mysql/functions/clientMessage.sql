BEGIN
    DECLARE messageID, answerID, socketID, clientID, dialogID, organizationsID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE answerText TEXT;
    DECLARE dialogBotWork TINYINT(1);
    DECLARE messagesArray, responce JSON;
    SET responce = JSON_ARRAY();
    SELECT socket_id, socket_connection_id, organization_id INTO socketID, connectionID, organizationsID FROM sockets WHERE socket_hash = socketHash;
    SELECT client_id INTO clientID FROM states WHERE socket_id = socketID;
    SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues WHERE client_id = clientID;
    INSERT INTO messages (message_text, dialog_id, message_client) VALUES (messageText, dialogID, 1);
    SELECT message_id INTO messageID FROM messages ORDER BY message_id DESC LIMIT 1;
    IF dialogBotWork
        THEN BEGIN
            SET answerID = getAnswerIdForMessage(messageID);
            IF answerID = 0
                THEN BEGIN
                    UPDATE messages SET message_error = 1 WHERE message_id = messageID;
                END;
                ELSE BEGIN
                    SELECT answer_text INTO answerText FROM answers WHERE answer_id = answerID;
                    INSERT INTO messages (message_text, dialog_id) VALUES (answerText, dialogID);
                END;
            END IF;
        END;
    END IF;
    CALL getMessagesForSocket(socketID, dialogID);
    SELECT state_json ->> "$.messages" INTO messagesArray FROM states WHERE socket_id = socketID;
    SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messagesArray));
    SET responce = JSON_MERGE(responce, JSON_OBJECT(
        "action", "Procedure",
        "data", JSON_OBJECT(
            "query", "dispatchSessions",
            "values", JSON_ARRAY(
                organizationsID
            )
        )
    ));
    SET responce = JSON_MERGE(responce, dispatchDialog(organizationsID, dialogID));
    RETURN responce;
END