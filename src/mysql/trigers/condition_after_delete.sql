BEGIN
	UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = OLD.intent_id) WHERE intent_id = OLD.intent_id;
END