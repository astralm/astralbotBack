BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE userID, organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
			UPDATE users SET user_telegram_notification = state WHERE user_id = userID;
			SET responce = dispatchProfile(organizationID, userID);
		END;
	END IF;
	RETURN responce;
END;