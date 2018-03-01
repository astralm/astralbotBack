BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE socketID, userID, organizationID, entitiesID, entitiesIterator, entitiesLength, entityIterator, entityLength, entityID, essenceID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE entityName, essenceValue VARCHAR(1024);
    DECLARE responce, entityArray, entitiesEssences JSON;
    SET responce = JSON_ARRAY();
    SET entitiesEssences = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            INSERT INTO entities (bot_id, user_id, entities_name, group_id) VALUES (botID, userID, name, groupID);
            SELECT entities_id INTO entitiesID FROM entities ORDER BY entities_id DESC LIMIT 1;
            SET entitiesIterator = 0;
            SET entitiesLength = JSON_LENGTH(entities);
            entitiesLoop: LOOP
                IF entitiesIterator >= entitiesLength
                    THEN LEAVE entitiesLoop;
                END IF;
                SET entityArray = JSON_EXTRACT(entities, CONCAT("$[", entitiesIterator, "]"));
                SET entityName = JSON_UNQUOTE(JSON_EXTRACT(entityArray, "$[0]"));
                INSERT INTO entity (entity_name, entities_id, user_id) VALUES (entityName, entitiesID, userID);
                SELECT entity_id INTO entityID FROM entity ORDER BY entity_id DESC LIMIT 1;
                SET entityIterator = 0;
                SET entityLength = JSON_LENGTH(entityArray);
                entityLoop: LOOP
                    IF entityIterator >= entityLength
                        THEN LEAVE entityLoop;
                    END IF;
                    SET essenceValue = JSON_UNQUOTE(JSON_EXTRACT(entityArray, CONCAT("$[", entityIterator, "]")));
                    SET essenceID = (SELECT (SELECT essence_id FROM essences WHERE essence_value = essenceValue) OR NULL);
                    IF essenceID 
                        THEN SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue;
                    END IF;
                    IF essenceID IS NULL
                        THEN BEGIN
                            INSERT INTO essences (essence_value, user_id) VALUES (essenceValue, userID);
                            SELECT essence_id INTO essenceID FROM essences ORDER BY essence_id DESC LIMIT 1;
                        END;
                    END IF;
                    IF !JSON_CONTAINS(entitiesEssences, JSON_ARRAY(essenceID))
                        THEN BEGIN
                            SET entitiesEssences = JSON_MERGE(entitiesEssences, CONCAT("",essenceID));
                            INSERT INTO entity_essences (entity_id, essence_id, user_id) VALUES (entityID, essenceID, userID);
                        END;
                    END IF;
                    SET entityIterator = entityIterator + 1;
                    ITERATE entityLoop;
                END LOOP;
                IF (SELECT COUNT(*) FROM entity_essences WHERE entity_id = entityID) = 0
                    THEN DELETE FROM entity WHERE entity_id = entityID;
                END IF;
                SET entitiesIterator = entitiesIterator + 1;
                ITERATE entitiesLoop;
            END LOOP;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 7) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchEntities",
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
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/entities:", botID)
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