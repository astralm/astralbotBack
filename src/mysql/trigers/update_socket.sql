BEGIN
	SET NEW.socket_date_update = NOW();
	IF NEW.socket_connection = 0
    	THEN 
        	SET NEW.socket_date_disconnect = NOW();
    END IF;
END