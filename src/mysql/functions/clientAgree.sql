BEGIN
    DECLARE clientAgree TINYINT(1);
    DECLARE socketID INT(11);
    DECLARE connectionID VARCHAR(128);
    SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
    SELECT state_json ->> "$.clientAgree" INTO clientAgree FROM states WHERE socket_id = socketID;
    IF clientAgree
        THEN SET clientAgree = !clientAgree;
        ELSE SET clientAgree = 1;
    END IF;
    UPDATE states SET state_json = JSON_SET(state_json, "$.clientAgree", clientAgree) WHERE socket_id = socketID;
    RETURN JSON_ARRAY(
        JSON_OBJECT(
            "action", "sendToSocket",
            "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                    JSON_OBJECT(
                        "action", "setClientInfo",
                        "data", JSON_OBJECT(
                            "clientAgree", clientAgree
                        )
                    )
                )
            )
        )
    );
END