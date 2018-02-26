BEGIN
	UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages WHERE dialog_id = NEW.dialog_id), dialog_error = NEW.message_error WHERE dialog_id = NEW.dialog_id;
END