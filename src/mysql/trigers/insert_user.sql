BEGIN
	DECLARE userHash VARCHAR(32) DEFAULT getHash(32);
    DECLARE userPassword VARCHAR(6) DEFAULT getHash(6);
    DECLARE organizationID INT(11);
	IF NEW.user_email REGEXP ".*.@.*[[.full-stop.]]..*"
    	THEN 
        	SET NEW.user_email = LOWER(NEW.user_email);
        	SET NEW.user_date_create = NOW();
            SET NEW.user_date_update = NOW();
            hashLoop: LOOP
            	IF (SELECT user_id FROM users WHERE user_hash = userHash) > 0
                	THEN 
                    	SET userHash = getHash(32);
                        ITERATE hashLoop;
                	ELSE
                    	LEAVE  hashLoop;
                END IF;
            END LOOP;
            passwordLoop: LOOP
            	IF (SELECT user_id FROM users WHERE user_password = userPassword) > 0
                	THEN 
                    	SET userPassword = getHash(6);
                        ITERATE passwordLoop;
                   	ELSE 
                    	LEAVE passwordLoop;
                END IF;
            END LOOP;
            SET NEW.user_hash = getHash(32);
            SET NEW.user_password = getHash(6);
            IF NEW.user_creator IS NOT NULL
            	THEN 
                	SELECT organization_id INTO organizationID FROM users WHERE user_id = NEW.user_creator;
                    SET NEW.organization_id = organizationID;
            END IF;
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid email address";
    END IF;
END