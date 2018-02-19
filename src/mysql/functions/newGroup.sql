BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, organizationID, socketID, groupID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE responce JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            INSERT INTO groups (bot_id, user_id, group_name, type_id) VALUES (botID, userID, name, typeID);
            SELECT group_id INTO groupID FROM groups ORDER BY group_id DESC LIMIT 1;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 30) WHERE socket_id = socketID;
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
END