BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE userID, socketID, nowUserID, page, organizationID INT(11);
	DECLARE nowUserName VARCHAR(64);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON DEFAULT JSON_ARRAY();
	DECLARE nowDialogBotWork TINYINT(1);
	IF validOperation 
		THEN BEGIN
			SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
			SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT user_id, dialog_bot_work INTO nowUserID, nowDialogBotWork FROM dialogues WHERE dialog_id = dialogID;
			SELECT state_json ->> "$.page" INTO page FROM states WHERE socket_id = socketID;
			IF nowUserID IS NOT NULL
				THEN BEGIN
					IF nowUserID = userID
						THEN BEGIN
							UPDATE dialogues SET user_id = NULL, dialog_bot_work = 1 WHERE dialog_id = dialogID;
							SET nowUserID = NULL;
							SET nowDialogBotWork = 1;
						END;
					END IF;
				END;
				ELSE BEGIN 
					UPDATE dialogues SET user_id = userID WHERE dialog_id = dialogID;
					SET nowUserID = userID;
				END;
			END IF;
			CASE page
				WHEN 9 THEN BEGIN 
					CALL getDialog(socketID, dialogID);
					SELECT user_name INTO nowUserName FROM users WHERE user_id = nowUserID;
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "sendToSocket",
						"data", JSON_OBJECT(
							"socket", connectionID,
							"data", JSON_ARRAY(
								JSON_OBJECT(
									"action", "mergeDeep",
									"data", JSON_OBJECT(
										"dialog", JSON_OBJECT(
											"user_id", nowUserID,
											"user_name", nowUserName,
											"dialog_bot_work", nowDialogBotWork
										)
									)
								)
							)
						)
					));
				END;
				ELSE BEGIN END;
			END CASE;
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
	END IF;
	RETURN 0;
END