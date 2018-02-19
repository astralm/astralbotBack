BEGIN
  DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_hash = userHash);
  DECLARE userAuth TINYINT(1) DEFAULT (SELECT user_auth FROM users WHERE user_id = userID);
  DECLARE userEmail VARCHAR(128);
  DECLARE userPassword VARCHAR(32);
  DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
  DECLARE stateJson, changePageJson, responce JSON;
  DECLARE connectionID VARCHAR(128) DEFAULT (SELECT socket_connection_id FROM sockets WHERE socket_id = socketID);
  SET responce = JSON_ARRAY();
  IF userAuth
    THEN BEGIN
      SELECT user_email, user_password INTO userEmail, userPassword FROM users WHERE user_id = userID;
      SET stateJson = login(userEmail, userPassword, socketHash);
      SET changePageJson = changePage(userHash, socketHash, pageID, itemID);
      SET responce = JSON_MERGE(responce, stateJson, changePageJson);
    END;
    ELSE BEGIN
      UPDATE states SET state_json = JSON_OBJECT(
        "loginMessage", "Требуется ручная авторизация",
        "socket", JSON_OBJECT(
          "hash", socketHash
        ),
        "user", JSON_OBJECT(
          "auth", 0
        )
      ) WHERE socket_id = socketID;
      SELECT state_json INTO stateJson FROM states WHERE socket_id = socketID;
      SET responce = JSON_MERGE(responce, JSON_OBJECT(
        "action", "sendToSocket",
          "data", JSON_OBJECT(
            "socket", connectionID,
              "data", JSON_ARRAY(
                JSON_OBJECT(
                    "action", "setState",
                      "data", stateJson
                  )
              )
          )
      ));
    END;
  END IF;
  RETURN responce;
END