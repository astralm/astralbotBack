BEGIN
	UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages AS m WHERE m.dialog_id = NEW.dialog_id) WHERE dialog_id = NEW.dialog_id;
    IF NEW.dispatch_id IS NOT NULL AND NEW.dispatch_id > 0
    	THEN UPDATE dispatches SET dispatch_messages_count = (SELECT COUNT(*) FROM messages WHERE dispatch_id = NEW.dispatch_id);
    END IF;
END