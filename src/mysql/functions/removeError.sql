BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT organization_id INTO organizationID FROM users WHERE user_hash = userHash;
			UPDATE dialogues SET dialog_error = 0 WHERE dialog_id = dialogID;
			SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
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
	END IF;
	RETURN responce;
END;