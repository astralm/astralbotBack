BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE uUsername, eEmail, connectionID VARCHAR(128);
	DECLARE pPhone BIGINT(11);
	DECLARE socketID, organizationID, dialogID INT(11);
	DECLARE nName VARCHAR(64);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT 
				client_name, 
				client_username, 
				client_phone, 
				client_email,
				organization_id 
			INTO 
				nName, 
				uUsername, 
				pPhone, 
				eEmail,
				organizationID
			FROM clients WHERE client_id = clientID;
			IF name IS NOT NULL
				THEN SET nName = name;
			END IF;
			IF username IS NOT NULL
				THEN SET uUsername = username;
			END IF;
			IF email IS NOT NULL AND (email REGEXP ".*.@.*[[.full-stop.]]..*")
				THEN SET eEmail = email;
			END IF;
			IF phone IS NOT NULL AND (phone REGEXP "^[0-9]{11}$")
				THEN SET pPhone = phone;
			END IF;
			UPDATE clients SET 
				client_email = eEmail, 
				client_username = uUsername, 
				client_phone = pPhone, 
				client_name = nName
			WHERE client_id = clientID;
			SELECT dialog_id INTO dialogID FROM dialogues WHERE client_id = clientID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 11) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, dispatchClientInfo(organizationID, clientID));
			SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchClients",
						"values", JSON_ARRAY(
							organizationID
						)
					)
				),
				JSON_OBJECT(
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/client:", clientID)
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END