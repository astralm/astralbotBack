BEGIN
	UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = OLD.intent_id);
END