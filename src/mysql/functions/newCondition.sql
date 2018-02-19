BEGIN
	INSERT INTO conditions (user_id, intent_id, condition_entities) VALUES (userId, intentId, conditionEntities);
    RETURN 1;
END