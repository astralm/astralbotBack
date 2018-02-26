BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, organizationID, socketID, conditionsLength, conditionsIterator, entitiesIterator, entitiesLength, lastGroupID, conditionsCount, botID, oldGroupID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE conditionValue, lastAnswer TEXT;
    DECLARE lastName VARCHAR(64);
    DECLARE responce, entities JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                intent_json ->> "$.intent_name",
                intent_json ->> "$.answer_text",
                group_id,
                bot_id
            INTO
                lastName,
                lastAnswer,
                lastGroupID,
                botID
            FROM intent_json WHERE intent_id = intentID;
            IF name IS NOT NULL AND name != lastName
                THEN SET lastName = name;
            END IF;
            IF answer IS NOT NULL AND answer != lastAnswer
                THEN SET lastAnswer = answer;
            END IF;
            SET oldGroupID = lastGroupID;
            SET lastGroupID = groupID;
            UPDATE intents SET intent_name = lastName, group_id = lastGroupID WHERE intent_id = intentID AND organization_id = organizationID;
            IF oldGroupID IS NOT NULL
                THEN SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, oldGroupID));
            END IF;
            IF lastGroupID IS NOT NULL 
                THEN SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, lastGroupID));
            END IF;
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
            UPDATE answers SET answer_text = lastAnswer WHERE intent_id = intentID AND organization_id = organizationID;
            DELETE FROM conditions WHERE intent_id = intentID AND organization_id = organizationID;
            SET conditionsLength = JSON_LENGTH(conditions);
            SET conditionsIterator = 0;
            conditionsLoop: LOOP
                IF conditionsIterator >= conditionsLength 
                    THEN LEAVE conditionsLoop;
                END IF;
                SET entities = JSON_EXTRACT(conditions, CONCAT("$[", conditionsIterator, "]"));
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
                INSERT INTO conditions (intent_id, user_id, condition_entities) VALUES (intentID, userID, conditionValue);
                SET conditionsIterator = conditionsIterator + 1;
                ITERATE conditionsLoop;
            END LOOP;
            DELETE c1 FROM conditions c1, conditions c2 WHERE c1.condition_id > c2.condition_id AND c1.condition_entities = c2.condition_entities AND c1.intent_id = intentID AND c2.intent_id = intentID AND c1.organization_id = organizationID AND c2.organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 28) WHERE socket_id = socketID;
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
        END;
    END IF;
    RETURN responce;
END