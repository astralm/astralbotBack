BEGIN
	SET NEW.entity_date_create = NOW(),
    	NEW.entity_date_update = NOW(),
        NEW.bot_id = (SELECT bot_id FROM entities WHERE entities_id = NEW.entities_id),
        NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END