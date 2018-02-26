BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE socketID, organizationID INT(11);
	DECLARE nName VARCHAR(64);
	DECLARE kKey, connectionID VARCHAR(128);
	DECLARE responce, bot JSON;
	SET responce = JSON_ARRAY();
	SELECT socket_id, socket_connection_id, organization_id INTO socketID, connectionID, organizationID FROM sockets WHERE socket_hash = socketHash;
	IF validOperation
		THEN BEGIN
			SELECT bot_name, bot_telegram_key INTO nName, kKey FROM bots WHERE bot_id = botID;
			IF botName IS NOT NULL
				THEN SET nName = botName;
			END IF;
			IF botKey IS NOT NULL AND IF(kKey IS NULL, 1, botKey != kKey)
				THEN BEGIN 
					SET kKey = botKey;
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "connectBots",
						"data", JSON_OBJECT(
							"bots", JSON_ARRAY(
								JSON_OBJECT(
									"bot_id", botID,
									"bot_telegram_key", kKey
								)
							)
						)
					));
				END;
				ELSEIF botKey IS NULL THEN BEGIN 
					SET kKey = NULL;
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "deleteBots",
						"data", JSON_OBJECT(
							"bots", JSON_ARRAY(
								botID
							)
						)
					));
				END;
			END IF;
			UPDATE bots SET bot_name = nName, bot_telegram_key = kKey WHERE bot_id = botID;
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchSessions",
						"values", JSON_ARRAY(
							organizationID
						)
					)
				),
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchBots",
						"values", JSON_ARRAY(
							organizationID
						)
					)
				)
			));
			SET responce = JSON_MERGE(responce, dispatchBot(organizationID, botID));
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"page", 24
							)
						),
						JSON_OBJECT(
							"action", "changePage",
							"data", JSON_OBJECT(
								"page", CONCAT("app/bot:", botID)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END