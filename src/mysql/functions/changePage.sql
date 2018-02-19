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
END