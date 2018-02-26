BEGIN 
	DECLARE newSocketID, oldSocketID, organizationID, clientID, dialogID INT(11);
	DECLARE connectionID, clientEmail VARCHAR(128);
	DECLARE clientName VARCHAR(64);
	DECLARE messages, responce JSON;
	DECLARE organizationWidgetsWork TINYINT(1);
	SELECT socket_id, socket_connection_id INTO newSocketID, connectionID FROM sockets WHERE socket_hash = newSocketHash;
	SELECT organization_id INTO organizationID FROM organizations WHERE organization_hash = organizationHash;
	SELECT organization_widgets_work INTO organizationWidgetsWork FROM organizations WHERE organization_id = organizationID;
	SET responce = JSON_ARRAY(
		JSON_OBJECT(
			"action", "initDom"
		),
		JSON_OBJECT(
			"action", "initEvents"
		)
	);
	IF oldSocketHash IS NOT NULL
		THEN BEGIN
			SELECT socket_id INTO oldSocketID FROM sockets WHERE socket_hash = oldSocketHash;
			SELECT client_id INTO clientID FROM states WHERE socket_id = oldSocketID;
			IF clientID IS NOT NULL
				THEN BEGIN
					INSERT INTO client_sockets (client_id, socket_id) VALUES (clientID, newSocketID);
					SELECT dialog_id INTO dialogID FROM dialogues WHERE client_id = clientID;
					CALL getMessagesForSocket(newSocketID, dialogID);
					SELECT state_json ->> "$.messages" INTO messages FROM states WHERE socket_id = newSocketID;
					SELECT client_email, client_name INTO clientEmail, clientName FROM clients WHERE client_id = clientID;
					SET responce = JSON_MERGE(
						responce,
						JSON_ARRAY(
							JSON_OBJECT(
								"action", "setClientInfo",
								"data", JSON_OBJECT(
									"clientEmail", clientEmail,
									"clientName", clientName,
									"clientAgree", 1
								)
							),
							JSON_OBJECT(
								"action", "loadDialog",
								"data", messages
							)
						)
					);
				END;
				ELSE UPDATE sockets SET organization_id = organizationID WHERE socket_id = newSocketID;
			END IF;
		END;
	END IF;
	IF organizationWidgetsWork 
		THEN SET responce = JSON_MERGE(
			responce,
			JSON_OBJECT(
				"action", "render"
			)
		);
	END IF;
	RETURN JSON_MERGE(JSON_ARRAY(
		JSON_OBJECT(
			"action", "sendToSocket",
			"data", JSON_OBJECT(
				"socket", connectionID,
				"data", responce
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
			"action", "Procedure",
			"data", JSON_OBJECT(
				"query", "dispatchClients",
				"values", JSON_ARRAY(
					organizationID
				)
			)
		)
	), dispatchDialog(organizationID, dialogID));
END