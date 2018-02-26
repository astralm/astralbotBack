BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE dispatchID, socketID, organizationID, userID INT(11);
	DECLARE responce JSON;
  DECLARE iterator, loopLimit INT(11) DEFAULT 0;
  DECLARE connectionID VARCHAR(128);
  SET responce = JSON_ARRAY();
  IF validOperation 
  	THEN BEGIN
  		SELECT socket_connection_id, socket_id INTO connectionID, socketID FROM sockets WHERE socket_hash = socketHash;
  		SELECT organization_id, user_id INTO organizationID, userID FROM users WHERE user_hash = userHash;
			INSERT INTO dispatches (user_id, dispatch_text) values (userID, dispatchText);
			SELECT dispatch_id INTO dispatchID FROM dispatches WHERE organization_id = organizationID ORDER BY dispatch_id DESC LIMIT 1;
			SET loopLimit = JSON_LENGTH(typesArray);
		  typesLoop: LOOP
		    INSERT INTO `dispatch_types` (`dispatch_id`, `type_id`) VALUES (dispatchID, JSON_EXTRACT(typesArray, CONCAT("$[", iterator, "]")));
		    SET iterator = iterator + 1;
		    IF iterator < loopLimit
		    	THEN ITERATE typesLoop;
		      ELSE LEAVE typesLoop;
		    END IF;
		  END LOOP;
		  SET iterator = 0;
		  SET loopLimit = JSON_LENGTH(botsArray);
		  botsLoop: LOOP
		  	INSERT INTO `dispatch_bots` (`dispatch_id`, `bot_id`) VALUES (dispatchID, JSON_EXTRACT(botsArray, CONCAT("$[", iterator, "]")));
		  	SET iterator = iterator + 1;
		      IF iterator < loopLimit
		      	THEN ITERATE botsLOOP;
		        ELSE LEAVE botsLOOP;
		      END IF;
		  END LOOP;
		  SET responce = JSON_MERGE(responce, setMessagesForDispatch(dispatchID));
		  CALL getDispatchesForSocket(socketID);
		  SET responce = JSON_MERGE(responce, dispatchDispatches(organizationID));
		  SET responce = JSON_MERGE(responce, JSON_OBJECT(
		  	"action", "Procedure",
		  	"data", JSON_OBJECT(
		  		"query", "dispatchSessions",
		  		"values", JSON_ARRAY(
		  			organizationID
		  		)
		  	)
		  ));
		END; 
	END IF;
	RETURN responce;
END