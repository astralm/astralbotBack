BEGIN
	DECLARE responce, entities JSON;
	DECLARE done TINYINT(1);
	DECLARE entitiesCursor CURSOR FOR SELECT entities_json FROM bot_entities WHERE bot_id = botID AND organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN entitiesCursor;
		entitiesLoop: LOOP
			FETCH entitiesCursor INTO entities;
			IF done 
				THEN LEAVE entitiesLoop;
			END IF;
			SET responce = JSON_MERGE(responce, entities);
			ITERATE entitiesLoop;
		END LOOP;
	CLOSE entitiesCursor;
	RETURN responce;
END;