BEGIN
	IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
  	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = NEW.group_id) WHERE group_id = NEW.group_id;
  END IF;
  UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = NEW.bot_id) WHERE bot_id = NEW.bot_id;
END