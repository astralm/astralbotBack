BEGIN
	DECLARE organizationHash VARCHAR(32) DEFAULT getHash(32);
    IF NEW.organization_site REGEXP ".*[[.full-stop.]]..*"
        THEN
        	SET NEW.organization_date_create = NOW();
            SET NEW.organization_date_update = NOW();
            hashLoop: LOOP
            	IF (SELECT organization_id FROM organizations WHERE organization_hash = organizationHash) > 0
                    THEN 
                        SET organizationHash = getHash(32);
                        ITERATE hashLoop;
                    ELSE LEAVE hashLoop;
                END IF;
            END LOOP;
            SET NEW.organization_hash = organizationHash;
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid organization site";
    END IF;
END