BEGIN
	SET NEW.entities_date_create = NOW();
    SET NEW.entities_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END