BEGIN
	DECLARE responce JSON;
	DECLARE essenceID, essenceLength, essenceLocation INT(11);
	DECLARE done TINYINT(1);
	DECLARE essencesCursor CURSOR FOR SELECT essence_id, LOCATE(essence_value, textNode) strLocate, CHAR_LENGTH(essence_value) FROM bot_essences WHERE bot_id = botID AND LOCATE(essence_value, textNode) > 0 ORDER BY strLocate;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN essencesCursor;
		essencesLoop: LOOP
			FETCH essencesCursor INTO essenceID, essenceLocation, essenceLength;
			IF done 
				THEN LEAVE essencesLoop;
			END IF;
			SET responce = JSON_ARRAY_APPEND(responce, "$", JSON_ARRAY(
				essenceID,
				JSON_ARRAY(
					CONCAT(essenceLocation + shift),
					CONCAT(essenceLocation + shift + essenceLength - 1)
				)
			));
			ITERATE essencesLoop;
		END LOOP;
	CLOSE essencesCursor;
	RETURN responce;
END;