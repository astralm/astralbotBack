BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID, socketID, botID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT bot_id INTO botID FROM groups WHERE group_id = groupID AND organization_id = organizationID;
			DELETE FROM groups WHERE group_id = groupID AND organization_id = organizationID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 30, "$.bot", JSON_OBJECT("bot_id", botID)) WHERE socket_id = socketID;
			SET responce = dispatchGroup(organizationID, groupID);
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
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
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "merge",
								"data", JSON_OBJECT(
									"page", 30
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/groups:", botID)
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