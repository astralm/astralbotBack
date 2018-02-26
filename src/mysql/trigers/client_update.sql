BEGIN
	SET NEW.client_date_update = NOW();
    SET NEW.client_sockets_online_count = (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = NEW.client_id AND socket_connection = 1);
    IF NEW.client_sockets_online_count = 0 
    	THEN SET NEW.client_online = 0;
        ELSE SET NEW.client_online = 1;
    END IF;
    IF NEW.client_online
    	THEN UPDATE dialogues SET dialog_active = 1 WHERE client_id = NEW.client_id;
        ELSE UPDATE dialogues SET dialog_active = 0 WHERE client_id = NEW.client_id;
    END IF;
END