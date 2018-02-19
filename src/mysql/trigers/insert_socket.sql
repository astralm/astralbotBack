BEGIN
	DECLARE socketHash VARCHAR(32) DEFAULT getHash(32);
	SET NEW.socket_date_create = NOW();
    SET NEW.socket_date_update = NOW();
    hashLoop: LOOP
    	IF (SELECT socket_id FROM sockets WHERE socket_hash = socketHash) > 0
        	THEN 
            	SET socketHash = getHash(32);
                ITERATE hashLoop;
            ELSE 
            	LEAVE hashLoop;
        END IF;
    END LOOP;
    SET NEW.socket_hash = getHash(32);
    IF NEW.socket_connection = 0
    	THEN SET NEW.socket_date_disconnect = NOW();
        ELSE SET NEW.socket_date_disconnect = NULL;
    END IF;
END