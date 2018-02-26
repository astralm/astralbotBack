BEGIN
	DECLARE socketsCount, userID, clientID INT(11);
	IF NEW.organization_id IS NOT NULL AND NEW.organization_id > 0
    	THEN 
        	IF NEW.type_id = 2
            	THEN
                	SET userID = (SELECT user_id FROM user_sockets WHERE socket_id = NEW.socket_id);
                	SET socketsCount = (SELECT COUNT(*) FROM user_sockets WHERE user_id = userID);
                	UPDATE users SET user_sockets_count = socketsCount WHERE user_id = userID;
                ELSEIF NEW.type_id = 1
                	THEN 
                    	SET clientID = (SELECT client_id FROM client_sockets WHERE socket_id = NEW.socket_id);
                        SET socketsCount = (SELECT COUNT(*) FROM client_sockets WHERE client_id = clientID);
                        UPDATE clients SET client_sockets_count = socketsCount WHERE client_id = clientID;
			END IF;
	END IF;
END