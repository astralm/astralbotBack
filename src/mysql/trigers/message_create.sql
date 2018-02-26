BEGIN
	SET NEW.message_date_create = NOW();
    SET NEW.message_date_update = NOW();
    SET NEW.bot_id = (SELECT bot_id FROM dialogues WHERE dialog_id = NEW.dialog_id);
    IF NEW.dispatch_id IS NOT NULL AND NEW.dispatch_id > 0 
    	THEN SET NEW.user_id = (SELECT user_id FROM dispatches WHERE dispatch_id = NEW.dispatch_id);
    END IF;
END