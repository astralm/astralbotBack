BEGIN
	SET NEW.answer_date_create = NOW();
    SET NEW.answer_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM intents WHERE intent_id = NEW.intent_id);
END