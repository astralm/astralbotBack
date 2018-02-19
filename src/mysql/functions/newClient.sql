BEGIN
    DECLARE organizationID, socketID, clientID, botID INT(11);
    DECLARE connectionID VARCHAR(128);
    SELECT organization_id, socket_connection_id, socket_id INTO organizationID, connectionID, socketID FROM sockets WHERE socket_hash = socketHash;
    INSERT INTO clients (client_email, client_name, organization_id, type_id) VALUES (clientEmail, clientName, organizationID, typeID);
    SELECT client_id INTO clientID FROM clients ORDER BY client_id DESC LIMIT 1;
    INSERT INTO client_sockets (socket_id, client_id) VALUES (socketID, clientID);
    SELECT bot_id INTO botID FROM bots WHERE bot_hash = botHash;
    INSERT INTO dialogues (client_id, bot_id, dialog_active) VALUES (clientID, botID, 1);
    UPDATE states SET state_json = JSON_SET(state_json, "$.clientEmail", clientEmail, "$.clientName", clientName) WHERE socket_id = socketID;
    RETURN JSON_ARRAY(
        JSON_OBJECT(
            "action", "sendToSocket",
            "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                    JSON_OBJECT(
                        "action", "setClientInfo",
                        "data", JSON_OBJECT(
                            "clientEmail", clientEmail,
                            "clientName", clientName
                        )
                    )
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
            "action", "Procedure",
            "data", JSON_OBJECT(
                "query", "dispatchClients",
                "values", JSON_ARRAY(
                    organizationID
                )
            )
        )
    );
END