BEGIN
	DECLARE done TINYINT(1);
	DECLARE entitiesLength, entitiesIterator, conditionsIterator INT(11);
	DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM sockets WHERE socket_id = socketID);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, entitiesArray, entities, conditionsArray, intent JSON;
	DECLARE conditionEntities TEXT;
	DECLARE conditionsCursor CURSOR FOR SELECT condition_entities FROM conditions WHERE intent_id = intentID AND organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SELECT intent_json INTO intent FROM intent_json WHERE intent_id = intentID AND organization_id = organizationID;
	SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
	SET conditionsArray = JSON_ARRAY();
	SET responce = JSON_ARRAY();
	SET conditionsIterator = 0;
	OPEN conditionsCursor;
		conditionsLoop: LOOP
			FETCH conditionsCursor INTO conditionEntities;
			IF done 
				THEN LEAVE conditionsLoop;
			END IF;
			SET entitiesArray = CONCAT("[", conditionEntities, "]");
			SET entitiesLength = JSON_LENGTH(entitiesArray);
			SET entitiesIterator = 0;
			entitiesLoop: LOOP
				IF entitiesIterator >= entitiesLength
					THEN LEAVE entitiesLoop;
				END IF;
				SELECT JSON_OBJECT(
					"entities_id", entities_id,
					"entities_name", entities_name
				) INTO entities FROM entities WHERE entities_id = JSON_EXTRACT(entitiesArray, CONCAT("$[", entitiesIterator, "]"));
				SET entitiesArray = JSON_SET(entitiesArray, CONCAT("$[", entitiesIterator, "]"), entities);
				SET entitiesIterator = entitiesIterator + 1;
				ITERATE entitiesLoop;
			END LOOP;
			SET conditionsArray = JSON_SET(conditionsArray, CONCAT("$[", conditionsIterator, "]"), entitiesArray);
			SET conditionsIterator = conditionsIterator + 1;
			ITERATE conditionsLoop;
		END LOOP;
	CLOSE conditionsCursor;
	SET intent = JSON_SET(intent, "$.conditions", IF(conditionsArray IS NULL, JSON_ARRAY(JSON_ARRAY()), conditionsArray));
	UPDATE states SET state_json = JSON_SET(state_json, "$.intent", intent) WHERE socket_id = socketID;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendToSocket",
		"data", JSON_OBJECT(
			"socket", connectionID,
			"data", JSON_ARRAY(
				JSON_OBJECT(
					"action", "merge",
					"data", JSON_OBJECT(
						"intent", intent
					)
				)
			)
		)
	));
	RETURN responce;
END;