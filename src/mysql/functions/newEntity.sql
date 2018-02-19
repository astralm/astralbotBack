BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, entitiesOrganizationID, userOrganizationID INT(11);
    IF validOperation = 1
    	THEN
        	SELECT user_id, organization_id INTO userID, userOrganizationID FROM users WHERE user_hash = userHash;
            SELECT organization_id INTO entitiesOrganizationID FROM entities WHERE entities_id = entitiesID;
            IF userOrganizationID = entitiesOrganizationID
            	THEN 
                	INSERT INTO entity (user_id, entities_id, entity_name) VALUES (userID, entitiesID, entityName);
                    RETURN 1;
            END IF;
    END IF;
    RETURN 0;
END