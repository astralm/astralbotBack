BEGIN
	DECLARE organizationID, socketID, typeID INT(11);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
	SELECT organization_id, socket_id, type_id INTO organizationID, socketID, typeID FROM sockets WHERE socket_connection_id = connectionID;
	UPDATE sockets SET socket_connection = 0 WHERE socket_id = socketID;
  IF typeID = 1
    THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
      "action", "Procedure",
      "data", JSON_OBJECT(
        "query", "dispatchSessions",
        "values", JSON_ARRAY(
          organizationID
        )
      )
    ));
  END IF;
  RETURN responce;
END