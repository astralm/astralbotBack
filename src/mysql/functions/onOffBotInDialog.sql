BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE dialogBotWork TINYINT(1);
	DECLARE organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT dialog_bot_work, organization_id INTO dialogBotWork, organizationID FROM dialogues WHERE dialog_id = dialogID;
			IF dialogBotWork
				THEN BEGIN 
					UPDATE dialogues SET dialog_bot_work = 0 WHERE dialog_id = dialogID;
					SET dialogBotWork = 0;
				END;
				ELSE BEGIN 
					UPDATE dialogues SET dialog_bot_work = 1 WHERE dialog_id = dialogID;
					SET dialogBotWork = 1;
				END;
			END IF;
			SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
		END;
	END IF;
	RETURN responce;
END