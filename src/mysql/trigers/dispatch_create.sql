BEGIN
	SET NEW.dispatch_date_create = NOW();
    SET NEW.dispatch_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END