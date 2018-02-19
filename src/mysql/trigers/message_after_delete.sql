BEGIN
	UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages WHERE dialog_id = OLD.dialog_id) WHERE dialog_id = OLD.dialog_id;
    IF OLD.dispatch_id IS NOT NULL AND OLD.dispatch_id > 0
    	THEN UPDATE dispatches SET dispatch_messages_count = (SELECT COUNT(*) FROM messages WHERE dispatch_id = OLD.dispatch_id);
    END IF;
END