BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID, socketID, botID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			IF LENGTH(name) > 0
				THEN BEGIN
					SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
					SELECT bot_id INTO botID FROM groups WHERE group_id = groupID;
					UPDATE groups SET group_name = name WHERE group_id = groupID;
					UPDATE states SET state_json = JSON_SET(state_json, "$.page", 32) WHERE socket_id = socketID;
					SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, groupID));
					SET responce = JSON_MERGE(responce, JSON_ARRAY(
						JSON_OBJECT(
							"action", "sendToSocket",
							"data", JSON_OBJECT(
								"socket", connectionID,
								"data", JSON_ARRAY(
									JSON_OBJECT(
										"action", "merge",
										"data", JSON_OBJECT(
											"page", 32
										)
									),
									JSON_OBJECT(
										"action", "changePage",
										"data", JSON_OBJECT(
											"page", CONCAT("app/group:", groupID)
										)
									)
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
							"action", "Procedure",
							"data", JSON_OBJECT(
								"query", "dispatchIntents",
								"values", JSON_ARRAY(
									organizationID,
									botID
								)
							)
						)
					));
				END;
			END IF;
		END;
	END IF;
	RETURN responce;
END;