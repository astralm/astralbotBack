BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, organizationID, intentID, socketID, conditionsLength, conditionsIterator, entitiesIterator, entitiesLength INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE conditionValue TEXT;
    DECLARE responce, entities JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            INSERT INTO intents (intent_name, bot_id, user_id, group_id) VALUES (name, botID, userID, groupID);
            SELECT intent_id INTO intentID FROM intents ORDER BY intent_id DESC LIMIT 1;
            INSERT INTO answers (user_id, intent_id, answer_text) VALUES (userID, intentID, answer);
            SET conditionsLength = JSON_LENGTH(conditions);
            SET conditionsIterator = 0;
            conditionsLoop: LOOP
                IF conditionsIterator >= conditionsLength 
                    THEN LEAVE conditionsLoop;
                END IF;
                SET entities = JSON_EXTRACT(conditions, CONCAT("$[", conditionsIterator, "]"));
                SET conditionsIterator = conditionsIterator + 1;
                SET entitiesLength = JSON_LENGTH(entities);
                SET entitiesIterator = 0;
                SET conditionValue = "";
                entitiesLoop: LOOP
                    IF entitiesIterator >= entitiesLength
                        THEN LEAVE entitiesLoop;
                    END IF;
                    SET conditionValue = CONCAT(conditionValue, ",", JSON_EXTRACT(entities, CONCAT("$[", entitiesIterator, "]")));
                    SET entitiesIterator = entitiesIterator + 1;
                    ITERATE entitiesLoop;
                END LOOP;
                SET conditionValue = RIGHT(conditionValue, LENGTH(conditionValue) - 1);
                INSERT INTO conditions (user_id, intent_id, condition_entities) VALUES (userID, intentID, conditionValue);
                ITERATE conditionsLoop;
            END LOOP;
            DELETE c1 FROM conditions c1, conditions c2 WHERE c1.condition_id > c2.condition_id AND c1.condition_entities = c2.condition_entities AND c1.intent_id = intentID AND c2.intent_id = intentID AND c1.organization_id = organizationID AND c2.organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 28, "$.intent", JSON_OBJECT("intent_id", intentID)) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, dispatchIntent(organizationID, intentID));
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
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "page", 28
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/intent:", intentID)
                                )
                            )
                        )
                    )
                )
            ));
            IF groupID IS NOT NULL
                THEN BEGIN 
                    SET responce = JSON_MERGE(responce, JSON_OBJECT(
                        "action", "Procedure",
                        "data", JSON_OBJECT(
                            "query", "dispatchGroups",
                            "values", JSON_ARRAY(
                                organizationID,
                                botID
                            )
                        )
                    ));
                    SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, groupID));
                END;
            END IF;
        END;
    END IF;
    RETURN responce;
END