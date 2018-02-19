BEGIN
	SET NEW.bot_date_create = NOW();
    SET NEW.bot_date_update = NOW();
    SET NEW.bot_hash = getHash(32);
    SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END