BEGIN
  DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_email = LOWER(userEmail) AND user_password = userPassword);
    DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
    DECLARE socketType INT(11) DEFAULT (SELECT type_id FROM sockets WHERE socket_id = socketID);
    DECLARE connectionID VARCHAR(128) DEFAULT (SELECT socket_connection_id FROM sockets WHERE socket_id = socketID);
    DECLARE userHash, organizationHash VARCHAR(32);
    DECLARE userSocketID INT(11) DEFAULT (SELECT user_socket_id FROM user_sockets WHERE user_id = userID AND socket_id = socketID);
    DECLARE stateJson, socketsArray, botsArray JSON;
    DECLARE statesCount, organizationType INT(11);
    DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM users WHERE user_id = userID);
    DECLARE responceJson, changePageJson JSON;
    DECLARE organizationWidgetsWork TINYINT(1);
    IF socketType = 2 AND userID > 0
      THEN 
          UPDATE users SET user_auth = 1 WHERE user_id = userID;
            SET userHash = (SELECT user_hash FROM users WHERE user_id = userID);
            IF userSocketID IS NULL
              THEN 
              INSERT INTO user_sockets (user_id, socket_id) VALUES (userID, socketID);
            END IF;
            SET botsArray = getBots(organizationID);
            SELECT type_id, organization_hash, organization_widgets_work INTO organizationType, organizationHash, organizationWidgetsWork FROM organizations WHERE organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.user", JSON_OBJECT(
                    "auth", 1, 
                    "hash", userHash, 
                    "id", userID
                ), 
                "$.loginMessage", "Вход выполнен", 
                "$.bots", botsArray,
                "$.organization", JSON_OBJECT(
                    "type_id", organizationType,
                    "organization_hash", organizationHash,
                    "organization_widgets_work", organizationWidgetsWork
                )
            ) WHERE socket_id = socketID;
            CALL getFIltersForSocket(socketID);
            SELECT state_json INTO stateJson FROM states WHERE socket_id = socketID;
            SET changePageJson = changePage(userHash, socketHash, 8, 0);
            SET responceJson = JSON_MERGE(
              JSON_ARRAY(
                JSON_OBJECT(
                  "action", "sendToSocket",
                  "data", JSON_OBJECT(
                    "socket", connectionID,
                    "data", JSON_ARRAY(
                      JSON_OBJECT(
                        "action", "setState",
                        "data", stateJson
                      ),
                      JSON_OBJECT(
                        "action", "setLocal",
                        "data",JSON_OBJECT(
                          "user", userHash
                        )
                      )
                    )
                  )
                )
              ),
              changePageJson
            );
        ELSE 
          UPDATE states SET state_json = JSON_SET(state_json, "$.loginMessage", "Неправильный логин или пароль") WHERE socket_id = socketID;
            SELECT state_json INTO stateJson FROM states WHERE socket_id = socketID;
            SET responceJson = JSON_ARRAY(
                JSON_OBJECT(
                "action", "sendToSocket",
                  "data", JSON_OBJECT(
                        "socket", connectionID,
                      "data", JSON_ARRAY(
                          JSON_OBJECT(
                              "action", "mergeDeep",
                                "data", stateJson
                            )
                        )
                  )
              )
            );
    END IF;
    RETURN responceJson;
END