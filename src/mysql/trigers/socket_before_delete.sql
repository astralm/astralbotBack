BEGIN 
	DECLARE userID, clientID, socketsCount INT(11);
    SET userID = (SELECT user_id FROM user_sockets WHERE socket_id = OLD.socket_id);
    IF userID IS NOT NULL AND userID > 0
    	THEN 
        	SET socketsCount = (SELECT COUNT(*) FROM user_sockets WHERE user_id = userID) - 1;
        	UPDATE users SET user_sockets_count = socketsCount WHERE user_id = userID;
        ELSE 
        	SET clientID = (SELECT client_id FROM client_sockets WHERE socket_id = OLD.socket_id);
            IF clientID IS NOT NULL AND clientID > 0
            	THEN 
                	SET socketsCount = (SELECT COUNT(*) FROM client_sockets WHERE client_id = clientID) - 1;
                    UPDATE clients SET client_sockets_count = socketsCount WHERE client_id = clientID;
            END IF;
    END IF;
END