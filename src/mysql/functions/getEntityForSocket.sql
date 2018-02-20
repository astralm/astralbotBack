BEGIN
	DECLARE responce, entityArray, entity JSON;
	DECLARE entityID, lastEntityID, essenceID, entityNumber, botID INT(11);
	DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM entities WHERE entities_id = entitiesID);
	DECLARE done TINYINT(1);
	DECLARE essenceValue VARCHAR(1024);
	DECLARE connectionID VARCHAR(128);
	DECLARE entityCursor CURSOR FOR SELECT entity_id, essence_id FROM entity_essences WHERE entities_id = entitiesID AND organization_id = organizationID ORDER BY entity_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET entityArray = JSON_ARRAY(JSON_ARRAY());
	SET responce = JSON_ARRAY();
	SET entityNumber = 0;
	SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
	SELECT entities_json, bot_id INTO entity, botID FROM entities_info WHERE entities_id = entitiesID AND organization_id = organizationID;
	OPEN entityCursor;
		entityLoop: LOOP
			FETCH entityCursor INTO entityID, essenceID;
			IF done 
				THEN LEAVE entityLoop;
			END IF;
			IF lastEntityID IS NOT NULL AND entityID != lastEntityID
				THEN BEGIN
					SET entityArray = JSON_SET(entityArray, CONCAT("$[", JSON_LENGTH(entityArray), "]"), JSON_ARRAY());
					SET entityNumber = JSON_LENGTH(entityArray) - 1;	
				END;
			END IF;
			SET lastEntityID = entityID;
			SELECT essence_value INTO essenceValue FROM essences WHERE essence_id = essenceID;
			SET entityArray = JSON_ARRAY_APPEND(entityArray, CONCAT("$[", entityNumber, "]"), essenceValue);
			ITERATE entityLoop;
		END LOOP;
	CLOSE entityCursor;
	SET entity = JSON_SET(entity, "$.entities", entityArray);
	UPDATE states SET state_json = JSON_SET(state_json, "$.page", 35, "$.entity", entity) WHERE socket_id = socketID;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendToSocket",
		"data", JSON_OBJECT(
			"socket", connectionID,
			"data", JSON_ARRAY(
				JSON_OBJECT(
					"action", "merge",
					"data", JSON_OBJECT(
						"entity", entity,
						"bot", JSON_OBJECT(
							"bot_id", botID
						)
					)
				)
			)
		)
	));
	RETURN responce;
END;