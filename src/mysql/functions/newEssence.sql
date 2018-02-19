BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, essenceID, entityEssenceID, userOrganizationID, entityOrganizationID INT(11);
    IF validOperation = 1
    	THEN
        	SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
           	SET essenceValue = LOWER(essenceValue);
            SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue LIMIT 1;
            IF essenceID IS NULL
            	THEN 
                	INSERT INTO essences (essence_value, user_id) VALUES (essenceValue, userID);
                    SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue ORDER BY essence_id DESC LIMIT 1; 
            END IF;
            SELECT entity_essence_id INTO entityEssenceID FROM entity_essences WHERE entity_id = entityID AND essence_id = essenceID;
            IF entityEssenceID IS NULL
            	THEN 
                	SELECT organization_id INTO userOrganizationID FROM users WHERE user_id = userID;
                    SELECT organization_id INTO entityOrganizationID FROM entity WHERE entity_id = entityID;
                    IF userOrganizationID = entityOrganizationID
                    	THEN 
                        	INSERT INTO entity_essences (entity_id, essence_id, user_id) VALUES (entityID, essenceID, userID);
                    		RETURN 1;
                    END IF;
            END IF;
    END IF;
    RETURN 0;
END