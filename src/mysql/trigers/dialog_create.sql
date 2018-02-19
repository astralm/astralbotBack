BEGIN
	SET NEW.dialog_date_create = NOW();
    SET NEW.dialog_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM clients WHERE client_id = NEW.client_id);
    SET NEW.type_id = (SELECT type_id FROM clients WHERE client_id = NEW.client_id);
END