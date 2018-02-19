BEGIN
	DECLARE socketType INT(11) DEFAULT (SELECT type_id FROM sockets WHERE socket_hash = socketHash);
    DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_hash = userHash);
    DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
    DECLARE connectionID VARCHAR(128) DEFAULT (SELECT socket_connection_id FROM sockets WHERE socket_id = socketID);
    DECLARE userSocketID INT(11);
    DECLARE stateJson JSON;
    IF socketType = 2 AND userID > 0 AND socketID > 0
    	THEN 
        	SET userSocketID = (SELECT user_socket_id FROM user_sockets WHERE user_id = userID AND socket_id = socketID);
            IF userSocketID > 0 
            	THEN 
                	UPDATE users SET user_auth = 0 WHERE user_id = userID;
                    DELETE FROM user_sockets WHERE socket_id = socketID;
                   	UPDATE states SET state_json = JSON_OBJECT(
                    	"socket", JSON_OBJECT(
                        	"hash", socketHash
                        ),
                        "loginMessage", "Вы успешно вышли из системы"
                    ) WHERE socket_id = socketID;
                    SELECT state_json INTO stateJson FROM states WHERE socket_id = socketID;
                    RETURN JSON_ARRAY(JSON_OBJECT(
                    	"action", "sendToSocket",
                        "data", JSON_OBJECT(
                        	"socket", connectionID,
                            "data", JSON_ARRAY(
                                JSON_OBJECT(
                                	"action", "deleteLocal",
                                    "data", "user"
                                ),
                            	JSON_OBJECT(
                                	"action", "setState",
                                    "data", stateJson
                                )
                            )
                        )
                    ));
            END IF;
    END IF;
    RETURN NULL;
END