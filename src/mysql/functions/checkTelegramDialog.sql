BEGIN
	DECLARE compare TINYINT(1);
	DECLARE organizationID, seconds INT(11);
	DECLARE dialogDateUpdate VARCHAR(19);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT NOW() >= (dialog_date_update + INTERVAL 10 MINUTE), organization_id, dialog_date_update INTO compare, organizationID, dialogDateUpdate FROM dialogues WHERE dialog_id = dialogID;
	IF compare
		THEN BEGIN 
			UPDATE dialogues SET dialog_active = 0 WHERE dialog_id = dialogID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "Procedure",
				"data", JSON_OBJECT(
					"query", "dispatchSessions",
					"values", JSON_ARRAY(
						organizationID
					)
				)
			));
		END;
		ELSE BEGIN
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "Query",
				"data", JSON_OBJECT(
					"query", "checkTelegramDialog",
					"timeout", 600000,
					"values", JSON_ARRAY(
						dialogID
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END