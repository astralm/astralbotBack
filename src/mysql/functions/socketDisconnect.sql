BEGIN
	DECLARE organizationID, socketID, typeID, dialogID, clientID INT(11);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
	SELECT organization_id, socket_id, type_id INTO organizationID, socketID, typeID FROM sockets WHERE socket_connection_id = connectionID;
	UPDATE sockets SET socket_connection = 0 WHERE socket_id = socketID;
  IF typeID = 1
    THEN BEGIN 
      SELECT IFNULL((SELECT client_id FROM client_sockets WHERE socket_id = socketID), NULL) INTO clientID;
      IF clientID IS NOT NULL
        THEN BEGIN 
          SET responce = JSON_MERGE(responce, JSON_OBJECT(
            "action", "Procedure",
            "data", JSON_OBJECT(
              "query", "dispatchClients",
              "values", JSON_ARRAY(
                organizationID
              )
            )
          ));
          SELECT dialog_id INTO dialogID FROM dialogues WHERE client_id = clientID; 
          SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
        END;
      END IF;
      SET responce = JSON_MERGE(responce, JSON_ARRAY(
        JSON_OBJECT(
          "action", "Procedure",
          "data", JSON_OBJECT(
            "query", "dispatchSessions",
            "values", JSON_ARRAY(
              organizationID
            )
          )
        )
      ));
    END;
  END IF;
  RETURN responce;
END