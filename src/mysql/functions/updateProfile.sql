BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE eEmail, connectionID VARCHAR(128);
	DECLARE socketID, userID, organizationID INT(11);
	DECLARE nName VARCHAR(64);
	DECLARE pPassword VARCHAR(32);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT socket_id, organization_id, socket_connection_id INTO socketID, organizationID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
			SELECT 
				user_name, 
				user_email,
				user_password
			INTO 
				nName, 
				eEmail,
				pPassword
			FROM users WHERE user_id = userID;
			IF name IS NOT NULL
				THEN SET nName = name;
			END IF;
			IF email IS NOT NULL AND (email REGEXP ".*.@.*[[.full-stop.]]..*")
				THEN SET eEmail = email;
			END IF;
			IF password IS NOT NULL
				THEN SET pPassword = password;
			END IF;
			UPDATE users SET 
				user_email = eEmail, 
				user_name = nName,
				user_password = pPassword
			WHERE user_id = userID;
			UPDATE states SET state_json = JSON_SET(
				state_json,
				"$.user.user_email", eEmail,
				"$.user.user_name", nName,
				"$.page", 13
			) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchUsers",
						"values", JSON_ARRAY(
							organizationID
						)
					)
				),
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchSessions",
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
								"action", "mergeDeep",
								"data", JSON_OBJECT(
									"user", JSON_OBJECT(
										"name", nName,
										"email", eEmail
									)
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", "app/profile"
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