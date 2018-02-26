BEGIN
	UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = NEW.intent_id) WHERE intent_id = NEW.intent_id;
END