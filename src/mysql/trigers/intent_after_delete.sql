BEGIN
	IF OLD.group_id IS NOT NULL AND OLD.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = OLD.group_id) WHERE group_id = OLD.group_id;
    END IF;
    UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = OLD.bot_id) WHERE bot_id = OLD.bot_id;
END