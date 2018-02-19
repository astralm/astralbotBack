BEGIN
	DECLARE userHash VARCHAR(32);
	IF (NEW.user_email REGEXP ".*.@.*[[.full-stop.]]..*")
    	THEN
        	IF NEW.user_auth != OLD.user_auth AND NEW.user_auth = 1
            	THEN 
                	SET userHash = getHash(32);
                    hashLoop: LOOP
                        IF (SELECT COUNT(*) FROM users WHERE user_hash = userHash) > 0
                            THEN SET userHash = getHash(32);
                            ELSE LEAVE hashLoop;
                        END IF;
                    END LOOP;
                    SET NEW.user_hash = userHash;
            END IF;
            SET NEW.user_date_update = NOW();
            SET NEW.user_sockets_online_count = (SELECT COUNT(*) FROM user_sockets_connection WHERE user_id = NEW.user_id AND socket_connection = 1);
            IF NEW.user_sockets_online_count = 0
            	THEN SET NEW.user_online = 0;
                ELSE SET NEW.user_online = 1;
            END IF;
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid email address";
    END IF;
END