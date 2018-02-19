BEGIN
	DECLARE validOpertation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE socketID, organizationID, botID, groupID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, groups JSON;
	SET responce = JSON_ARRAY();
	SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
	IF validOpertation
		THEN BEGIN
			SELECT bot_id, group_id INTO botID, groupID FROM intents WHERE intent_id = intentID;
			DELETE FROM intents WHERE intent_id = intentID AND organization_id = organizationID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 6) WHERE socket_id = socketID;
			SET groups = getIntentsGroups(organizationID);
			SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, groupID));
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchIntents",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchGroups",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "merge",
								"data", JSON_OBJECT(
									"page", 6,
									"groups", groups,
									"bot", JSON_OBJECT(
										"bot_id", botID
									)
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/intents:", botID)
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END;