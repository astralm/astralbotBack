BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE userID, organizationID, botID, socketID INT(11);
  DECLARE responce, bot JSON;
  DECLARE connectionID VARCHAR(128);
  SET responce = JSON_ARRAY();
  IF validOperation = 1
  	THEN BEGIN
    	SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
    	SELECT socket_connection_id, socket_id INTO connectionID, socketID FROM sockets WHERE socket_hash = socketHash;
    	INSERT INTO bots (bot_name, bot_telegram_key, user_id) VALUES (botName, botKey, userID);
    	SELECT bot_id INTO botID FROM bots ORDER BY bot_id DESC LIMIT 1;
    	SELECT bot_json INTO bot FROM bot_info WHERE bot_id = botID;
    	UPDATE states SET state_json = JSON_SET(state_json, "$.page", 24, "$.bot", bot) WHERE socket_id = socketID;
    	SET responce = JSON_MERGE(responce, JSON_ARRAY(
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
	    			"query", "dispatchBots",
	    			"values", JSON_ARRAY(
	    				organizationID
	    			)
	    		)
	    	)
  		));
    	IF botKey IS NOT NULL
    		THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
    			"action", "connectBots",
    			"data", JSON_OBJECT(
    				"bots", JSON_ARRAY(
    					JSON_OBJECT(
    						"bot_id", botID,
    						"bot_telegram_key", botKey
    					)
    				)
    			)
    		));
    	END IF;
    	SET responce = JSON_MERGE(responce, JSON_OBJECT(
    		"action", "sendToSocket",
    		"data", JSON_OBJECT(
    			"socket", connectionID,
    			"data", JSON_ARRAY(
    				JSON_OBJECT(
    					"action", "merge",
    					"data", JSON_OBJECT(
    						"page", 24,
    						"bot", bot
    					)
    				),
    				JSON_OBJECT(
    					"action", "changePage",
    					"data", JSON_OBJECT(
    						"page", CONCAT("app/bot:", botID)
    					)
    				)
    			)
    		)
    	));
    END;
 	END IF;
  RETURN responce;
END