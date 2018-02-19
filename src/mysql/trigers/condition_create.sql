BEGIN
	SET NEW.condition_date_create = NOW();
    SET NEW.condition_date_update = NOW();
    SET NEW.bot_id = (SELECT bot_id FROM intents WHERE intent_id = NEW.intent_id);
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END