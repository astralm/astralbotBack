BEGIN
    DECLARE dispatchText TEXT DEFAULT (SELECT dispatch_text FROM dispatches WHERE dispatch_id = dispatchID);
    DECLARE done INT(1) DEFAULT 0;
    DECLARE dialogID, dialogType, socketID, clientID, socketsIterator, socketsCount, botID, organizationID INT(11);
    DECLARE chat VARCHAR(128);
    DECLARE responce, messages JSON;
    DECLARE dispatchDialoguesCursor CURSOR FOR SELECT dialog_id FROM dispatch_dialogues WHERE dispatch_id = dispatchID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SET responce = JSON_ARRAY();
    OPEN dispatchDialoguesCursor;
    	dialoguesLoop: LOOP
        	FETCH dispatchDialoguesCursor INTO dialogID;
            IF done = 1 
            	THEN LEAVE dialoguesLoop;
            END IF;
            INSERT INTO messages (dialog_id, message_text, dispatch_id) VALUES (dialogID, dispatchText, dispatchID);
            SELECT type_id, client_id, organization_id INTO dialogType, clientID, organizationID FROM dialogues WHERE dialog_id = dialogID;
            IF dialogType = 1
                THEN BEGIN
                    SET socketsIterator = 0;
                    SELECT COUNT(*) INTO socketsCount FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1;
                    socketsLoop: LOOP
                        IF socketsIterator = socketsCount 
                            THEN LEAVE socketsLoop;
                        END IF;
                        SELECT socket_id INTO socketID FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1 LIMIT 1 OFFSET socketsIterator;
                        CALL getMessagesForSocket(socketID, dialogID);
                        SET socketsIterator = socketsIterator + 1;
                        ITERATE socketsLoop;
                    END LOOP;
                    SELECT state_json ->> "$.messages" INTO messages FROM states WHERE socket_id = socketID;
                    IF done
                        THEN SET done = 0;
                    END IF;
                    SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messages));
                END;
                ELSEIF dialogType = 5 THEN BEGIN
                    SELECT bot_id INTO botID FROM dialogues WHERE dialog_id = dialogID;
                    SELECT client_telegram_chat INTO chat FROM clients WHERE client_id = clientID;
                    SET responce = JSON_MERGE(responce, JSON_OBJECT(
                        "action", "sendToTelegram",
                        "data", JSON_OBJECT(
                            "bot_id", botID,
                            "chats", JSON_ARRAY(
                                chat
                            ),
                            "message", dispatchText
                        )
                    ));
                END;
            END IF;
            SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
            ITERATE dialoguesLoop;
        END LOOP;
    CLOSE dispatchDialoguesCursor;
    RETURN responce;
END