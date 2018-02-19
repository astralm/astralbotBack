DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clientMessage`(`socketHash` VARCHAR(32) CHARSET utf8, `messageText` TEXT CHARSET utf8) RETURNS json
    NO SQL
BEGIN
    DECLARE messageID, answerID, socketID, clientID, dialogID, organizationsID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE answerText TEXT;
    DECLARE dialogBotWork TINYINT(1);
    DECLARE messagesArray, responce JSON;
    SET responce = JSON_ARRAY();
    SELECT socket_id, socket_connection_id, organization_id INTO socketID, connectionID, organizationsID FROM sockets WHERE socket_hash = socketHash;
    SELECT client_id INTO clientID FROM states WHERE socket_id = socketID;
    SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues WHERE client_id = clientID;
    INSERT INTO messages (message_text, dialog_id, message_client) VALUES (messageText, dialogID, 1);
    SELECT message_id INTO messageID FROM messages ORDER BY message_id DESC LIMIT 1;
    IF dialogBotWork
        THEN BEGIN
            SET answerID = getAnswerIdForMessage(messageID);
            IF answerID = 0
                THEN BEGIN
                    UPDATE messages SET message_error = 1 WHERE message_id = messageID;
                END;
                ELSE BEGIN
                    SELECT answer_text INTO answerText FROM answers WHERE answer_id = answerID;
                    INSERT INTO messages (message_text, dialog_id) VALUES (answerText, dialogID);
                END;
            END IF;
        END;
    END IF;
    CALL getMessagesForSocket(socketID, dialogID);
    SELECT state_json ->> "$.messages" INTO messagesArray FROM states WHERE socket_id = socketID;
    SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messagesArray));
    SET responce = JSON_MERGE(responce, JSON_OBJECT(
        "action", "Procedure",
        "data", JSON_OBJECT(
            "query", "dispatchSessions",
            "values", JSON_ARRAY(
                organizationsID
            )
        )
    ));
    SET responce = JSON_MERGE(responce, dispatchDialog(organizationsID, dialogID));
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `deleteDispatch`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dispatchID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOpertaion TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOpertaion
		THEN BEGIN
			SELECT organization_id INTO organizationID FROM sockets WHERE socket_hash = socketHash;
			DELETE FROM dispatches WHERE dispatch_id = dispatchID;
			SET responce = JSON_MERGE(responce, dispatchDispatches(organizationID));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `changePage`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `typeID` INT(11), `itemID` INT(11)) RETURNS json
    NO SQL
BEGIN
  DECLARE validOperatation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE stateJson, responce, sessionsFilters, dialog, clientsFilters, client, usersFilters, user, organization, organizations, dispatches, bots, bot, groups, entities, groupObj JSON;
  DECLARE socketID, organizationID, userID, botID INT(11);
  DECLARE connectionID, userEmail, uUserEmail VARCHAR(128);
  DECLARE userName, uUserName VARCHAR(64);
  IF validOperatation = 1
    THEN 
      BEGIN
        SELECT socket_id, socket_connection_id, JSON_ARRAY(), organization_id INTO socketID, connectionID, responce, organizationID FROM sockets WHERE socket_hash = socketHash;
        SELECT user_id, user_name, user_email INTO userID, userName, userEmail FROM users WHERE user_hash = userHash;
        UPDATE states SET state_json = JSON_SET(state_json, "$.page", typeID) WHERE socket_id = socketID;
        CASE typeID
          WHEN 8 THEN BEGIN
            SELECT state_json ->> "$.sessionsFilters" INTO sessionsFilters FROM states WHERE socket_id = socketID;
            SET bots = getBots(organizationID);
            SET responce = JSON_MERGE(
              responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "bots", bots
                      )
                    ),
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "sessionsFilters", sessionsFilters,
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/tableSession"
                      )
                    )
                  )
                )
              ),
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getDialoguesForSocket",
                    "values", JSON_ARRAY(socketID)
                )
              )
            );
          END;
          WHEN 9 THEN BEGIN
            IF itemID > 0
              THEN BEGIN 
                CALL getDialog(socketID, itemID);
                SELECT state_json ->> "$.dialog" INTO dialog FROM states WHERE socket_id = socketID;
                SET responce = JSON_MERGE(responce, JSON_OBJECT(
                  "action", "sendToSocket",
                  "data", JSON_OBJECT(
                    "socket", connectionID,
                    "data", JSON_ARRAY(
                      JSON_OBJECT(
                        "action", "mergeDeep",
                        "data", JSON_OBJECT(
                          "dialog", dialog,
                          "page", typeID
                        )
                      ),
                      JSON_OBJECT(
                        "action", "changePage",
                        "data", JSON_OBJECT(
                          "page", CONCAT("app/dialog:",itemID)
                        )
                      )
                    )
                  )
                ));
              END;
            END IF;
          END;
          WHEN 10 THEN BEGIN
            SELECT state_json ->> "$.clientsFilters" INTO clientsFilters FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(
              responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "clientsFilters", clientsFilters,
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/clients"
                      )
                    )
                  )
                )
              ),
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getClientsForSocket",
                    "values", JSON_ARRAY(socketID)
                )
              )
            );
          END;
          WHEN 11 THEN BEGIN
            IF itemID > 0
              THEN BEGIN 
                SELECT client_json INTO client FROM clients_json WHERE organization_id = organizationID AND client_id = itemID;
                IF client IS NOT NULL 
                  THEN UPDATE states SET state_json = JSON_SET(state_json, "$.client", client) WHERE socket_id = socketID;
                END IF;
                SET responce = JSON_MERGE(responce, JSON_OBJECT(
                  "action", "sendToSocket",
                  "data", JSON_OBJECT(
                    "socket", connectionID,
                    "data", JSON_ARRAY(
                      JSON_OBJECT(
                        "action", "mergeDeep",
                        "data", JSON_OBJECT(
                          "client", client,
                          "page", typeID
                        )
                      ),
                      JSON_OBJECT(
                        "action", "changePage",
                        "data", JSON_OBJECT(
                          "page", CONCAT("app/client:",itemID)
                        )
                      )
                    )
                  )
                ));
              END;
            END IF;
          END;
          WHEN 12 THEN BEGIN
            SELECT state_json ->> "$.usersFilters" INTO usersFilters FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(
              responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "usersFilters", usersFilters,
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/administrators"
                      )
                    )
                  )
                )
              ),
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getUsersForSocket",
                    "values", JSON_ARRAY(socketID)
                )
              )
            );
          END;
          WHEN 13 THEN BEGIN
            SELECT profile_json, organization_json INTO user, organization FROM profile_json WHERE user_id = userID; 
            UPDATE states SET state_json = JSON_SET(state_json, "$.user", user) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_OBJECT(
              "action", "sendToSocket",
              "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                  JSON_OBJECT(
                    "action", "mergeDeep",
                    "data", JSON_OBJECT(
                      "user", user,
                      "organization", organization,
                      "page", typeID
                    )
                  ),
                  JSON_OBJECT(
                    "action", "changePage",
                    "data", JSON_OBJECT(
                      "page", "app/profile"
                    )
                  )
                )
              )
            ));
          END;
          WHEN 14 THEN BEGIN
            SELECT state_json ->> "$.user.user_name", state_json ->> "$.user.user_email" INTO uUserName, uUserEmail FROM states WHERE socket_id = socketID;
            IF uUserName IS NULL
              THEN SET uUserName = userName; 
            END IF;
            IF uUserEmail IS NULL
              THEN SET uUserEmail = userEmail;
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.user.name", uUserName, "$.user.email", uUserEmail) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_OBJECT(
              "action", "sendToSocket",
              "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                  JSON_OBJECT(
                    "action", "mergeDeep",
                    "data", JSON_OBJECT(
                      "user", JSON_OBJECT(
                        "name", uUserName,
                        "email", uUserEmail
                      ),
                      "page", typeID
                    )
                  ),
                  JSON_OBJECT(
                    "action", "changePage",
                    "data", JSON_OBJECT(
                      "page", "app/edituser"
                    )
                  )
                )
              )
            ));
          END;
          WHEN 15 THEN BEGIN
            CALL getOrganizationsForSocket(socketID);
            SELECT state_json ->> "$.organizations" INTO organizations FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "organizations", organizations,
                        "organization", JSON_OBJECT(
                          "organization_id", organizationID
                        ),
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/newuser"
                      )
                    )
                  )
                )
              )
            );
          END;
          WHEN 16 THEN BEGIN
            CALL getDispatchesForSocket(socketID);
            SELECT state_json ->> "$.dispatches" INTO dispatches FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_OBJECT(
              "action", "sendToSocket",
              "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                  JSON_OBJECT(
                    "action", "mergeDeep",
                    "data", JSON_OBJECT(
                      "dispatches", dispatches,
                      "page", typeID
                    )
                  ),
                  JSON_OBJECT(
                    "action", "changePage",
                    "data", JSON_OBJECT(
                      "page", "app/dispatch"
                    )
                  )
                )
              )
            ));
          END;
          WHEN 17 THEN BEGIN
            SELECT state_json ->> "$.organizations" INTO organizations FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/organizations"
                      )
                    )
                  )
                )
              ),
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getFilterOrganizationsForSocket",
                  "values", JSON_ARRAY(
                    socketID
                  )
                )
              )
            );
          END;
          WHEN 18 THEN BEGIN
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/neworganization"
                      )
                    )
                  )
                )
              )
            );
          END;
          WHEN 19 THEN BEGIN
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/editclient"
                      )
                    )
                  )
                )
              )
            );
          END;
          WHEN 20 THEN BEGIN
            CALL getOrganizationForSocket(socketID, itemID);
            SELECT state_json ->> "$.viewOrganization" INTO organization FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "viewOrganization", organization
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/organization:", itemID)
                      )
                    )
                  )
                )
              )
            );
          END;
          WHEN 21 THEN BEGIN
            CALL getOrganizationForSocket(socketID, itemID);
            SELECT state_json ->> "$.viewOrganization" INTO organization FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "viewOrganization", organization
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/editorganization:", itemID)
                      )
                    )
                  )
                )
              )
            );
          END;
          WHEN 22 THEN BEGIN
            SET responce = JSON_MERGE(responce, 
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/widgets"
                      )
                    )
                  )
                )
              )
            );
          END;
          WHEN 23 THEN BEGIN
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getFilterBotsForSocket",
                  "values", JSON_ARRAY(
                    socketID
                  )
                )
              ),
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "mergeDeep",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/bots"
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 24 THEN BEGIN
            SELECT bot_json INTO bot FROM bot_info WHERE organization_id = organizationID AND bot_id = itemID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.bot", bot) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "bot", bot
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/bot:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 25 THEN BEGIN
            SELECT bot_json INTO bot FROM bot_info WHERE organization_id = organizationID AND bot_id = itemID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.bot", bot) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "bot", bot
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/editbot:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 26 THEN BEGIN
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", "app/newbot"
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 6 THEN BEGIN
            SET groups = getIntentsGroups(organizationID);
            UPDATE states SET state_json = JSON_SET(state_json, "$.bot", JSON_OBJECT(
              "bot_id", itemID
            )) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getIntentsForSocket",
                  "values", JSON_ARRAY(
                    socketID,
                    itemID
                  )
                )
              ),
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "intentsGroups", groups,
                        "bot", JSON_OBJECT(
                          "bot_id", itemID
                        )
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/intents:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 27 THEN BEGIN
            SET bots = getBots(organizationID);
            SET groups = getBotIntentsGroups(organizationID, IF(itemID > 0, itemID, JSON_EXTRACT(bots, "$[0].bot_id")));
            SET entities = getBotEntities(organizationID, IF(itemID > 0, itemID, JSON_EXTRACT(bots, "$[0].bot_id")));
            UPDATE states SET state_json = JSON_SET(state_json, "$.intentsGroups", groups, "$.entities", entities, "$.bots", bots) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "intentsGroups", groups,
                        "page", typeID,
                        "entities", entities,
                        "bots", bots
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/newintent:", IF(itemID > 0, itemID, JSON_EXTRACT(bots, "$[0].bot_id")))
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 28 THEN BEGIN
            SET responce = JSON_MERGE(responce, getIntentForSocket(socketID, itemID));
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/intent:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 29 THEN BEGIN
            SET responce = JSON_MERGE(responce, getIntentForSocket(socketID, itemID));
            SELECT state_json ->> "$.intent.bot_id" INTO botID FROM states WHERE socket_id = socketID;
            SET bots = getBots(organizationID);
            SET groups = getBotIntentsGroups(organizationID, botID);
            SET entities = getBotEntities(organizationID, botID);
            UPDATE states SET state_json = JSON_SET(state_json, "$.intentsGroups", groups, "$.entities", entities, "$.bots", bots) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "intentsGroups", groups,
                        "page", typeID,
                        "entities", entities,
                        "bots", bots
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/editintent:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 30 THEN BEGIN
            UPDATE states SET state_json = JSON_SET(state_json, "$.bot", JSON_OBJECT(
              "bot_id", itemID
            )) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getGroupsForSocket",
                  "values", JSON_ARRAY(
                    socketID,
                    itemID
                  )
                )
              ),
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "bot", JSON_OBJECT(
                          "bot_id", itemID
                        )
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/groups:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 31 THEN BEGIN
            SET bots = getBots(organizationID);
            UPDATE states SET state_json = JSON_SET(state_json, "$.bots", bots) WHERE socket_id = socketID; 
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "bots", bots
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/newgroup:", IF(itemID > 0, itemID, JSON_EXTRACT(bots, "$[0].bot_id")))
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 32 THEN BEGIN
            SELECT group_json INTO groupObj FROM group_json WHERE group_id = itemID AND organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.group", groupObj) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "group", groupObj
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/group:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 33 THEN BEGIN
            SELECT group_json INTO groupObj FROM group_json WHERE group_id = itemID AND organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.group", groupObj) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "group", groupObj
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/editgroup:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 7 THEN BEGIN
            SET groups = getEntitiesGroups(organizationID, itemID);
            UPDATE states SET state_json = JSON_SET(state_json, "$.bot", JSON_OBJECT(
              "bot_id", itemID
            )) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                  "query", "getEntitiesForSocket",
                  "values", JSON_ARRAY(
                    socketID,
                    itemID
                  )
                )
              ),
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "entitiesGroups", groups,
                        "bot", JSON_OBJECT(
                          "bot_id", itemID
                        )
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/entities:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 34 THEN BEGIN
            SET bots = getBots(organizationID);
            SET groups = getEntitiesGroups(organizationID, IF(itemID > 0, itemID, JSON_EXTRACT(bots, "$[0].bot_id")));
            UPDATE states SET state_json = JSON_SET(state_json, "$.entitiesGroups", groups, "$.bots", bots) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "entitiesGroups", groups,
                        "page", typeID,
                        "bots", bots
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/newentities:", IF(itemID > 0, itemID, JSON_EXTRACT(bots, "$[0].bot_id")))
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 35 THEN BEGIN
            SET responce = JSON_MERGE(responce, getEntityForSocket(socketID, itemID));
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/entity:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          WHEN 36 THEN BEGIN
            SELECT bot_id INTO botID FROM entities WHERE entities_id = itemID; 
            SET groups = getEntitiesGroups(organizationID, botID);
            SET responce = JSON_MERGE(responce, getEntityForSocket(socketID, itemID));
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
              JSON_OBJECT(
                "action", "sendToSocket",
                "data", JSON_OBJECT(
                  "socket", connectionID,
                  "data", JSON_ARRAY(
                    JSON_OBJECT(
                      "action", "merge",
                      "data", JSON_OBJECT(
                        "page", typeID,
                        "entitiesGroups", groups
                      )
                    ),
                    JSON_OBJECT(
                      "action", "changePage",
                      "data", JSON_OBJECT(
                        "page", CONCAT("app/editentities:", itemID)
                      )
                    )
                  )
                )
              )
            ));
          END;
          ELSE BEGIN END;
        END CASE;
      END;
  END IF;
  RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clientAgree`(`socketHash` VARCHAR(32) CHARSET utf8) RETURNS json
    NO SQL
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clientMessageTelegram`(`chat` VARCHAR(128) CHARSET utf8, `botID` INT(11), `messageText` TEXT CHARSET utf8, `clientName` VARCHAR(64) CHARSET utf8, `clientUsername` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE clientID, dialogID, answerID, organizationID, messageID INT(11);
	DECLARE dialogBotWork TINYINT(1);
	DECLARE answerText TEXT;
	DECLARE notificationText VARCHAR(512);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT client_id INTO clientID FROM client_bot WHERE client_telegram_chat = chat AND bot_id = botID ORDER BY client_id DESC LIMIT 1;
	SELECT organization_id INTO organizationID FROM bots WHERE bot_id = botID;
	SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues WHERE client_id = clientID AND bot_id = botID;
	IF clientID IS NULL
		THEN BEGIN
			INSERT INTO clients (client_name, client_username, organization_id, type_id, client_telegram_chat) values (clientName, clientUsername, organizationID, 5, chat);
			SELECT client_id INTO clientID FROM clients ORDER BY client_id DESC LIMIT 1;
			INSERT INTO dialogues (client_id, bot_id, dialog_active) values (clientID, botID, 1);
			SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues ORDER BY dialog_id DESC LIMIT 1;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "Procedure",
        "data", JSON_OBJECT(
          "query", "dispatchClients",
          "values", JSON_ARRAY(
              organizationID
          )
        )
			));
		END;
	END IF;
	INSERT INTO messages (message_text, dialog_id, message_client) VALUES (messageText, dialogID, 1);
	SELECT message_id INTO messageID FROM messages ORDER BY message_id DESC LIMIT 1;
	IF dialogBotWork
		THEN BEGIN
			SET answerID = getAnswerIdForMessage(messageID);
			IF answerID = 0
				THEN BEGIN 
					UPDATE messages SET message_error = 1 WHERE message_id = messageID;
					SET notificationText = CONCAT("Бот не смог подобрать ответ в сессии ", dialogID, ";
Ссылка на диалог: https://astralbot.ru/#/app/dialog:", dialogID, ";
Ссылка на клиента: https://astralbot.ru/#/app/client:", clientID, ";
Сообщение: 
", messageText);
					SET responce = JSON_MERGE(responce, sendNotification(organizationID, notificationText));
				END;
				ELSE BEGIN
					SELECT answer_text INTO answerText FROM answers WHERE answer_id = answerID;
					INSERT INTO messages (message_text, dialog_id) VALUES (answerText, dialogID);
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "sendToTelegram",
						"data", JSON_OBJECT(
							"bot_id", botID,
							"chats", JSON_ARRAY(
								chat
							),
							"message", answerText
						)
					));
				END;
			END IF;
		END;
	END IF;
	SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
    "action", "Procedure",
    "data", JSON_OBJECT(
        "query", "dispatchSessions",
        "values", JSON_ARRAY(
            organizationID
        )
    )
  ));
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `bindDialog`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE userID, socketID, nowUserID, page, organizationID INT(11);
	DECLARE nowUserName VARCHAR(64);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON DEFAULT JSON_ARRAY();
	DECLARE nowDialogBotWork TINYINT(1);
	IF validOperation 
		THEN BEGIN
			SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
			SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT user_id, dialog_bot_work INTO nowUserID, nowDialogBotWork FROM dialogues WHERE dialog_id = dialogID;
			SELECT state_json ->> "$.page" INTO page FROM states WHERE socket_id = socketID;
			IF nowUserID IS NOT NULL
				THEN BEGIN
					IF nowUserID = userID
						THEN BEGIN
							UPDATE dialogues SET user_id = NULL, dialog_bot_work = 1 WHERE dialog_id = dialogID;
							SET nowUserID = NULL;
							SET nowDialogBotWork = 1;
						END;
					END IF;
				END;
				ELSE BEGIN 
					UPDATE dialogues SET user_id = userID WHERE dialog_id = dialogID;
					SET nowUserID = userID;
				END;
			END IF;
			CASE page
				WHEN 9 THEN BEGIN 
					CALL getDialog(socketID, dialogID);
					SELECT user_name INTO nowUserName FROM users WHERE user_id = nowUserID;
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "sendToSocket",
						"data", JSON_OBJECT(
							"socket", connectionID,
							"data", JSON_ARRAY(
								JSON_OBJECT(
									"action", "mergeDeep",
									"data", JSON_OBJECT(
										"dialog", JSON_OBJECT(
											"user_id", nowUserID,
											"user_name", nowUserName,
											"dialog_bot_work", nowDialogBotWork
										)
									)
								)
							)
						)
					));
				END;
				ELSE BEGIN END;
			END CASE;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
          "action", "Procedure",
          "data", JSON_OBJECT(
              "query", "dispatchSessions",
              "values", JSON_ARRAY(
                  organizationID
              )
          )
      ));
			RETURN responce;
		END;
	END IF;
	RETURN 0;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `deleteEntities`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `entitiesID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE socketID, organizationID, botID INT(11);
	DECLARE connectionID VARCHAR(32);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation 
		THEN BEGIN
			SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT bot_id INTO botID FROM entities WHERE entities_id = entitiesID;
			DELETE FROM entities WHERE entities_id = entitiesID AND organization_id = organizationID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 7) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchEntities",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "merge",
								"data", JSON_OBJECT(
									"page", 7
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/entities:", botID)
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `deleteGroup`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `groupID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID, socketID, botID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT bot_id INTO botID FROM groups WHERE group_id = groupID AND organization_id = organizationID;
			DELETE FROM groups WHERE group_id = groupID AND organization_id = organizationID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 30, "$.bot", JSON_OBJECT("bot_id", botID)) WHERE socket_id = socketID;
			SET responce = dispatchGroup(organizationID, groupID);
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchGroups",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchIntents",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "merge",
								"data", JSON_OBJECT(
									"page", 30
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/groups:", botID)
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `deleteIntent`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `intentID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOpertation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE socketID, organizationID, botID, groupID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, groups JSON;
	SET responce = JSON_ARRAY();
	SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
	IF validOpertation
		THEN BEGIN
			SELECT bot_id, group_id INTO botID, groupID FROM intents WHERE intent_id = intentID;
			DELETE FROM intents WHERE intent_id = intentID AND organization_id = organizationID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 6) WHERE socket_id = socketID;
			SET groups = getIntentsGroups(organizationID);
			SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, groupID));
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchIntents",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchGroups",
						"values", JSON_ARRAY(
							organizationID,
							botID
						)
					)
				),
				JSON_OBJECT(
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "merge",
								"data", JSON_OBJECT(
									"page", 6,
									"groups", groups,
									"bot", JSON_OBJECT(
										"bot_id", botID
									)
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/intents:", botID)
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchBot`(`organizationID` INT(11), `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, bot JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND (state_json ->> "$.page" = 24 OR state_json ->> "$.page" = 25) AND state_json ->> "$.bot.bot_id" = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SELECT bot_json INTO bot FROM bot_info WHERE organization_id = organizationID AND bot_id = botID;
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			UPDATE states SET state_json = JSON_SET(state_json, "$.bot", bot) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"bot", bot
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchClient`(`clientID` INT(11), `action` VARCHAR(128) CHARSET utf8, `data` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	DECLARE done TINYINT(1);
	DECLARE socketsCursor CURSOR FOR SELECT socket_connection_id FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO connectionID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", action,
							"data", data
						)
					)
				)
			));
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchClientInfo`(`organizationID` INT(11), `clientID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, client JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND (state_json ->> "$.page" = 11 OR state_json ->> "$.page" = 19) AND state_json ->> "$.client.client_id" = clientID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT client_json INTO client FROM clients_json WHERE organization_id = organizationID AND client_id = clientID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"client", client
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchDialog`(`organizationID` INT(11), `dialogID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE responce, dialog JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 9 AND state_json ->> "$.dialog.dialog_id" = dialogID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			CALL getDialog(socketID, dialogID);
			SELECT state_json ->> "$.dialog" INTO dialog FROM states WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"dialog", dialog
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchDispatches`(`organizationID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE responce, dispatches JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 16;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			CALL getDispatchesForSocket(socketID);
			SELECT state_json ->> "$.dispatches" INTO dispatches FROM states WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"dispatches", dispatches
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchGroup`(`organizationID` INT(11), `groupID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, groupObj JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 32 AND state_json ->> "$.group.group_id" = groupID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SELECT group_json INTO groupObj FROM group_info WHERE organization_id = organizationID AND group_id = groupID;
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			UPDATE states SET state_json = JSON_SET(state_json, "$.group", groupObj) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"group", groupObj
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchIntent`(`organizationID` INT(11), `intentID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, groupObj JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 28 AND state_json ->> "$.intent.intent_id" = intentID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, getIntentForSocket(socketID, intentID));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchOrganization`(`organizationID` INT(11), `viewOrganizationID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, organization JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND (state_json ->> "$.page" = 20 OR state_json ->> "$.page" = 21) AND state_json ->> "$.viewOrganization.organization_id" = viewOrganizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			CALL getOrganizationForSocket(socketID, viewOrganizationID);
			SELECT state_json ->> "$.viewOrganization" INTO organization FROM states WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"viewOrganization", organization
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchWidgetsState`(`organizationID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done, organizationWidgetsWork TINYINT(1);
	DECLARE responce, dispatches JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 22;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SELECT organization_widgets_work INTO organizationWidgetsWork FROM organizations WHERE organization_id = organizationID;
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.organization.organization_widgets_work", organizationWidgetsWork) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "mergeDeep",
							"data", JSON_OBJECT(
								"organization", JSON_OBJECT(
									"organization_widgets_work", organizationWidgetsWork
								)
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `forgotPassword`(`socketHash` VARCHAR(32) CHARSET utf8, `userEmail` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE userPassword VARCHAR(32);
	DECLARE connectionID VARCHAR(128);
	DECLARE message VARCHAR(52);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT user_password INTO userPassword FROM users WHERE user_email = userEmail;
	SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_hash = socketHash;
	IF userPassword IS NOT NULL
		THEN BEGIN
			SET message = "Сообщение с паролем будет направленно на вашу почту.";
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "Email",
				"data", JSON_OBJECT(
					"emails", JSON_ARRAY(
						userEmail
					),
					"subject", "Востановление пароля",
					"text", CONCAT("Ваш пароль: ", userPassword)
				)
			));
		END;
		ELSE SET message = "Пользователь с таким email не найден.";
	END IF;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendToSocket",
		"data", JSON_OBJECT(
			"socket", connectionID,
			"data", JSON_ARRAY(
				JSON_OBJECT(
					"action", "merge",
					"data", JSON_OBJECT(
						"forgotPasswordMessage", message
					)
				),
				JSON_OBJECT(
					"action", "changePage",
					"data", JSON_OBJECT(
						"page", "confirm-email"
					)
				)
			)
		)
	));
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getAnswerIdForMessage`(`messageID` INT(11)) RETURNS int(11)
    NO SQL
BEGIN
    DECLARE messageText, entitiesString TEXT;
    DECLARE answerID, entitiesID, essenceID, stringLength, organizationID, dialogID, botID, lastLocate, essenceLength INT(11);
    DECLARE essenceValue VARCHAR(1024);
    DECLARE done TINYINT(1);
    DECLARE essencesCursor CURSOR FOR SELECT essence_value, essence_id, CHAR_LENGTH(essence_value) FROM essences;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SET entitiesString = "";
    SET answerID = 0;
    SELECT message_text, dialog_id INTO messageText, dialogID FROM messages WHERE message_id = messageID;
    SELECT organization_id, bot_id INTO organizationID, botID FROM dialogues WHERE dialog_id = dialogID; 
    SET stringLength = CHAR_LENGTH(messageText);
    IF stringLength > 0
        THEN BEGIN
            searchLoop: LOOP
                OPEN essencesCursor;
                    essencesLoop: LOOP
                        FETCH essencesCursor INTO essenceValue, essenceID, essenceLength;
                        SET lastLocate = LOCATE(essenceValue, messageText);
                        IF done OR lastLocate > 0
                            THEN LEAVE essencesLoop;
                        END IF;
                        ITERATE essencesLoop;
                    END LOOP;
                CLOSE essencesCursor;
                IF lastLocate = 0
                    THEN LEAVE searchLoop;
                END IF;
                SET messageText = SUBSTRING(messageText, lastLocate + essenceLength);
                SELECT entities_id INTO entitiesID FROM entities_essences WHERE essence_id = essenceID;
                IF entitiesID IS NOT NULL
                    THEN BEGIN 
                        SET entitiesString = CONCAT(entitiesString, ",", entitiesID);
                    END;
                END IF;
                ITERATE searchLoop;
            END LOOP;
        END;
        SET stringLength = CHAR_LENGTH(entitiesString);
        IF stringLength > 0
            THEN BEGIN
                SET entitiesString = RIGHT(entitiesString, stringLength - 1);
                UPDATE messages SET message_value = entitiesString WHERE message_id = messageID;
                SELECT answer_id INTO answerID FROM conditions_answers WHERE condition_entities = entitiesString AND organization_id = organizationID AND bot_id = botID LIMIT 1;
            END;
        END IF;
    END IF;
    RETURN answerID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getBotEntities`(`organizationID` INT(11), `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE responce, entities JSON;
	DECLARE done TINYINT(1);
	DECLARE entitiesCursor CURSOR FOR SELECT entities_json FROM bot_entities WHERE bot_id = botID AND organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN entitiesCursor;
		entitiesLoop: LOOP
			FETCH entitiesCursor INTO entities;
			IF done 
				THEN LEAVE entitiesLoop;
			END IF;
			SET responce = JSON_MERGE(responce, entities);
			ITERATE entitiesLoop;
		END LOOP;
	CLOSE entitiesCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getBotIntentsGroups`(`organizationID` INT(11), `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE responce, gGroup JSON;
	DECLARE done TINYINT(1);
	DECLARE groupsCursor CURSOR FOR SELECT group_json FROM organization_groups WHERE organization_id = organizationID AND type_id = 6 AND bot_id = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN groupsCursor;
		groupsLoop: LOOP
			FETCH groupsCursor INTO gGroup;
			IF done
				THEN LEAVE groupsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, gGroup);
			ITERATE groupsLoop;
		END LOOP;
	CLOSE groupsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getBots`(`organizationID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE responce, bot JSON;
	DECLARE done TINYINT(1);
	DECLARE botsCursor CURSOR FOR SELECT bot_json FROM organization_bots WHERE organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN botsCursor;
		botsLoop: LOOP
			FETCH botsCursor INTO bot;
			IF done
				THEN LEAVE botsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, bot);
			ITERATE botsLoop;
		END LOOP;
	CLOSE botsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getBotsForDispatch`(`dispatchID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE bots, bot JSON DEFAULT JSON_ARRAY();
	DECLARE done TINYINT(1);
	DECLARE botsCursor CURSOR FOR SELECT bot_json FROM bot_json WHERE dispatch_id = dispatchID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN botsCursor;
		botsLoop: LOOP
			FETCH botsCursor INTO bot;
			IF done
				THEN LEAVE botsLoop;
			END IF;
			SET bots = JSON_MERGE(bots, bot);
			ITERATE botsLoop;
		END LOOP;
	CLOSE botsCursor;
	RETURN bots;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getBotsToServer`() RETURNS json
    NO SQL
BEGIN
	DECLARE responce, bot JSON;
	DECLARE done TINYINT(1);
	DECLARE botsCursor CURSOR FOR SELECT bot_json FROM bots_json;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN botsCursor;
		botsLoop: LOOP
			FETCH botsCursor INTO bot;
			IF done
				THEN LEAVE botsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, bot);
			ITERATE botsLoop;
		END LOOP;
	CLOSE botsCursor;
	RETURN JSON_ARRAY(JSON_OBJECT(
		"action", "connectBots",
		"data", JSON_OBJECT(
			"bots", responce
		)
	));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getEntitiesGroups`(`organizationID` INT(11), `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE responce, gGroup JSON;
	DECLARE done TINYINT(1);
	DECLARE groupsCursor CURSOR FOR SELECT group_json FROM organization_groups WHERE organization_id = organizationID AND type_id = 7 AND bot_id = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN groupsCursor;
		groupsLoop: LOOP
			FETCH groupsCursor INTO gGroup;
			IF done
				THEN LEAVE groupsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, gGroup);
			ITERATE groupsLoop;
		END LOOP;
	CLOSE groupsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getEntityForSocket`(`socketID` INT(11), `entitiesID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE responce, entityArray, entity JSON;
	DECLARE entityID, lastEntityID, essenceID, entityNumber, botID INT(11);
	DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM entities WHERE entities_id = entitiesID);
	DECLARE done TINYINT(1);
	DECLARE essenceValue VARCHAR(1024);
	DECLARE connectionID VARCHAR(128);
	DECLARE entityCursor CURSOR FOR SELECT entity_id, essence_id FROM entity_essences WHERE entities_id = entitiesID AND organization_id = organizationID ORDER BY entity_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET entityArray = JSON_ARRAY(JSON_ARRAY());
	SET responce = JSON_ARRAY();
	SET entityNumber = 0;
	SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
	SELECT entities_json, bot_id INTO entity, botID FROM entities_info WHERE entities_id = entitiesID AND organization_id = organizationID;
	OPEN entityCursor;
		entityLoop: LOOP
			FETCH entityCursor INTO entityID, essenceID;
			IF done 
				THEN LEAVE entityLoop;
			END IF;
			IF lastEntityID IS NOT NULL AND entityID != lastEntityID
				THEN BEGIN
					SET entityArray = JSON_SET(entityArray, CONCAT("$[", JSON_LENGTH(entityArray), "]"), JSON_ARRAY());
					SET entityNumber = JSON_LENGTH(entityArray) - 1;	
				END;
			END IF;
			SET lastEntityID = entityID;
			SELECT essence_value INTO essenceValue FROM essences WHERE essence_id = essenceID;
			SET entityArray = JSON_ARRAY_APPEND(entityArray, CONCAT("$[", entityNumber, "]"), essenceValue);
			ITERATE entityLoop;
		END LOOP;
	CLOSE entityCursor;
	SET entity = JSON_SET(entity, "$.entities", entityArray);
	UPDATE states SET state_json = JSON_SET(state_json, "$.page", 35, "$.entity", entity) WHERE socket_id = socketID;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendToSocket",
		"data", JSON_OBJECT(
			"socket", connectionID,
			"data", JSON_ARRAY(
				JSON_OBJECT(
					"action", "merge",
					"data", JSON_OBJECT(
						"page", 35,
						"entity", entity,
						"bot", JSON_OBJECT(
							"bot_id", botID
						)
					)
				),
				JSON_OBJECT(
					"action", "changePage",
					"data", JSON_OBJECT(
						"page", CONCAT("app/entity:", entitiesID)
					)
				)
			)
		)
	));
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getHash`(`max` INT(3)) RETURNS varchar(999) CHARSET utf8
    NO SQL
BEGIN
	DECLARE symbol VARCHAR(1);
    DECLARE str VARCHAR(999) DEFAULT "";
    DECLARE iterator INT(11) DEFAULT 0;
    generation: LOOP
    	SET symbol = LOWER(CONV(CEIL(RAND()*0xF),10,16)),
        	iterator = iterator + 1;
        IF CEIL(RAND()*2) = 1 
        	THEN SET symbol = UPPER(symbol);
        END IF;
        SET str = CONCAT(str, symbol);
        IF iterator < max
        	THEN ITERATE generation;
            ELSE LEAVE generation;
 		END IF;
    END LOOP;
   	RETURN str;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getIntentForSocket`(`socketID` INT(11), `intentID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE done TINYINT(1);
	DECLARE entitiesLength, entitiesIterator, conditionsIterator INT(11);
	DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM sockets WHERE socket_id = socketID);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce, entitiesArray, entities, conditionsArray, intent JSON;
	DECLARE conditionEntities TEXT;
	DECLARE conditionsCursor CURSOR FOR SELECT condition_entities FROM conditions WHERE intent_id = intentID AND organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SELECT intent_json INTO intent FROM intent_json WHERE intent_id = intentID AND organization_id = organizationID;
	SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
	SET conditionsArray = JSON_ARRAY();
	SET responce = JSON_ARRAY();
	SET conditionsIterator = 0;
	OPEN conditionsCursor;
		conditionsLoop: LOOP
			FETCH conditionsCursor INTO conditionEntities;
			IF done 
				THEN LEAVE conditionsLoop;
			END IF;
			SET entitiesArray = CONCAT("[", conditionEntities, "]");
			SET entitiesLength = JSON_LENGTH(entitiesArray);
			SET entitiesIterator = 0;
			entitiesLoop: LOOP
				IF entitiesIterator >= entitiesLength
					THEN LEAVE entitiesLoop;
				END IF;
				SELECT JSON_OBJECT(
					"entities_id", entities_id,
					"entities_name", entities_name
				) INTO entities FROM entities WHERE entities_id = JSON_EXTRACT(entitiesArray, CONCAT("$[", entitiesIterator, "]"));
				SET entitiesArray = JSON_SET(entitiesArray, CONCAT("$[", entitiesIterator, "]"), entities);
				SET entitiesIterator = entitiesIterator + 1;
				ITERATE entitiesLoop;
			END LOOP;
			SET conditionsArray = JSON_SET(conditionsArray, CONCAT("$[", conditionsIterator, "]"), entitiesArray);
			SET conditionsIterator = conditionsIterator + 1;
			ITERATE conditionsLoop;
		END LOOP;
	CLOSE conditionsCursor;
	SET intent = JSON_SET(intent, "$.conditions", IF(conditionsArray IS NULL, JSON_ARRAY(JSON_ARRAY()), conditionsArray));
	UPDATE states SET state_json = JSON_SET(state_json, "$.intent", intent) WHERE socket_id = socketID;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendToSocket",
		"data", JSON_OBJECT(
			"socket", connectionID,
			"data", JSON_ARRAY(
				JSON_OBJECT(
					"action", "merge",
					"data", JSON_OBJECT(
						"intent", intent
					)
				)
			)
		)
	));
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getIntentsGroups`(`organizationID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE responce, gGroup JSON;
	DECLARE done TINYINT(1);
	DECLARE groupsCursor CURSOR FOR SELECT group_json FROM organization_groups WHERE organization_id = organizationID AND type_id = 6;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN groupsCursor;
		groupsLoop: LOOP
			FETCH groupsCursor INTO gGroup;
			IF done
				THEN LEAVE groupsLoop;
			END IF;
			SET responce = JSON_MERGE(responce, gGroup);
			ITERATE groupsLoop;
		END LOOP;
	CLOSE groupsCursor;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `getTypesForDispatch`(`dispatchID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE typeID INT(11);
	DECLARE types JSON DEFAULT JSON_ARRAY();
	DECLARE done TINYINT(1);
	DECLARE typesCursor CURSOR FOR SELECT type_id FROM dispatch_types WHERE dispatch_id = dispatchID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN typesCursor;
		typesLoop: LOOP
			FETCH typesCursor INTO typeID;
			IF done
				THEN LEAVE typesLoop;
			END IF;
			SET types = JSON_MERGE(types, CONCAT("",typeID));
			ITERATE typesLoop;
		END LOOP;
	CLOSE typesCursor;
	RETURN types;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `login`(`userEmail` VARCHAR(128) CHARSET utf8, `userPassword` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS json
    NO SQL
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
    DECLARE done TINYINT(1) DEFAULT 0;
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `loginClient`(`newSocketHash` VARCHAR(32) CHARSET utf8, `oldSocketHash` VARCHAR(32) CHARSET utf8, `organizationHash` VARCHAR(32) CHARSET utf8) RETURNS json
    NO SQL
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
	RETURN JSON_ARRAY(
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
		)
	);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `loginTelegram`(`userHash` VARCHAR(32) CHARSET utf8, `chat` VARCHAR(128) CHARSET utf8, `username` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE userID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
	IF userID IS NOT NULL
		THEN BEGIN
			UPDATE users SET user_telegram_chat = chat, user_telegram_username = username, user_telegram_notification = 1 WHERE user_id = userID;
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendTelegramNotification",
				"data", JSON_OBJECT(
					"chats", JSON_ARRAY(
						chat
					),
					"message", "Авторизация чата прошла успешно. Для того чтобы выключить оповещения отправьте команду /unbindme, а для их включения /bindme."
				)
			));
		END;
		ELSE BEGIN
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendTelegramNotification",
				"data", JSON_OBJECT(
					"chats", JSON_ARRAY(
						chat
					),
					"message", "Авторизация не произошла. Пользователь не найден. Попробуйте заново скопировать код авторизации из раздела 'профиль' - https://astralbot.ru/#/app/profile"
				)
			));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `loginWithHash`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `pageID` INT(11), `itemID` INT(11)) RETURNS json
    NO SQL
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `logout`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS json
    NO SQL
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newBot`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botName` VARCHAR(64) CHARSET utf8, `botKey` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newClient`(`socketHash` VARCHAR(32) CHARSET utf8, `clientName` VARCHAR(64) CHARSET utf8, `clientEmail` VARCHAR(128) CHARSET utf8, `botHash` VARCHAR(32) CHARSET utf8, `typeID` INT(11)) RETURNS json
    NO SQL
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newCondition`(`intentId` INT, `userId` INT, `conditionEntities` TEXT CHARSET utf8) RETURNS tinyint(1)
    NO SQL
BEGIN
	INSERT INTO conditions (user_id, intent_id, condition_entities) VALUES (userId, intentId, conditionEntities);
    RETURN 1;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newDispatch`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dispatchText` TEXT CHARSET utf8, `typesArray` JSON, `botsArray` JSON) RETURNS json
    NO SQL
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
		  CALL setMessagesForDispatch(dispatchID);
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newEntities`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `groupID` INT(11), `name` VARCHAR(1024) CHARSET utf8, `entities` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE socketID, userID, organizationID, entitiesID, entitiesIterator, entitiesLength, entityIterator, entityLength, entityID, essenceID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE entityName, essenceValue VARCHAR(1024);
    DECLARE responce, entityArray JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            INSERT INTO entities (bot_id, user_id, entities_name, group_id) VALUES (botID, userID, name, groupID);
            SELECT entities_id INTO entitiesID FROM entities ORDER BY entities_id DESC LIMIT 1;
            SET entitiesIterator = 0;
            SET entitiesLength = JSON_LENGTH(entities);
            entitiesLoop: LOOP
                IF entitiesIterator >= entitiesLength
                    THEN LEAVE entitiesLoop;
                END IF;
                SET entityArray = JSON_EXTRACT(entities, CONCAT("$[", entitiesIterator, "]"));
                SET entityName = JSON_UNQUOTE(JSON_EXTRACT(entityArray, "$[0]"));
                INSERT INTO entity (entity_name, entities_id, user_id) VALUES (entityName, entitiesID, userID);
                SELECT entity_id INTO entityID FROM entity ORDER BY entity_id DESC LIMIT 1;
                SET entityIterator = 0;
                SET entityLength = JSON_LENGTH(entityArray);
                entityLoop: LOOP
                    IF entityIterator >= entityLength
                        THEN LEAVE entityLoop;
                    END IF;
                    SET essenceValue = JSON_UNQUOTE(JSON_EXTRACT(entityArray, CONCAT("$[", entityIterator, "]")));
                    SET essenceID = (SELECT (SELECT essence_id FROM essences WHERE essence_value = essenceValue) OR NULL);
                    IF essenceID 
                        THEN SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue;
                    END IF;
                    IF essenceID IS NULL
                        THEN BEGIN
                            INSERT INTO essences (essence_value, user_id) VALUES (essenceValue, userID);
                            SELECT essence_id INTO essenceID FROM essences ORDER BY essence_id DESC LIMIT 1;
                        END;
                    END IF;
                    INSERT INTO entity_essences (entity_id, essence_id, user_id) VALUES (entityID, essenceID, userID);
                    SET entityIterator = entityIterator + 1;
                    ITERATE entityLoop;
                END LOOP;
                SET entitiesIterator = entitiesIterator + 1;
                ITERATE entitiesLoop;
            END LOOP;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 7) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchEntities",
                        "values", JSON_ARRAY(
                            organizationID,
                            botID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/entities:", botID)
                                )
                            )
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newEntity`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `entityName` VARCHAR(1024) CHARSET utf8, `entitiesID` INT(11)) RETURNS tinyint(1)
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, entitiesOrganizationID, userOrganizationID INT(11);
    IF validOperation = 1
    	THEN
        	SELECT user_id, organization_id INTO userID, userOrganizationID FROM users WHERE user_hash = userHash;
            SELECT organization_id INTO entitiesOrganizationID FROM entities WHERE entities_id = entitiesID;
            IF userOrganizationID = entitiesOrganizationID
            	THEN 
                	INSERT INTO entity (user_id, entities_id, entity_name) VALUES (userID, entitiesID, entityName);
                    RETURN 1;
            END IF;
    END IF;
    RETURN 0;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newEssence`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `essenceValue` VARCHAR(1024) CHARSET utf8, `entityID` INT(11)) RETURNS tinyint(1)
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, essenceID, entityEssenceID, userOrganizationID, entityOrganizationID INT(11);
    IF validOperation = 1
    	THEN
        	SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
           	SET essenceValue = LOWER(essenceValue);
            SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue LIMIT 1;
            IF essenceID IS NULL
            	THEN 
                	INSERT INTO essences (essence_value, user_id) VALUES (essenceValue, userID);
                    SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue ORDER BY essence_id DESC LIMIT 1; 
            END IF;
            SELECT entity_essence_id INTO entityEssenceID FROM entity_essences WHERE entity_id = entityID AND essence_id = essenceID;
            IF entityEssenceID IS NULL
            	THEN 
                	SELECT organization_id INTO userOrganizationID FROM users WHERE user_id = userID;
                    SELECT organization_id INTO entityOrganizationID FROM entity WHERE entity_id = entityID;
                    IF userOrganizationID = entityOrganizationID
                    	THEN 
                        	INSERT INTO entity_essences (entity_id, essence_id, user_id) VALUES (entityID, essenceID, userID);
                    		RETURN 1;
                    END IF;
            END IF;
    END IF;
    RETURN 0;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newGroup`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `typeID` INT(11), `name` VARCHAR(64) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, organizationID, socketID, groupID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE responce JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            INSERT INTO groups (bot_id, user_id, group_name, type_id) VALUES (botID, userID, name, typeID);
            SELECT group_id INTO groupID FROM groups ORDER BY group_id DESC LIMIT 1;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 30) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchGroups",
                        "values", JSON_ARRAY(
                            organizationID,
                            botID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchIntents",
                        "values", JSON_ARRAY(
                            organizationID,
                            botID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "page", 30
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/groups:", botID)
                                )
                            )
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newIntent`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8, `conditions` JSON, `answer` TEXT CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, organizationID, intentID, socketID, conditionsLength, conditionsIterator, entitiesIterator, entitiesLength INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE conditionValue TEXT;
    DECLARE responce, entities JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            INSERT INTO intents (intent_name, bot_id, user_id, group_id) VALUES (name, botID, userID, groupID);
            SELECT intent_id INTO intentID FROM intents ORDER BY intent_id DESC LIMIT 1;
            INSERT INTO answers (user_id, intent_id, answer_text) VALUES (userID, intentID, answer);
            SET conditionsLength = JSON_LENGTH(conditions);
            SET conditionsIterator = 0;
            conditionsLoop: LOOP
                IF conditionsIterator >= conditionsLength 
                    THEN LEAVE conditionsLoop;
                END IF;
                SET entities = JSON_EXTRACT(conditions, CONCAT("$[", conditionsIterator, "]"));
                SET conditionsIterator = conditionsIterator + 1;
                SET entitiesLength = JSON_LENGTH(entities);
                SET entitiesIterator = 0;
                SET conditionValue = "";
                entitiesLoop: LOOP
                    IF entitiesIterator >= entitiesLength
                        THEN LEAVE entitiesLoop;
                    END IF;
                    SET conditionValue = CONCAT(conditionValue, ",", JSON_EXTRACT(entities, CONCAT("$[", entitiesIterator, "]")));
                    SET entitiesIterator = entitiesIterator + 1;
                    ITERATE entitiesLoop;
                END LOOP;
                SET conditionValue = RIGHT(conditionValue, LENGTH(conditionValue) - 1);
                INSERT INTO conditions (user_id, intent_id, condition_entities) VALUES (userID, intentID, conditionValue);
                ITERATE conditionsLoop;
            END LOOP;
            DELETE c1 FROM conditions c1, conditions c2 WHERE c1.condition_id > c2.condition_id AND c1.condition_entities = c2.condition_entities AND c1.intent_id = intentID AND c2.intent_id = intentID AND c1.organization_id = organizationID AND c2.organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 28, "$.intent", JSON_OBJECT("intent_id", intentID)) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, dispatchIntent(organizationID, intentID));
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchIntents",
                        "values", JSON_ARRAY(
                            organizationID,
                            botID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "page", 28
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/intent:", intentID)
                                )
                            )
                        )
                    )
                )
            ));
            IF groupID IS NOT NULL
                THEN BEGIN 
                    SET responce = JSON_MERGE(responce, JSON_OBJECT(
                        "action", "Procedure",
                        "data", JSON_OBJECT(
                            "query", "dispatchGroups",
                            "values", JSON_ARRAY(
                                organizationID,
                                botID
                            )
                        )
                    ));
                    SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, groupID));
                END;
            END IF;
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newOrganization`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `organizationName` VARCHAR(256) CHARSET utf8, `organizationSite` VARCHAR(256) CHARSET utf8, `organizationRoot` BOOLEAN) RETURNS json
    NO SQL
BEGIN
    DECLARE validOpertation TINYINT(1) DEFAULT validRootOperation(userHash, socketHash);
    DECLARE userID, socketID, organizationID, newOrganizationID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE organizations, responce, organization JSON;
    SET responce = JSON_ARRAY();
    IF validOpertation
        THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            IF organizationRoot
                THEN SET organizationRoot = 3;
                ELSE SET organizationRoot = 4;
            END IF;
            INSERT INTO organizations (organization_name, organization_site, type_id, user_id) VALUES (organizationName, organizationSite, organizationRoot, userID);
            SELECT organization_id INTO newOrganizationID FROM organizations ORDER BY organization_id DESC LIMIT 1;
            CALL getOrganizationForSocket(socketID, newOrganizationID);
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 21) WHERE socket_id = socketID;
            SELECT state_json ->> "$.viewOrganization" INTO organization FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchOrganizations",
                        "values", JSON_ARRAY(
                            organizationID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "viewOrganization", organization
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/organization:", newOrganizationID)
                                )
                            )
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newSocket`(`typeID` ENUM('1','2'), `socketConnectionID` VARCHAR(128) CHARSET utf8, `socketEngineName` VARCHAR(128) CHARSET utf8, `socketEngineVersion` VARCHAR(128) CHARSET utf8, `socketOsName` VARCHAR(128) CHARSET utf8, `socketOsVersion` VARCHAR(128) CHARSET utf8, `socketDeviceVendor` VARCHAR(128) CHARSET utf8, `socketDeviceModel` VARCHAR(128) CHARSET utf8, `socketDeviceType` VARCHAR(128) CHARSET utf8, `socketCpuArchitecture` VARCHAR(128) CHARSET utf8, `socketBrowserName` VARCHAR(128) CHARSET utf8, `socketBrowserVersion` VARCHAR(128) CHARSET utf8, `socketUrl` VARCHAR(512) CHARSET utf8, `organizationID` INT(11), `socketIP` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
    DECLARE socketHash VARCHAR(32);
    DECLARE socketID INT(11);
    DECLARE stateJson JSON;
    DECLARE connectionID VARCHAR(128);
    DECLARE responce JSON;
    SET responce = JSON_ARRAY();
    INSERT INTO sockets (
        type_id, 
        socket_connection_id, 
        socket_engine_name, 
        socket_engine_version, 
        socket_os_version, 
        socket_device_vendor, 
        socket_device_model, 
        socket_device_type,
        socket_browser_name,
        socket_browser_version,
        socket_url, 
        socket_ip, 
        organization_id, 
        socket_os_name
    ) VALUES (
        typeID, 
        socketConnectionID, 
        socketEngineName, 
        socketEngineVersion, 
        socketOsVersion, 
        socketDeviceVendor, 
        socketDeviceModel, 
        socketDeviceType,
        socketBrowserName,
        socketBrowserVersion, 
        socketUrl, 
        socketIP, 
        organizationID, 
        socketOsName
    );
    SELECT socket_hash, socket_id, socket_connection_id INTO socketHash, socketID, connectionID FROM sockets ORDER BY socket_id DESC LIMIT 1;
    SET stateJson = JSON_OBJECT(
        "socket", JSON_OBJECT(
            "hash", socketHash
        )
    );
    UPDATE states SET state_json = stateJson WHERE socket_id = socketID;
    IF typeID = 1 
        THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
            "action", "sendToSocket",
            "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                    JSON_OBJECT(
                        "action", "setSocketHash",
                        "data", JSON_OBJECT(
                            "newSocketHash", socketHash
                        )
                    ),
                    JSON_OBJECT(
                        "action", "sendInfo"
                    )
                )
            )
        ));
        ELSE SET responce = JSON_MERGE(responce, JSON_OBJECT(
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
                        "data", JSON_OBJECT(
                            "socket", socketHash
                        )
                    )
                )
            )
        ));
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `newUser`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `userEmail` VARCHAR(128) CHARSET utf8, `userName` VARCHAR(64) CHARSET utf8, `organizationID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validRootOperation(userHash, socketHash);
  DECLARE userID, newUserID, socketID INT(11);
  DECLARE connectionID VARCHAR(128);
  DECLARE userPassword VARCHAR(32);
  DECLARE responce, users JSON;
  SET responce = JSON_ARRAY();
  IF validOperation = 1
  	THEN 
      	SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
      	SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
      	INSERT INTO users (user_name, user_email, user_creator, organization_id) VALUES (userName, userEmail, userID, organizationID);
        SELECT user_password INTO userPassword FROM users ORDER BY user_id DESC LIMIT 1;
      	UPDATE states SET state_json = JSON_SET(state_json, "$.page", 12) WHERE socket_id = socketID;
      	SET responce = JSON_MERGE(responce, JSON_ARRAY(
      		JSON_OBJECT(
      			"action", "Procedure",
      			"data", JSON_OBJECT(
      				"query", "dispatchUsers",
      				"values", JSON_ARRAY(
      					organizationID
      				)
      			)
      		),
      		JSON_OBJECT(
      			"action", "sendToSocket",
      			"data", JSON_OBJECT(
      				"socket", connectionID,
      				"data", JSON_ARRAY(
      					JSON_OBJECT(
      						"action", "changePage",
      						"data", JSON_OBJECT(
      							"page", "app/administrators"
      						)
      					)
      				)
      			)
      		),
          JSON_OBJECT(
            "action", "Email",
            "data", JSON_OBJECT(
              "emails", JSON_ARRAY(
                userEmail
              ),
              "subject", "Добро пожаловать в astralbot",
              "text", CONCAT("Вы были приглашены в систему https://astralbot.ru .

Ваш пароль для входа: ", userPassword, " . 

Пароль можно сменить в разделе 'Профиль'")
            )
          )
      	));
  END IF;
  RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `onOffBotInDialog`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE dialogBotWork TINYINT(1);
	DECLARE organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT dialog_bot_work, organization_id INTO dialogBotWork, organizationID FROM dialogues WHERE dialog_id = dialogID;
			IF dialogBotWork
				THEN BEGIN 
					UPDATE dialogues SET dialog_bot_work = 0 WHERE dialog_id = dialogID;
					SET dialogBotWork = 0;
				END;
				ELSE BEGIN 
					UPDATE dialogues SET dialog_bot_work = 1 WHERE dialog_id = dialogID;
					SET dialogBotWork = 1;
				END;
			END IF;
			SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `removeError`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT organization_id INTO organizationID FROM users WHERE user_hash = userHash;
			UPDATE dialogues SET dialog_error = 0 WHERE dialog_id = dialogID;
			SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `sendNotification`(`organizationID` INT(11), `messageText` TEXT CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE telegramUsers, responce JSON;
	DECLARE chat VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE telegramUsersCursor CURSOR FOR SELECT user_telegram_chat FROM users WHERE user_telegram_notification = 1 AND organization_id = organizationID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET telegramUsers = JSON_ARRAY();
	SET responce = JSON_ARRAY();
	OPEN telegramUsersCursor;
		telegramUsersLoop: LOOP
			FETCH telegramUsersCursor INTO chat;
			IF done
				THEN LEAVE telegramUsersLoop;
			END IF;
			SET telegramUsers = JSON_MERGE(telegramUsers, chat);
			ITERATE telegramUsersLoop;
		END LOOP;
	CLOSE telegramUsersCursor;
	IF JSON_LENGTH(telegramUsers) > 0
		THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
			"action", "sendTelegramNotification",
			"data", JSON_OBJECT(
				"chats", telegramUsers,
				"message", messageText
			)
		));
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setBotsFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE botsFilters, removeResult JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
    	THEN BEGIN
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
        	SELECT 
                state_json ->> "$.botsFilters.filters", 
                state_json ->> "$.botsFilters.limit", 
                state_json ->> "$.botsFilters.offset", 
                state_json ->> "$.botsFilters.order", 
                state_json ->> "$.botsFilters.desc" 
            INTO 
                botsFilters,  
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "active" THEN SET removeResult = JSON_REMOVE(
                    botsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", "inactive"))
                );
                WHEN "inactive" THEN SET removeResult = JSON_REMOVE(
                    botsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", "active"))
                );
                WHEN "all" THEN BEGIN 
                    SET botsFilters = JSON_ARRAY("all");
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET botsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        botsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET botsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(botsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                botsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET botsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET botsFilters = JSON_MERGE(botsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(botsFilters) = 0
                THEN SET botsFilters = JSON_ARRAY("all");
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.botsFilters.filters", botsFilters, 
                "$.botsFilters.limit", Llimit, 
                "$.botsFilters.offset", Oofset, 
                "$.botsFilters.order", Oorder,
                "$.botsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.botsFilters" INTO botsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "botsFilters", botsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getFilterBotsForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setClientsFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE clientsFilters, removeResult JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
    	THEN BEGIN
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
        	SELECT 
                state_json ->> "$.clientsFilters.filters", 
                state_json ->> "$.clientsFilters.limit", 
                state_json ->> "$.clientsFilters.offset", 
                state_json ->> "$.clientsFilters.order", 
                state_json ->> "$.clientsFilters.desc" 
            INTO 
                clientsFilters,  
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "active" THEN SET removeResult = JSON_REMOVE(
                    clientsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(clientsFilters, "one", "inactive"))
                );
                WHEN "inactive" THEN SET removeResult = JSON_REMOVE(
                    clientsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(clientsFilters, "one", "active"))
                );
                WHEN "all" THEN BEGIN 
                    SET clientsFilters = JSON_ARRAY("all");
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET clientsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        clientsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(clientsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET clientsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(clientsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                clientsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(clientsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET clientsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET clientsFilters = JSON_MERGE(clientsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(clientsFilters) = 0
                THEN SET clientsFilters = JSON_ARRAY("all");
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.clientsFilters.filters", clientsFilters, 
                "$.clientsFilters.limit", Llimit, 
                "$.clientsFilters.offset", Oofset, 
                "$.clientsFilters.order", Oorder,
                "$.clientsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.clientsFilters" INTO clientsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "clientsFilters", clientsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getClientsForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setEntitiesFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON, `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE entitiesFilters, removeResult, groups, filterGroups, responce JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    SET responce = JSON_ARRAY();
    IF validOperation
        THEN BEGIN
            SET filtergroups = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.groups"));
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                state_json ->> "$.entitiesFilters.filters", 
                state_json ->> "$.entitiesFilters.groups",
                state_json ->> "$.entitiesFilters.limit", 
                state_json ->> "$.entitiesFilters.offset", 
                state_json ->> "$.entitiesFilters.order", 
                state_json ->> "$.entitiesFilters.desc" 
            INTO 
                entitiesFilters, 
                groups, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "all" THEN BEGIN 
                    SET entitiesFilters = JSON_ARRAY("all");
                    SET groups = JSON_ARRAY();
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET entitiesFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        entitiesFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(entitiesFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET entitiesFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(entitiesFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                entitiesFilters,
                                JSON_UNQUOTE(JSON_SEARCH(entitiesFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET entitiesFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET entitiesFilters = JSON_MERGE(entitiesFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(entitiesFilters) = 0
                THEN SET entitiesFilters = JSON_ARRAY("all");
            END IF;
            IF filterGroups IS NOT NULL
                THEN SET groups = filterGroups;
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.entitiesFilters.filters", entitiesFilters, 
                "$.entitiesFilters.groups", groups, 
                "$.entitiesFilters.limit", Llimit, 
                "$.entitiesFilters.offset", Oofset, 
                "$.entitiesFilters.order", Oorder,
                "$.entitiesFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.entitiesFilters" INTO entitiesFilters FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "entitiesFilters", entitiesFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getEntitiesForSocket",
                        "values", JSON_ARRAY(
                            socketID,
                            botID
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setGroupsFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON, `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE groupsFilters, removeResult JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
        THEN BEGIN
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                state_json ->> "$.groupsFilters.filters", 
                state_json ->> "$.groupsFilters.limit", 
                state_json ->> "$.groupsFilters.offset", 
                state_json ->> "$.groupsFilters.order", 
                state_json ->> "$.groupsFilters.desc" 
            INTO 
                groupsFilters, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "intents" THEN SET removeResult = JSON_REMOVE(
                    groupsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", "entities"))
                );
                WHEN "entities" THEN SET removeResult = JSON_REMOVE(
                    groupsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", "intents"))
                );
                WHEN "all" THEN SET groupsFilters = JSON_ARRAY("all");
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET groupsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        groupsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET groupsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(groupsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                groupsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET groupsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET groupsFilters = JSON_MERGE(groupsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(groupsFilters) = 0
                THEN SET groupsFilters = JSON_ARRAY("all");
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.groupsFilters.filters", groupsFilters, 
                "$.groupsFilters.limit", Llimit, 
                "$.groupsFilters.offset", Oofset, 
                "$.groupsFilters.order", Oorder,
                "$.groupsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.groupsFilters" INTO groupsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "groupsFilters", groupsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getGroupsForSocket",
                        "values", JSON_ARRAY(
                            socketID,
                            botID
                        )
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setIntentsFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON, `botID` INT(11)) RETURNS json
    NO SQL
BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE intentsFilters, removeResult, groups, filterGroups JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
        THEN BEGIN
            SET filtergroups = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.groups"));
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                state_json ->> "$.intentsFilters.filters", 
                state_json ->> "$.intentsFilters.groups",
                state_json ->> "$.intentsFilters.limit", 
                state_json ->> "$.intentsFilters.offset", 
                state_json ->> "$.intentsFilters.order", 
                state_json ->> "$.intentsFilters.desc" 
            INTO 
                intentsFilters, 
                groups, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "all" THEN BEGIN 
                    SET intentsFilters = JSON_ARRAY("all");
                    SET groups = JSON_ARRAY();
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET intentsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        intentsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(intentsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET intentsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(intentsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                intentsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(intentsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET intentsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET intentsFilters = JSON_MERGE(intentsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(intentsFilters) = 0
                THEN SET intentsFilters = JSON_ARRAY("all");
            END IF;
            IF filterGroups IS NOT NULL
                THEN SET groups = filterGroups;
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.intentsFilters.filters", intentsFilters, 
                "$.intentsFilters.groups", groups, 
                "$.intentsFilters.limit", Llimit, 
                "$.intentsFilters.offset", Oofset, 
                "$.intentsFilters.order", Oorder,
                "$.intentsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.intentsFilters" INTO intentsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "intentsFilters", intentsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getIntentsForSocket",
                        "values", JSON_ARRAY(
                            socketID,
                            botID
                        )
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setOrganizationsFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE organizationsFilters, removeResult JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
    	THEN BEGIN
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
        	SELECT 
                state_json ->> "$.organizationsFilters.filters", 
                state_json ->> "$.organizationsFilters.limit", 
                state_json ->> "$.organizationsFilters.offset", 
                state_json ->> "$.organizationsFilters.order", 
                state_json ->> "$.organizationsFilters.desc" 
            INTO 
                organizationsFilters,  
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "root" THEN SET removeResult = JSON_REMOVE(
                    organizationsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", "user"))
                );
                WHEN "user" THEN SET removeResult = JSON_REMOVE(
                    organizationsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", "root"))
                );
                WHEN "all" THEN BEGIN 
                    SET organizationsFilters = JSON_ARRAY("all");
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET organizationsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        organizationsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET organizationsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(organizationsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                organizationsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET organizationsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET organizationsFilters = JSON_MERGE(organizationsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(organizationsFilters) = 0
                THEN SET organizationsFilters = JSON_ARRAY("all");
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.organizationsFilters.filters", organizationsFilters, 
                "$.organizationsFilters.limit", Llimit, 
                "$.organizationsFilters.offset", Oofset, 
                "$.organizationsFilters.order", Oorder,
                "$.organizationsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.organizationsFilters" INTO organizationsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "organizationsFilters", organizationsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getFilterOrganizationsForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setSessionsFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE sessionsFilters, removeResult, bots, filterBots JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE dateStart, dateEnd, filterDateStart, filterDateEnd VARCHAR(19);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
    	THEN BEGIN
            SET filterDateStart = DATE(FROM_UNIXTIME(JSON_UNQUOTE(JSON_EXTRACT(filter, "$.dateStart"))));
            SET filterDateEnd = DATE(FROM_UNIXTIME(JSON_UNQUOTE(JSON_EXTRACT(filter, "$.dateEnd"))));
            SET filterbots = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.bots"));
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
        	SELECT 
                state_json ->> "$.sessionsFilters.filters", 
                state_json ->> "$.sessionsFilters.bots", 
                state_json ->> "$.sessionsFilters.dateStart", 
                state_json ->> "$.sessionsFilters.dateEnd", 
                state_json ->> "$.sessionsFilters.limit", 
                state_json ->> "$.sessionsFilters.offset", 
                state_json ->> "$.sessionsFilters.order", 
                state_json ->> "$.sessionsFilters.desc" 
            INTO 
                sessionsFilters, 
                bots, 
                dateStart, 
                dateEnd, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
            	WHEN "free" THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "busy"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "user"))
                    );
                END;
                WHEN "busy" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters, 
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "free"))
                );
                WHEN "error" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "success"))
                );
                WHEN "success" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "error"))
                );
                WHEN "active" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "inactive"))
                );
                WHEN "inactive" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "active"))
                );
                WHEN "widget" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "telegram"))
                );
                WHEN "telegram" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "widget"))
                );
                WHEN "empty" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "notempty"))
                );
                WHEN "notempty" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "empty"))
                );
                WHEN "today" THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "yesterday"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "customdate"))
                    );
                    SET filterDateStart = CURDATE();
                    SET filterDateEnd = CURDATE();
                END;
                WHEN "yesterday" THEN BEGIN
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "today"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "customdate"))
                    );
                    SET filterDateStart = SUBDATE(CURDATE(), 1);
                    SET filterDateEnd = SUBDATE(CURDATE(), 1);
                END;
                WHEN "customdate" THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "today"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "yesterday"))
                    );
                END;
                WHEN "all" THEN BEGIN 
                    SET sessionsFilters = JSON_ARRAY("all");
                    SET bots = JSON_ARRAY();
                END;
                WHEN "user" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "free"))
                );
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET sessionsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(sessionsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                sessionsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET sessionsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET sessionsFilters = JSON_MERGE(sessionsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(sessionsFilters) = 0
                THEN SET sessionsFilters = JSON_ARRAY("all");
            END IF;
            IF filterDateStart IS NOT NULL
                THEN SET dateStart = filterDateStart;
            END IF;
            IF filterDateEnd IS NOT NULL
                THEN SET dateEnd = filterDateEnd;
            END IF;
            IF filterBots IS NOT NULL
                THEN SET bots = filterBots;
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.sessionsFilters.filters", sessionsFilters, 
                "$.sessionsFilters.bots", bots, 
                "$.sessionsFilters.dateStart", dateStart, 
                "$.sessionsFilters.dateEnd", dateEnd, 
                "$.sessionsFilters.limit", Llimit, 
                "$.sessionsFilters.offset", Oofset, 
                "$.sessionsFilters.order", Oorder,
                "$.sessionsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.sessionsFilters" INTO sessionsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "sessionsFilters", sessionsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getDialoguesForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setUsersFilter`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS json
    NO SQL
BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE usersFilters, removeResult JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
        THEN BEGIN
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                state_json ->> "$.usersFilters.filters", 
                state_json ->> "$.usersFilters.limit", 
                state_json ->> "$.usersFilters.offset", 
                state_json ->> "$.usersFilters.order", 
                state_json ->> "$.usersFilters.desc" 
            INTO 
                usersFilters,  
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "active" THEN SET removeResult = JSON_REMOVE(
                    usersFilters,
                    JSON_UNQUOTE(JSON_SEARCH(usersFilters, "one", "inactive"))
                );
                WHEN "inactive" THEN SET removeResult = JSON_REMOVE(
                    usersFilters,
                    JSON_UNQUOTE(JSON_SEARCH(usersFilters, "one", "active"))
                );
                WHEN "all" THEN BEGIN 
                    SET usersFilters = JSON_ARRAY("all");
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET usersFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        usersFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(usersFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET usersFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(usersFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                usersFilters,
                                JSON_UNQUOTE(JSON_SEARCH(usersFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET usersFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET usersFilters = JSON_MERGE(usersFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(usersFilters) = 0
                THEN SET usersFilters = JSON_ARRAY("all");
            END IF;
            IF filterLimit IS NOT NULL
                THEN SET Llimit = filterLimit;
            END IF;
            IF filterOffset IS NOT NULL
                THEN SET Oofset = filterOffset;
            END IF;
            IF filterOrder IS NOT NULL
                THEN SET Oorder = filterOrder;
            END IF;
            IF filterDesc IS NOT NULL
                THEN SET Ddesc = filterDesc;
            END IF;
            UPDATE states SET state_json = JSON_SET(
                state_json, 
                "$.usersFilters.filters", usersFilters, 
                "$.usersFilters.limit", Llimit, 
                "$.usersFilters.offset", Oofset, 
                "$.usersFilters.order", Oorder,
                "$.usersFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.usersFilters" INTO usersFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "usersFilters", usersFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getUsersForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `setWidgetsState`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
  DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE organizationID INT(11);
  DECLARE organizationWidgetsWork TINYINT(1);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  IF validOperation
    THEN BEGIN
      SELECT organization_id INTO organizationID FROM sockets WHERE socket_hash = socketHash;
      SELECT organization_widgets_work INTO organizationWidgetsWork FROM organizations WHERE organization_id = organizationID;
      SET organizationWidgetsWork = !organizationWidgetsWork;
      UPDATE organizations SET organization_widgets_work = organizationWidgetsWork WHERE organization_id = organizationID;
      SET responce = JSON_MERGE(responce, dispatchWidgetsState(organizationID));
    END;
  END IF;
  RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `socketDisconnect`(`connectionID` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateBotInfo`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `botName` VARCHAR(64) CHARSET utf8, `botKey` VARCHAR(128) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE socketID, organizationID INT(11);
	DECLARE nName VARCHAR(64);
	DECLARE kKey, connectionID VARCHAR(128);
	DECLARE responce, bot JSON;
	SET responce = JSON_ARRAY();
	SELECT socket_id, socket_connection_id, organization_id INTO socketID, connectionID, organizationID FROM sockets WHERE socket_hash = socketHash;
	IF validOperation
		THEN BEGIN
			SELECT bot_name, bot_telegram_key INTO nName, kKey FROM bots WHERE bot_id = botID;
			IF botName IS NOT NULL
				THEN SET nName = botName;
			END IF;
			IF botKey IS NOT NULL AND IF(kKey IS NULL, 1, botKey != kKey)
				THEN BEGIN 
					SET kKey = botKey;
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "connectBots",
						"data", JSON_OBJECT(
							"bots", JSON_ARRAY(
								JSON_OBJECT(
									"bot_id", botID,
									"bot_telegram_key", kKey
								)
							)
						)
					));
				END;
				ELSEIF botKey IS NULL THEN BEGIN 
					SET kKey = NULL;
					SET responce = JSON_MERGE(responce, JSON_OBJECT(
						"action", "deleteBots",
						"data", JSON_OBJECT(
							"bots", JSON_ARRAY(
								botID
							)
						)
					));
				END;
			END IF;
			UPDATE bots SET bot_name = nName, bot_telegram_key = kKey WHERE bot_id = botID;
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
			SET responce = JSON_MERGE(responce, dispatchBot(organizationID, botID));
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"page", 24
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
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateClientInfo`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `email` VARCHAR(128) CHARSET utf8, `phone` VARCHAR(11) CHARSET utf8, `name` VARCHAR(64) CHARSET utf8, `username` VARCHAR(128) CHARSET utf8, `clientID` INT(11)) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE uUsername, eEmail, connectionID VARCHAR(128);
	DECLARE pPhone BIGINT(11);
	DECLARE socketID, organizationID INT(11);
	DECLARE nName VARCHAR(64);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT 
				client_name, 
				client_username, 
				client_phone, 
				client_email,
				organization_id 
			INTO 
				nName, 
				uUsername, 
				pPhone, 
				eEmail,
				organizationID
			FROM clients WHERE client_id = clientID;
			IF name IS NOT NULL
				THEN SET nName = name;
			END IF;
			IF username IS NOT NULL
				THEN SET uUsername = username;
			END IF;
			IF email IS NOT NULL AND (email REGEXP ".*.@.*[[.full-stop.]]..*")
				THEN SET eEmail = email;
			END IF;
			IF phone IS NOT NULL AND (phone REGEXP "^[0-9]{11}$")
				THEN SET pPhone = phone;
			END IF;
			UPDATE clients SET 
				client_email = eEmail, 
				client_username = uUsername, 
				client_phone = pPhone, 
				client_name = nName
			WHERE client_id = clientID;
			UPDATE states SET state_json = JSON_SET(state_json, "$.page", 11) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, dispatchClientInfo(organizationID, clientID));
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchClients",
						"values", JSON_ARRAY(
							organizationID
						)
					)
				),
				JSON_OBJECT(
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", CONCAT("app/client:", clientID)
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateEntities`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `entitiesID` INT(11), `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8, `entities` JSON) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE socketID, userID, botID, organizationID, entitiesIterator, entitiesLength, entityIterator, entityLength, entityID, essenceID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE entityName, essenceValue VARCHAR(1024);
    DECLARE responce, entityArray JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT bot_id INTO botID FROM entities WHERE entities_id = entitiesID;
            UPDATE entities SET entities_name = name, group_id = groupID WHERE entities_id = entitiesID;
            SET entitiesIterator = 0;
            SET entitiesLength = JSON_LENGTH(entities);
            DELETE FROM entity WHERE entities_id = entitiesID;
            entitiesLoop: LOOP
                IF entitiesIterator >= entitiesLength
                    THEN LEAVE entitiesLoop;
                END IF;
                SET entityArray = JSON_EXTRACT(entities, CONCAT("$[", entitiesIterator, "]"));
                SET entityName = JSON_UNQUOTE(JSON_EXTRACT(entityArray, "$[0]"));
                INSERT INTO entity (entity_name, entities_id, user_id) VALUES (entityName, entitiesID, userID);
                SELECT entity_id INTO entityID FROM entity ORDER BY entity_id DESC LIMIT 1;
                SET entityIterator = 0;
                SET entityLength = JSON_LENGTH(entityArray);
                entityLoop: LOOP
                    IF entityIterator >= entityLength
                        THEN LEAVE entityLoop;
                    END IF;
                    SET essenceValue = JSON_UNQUOTE(JSON_EXTRACT(entityArray, CONCAT("$[", entityIterator, "]")));
                    SET essenceID = (SELECT (SELECT essence_id FROM essences WHERE essence_value = essenceValue) OR NULL);
                    IF essenceID 
                        THEN SELECT essence_id INTO essenceID FROM essences WHERE essence_value = essenceValue;
                    END IF;
                    IF essenceID IS NULL
                        THEN BEGIN
                            INSERT INTO essences (essence_value, user_id) VALUES (essenceValue, userID);
                            SELECT essence_id INTO essenceID FROM essences ORDER BY essence_id DESC LIMIT 1;
                        END;
                    END IF;
                    INSERT INTO entity_essences (entity_id, essence_id, user_id) VALUES (entityID, essenceID, userID);
                    SET entityIterator = entityIterator + 1;
                    ITERATE entityLoop;
                END LOOP;
                SET entitiesIterator = entitiesIterator + 1;
                ITERATE entitiesLoop;
            END LOOP;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 35, "$.bot", JSON_OBJECT("bot_id", botID)) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, getEntityForSocket(socketID, entitiesID));
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchEntities",
                        "values", JSON_ARRAY(
                            organizationID,
                            botID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "page", 35
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/entity:", entitiesID)
                                )
                            )
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateGroup`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID, socketID, botID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			IF LENGTH(name) > 0
				THEN BEGIN
					SELECT organization_id, socket_id, socket_connection_id INTO organizationID, socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
					SELECT bot_id INTO botID FROM groups WHERE group_id = groupID;
					UPDATE groups SET group_name = name WHERE group_id = groupID;
					UPDATE states SET state_json = JSON_SET(state_json, "$.page", 32) WHERE socket_id = socketID;
					SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, groupID));
					SET responce = JSON_MERGE(responce, JSON_ARRAY(
						JSON_OBJECT(
							"action", "sendToSocket",
							"data", JSON_OBJECT(
								"socket", connectionID,
								"data", JSON_ARRAY(
									JSON_OBJECT(
										"action", "merge",
										"data", JSON_OBJECT(
											"page", 32
										)
									),
									JSON_OBJECT(
										"action", "changePage",
										"data", JSON_OBJECT(
											"page", CONCAT("app/group:", groupID)
										)
									)
								)
							)
						),
						JSON_OBJECT(
							"action", "Procedure",
							"data", JSON_OBJECT(
								"query", "dispatchGroups",
								"values", JSON_ARRAY(
									organizationID,
									botID
								)
							)
						),
						JSON_OBJECT(
							"action", "Procedure",
							"data", JSON_OBJECT(
								"query", "dispatchIntents",
								"values", JSON_ARRAY(
									organizationID,
									botID
								)
							)
						)
					));
				END;
			END IF;
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateIntent`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `intentID` INT(11), `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8, `conditions` JSON, `answer` TEXT CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE userID, organizationID, socketID, conditionsLength, conditionsIterator, entitiesIterator, entitiesLength, lastGroupID, conditionsCount, botID, oldGroupID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE conditionValue, lastAnswer TEXT;
    DECLARE lastName VARCHAR(64);
    DECLARE responce, entities JSON;
    SET responce = JSON_ARRAY();
    IF validOperation = 1
    	THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                intent_json ->> "$.intent_name",
                intent_json ->> "$.answer_text",
                group_id,
                bot_id
            INTO
                lastName,
                lastAnswer,
                lastGroupID,
                botID
            FROM intent_json WHERE intent_id = intentID;
            IF name IS NOT NULL AND name != lastName
                THEN SET lastName = name;
            END IF;
            IF answer IS NOT NULL AND answer != lastAnswer
                THEN SET lastAnswer = answer;
            END IF;
            SET oldGroupID = lastGroupID;
            SET lastGroupID = groupID;
            UPDATE intents SET intent_name = lastName, group_id = lastGroupID WHERE intent_id = intentID AND organization_id = organizationID;
            IF oldGroupID IS NOT NULL
                THEN SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, oldGroupID));
            END IF;
            IF lastGroupID IS NOT NULL 
                THEN SET responce = JSON_MERGE(responce, dispatchGroup(organizationID, lastGroupID));
            END IF;
            SET responce = JSON_MERGE(responce, JSON_OBJECT(
                "action", "Procedure",
                "data", JSON_OBJECT(
                    "query", "dispatchGroups",
                    "values", JSON_ARRAY(
                        organizationID,
                        botID
                    )
                )
            ));
            UPDATE answers SET answer_text = lastAnswer WHERE intent_id = intentID AND organization_id = organizationID;
            DELETE FROM conditions WHERE intent_id = intentID AND organization_id = organizationID;
            SET conditionsLength = JSON_LENGTH(conditions);
            SET conditionsIterator = 0;
            conditionsLoop: LOOP
                IF conditionsIterator >= conditionsLength 
                    THEN LEAVE conditionsLoop;
                END IF;
                SET entities = JSON_EXTRACT(conditions, CONCAT("$[", conditionsIterator, "]"));
                SET entitiesLength = JSON_LENGTH(entities);
                SET entitiesIterator = 0;
                SET conditionValue = "";
                entitiesLoop: LOOP
                    IF entitiesIterator >= entitiesLength
                        THEN LEAVE entitiesLoop;
                    END IF;
                    SET conditionValue = CONCAT(conditionValue, ",", JSON_EXTRACT(entities, CONCAT("$[", entitiesIterator, "]")));
                    SET entitiesIterator = entitiesIterator + 1;
                    ITERATE entitiesLoop;
                END LOOP;
                SET conditionValue = RIGHT(conditionValue, LENGTH(conditionValue) - 1);
                INSERT INTO conditions (intent_id, user_id, condition_entities) VALUES (intentID, userID, conditionValue);
                SET conditionsIterator = conditionsIterator + 1;
                ITERATE conditionsLoop;
            END LOOP;
            DELETE c1 FROM conditions c1, conditions c2 WHERE c1.condition_id > c2.condition_id AND c1.condition_entities = c2.condition_entities AND c1.intent_id = intentID AND c2.intent_id = intentID AND c1.organization_id = organizationID AND c2.organization_id = organizationID;
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 28) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, dispatchIntent(organizationID, intentID));
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchIntents",
                        "values", JSON_ARRAY(
                            organizationID,
                            botID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "page", 28 
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/intent:", intentID)
                                )
                            )
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateOrganization`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `organizationID` INT(11), `name` VARCHAR(256) CHARSET utf8, `site` VARCHAR(256) CHARSET utf8, `organizationRoot` BOOLEAN) RETURNS json
    NO SQL
BEGIN
  DECLARE validOrganization TINYINT(1) DEFAULT validRootOperation(userHash, socketHash);
  DECLARE Nname, Ssite VARCHAR(256);
  DECLARE connectionID VARCHAR(128);
  DECLARE typeID, socketID, userOrganizationID INT(11);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  IF validOrganization
    THEN BEGIN
      SELECT socket_id, organization_id, socket_connection_id INTO socketID, userOrganizationID, connectionID FROM sockets WHERE socket_hash = socketHash;
      SELECT organization_name, organization_site, type_id INTO Nname, Ssite, typeID FROM organizations WHERE organization_id = organizationID;
      IF name IS NOT NULL
        THEN SET Nname = name;
      END IF;
      IF site IS NOT NULL
        THEN SET Ssite = site;
      END IF;
      IF organizationRoot IS NOT NULL
        THEN BEGIN
          IF organizationRoot
            THEN SET typeID = 3;
            ELSE SET typeID = 4;
          END IF;
        END;
      END IF;
      UPDATE organizations SET organization_name = Nname, organization_site = Ssite, type_id = typeID WHERE organization_id = organizationID;
      UPDATE states SET state_json = JSON_SET(state_json, "$.viewOrganization.organization_name", Nname, "$.viewOrganization.organization_site", Ssite, "$.viewOrganization.type_id", typeID) WHERE socket_id = socketID;
      SET responce = JSON_MERGE(responce, dispatchOrganization(userOrganizationID, organizationID));
      SET responce = JSON_MERGE(responce, JSON_ARRAY(
        JSON_OBJECT(
          "action", "Procedure",
          "data", JSON_OBJECT(
            "query", "dispatchOrganizations",
            "values", JSON_ARRAY(
              userOrganizationID
            )
          )
        ),
        JSON_OBJECT(
          "action", "sendToSocket",
          "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(
              JSON_OBJECT(
                "action", "changePage",
                "data", JSON_OBJECT(
                  "page", CONCAT("app/organization:", organizationID)
                )
              )
            )
          )
        )
      ));
    END;
  END IF;
  RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateProfile`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `email` VARCHAR(128) CHARSET utf8, `password` VARCHAR(32) CHARSET utf8, `name` VARCHAR(64) CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE eEmail, connectionID VARCHAR(128);
	DECLARE socketID, userID, organizationID INT(11);
	DECLARE nName VARCHAR(64);
	DECLARE pPassword VARCHAR(32);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOperation
		THEN BEGIN
			SELECT socket_id, organization_id, socket_connection_id INTO socketID, organizationID, connectionID FROM sockets WHERE socket_hash = socketHash;
			SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
			SELECT 
				user_name, 
				user_email,
				user_password
			INTO 
				nName, 
				eEmail,
				pPassword
			FROM users WHERE user_id = userID;
			IF name IS NOT NULL
				THEN SET nName = name;
			END IF;
			IF email IS NOT NULL AND (email REGEXP ".*.@.*[[.full-stop.]]..*")
				THEN SET eEmail = email;
			END IF;
			IF password IS NOT NULL
				THEN SET pPassword = password;
			END IF;
			UPDATE users SET 
				user_email = eEmail, 
				user_name = nName,
				user_password = pPassword
			WHERE user_id = userID;
			UPDATE states SET state_json = JSON_SET(
				state_json,
				"$.user.user_email", eEmail,
				"$.user.user_name", nName,
				"$.page", 13
			) WHERE socket_id = socketID;
			SET responce = JSON_MERGE(responce, JSON_ARRAY(
				JSON_OBJECT(
					"action", "Procedure",
					"data", JSON_OBJECT(
						"query", "dispatchUsers",
						"values", JSON_ARRAY(
							organizationID
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
					"action", "sendToSocket",
					"data", JSON_OBJECT(
						"socket", connectionID,
						"data", JSON_ARRAY(
							JSON_OBJECT(
								"action", "mergeDeep",
								"data", JSON_OBJECT(
									"user", JSON_OBJECT(
										"name", nName,
										"email", eEmail
									)
								)
							),
							JSON_OBJECT(
								"action", "changePage",
								"data", JSON_OBJECT(
									"page", "app/profile"
								)
							)
						)
					)
				)
			));
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `updateUserProfile`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `userEmail` VARCHAR(128) CHARSET utf8, `userPassword` VARCHAR(32) CHARSET utf8, `userName` VARCHAR(64) CHARSET utf8) RETURNS tinyint(1)
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE oldEmail, userTelegramUsername VARCHAR(128);
    DECLARE oldName, creatorName VARCHAR(64);
    DECLARE oldPassword VARCHAR(32);
    DECLARE userID, socketID, organizationID, creatorID, userSocketsCount, userSocketsOnlineCount INT(11);
    DECLARE stateJson, userJson JSON;
    DECLARE userDateCreate, userDateUpdate VARCHAR(19);
    DECLARE userTelegramNotification, userWebNotifications, userOnline TINYINT(1);
    DECLARE organizationName VARCHAR(256);
    IF validOperation = 1
    	THEN 
			IF userEmail IS NULL OR userPassword IS NULL OR userName IS NULL
            	THEN
                	SELECT user_email, user_password, user_name INTO oldEmail, oldPassword, oldName FROM users WHERE user_hash = userhash;
                	IF userEmail IS NULL THEN SET userEmail = oldEmail; END IF;
                	IF userPassword IS NULL THEN SET userPassword = oldPassword; END IF;
                	IF userName IS NULL THEN SET userName = oldName; END IF;
            END IF;
			UPDATE users SET user_email = userEmail, user_name = user_name, user_password = userPassword WHERE user_hash = userHash;
            SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
            SELECT socket_id INTO socketID FROM sockets WHERE socket_hash = socketHash;
            SELECT state_json INTO stateJson FROM states WHERE socket_id = socketID;
            SELECT user_name, user_email, user_password INTO userName, userEmail, userPassword FROM users WHERE user_id = userID;
           	SET userJson = JSON_EXTRACT(stateJson, "$.user");
            SET userJson = JSON_SET(userJson, "$.name", userName, "$.email", userEmail);
            SET stateJson = JSON_SET(stateJson, "$.user", userJson);
            UPDATE states SET state_json = stateJson WHERE socket_id = socketID;
            RETURN 1;
    END IF;
    RETURN 0;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `userMessage`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11), `message` TEXT CHARSET utf8) RETURNS json
    NO SQL
BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE responce JSON DEFAULT JSON_ARRAY();
	DECLARE userID, socketID, messagesLength, clientID, clientSocketID, organizationID, botID INT(11);
	DECLARE chat VARCHAR(128);
	DECLARE messages, newMessage JSON;
	IF validOperation
		THEN BEGIN
			IF LENGTH(message) > 0
				THEN BEGIN 
					SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
					SELECT socket_id INTO socketID FROM sockets WHERE socket_hash = socketHash;
					INSERT INTO messages (dialog_id, user_id, message_text) VALUES (dialogID, userID, message);					
					CALL getDialog(socketID, dialogID);
					SELECT state_json ->> "$.dialog.messages" INTO messages FROM states WHERE socket_id = socketID;
					SET messagesLength = JSON_LENGTH(messages);
					SET newMessage = JSON_EXTRACT(messages, CONCAT("$[", messagesLength - 1, "]"));
					SELECT client_id, bot_id INTO clientID, botID FROM dialogues WHERE dialog_id = dialogID;
					SELECT socket_id INTO clientSocketID FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1 LIMIT 1;
					UPDATE dialogues SET dialog_error = 0 WHERE dialog_id = dialogID;
					SELECT client_telegram_chat INTO chat FROM clients WHERE client_id = clientID;
					CALL getMessagesForSocket(clientSocketID, dialogID);
					IF chat IS NOT NULL
						THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
							"action", "sendToTelegram",
							"data", JSON_OBJECT(
								"bot_id", botID,
								"chats", JSON_ARRAY(
									chat
								),
								"message", message
							)
						));
						ELSE SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messages));
					END IF;
					SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
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
		END;
	END IF;
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `userTelegramState`(`chat` VARCHAR(128) CHARSET utf8, `state` BOOLEAN) RETURNS json
    NO SQL
BEGIN
	DECLARE responce JSON;
	DECLARE userID INT(11);
	DECLARE message VARCHAR(226);
	SET responce = JSON_ARRAY();
	SELECT user_id INTO userID FROM users WHERE user_telegram_chat = chat;
	IF userID IS NOT NULL
		THEN BEGIN
			UPDATE users SET user_telegram_notification = state WHERE user_telegram_chat = chat;
			IF state
				THEN SET message = "Оповещения включены";
				ELSE SET message = "Оповещения выключены";
			END IF;
		END;
		ELSE SET message = "Вы не авторизовали свой телеграм в системе astralbot. Для этого перейдите в раздел 'профиль' и скопируйте ключ авторизации для телеграм. После отправьте ключ в этот чат. Ссылка на ваш профиль https://astralbot.ru/#/app/profile";
	END IF;
	SET responce = JSON_MERGE(responce, JSON_OBJECT(
		"action", "sendTelegramNotification",
		"data", JSON_OBJECT(
			"chats", JSON_ARRAY(
				chat
			),
			"message", message
		)
	));
	RETURN responce;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `validRootOperation`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS tinyint(4)
    NO SQL
BEGIN
	DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_hash = userHash);
  DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
  DECLARE userSocketConnectedCount INT(11) DEFAULT (SELECT COUNT(*) FROM user_sockets_connection WHERE user_id = userID AND socket_id = socketID AND socket_connection = 1);
  DECLARE userAuth TINYINT(1) DEFAULT (SELECT user_auth FROM users WHERE user_id = userID);
  DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM users WHERE user_id = userID);
  DECLARE organizationType INT(11) DEFAULT (SELECT type_id FROM organizations WHERE organization_id = organizationID);
  IF userSocketConnectedCount > 0 AND userAuth = 1 AND organizationType = 3
  	THEN RETURN 1;
    ELSE RETURN 0;
 	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `validStandartOperation`(`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS tinyint(1)
    NO SQL
BEGIN
	DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_hash = userHash);
    DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
    DECLARE userSocketConnectedCount INT(11) DEFAULT (SELECT COUNT(*) FROM user_sockets_connection WHERE user_id = userID AND socket_id = socketID AND socket_connection = 1);
    DECLARE userAuth TINYINT(1) DEFAULT (SELECT user_auth FROM users WHERE user_id = userID);
    IF userSocketConnectedCount > 0 AND userAuth = 1
    	THEN RETURN 1;
        ELSE RETURN 0;
   	END IF;
END$$
DELIMITER ;
