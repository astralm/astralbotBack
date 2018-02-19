DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchEntities`(IN `organizationID` INT(11), IN `botID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command, groups JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 7 AND state_json ->> "$.bot.bot_id" = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SET groups = getEntitiesGroups(organizationID, botID);
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getEntitiesForSocket(socketID, botID, command);
			SET responce = JSON_MERGE(responce, command);
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"entitiesGroups", groups
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchBots`(IN `organizationID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 23;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getFilterBotsForSocket(socketID, command);
			SET responce = JSON_MERGE(responce, command);
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchOrganizations`(IN `organizationID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 17;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getFilterOrganizationsForSocket(socketID, command);
			SET responce = JSON_MERGE(responce, command);
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchClients`(IN `organizationID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 10;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getClientsForSocket(socketID, command);
			SET responce = JSON_MERGE(responce, command);
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchGroups`(IN `organizationID` INT(11), IN `botID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 30 AND state_json ->> "$.bot.bot_id" = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getGroupsForSocket(socketID, botID, command);
			SET responce = JSON_MERGE(responce, command);
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchIntents`(IN `organizationID` INT(11), IN `botID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID INT(11);
	DECLARE connectionID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command, groups JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 6 AND state_json ->> "$.bot.bot_id" = botID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SET groups = getIntentsGroups(organizationID);
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getIntentsForSocket(socketID, botID, command);
			SET responce = JSON_MERGE(responce, command);
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"intentsGroups", groups
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchSessions`(IN `organizationID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE connectionID VARCHAR(128);
	DECLARE command, bots JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 8;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	SET bots = getBots(organizationID);
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getDialoguesForSocket(socketID, command);
			SET responce = JSON_MERGE(responce, command);
			SET responce = JSON_MERGE(responce, JSON_OBJECT(
				"action", "sendToSocket",
				"data", JSON_OBJECT(
					"socket", connectionID,
					"data", JSON_ARRAY(
						JSON_OBJECT(
							"action", "merge",
							"data", JSON_OBJECT(
								"bots", bots
							)
						)
					)
				)
			));
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchUsers`(IN `organizationID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
	DECLARE socketID VARCHAR(128);
	DECLARE done TINYINT(1);
	DECLARE command JSON;
	DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 12;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET responce = JSON_ARRAY();
	OPEN socketsCursor;
		socketsLoop: LOOP
			FETCH socketsCursor INTO socketID;
			IF done 
				THEN LEAVE socketsLoop;
			END IF;
			SET command = JSON_ARRAY();
			CALL getUsersForSocket(socketID, command);
			SET responce = JSON_MERGE(responce, command);
			ITERATE socketsLoop;
		END LOOP;
	CLOSE socketsCursor;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getClient`(IN `socketID` INT(11), IN `itemID` INT(11))
    NO SQL
BEGIN
	
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getClientsForSocket`(IN `socketID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE clientsFilters, filters, clientJson, clients JSON;
    DECLARE iteration, filtersLength, organizationID, filterLimit, filterOffset, iterationOffset INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE clientsCursor CURSOR FOR SELECT * FROM filters_clients_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.clientsFilters", 
        state_json ->> "$.clientsFilters.filters", 
        JSON_LENGTH(state_json ->> "$.clientsFilters.filters"), 
        organization_id, 
        state_json ->> "$.clientsFilters.limit", 
        state_json ->> "$.clientsFilters.offset",   
        state_json ->> "$.clientsFilters.order", 
        state_json ->> "$.clientsFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_clients_view AS SELECT client_json FROM clients_json WHERE organization_id = ", organization_id),
        JSON_ARRAY()
    INTO 
        clientsFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,  
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        clients
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "active" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND client_online = 1");
                    WHEN filterItem = "inactive" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND client_online = 0");
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN clientsCursor;
        cursorLoop: LOOP
            FETCH clientsCursor INTO clientJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET clients = JSON_MERGE(clients, clientJson);
        END LOOP;
    CLOSE clientsCursor;
    DROP VIEW filters_clients_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.clients", clients) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "clients", clients
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getDialog`(IN `socketID` INT(11), IN `dialogID` INT(11))
    NO SQL
BEGIN
	DECLARE messagesArray, dialog, message JSON;
	DECLARE done TINYINT(1) DEFAULT 0;
	DECLARE connectionID VARCHAR(128) DEFAULT (SELECT socket_connection_id FROM sockets WHERE socket_id = socketID);
	DECLARE messagesCursor CURSOR FOR SELECT message_json FROM message_json WHERE dialog_id = dialogID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET messagesArray = JSON_ARRAY();
	OPEN messagesCursor;
		messagesLoop: LOOP
			FETCH messagesCursor INTO message;
			IF done = 1
				THEN LEAVE messagesLoop;
			END IF;
			SET messagesArray = JSON_MERGE(messagesArray, message);
			ITERATE messagesLoop;
		END LOOP;
	CLOSE messagesCursor;
	SELECT JSON_SET(dialog_json, "$.messages", messagesArray) INTO dialog FROM dialog_json WHERE dialog_id = dialogID;
	UPDATE states SET state_json = JSON_SET(state_json, "$.dialog", dialog) WHERE socket_id = socketID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getDialoguesForSocket`(IN `socketID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE sessionsFilters, filters, bots, dialogJson, dialogues JSON;
    DECLARE iteration, filtersLength, organizationID, countDialogues, filterLimit, filterOffset, iterationOffset, userID INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE dateStart, dateEnd VARCHAR(19);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE dialoguesCursor CURSOR FOR SELECT * FROM filters_dialogues_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.sessionsFilters", 
        state_json ->> "$.sessionsFilters.filters", 
        JSON_LENGTH(state_json ->> "$.sessionsFilters.filters"), 
        organization_id, 
        state_json ->> "$.sessionsFilters.limit", 
        state_json ->> "$.sessionsFilters.offset", 
        state_json ->> "$.sessionsFilters.dateStart", 
        state_json ->> "$.sessionsFilters.dateEnd", 
        state_json ->> "$.sessionsFilters.bots", 
        state_json ->> "$.sessionsFilters.order", 
        state_json ->> "$.sessionsFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_dialogues_view AS SELECT dialog_json FROM dialogues_json WHERE organization_id = ", organization_id),
        JSON_ARRAY(),
        user_id
    INTO 
        sessionsFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset, 
        dateStart, 
        dateEnd, 
        bots, 
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        dialogues,
        userID
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "free" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND user_id IS NULL");
                    WHEN filterItem = "busy" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND user_id IS NOT NULL");
                    WHEN filterItem = "error" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND dialog_error = 1");
                    WHEN filterItem = "success" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND dialog_error = 0");
                    WHEN filterItem = "active" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND dialog_active = 1");
                    WHEN filterItem = "inactive" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND dialog_active = 0");
                    WHEN filterItem = "widget" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND type_id = 1");
                    WHEN filterItem = "telegram" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND type_id = 5");
                    WHEN filterItem = "empty" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND dialog_messages_count = 0");
                    WHEN filterItem = "notempty" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND dialog_messages_count > 0");
                    WHEN filterItem IN ("today", "yesterday", "customdate") THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND DATE(dialog_date_update) BETWEEN '", dateStart, "' AND '", dateEnd, "'");
                    WHEN filterItem = "bot" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND JSON_CONTAINS('", bots, "', JSON_ARRAY(bot_id)) = 1");
                    WHEN filterItem = "user" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND user_id = ", userID);
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN dialoguesCursor;
        cursorLoop: LOOP
            FETCH dialoguesCursor INTO dialogJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET dialogues = JSON_MERGE(dialogues, dialogJson);
        END LOOP;
    CLOSE dialoguesCursor;
    DROP VIEW filters_dialogues_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.sessions", dialogues) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "sessions", dialogues
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getDispatchesForSocket`(IN `socketID` INT(11))
    NO SQL
BEGIN
  DECLARE done TINYINT(1);
  DECLARE dispatches, dispatch, types, bots JSON;
  DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM sockets WHERE socket_id = socketID);
  DECLARE dispatchesCursor CURSOR FOR SELECT dispatch_json FROM dispatch_json WHERE organization_id = organizationID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET dispatches = JSON_ARRAY();
  OPEN dispatchesCursor;
    dispatchesLoop: LOOP
      FETCH dispatchesCursor INTO dispatch;
      IF done
        THEN LEAVE dispatchesLoop;
      END IF;
      SET types = getTypesForDispatch(JSON_EXTRACT(dispatch, "$.dispatch_id"));
      SET bots = getBotsForDispatch(JSON_EXTRACT(dispatch, "$.dispatch_id"));
      SET dispatch = JSON_SET(dispatch, "$.types", types, "$.bots", bots);
      SET dispatches = JSON_MERGE(dispatches, dispatch);
      ITERATE dispatchesLoop;
    END LOOP;
  CLOSE dispatchesCursor;
  UPDATE states SET state_json = JSON_SET(state_json, "$.dispatches", dispatches) WHERE socket_id = socketID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getEntitiesForSocket`(IN `socketID` INT(11), IN `botID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE entitiesFilters, filters, dialogJson, entities, groups JSON;
    DECLARE iteration, filtersLength, organizationID, countDialogues, filterLimit, filterOffset, iterationOffset, userID INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE entitiesCursor CURSOR FOR SELECT * FROM filters_entities_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.entitiesFilters", 
        state_json ->> "$.entitiesFilters.filters", 
        JSON_LENGTH(state_json ->> "$.entitiesFilters.filters"), 
        organization_id, 
        state_json ->> "$.entitiesFilters.limit", 
        state_json ->> "$.entitiesFilters.offset",  
        state_json ->> "$.entitiesFilters.order", 
        state_json ->> "$.entitiesFilters.desc",
        state_json ->> "$.entitiesFilters.groups",
        0,
        CONCAT("CREATE VIEW filters_entities_view AS SELECT entities_json FROM entities_json WHERE organization_id = ", organization_id, " AND bot_id = ", botID),
        JSON_ARRAY(),
        user_id
    INTO 
        entitiesFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,
        filterOrder, 
        filterDesc,
        groups,
        iteration,
        @MysqlQueryText,
        entities,
        userID
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "group" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND JSON_CONTAINS('", groups, "', JSON_ARRAY(group_id)) = 1");
                    WHEN filterItem = "nogroup" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, IF(JSON_CONTAINS(filters, JSON_ARRAY("group")) = 1, " OR", " AND")," group_id IS NULL");
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN entitiesCursor;
        cursorLoop: LOOP
            FETCH entitiesCursor INTO dialogJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET entities = JSON_MERGE(entities, dialogJson);
        END LOOP;
    CLOSE entitiesCursor;
    DROP VIEW filters_entities_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.entities", entities) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "entities", entities
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilterBotsForSocket`(IN `socketID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE botsFilters, filters, botJson, bots JSON;
    DECLARE iteration, filtersLength, organizationID, filterLimit, filterOffset, iterationOffset INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE botsCursor CURSOR FOR SELECT * FROM filters_bots_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.botsFilters", 
        state_json ->> "$.botsFilters.filters", 
        JSON_LENGTH(state_json ->> "$.botsFilters.filters"), 
        organization_id, 
        state_json ->> "$.botsFilters.limit", 
        state_json ->> "$.botsFilters.offset",   
        state_json ->> "$.botsFilters.order", 
        state_json ->> "$.botsFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_bots_view AS SELECT bot_json FROM filter_bots_json WHERE organization_id = ", organization_id),
        JSON_ARRAY()
    INTO 
        botsFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,  
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        bots
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                /*CASE  
                    ELSE BEGIN END;
                END CASE;*/
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN botsCursor;
        cursorLoop: LOOP
            FETCH botsCursor INTO botJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET bots = JSON_MERGE(bots, botJson);
        END LOOP;
    CLOSE botsCursor;
    DROP VIEW filters_bots_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.bots", bots) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "bots", bots
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilterOrganizationsForSocket`(IN `socketID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE organizationsFilters, filters, organizationJson, organizations JSON;
    DECLARE iteration, filtersLength, organizationID, filterLimit, filterOffset, iterationOffset INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE organizationsCursor CURSOR FOR SELECT * FROM filters_organizations_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.organizationsFilters", 
        state_json ->> "$.organizationsFilters.filters", 
        JSON_LENGTH(state_json ->> "$.organizationsFilters.filters"), 
        organization_id, 
        state_json ->> "$.organizationsFilters.limit", 
        state_json ->> "$.organizationsFilters.offset",   
        state_json ->> "$.organizationsFilters.order", 
        state_json ->> "$.organizationsFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_organizations_view AS SELECT organization_json FROM organizations_json"),
        JSON_ARRAY()
    INTO 
        organizationsFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,  
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        organizations
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "root" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " WHERE type_id = 3");
                    WHEN filterItem = "user" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " WHERE type_id = 4");
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN organizationsCursor;
        cursorLoop: LOOP
            FETCH organizationsCursor INTO organizationJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET organizations = JSON_MERGE(organizations, organizationJson);
        END LOOP;
    CLOSE organizationsCursor;
    DROP VIEW filters_organizations_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.organizations", organizations) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "organizations", organizations
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getFiltersForSocket`(IN `socketID` INT(11))
    NO SQL
BEGIN
    DECLARE sessionsFilters, usersFilters, dispatchesFilters, organizationsFilters, sessions, clientsFilters, botsFilters, intentsFilters, groupsFilters, entitiesFilters JSON;
    DECLARE query varchar(1024);
    DECLARE connectionID VARCHAR(128);
  DECLARE userID INT(11);
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    SELECT 
        state_json ->> "$.sessionsFilters", 
        state_json ->> "$.usersFilters", 
        state_json ->> "$.dispatchesFilters", 
        state_json ->> "$.organizationsFilters", 
        state_json ->> "$.clientsFilters",
        state_json ->> "$.botsFilters",
        state_json ->> "$.intentsFilters",
        state_json ->> "$.groupsFilters",
        state_json ->> "$.entitiesFilters"
    INTO 
        sessionsFilters, 
        usersFilters, 
        dispatchesFilters, 
        organizationsFilters, 
        clientsFilters,
        botsFilters,
        intentsFilters,
        groupsFilters,
        entitiesFilters
    FROM states WHERE socket_id = socketID;
    SELECT user_id INTO userID FROM user_sockets WHERE socket_id = socketID;

    IF sessionsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.sessionsFilters" INTO sessionsFilters FROM states WHERE user_id = userID AND state_json ->> "$.sessionsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF sessionsFilters IS NULL
                THEN SET sessionsFilters = JSON_OBJECT(
                    "order", "dialog_id",
                    "limit", 50,
                    "offset", 0,
                    "desc", 1,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.sessionsFilters", sessionsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF usersFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.usersFilters" INTO usersFilters FROM states WHERE user_id = userID AND state_json ->> "$.usersFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF usersFilters IS NULL
                THEN SET usersFilters = JSON_OBJECT(
                    "order", "user_name",
                    "limit", 50,
                    "offset", 0,
                    "desc", 1,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.usersFilters", usersFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF organizationsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.organizationsFilters" INTO organizationsFilters FROM states WHERE user_id = userID AND state_json ->> "$.organizationsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF organizationsFilters IS NULL
                THEN SET organizationsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "organization_id",
                    "desc", 1,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.organizationsFilters", organizationsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF dispatchesFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.dispatchesFilters" INTO dispatchesFilters FROM states WHERE user_id = userID AND state_json ->> "$.dispatchesFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF dispatchesFilters IS NULL
                THEN SET dispatchesFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "dispatch_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.dispatchesFilters", dispatchesFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF clientsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.clientsFilters" INTO clientsFilters FROM states WHERE user_id = userID AND state_json ->> "$.clientsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF clientsFilters IS NULL
                THEN SET clientsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "client_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.clientsFilters", clientsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF botsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.botsFilters" INTO botsFilters FROM states WHERE user_id = userID AND state_json ->> "$.botsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF botsFilters IS NULL
                THEN SET botsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "bot_date_update",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.botsFilters", botsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF intentsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.intentsFilters" INTO intentsFilters FROM states WHERE user_id = userID AND state_json ->> "$.intentsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF intentsFilters IS NULL
                THEN SET intentsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "intent_id",
                    "desc", 0,
                    "groups", JSON_ARRAY(),
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.intentsFilters", intentsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF groupsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.groupsFilters" INTO groupsFilters FROM states WHERE user_id = userID AND state_json ->> "$.groupsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF groupsFilters IS NULL
                THEN SET groupsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "group_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.groupsFilters", groupsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF entitiesFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.entitiesFilters" INTO entitiesFilters FROM states WHERE user_id = userID AND state_json ->> "$.entitiesFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF entitiesFilters IS NULL
                THEN SET entitiesFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "entities_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all"),
                    "groups", JSON_ARRAY()
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.entitiesFilters", entitiesFilters) WHERE socket_id = socketID;
        END;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getGroupsForSocket`(IN `socketID` INT(11), IN `botID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE groupsFilters, filters, dialogJson, groups JSON;
    DECLARE iteration, filtersLength, organizationID, countDialogues, filterLimit, filterOffset, iterationOffset, userID INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE groupsCursor CURSOR FOR SELECT * FROM filters_groups_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.groupsFilters", 
        state_json ->> "$.groupsFilters.filters", 
        JSON_LENGTH(state_json ->> "$.groupsFilters.filters"), 
        organization_id, 
        state_json ->> "$.groupsFilters.limit", 
        state_json ->> "$.groupsFilters.offset",  
        state_json ->> "$.groupsFilters.order", 
        state_json ->> "$.groupsFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_groups_view AS SELECT group_json FROM groups_json WHERE organization_id = ", organization_id, " AND bot_id = ", botID),
        JSON_ARRAY(),
        user_id
    INTO 
        groupsFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        groups,
        userID
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "intents" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND type_id = ", 6);
                    WHEN filterItem = "entities" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND type_id = ", 7);
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN groupsCursor;
        cursorLoop: LOOP
            FETCH groupsCursor INTO dialogJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET groups = JSON_MERGE(groups, dialogJson);
        END LOOP;
    CLOSE groupsCursor;
    DROP VIEW filters_groups_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.groups", groups) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "groups", groups
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getIntentsForSocket`(IN `socketID` INT(11), IN `botID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE intentsFilters, filters, groups, dialogJson, intents JSON;
    DECLARE iteration, filtersLength, organizationID, countDialogues, filterLimit, filterOffset, iterationOffset, userID INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE intentsCursor CURSOR FOR SELECT * FROM filters_intents_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.intentsFilters", 
        state_json ->> "$.intentsFilters.filters", 
        JSON_LENGTH(state_json ->> "$.intentsFilters.filters"), 
        organization_id, 
        state_json ->> "$.intentsFilters.limit", 
        state_json ->> "$.intentsFilters.offset", 
        state_json ->> "$.intentsFilters.groups", 
        state_json ->> "$.intentsFilters.order", 
        state_json ->> "$.intentsFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_intents_view AS SELECT intent_json FROM intents_json WHERE organization_id = ", organization_id, " AND bot_id = ", botID),
        JSON_ARRAY(),
        user_id
    INTO 
        intentsFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,
        groups, 
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        intents,
        userID
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "group" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND JSON_CONTAINS('", groups, "', JSON_ARRAY(group_id)) = 1");
                    WHEN filterItem = "nogroup" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, IF(JSON_CONTAINS(filters, JSON_ARRAY("group")) = 1, " OR", " AND")," group_id IS NULL");
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN intentsCursor;
        cursorLoop: LOOP
            FETCH intentsCursor INTO dialogJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET intents = JSON_MERGE(intents, dialogJson);
        END LOOP;
    CLOSE intentsCursor;
    DROP VIEW filters_intents_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.intents", intents) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "intents", intents
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getMessagesForSocket`(IN `socketID` INT(11), IN `dialogID` INT(11))
    NO SQL
BEGIN
	DECLARE messages, message JSON;
	DECLARE done TINYINT(1);
	DECLARE messagesCursor CURSOR FOR SELECT message_json FROM message_json WHERE dialog_id = dialogID;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN messagesCursor;
		SET messages = JSON_ARRAY();
		messagesLoop: LOOP
			FETCH messagesCursor INTO message;
			IF done
				THEN LEAVE messagesLoop;
			END IF;
			SET messages = JSON_MERGE(messages, message);
			ITERATE messagesLoop;
		END LOOP;
	CLOSE messagesCursor;
	UPDATE states SET state_json = JSON_SET(state_json, "$.messages", messages) WHERE socket_id = socketID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrganizationForSocket`(IN `socketID` INT(11), IN `organizationID` INT(11))
    NO SQL
BEGIN
  DECLARE organization JSON;
  SELECT organization_json INTO organization FROM organizations_json WHERE organization_id = organizationID;
  UPDATE states SET state_json = JSON_SET(state_json, "$.viewOrganization", organization) WHERE socket_id = socketID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrganizationsForSocket`(IN `socketID` INT(11))
    NO SQL
BEGIN
	DECLARE done TINYINT(1);
	DECLARE organizations, organization JSON;
	DECLARE organizationsCursor CURSOR FOR SELECT organization_json FROM organization_json;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	SET organizations = JSON_ARRAY();
	OPEN organizationsCursor;
		organizationsLoop: LOOP
			FETCH organizationsCursor INTO organization;
			IF done
				THEN LEAVE organizationsLoop;
			END IF;
			SET organizations = JSON_MERGE(organizations, organization);
			ITERATE organizationsLoop;
		END LOOP;
	CLOSE organizationsCursor;
	UPDATE states SET state_json = JSON_SET(state_json, "$.organizations", organizations) WHERE socket_id = socketID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUsersForSocket`(IN `socketID` INT(11), OUT `responce` JSON)
    NO SQL
BEGIN
    DECLARE usersFilters, filters, userJson, users JSON;
    DECLARE iteration, filtersLength, organizationID, filterLimit, filterOffset, iterationOffset INT(11);
    DECLARE filterItem, filterOrder VARCHAR(512);
    DECLARE filterDesc, done TINYINT(1);
    DECLARE connectionID VARCHAR(128);
    DECLARE usersCursor CURSOR FOR SELECT * FROM filters_users_view;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SELECT 
        state_json ->> "$.usersFilters", 
        state_json ->> "$.usersFilters.filters", 
        JSON_LENGTH(state_json ->> "$.usersFilters.filters"), 
        organization_id, 
        state_json ->> "$.usersFilters.limit", 
        state_json ->> "$.usersFilters.offset",   
        state_json ->> "$.usersFilters.order", 
        state_json ->> "$.usersFilters.desc",
        0,
        CONCAT("CREATE VIEW filters_users_view AS SELECT user_json FROM users_json WHERE organization_id = ", organization_id),
        JSON_ARRAY()
    INTO 
        usersFilters, 
        filters, 
        filtersLength, 
        organizationID, 
        filterLimit, 
        filterOffset,  
        filterOrder, 
        filterDesc,
        iteration,
        @MysqlQueryText,
        users
    FROM states WHERE socket_id = socketID;
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    IF JSON_CONTAINS(filters, JSON_ARRAY("all")) = 0
        THEN BEGIN
            filtersLoop: LOOP
                SET filterItem = JSON_UNQUOTE(JSON_EXTRACT(filters, CONCAT("$[", iteration, "]")));
                CASE  
                    WHEN filterItem = "active" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND user_online = 1");
                    WHEN filterItem = "inactive" THEN SET @MysqlQueryText = CONCAT(@MysqlQueryText, " AND user_online = 0");
                    ELSE BEGIN END;
                END CASE;
                SET iteration = iteration + 1;
                IF iteration >= filtersLength
                    THEN LEAVE filtersLoop;
                    ELSE ITERATE filtersLoop;
                END IF;
            END LOOP;
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," ORDER BY ", filterOrder);
    IF filterDesc = 1
        THEN BEGIN 
            SET @MysqlQueryText = CONCAT(@MysqlQueryText, " DESC");
        END;
    END IF;
    SET @MysqlQueryText = CONCAT(@MysqlQueryText," LIMIT ", filterLimit," OFFSET ",filterOffset);
    PREPARE mysqlQuery FROM @MysqlQueryText;
    EXECUTE mysqlQuery;
    DEALLOCATE PREPARE mysqlQuery;
    OPEN usersCursor;
        cursorLoop: LOOP
            FETCH usersCursor INTO userJson;
            IF done = 1
                THEN LEAVE cursorLoop;
            END IF;
            SET users = JSON_MERGE(users, userJson);
        END LOOP;
    CLOSE usersCursor;
    DROP VIEW filters_users_view;
    UPDATE states SET state_json = JSON_SET(state_json, "$.users", users) WHERE socket_id = socketID;
    SET responce = JSON_ARRAY(JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(JSON_OBJECT(
                "action", "merge",
                "data", JSON_OBJECT(
                    "users", users
                )
            ))
        )
    ));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `setMessagesForDispatch`(IN `dispatchID` INT(11))
    NO SQL
BEGIN
    DECLARE dispatchText TEXT DEFAULT (SELECT dispatch_text FROM dispatches WHERE dispatch_id = dispatchID);
    DECLARE done INT(1) DEFAULT 0;
    DECLARE dialogID INT(11);
    DECLARE dispatchDialoguesCursor CURSOR FOR SELECT dialog_id FROM dispatch_dialogues WHERE dispatch_id = dispatchID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN dispatchDialoguesCursor;
    	dialoguesLoop: LOOP
        	FETCH dispatchDialoguesCursor INTO dialogID;
            IF done = 1 
            	THEN LEAVE dialoguesLoop;
            END IF;
            INSERT INTO messages (dialog_id, message_text, dispatch_id) VALUES (dialogID, dispatchText, dispatchID);
        END LOOP;
    CLOSE dispatchDialoguesCursor;
END$$
DELIMITER ;
