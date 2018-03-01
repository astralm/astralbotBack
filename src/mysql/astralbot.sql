SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchBots` (IN `organizationID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchClients` (IN `organizationID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchEntities` (IN `organizationID` INT(11), IN `botID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchGroups` (IN `organizationID` INT(11), IN `botID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchIntents` (IN `organizationID` INT(11), IN `botID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchOrganizations` (IN `organizationID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchSessions` (IN `organizationID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `dispatchUsers` (IN `organizationID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getClient` (IN `socketID` INT(11), IN `itemID` INT(11))  NO SQL
BEGIN
  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getClientsForSocket` (IN `socketID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDialog` (IN `socketID` INT(11), IN `dialogID` INT(11))  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDialoguesForSocket` (IN `socketID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDispatchesForSocket` (IN `socketID` INT(11))  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getEntitiesForSocket` (IN `socketID` INT(11), IN `botID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilterBotsForSocket` (IN `socketID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilterOrganizationsForSocket` (IN `socketID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFiltersForSocket` (IN `socketID` INT(11))  NO SQL
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
                    "filters", JSON_ARRAY("all"),
                    "bots", JSON_ARRAY()
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getGroupsForSocket` (IN `socketID` INT(11), IN `botID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getIntentsForSocket` (IN `socketID` INT(11), IN `botID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getMessagesForSocket` (IN `socketID` INT(11), IN `dialogID` INT(11))  NO SQL
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrganizationForSocket` (IN `socketID` INT(11), IN `organizationID` INT(11))  NO SQL
BEGIN
  DECLARE organization JSON;
  SELECT organization_json INTO organization FROM organizations_json WHERE organization_id = organizationID;
  UPDATE states SET state_json = JSON_SET(state_json, "$.viewOrganization", organization) WHERE socket_id = socketID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrganizationsForSocket` (IN `socketID` INT(11))  NO SQL
BEGIN
  DECLARE done TINYINT(1);
  DECLARE organizations, organization JSON;
  DECLARE organizationsCursor CURSOR FOR SELECT organization_json FROM organization_json;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET organizations = JSON_ARRAY();
  OPEN organizationsCursor;
    organizationsLoop:LOOP
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUsersForSocket` (IN `socketID` INT(11), OUT `responce` JSON)  NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `bindDialog` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `changePage` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `typeID` INT(11), `itemID` INT(11)) RETURNS JSON NO SQL
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
                        "action", "merge",
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

CREATE DEFINER=`root`@`localhost` FUNCTION `changeTelegramState` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `state` TINYINT(1)) RETURNS JSON NO SQL
BEGIN
  DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE userID, organizationID INT(11);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  IF validOperation
    THEN BEGIN
      SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
      UPDATE users SET user_telegram_notification = state WHERE user_id = userID;
      SET responce = dispatchProfile(organizationID, userID);
    END;
  END IF;
  RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `changeWebState` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `state` TINYINT(1)) RETURNS JSON NO SQL
BEGIN
  DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE userID, organizationID INT(11);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  IF validOperation
    THEN BEGIN
      SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
      UPDATE users SET user_web_notifications = state WHERE user_id = userID;
      SET responce = dispatchProfile(organizationID, userID);
    END;
  END IF;
  RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `checkTelegramDialog` (`dialogID` INT(11)) RETURNS JSON NO SQL
BEGIN
  DECLARE compare TINYINT(1);
  DECLARE organizationID, seconds INT(11);
  DECLARE dialogDateUpdate VARCHAR(19);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  SELECT NOW() >= (dialog_date_update + INTERVAL 10 MINUTE), organization_id, dialog_date_update INTO compare, organizationID, dialogDateUpdate FROM dialogues WHERE dialog_id = dialogID;
  IF compare
    THEN BEGIN 
      UPDATE dialogues SET dialog_active = 0 WHERE dialog_id = dialogID;
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

CREATE DEFINER=`root`@`localhost` FUNCTION `clientAgree` (`socketHash` VARCHAR(32) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `clientMessage` (`socketHash` VARCHAR(32) CHARSET utf8, `messageText` TEXT CHARSET utf8) RETURNS JSON NO SQL
BEGIN
    DECLARE messageID, answerID, socketID, clientID, dialogID, organizationID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE answerText TEXT;
    DECLARE notificationText VARCHAR(512);
    DECLARE dialogBotWork TINYINT(1);
    DECLARE messagesArray, responce JSON;
    SET responce = JSON_ARRAY();
    SELECT socket_id, socket_connection_id, organization_id INTO socketID, connectionID, organizationID FROM sockets WHERE socket_hash = socketHash;
    SELECT client_id INTO clientID FROM states WHERE socket_id = socketID;
    SELECT dialog_id, dialog_bot_work INTO dialogID, dialogBotWork FROM dialogues WHERE client_id = clientID;
    INSERT INTO messages (message_text, dialog_id, message_client) VALUES (messageText, dialogID, 1);
    SELECT message_id INTO messageID FROM messages ORDER BY message_id DESC LIMIT 1;
    CALL getMessagesForSocket(socketID, dialogID);
    SELECT state_json ->> "$.messages" INTO messagesArray FROM states WHERE socket_id = socketID;
    SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messagesArray, 0));
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
                    SET responce = JSON_MERGE(responce, sendPush(organizationID, 9, dialogID, CONCAT("Бот не смог подобрать ответ в сессии ", dialogID), 1, CONCAT("Ошибка в диалоге ", dialogID), 1));
                END;
                ELSE BEGIN
                    SELECT answer_text INTO answerText FROM answers WHERE answer_id = answerID;
                    INSERT INTO messages (message_text, dialog_id) VALUES (answerText, dialogID);
                    CALL getMessagesForSocket(socketID, dialogID);
                    SELECT state_json ->> "$.messages" INTO messagesArray FROM states WHERE socket_id = socketID;
                    SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messagesArray, 7000));
                END;
            END IF;
        END;
    END IF;
    SET responce = JSON_MERGE(responce, JSON_OBJECT(
        "action", "Procedure",
        "data", JSON_OBJECT(
            "query", "dispatchSessions",
            "values", JSON_ARRAY(
                organizationID
            )
        )
    ));
    SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
    RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `clientMessageTelegram` (`chat` VARCHAR(128) CHARSET utf8, `botID` INT(11), `messageText` TEXT CHARSET utf8, `clientName` VARCHAR(64) CHARSET utf8, `clientUsername` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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
  UPDATE dialogues SET dialog_active = 1 WHERE dialog_id = dialogID;
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
          SET responce = JSON_MERGE(responce, sendPush(organizationID, 9, dialogID, CONCAT("Бот не смог подобрать ответ в сессии ", dialogID), 1, CONCAT("Ошибка в диалоге ", dialogID), 1));
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
              "message", answerText,
              "timeout", 7000
            )
          ));
        END;
      END IF;
    END;
  END IF;
  SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
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
      "action", "Query",
      "data", JSON_OBJECT(
          "query", "checkTelegramDialog",
          "timeout", 600000,
          "values", JSON_ARRAY(
              dialogID
          )
      )
    )
  ));
  RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `deleteDispatch` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dispatchID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `deleteEntities` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `entitiesID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `deleteGroup` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `groupID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `deleteIntent` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `intentID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchBot` (`organizationID` INT(11), `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchClient` (`clientID` INT(11), `action` VARCHAR(128) CHARSET utf8, `data` JSON, `timeout` INT(11)) RETURNS JSON NO SQL
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
          "timeout", timeout,
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchClientInfo` (`organizationID` INT(11), `clientID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchDialog` (`organizationID` INT(11), `dialogID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchDispatches` (`organizationID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchEntity` (`organizationID` INT(11), `entitiesID` INT(11)) RETURNS JSON NO SQL
BEGIN
  DECLARE socketID INT(11);
  DECLARE done TINYINT(1);
  DECLARE connectionID VARCHAR(128);
  DECLARE responce, entity JSON;
  DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND (state_json ->> "$.page" = 35 OR state_json ->> "$.page" = 36) AND state_json ->> "$.entity.entities_id" = entitiesID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET responce = JSON_ARRAY();
  OPEN socketsCursor;
    socketsLoop: LOOP
      FETCH socketsCursor INTO socketID;
      SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
      IF done 
        THEN LEAVE socketsLoop;
      END IF;
      SET responce = JSON_MERGE(responce, getEntityForSocket(socketID, entitiesID));
      ITERATE socketsLoop;
    END LOOP;
  CLOSE socketsCursor;
  RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchGroup` (`organizationID` INT(11), `groupID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchIntent` (`organizationID` INT(11), `intentID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchOrganization` (`organizationID` INT(11), `viewOrganizationID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchProfile` (`organizationID` INT(11), `userID` INT(11)) RETURNS JSON NO SQL
BEGIN
  DECLARE socketID INT(11);
  DECLARE done TINYINT(1);
  DECLARE connectionID VARCHAR(128);
  DECLARE responce, profile JSON;
  DECLARE socketsCursor CURSOR FOR SELECT socket_id FROM sockets_states WHERE organization_id = organizationID AND socket_connection = 1 AND state_json ->> "$.page" = 13 AND state_json ->> "$.user.id" = userID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET responce = JSON_ARRAY();
  SELECT profile_json INTO profile FROM profile_json WHERE user_id = userID;
  OPEN socketsCursor;
    socketsLoop: LOOP
      FETCH socketsCursor INTO socketID;
      IF done 
        THEN LEAVE socketsLoop;
      END IF;
      SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
      UPDATE states SET state_json = JSON_SET(state_json, "$.user", profile) WHERE socket_id = socketID;
      SET responce = JSON_MERGE(responce, JSON_OBJECT(
        "action", "sendToSocket",
        "data", JSON_OBJECT(
          "socket", connectionID,
          "data", JSON_ARRAY(
            JSON_OBJECT(
              "action", "mergeDeep",
              "data", JSON_OBJECT(
                "user", profile
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

CREATE DEFINER=`root`@`localhost` FUNCTION `dispatchWidgetsState` (`organizationID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `forgotPassword` (`socketHash` VARCHAR(32) CHARSET utf8, `userEmail` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getAnswerIdForMessage` (`messageID` INT(11)) RETURNS INT(11) NO SQL
BEGIN
    DECLARE messageText, entitiesString TEXT;
    DECLARE answerID, entitiesID, essenceID, stringLength, organizationID, dialogID, botID, lastLocate, essenceLength INT(11);
    DECLARE essenceValue VARCHAR(1024);
    DECLARE done TINYINT(1);
    DECLARE essencesCursor CURSOR FOR SELECT LOWER(essence_value), essence_id, CHAR_LENGTH(essence_value) FROM essences;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SET entitiesString = "";
    SET answerID = 0;
    SELECT LOWER(message_text), dialog_id INTO messageText, dialogID FROM messages WHERE message_id = messageID;
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
                SELECT entities_id INTO entitiesID FROM entities_essences WHERE essence_id = essenceID AND bot_id = botID;
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getBotEntities` (`organizationID` INT(11), `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getBotIntentsGroups` (`organizationID` INT(11), `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getBots` (`organizationID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getBotsForDispatch` (`dispatchID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getBotsToServer` () RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getEntitiesGroups` (`organizationID` INT(11), `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getEntityForSocket` (`socketID` INT(11), `entitiesID` INT(11)) RETURNS JSON NO SQL
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
            "entity", entity,
            "bot", JSON_OBJECT(
              "bot_id", botID
            )
          )
        )
      )
    )
  ));
  RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getHash` (`max` INT(3)) RETURNS VARCHAR(999) CHARSET utf8 NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getIntentForSocket` (`socketID` INT(11), `intentID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getIntentsGroups` (`organizationID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getTypesForDispatch` (`dispatchID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `login` (`userEmail` VARCHAR(128) CHARSET utf8, `userPassword` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS JSON NO SQL
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
            SET responceJson = JSON_MERGE(responceJson, JSON_OBJECT(
              "action", "Procedure",
              "data", JSON_OBJECT(
                "query", "dispatchUsers",
                "values", JSON_ARRAY(
                  organizationID
                )
              )
            ));
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

CREATE DEFINER=`root`@`localhost` FUNCTION `loginClient` (`newSocketHash` VARCHAR(32) CHARSET utf8, `oldSocketHash` VARCHAR(32) CHARSET utf8, `organizationHash` VARCHAR(32) CHARSET utf8) RETURNS JSON NO SQL
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
  RETURN JSON_MERGE(JSON_ARRAY(
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
  ), dispatchDialog(organizationID, dialogID));
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `loginTelegram` (`userHash` VARCHAR(32) CHARSET utf8, `chat` VARCHAR(128) CHARSET utf8, `username` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `loginWithHash` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `pageID` INT(11), `itemID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `logout` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS JSON NO SQL
BEGIN
  DECLARE socketType INT(11) DEFAULT (SELECT type_id FROM sockets WHERE socket_hash = socketHash);
    DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_hash = userHash);
    DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
    DECLARE connectionID VARCHAR(128) DEFAULT (SELECT socket_connection_id FROM sockets WHERE socket_id = socketID);
    DECLARE userSocketID, organizationID INT(11);
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
                    SELECT organization_id INTO organizationID FROM users WHERE user_id = userID;
                    RETURN JSON_ARRAY(
                        JSON_OBJECT(
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
                        ),
                        JSON_OBJECT(
                            "action", "Procedure",
                            "data", JSON_OBJECT(
                                "query", "dispatchUsers",
                                "values", JSON_ARRAY(
                                    organizationID
                                )
                            )
                        )
                    );
            END IF;
    END IF;
    RETURN NULL;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `newBot` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botName` VARCHAR(64) CHARSET utf8, `botKey` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newClient` (`socketHash` VARCHAR(32) CHARSET utf8, `clientName` VARCHAR(64) CHARSET utf8, `clientEmail` VARCHAR(128) CHARSET utf8, `botHash` VARCHAR(32) CHARSET utf8, `typeID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newCondition` (`intentId` INT, `userId` INT, `conditionEntities` TEXT CHARSET utf8) RETURNS TINYINT(1) NO SQL
BEGIN
  INSERT INTO conditions (user_id, intent_id, condition_entities) VALUES (userId, intentId, conditionEntities);
    RETURN 1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `newDispatch` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dispatchText` TEXT CHARSET utf8, `typesArray` JSON, `botsArray` JSON) RETURNS JSON NO SQL
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
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `newEntities` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `groupID` INT(11), `name` VARCHAR(1024) CHARSET utf8, `entities` JSON) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newEntity` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `entityName` VARCHAR(1024) CHARSET utf8, `entitiesID` INT(11)) RETURNS TINYINT(1) NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newEssence` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `essenceValue` VARCHAR(1024) CHARSET utf8, `entityID` INT(11)) RETURNS TINYINT(1) NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newGroup` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `typeID` INT(11), `name` VARCHAR(64) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newIntent` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8, `conditions` JSON, `answer` TEXT CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newOrganization` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `organizationName` VARCHAR(256) CHARSET utf8, `organizationSite` VARCHAR(256) CHARSET utf8, `organizationRoot` BOOLEAN) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newSocket` (`typeID` ENUM('1','2'), `socketConnectionID` VARCHAR(128) CHARSET utf8, `socketEngineName` VARCHAR(128) CHARSET utf8, `socketEngineVersion` VARCHAR(128) CHARSET utf8, `socketOsName` VARCHAR(128) CHARSET utf8, `socketOsVersion` VARCHAR(128) CHARSET utf8, `socketDeviceVendor` VARCHAR(128) CHARSET utf8, `socketDeviceModel` VARCHAR(128) CHARSET utf8, `socketDeviceType` VARCHAR(128) CHARSET utf8, `socketCpuArchitecture` VARCHAR(128) CHARSET utf8, `socketBrowserName` VARCHAR(128) CHARSET utf8, `socketBrowserVersion` VARCHAR(128) CHARSET utf8, `socketUrl` VARCHAR(512) CHARSET utf8, `organizationID` INT(11), `socketIP` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `newUser` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `userEmail` VARCHAR(128) CHARSET utf8, `userName` VARCHAR(64) CHARSET utf8, `organizationID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `onOffBotInDialog` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `removeError` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `sendNotification` (`organizationID` INT(11), `messageText` TEXT CHARSET utf8) RETURNS JSON NO SQL
BEGIN
  DECLARE telegramUsers, responce JSON;
  DECLARE chat VARCHAR(128);
  DECLARE done TINYINT(1);
  DECLARE telegramUsersCursor CURSOR FOR SELECT user_telegram_chat FROM users WHERE user_telegram_notification = 1 AND organization_id = organizationID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET telegramUsers = JSON_ARRAY();
  SET responce = JSON_ARRAY();
  OPEN telegramUsersCursor;
    telegramUsersLoop:LOOP
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

CREATE DEFINER=`root`@`localhost` FUNCTION `sendPush` (`organizationID` INT(11), `pageID` INT(11), `itemID` INT(11), `body` TEXT CHARSET utf8, `requireInteraction` TINYINT(1), `title` TEXT CHARSET utf8, `onclick` TINYINT(1)) RETURNS JSON NO SQL
BEGIN
  DECLARE done TINYINT(1);
  DECLARE connectionID VARCHAR(128);
  DECLARE responce JSON;
  DECLARE socketsCursor CURSOR FOR SELECT socket_connection_id FROM web_push_sockets WHERE organization_id = organizationID;
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
              "action", "notification",
              "data", JSON_OBJECT(
                "page_id", pageID,
                "item_id", itemID,
                "body", body,
                "requireInteraction", requireInteraction,
                "title", title,
                "onclick", onclick
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setBotsFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setClientsFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setEntitiesFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON, `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setGroupsFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON, `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setIntentsFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON, `botID` INT(11)) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setMessagesForDispatch` (`dispatchID` INT(11)) RETURNS JSON NO SQL
BEGIN
    DECLARE dispatchText TEXT DEFAULT (SELECT dispatch_text FROM dispatches WHERE dispatch_id = dispatchID);
    DECLARE done INT(1) DEFAULT 0;
    DECLARE dialogID, dialogType, socketID, clientID, socketsIterator, socketsCount, botID, organizationID INT(11);
    DECLARE chat VARCHAR(128);
    DECLARE responce, messages JSON;
    DECLARE dispatchDialoguesCursor CURSOR FOR SELECT dialog_id FROM dispatch_dialogues WHERE dispatch_id = dispatchID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SET responce = JSON_ARRAY();
    OPEN dispatchDialoguesCursor;
      dialoguesLoop: LOOP
          FETCH dispatchDialoguesCursor INTO dialogID;
            IF done = 1 
              THEN LEAVE dialoguesLoop;
            END IF;
            INSERT INTO messages (dialog_id, message_text, dispatch_id) VALUES (dialogID, dispatchText, dispatchID);
            SELECT type_id, client_id, organization_id INTO dialogType, clientID, organizationID FROM dialogues WHERE dialog_id = dialogID;
            IF dialogType = 1
                THEN BEGIN
                    SET socketsIterator = 0;
                    SELECT COUNT(*) INTO socketsCount FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1;
                    socketsLoop: LOOP
                        IF socketsIterator = socketsCount 
                            THEN LEAVE socketsLoop;
                        END IF;
                        SELECT socket_id INTO socketID FROM client_sockets_connection WHERE client_id = clientID AND socket_connection = 1 LIMIT 1 OFFSET socketsIterator;
                        CALL getMessagesForSocket(socketID, dialogID);
                        SET socketsIterator = socketsIterator + 1;
                        ITERATE socketsLoop;
                    END LOOP;
                    SELECT state_json ->> "$.messages" INTO messages FROM states WHERE socket_id = socketID;
                    IF done
                        THEN SET done = 0;
                    END IF;
                    SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messages));
                END;
                ELSEIF dialogType = 5 THEN BEGIN
                    SELECT bot_id INTO botID FROM dialogues WHERE dialog_id = dialogID;
                    SELECT client_telegram_chat INTO chat FROM clients WHERE client_id = clientID;
                    SET responce = JSON_MERGE(responce, JSON_OBJECT(
                        "action", "sendToTelegram",
                        "data", JSON_OBJECT(
                            "bot_id", botID,
                            "chats", JSON_ARRAY(
                                chat
                            ),
                            "message", dispatchText
                        )
                    ));
                END;
            END IF;
            SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
            ITERATE dialoguesLoop;
        END LOOP;
    CLOSE dispatchDialoguesCursor;
    RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `setOrganizationsFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setSessionsFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS JSON NO SQL
BEGIN
  DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE sessionsFilters, removeResult, bots, filterBots, responce JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE dateStart, dateEnd, filterDateStart, filterDateEnd VARCHAR(19);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1); 
    SET responce = JSON_ARRAY();
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
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
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
            ));
        END;
    END IF;
    RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `setUsersFilter` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `filter` JSON) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `setWidgetsState` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `socketDisconnect` (`connectionID` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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
    ELSEIF typeID = 2 THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
      "action", "Procedure",
      "data", JSON_OBJECT(
        "query", "dispatchUsers",
        "values", JSON_ARRAY(
          organizationID
        )
      )
    ));
  END IF;
  RETURN responce;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `updateBotInfo` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `botID` INT(11), `botName` VARCHAR(64) CHARSET utf8, `botKey` VARCHAR(128) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateClientInfo` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `email` VARCHAR(128) CHARSET utf8, `phone` VARCHAR(11) CHARSET utf8, `name` VARCHAR(64) CHARSET utf8, `username` VARCHAR(128) CHARSET utf8, `clientID` INT(11)) RETURNS JSON NO SQL
BEGIN
  DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE uUsername, eEmail, connectionID VARCHAR(128);
  DECLARE pPhone BIGINT(11);
  DECLARE socketID, organizationID, dialogID INT(11);
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
      SELECT dialog_id INTO dialogID FROM dialogues WHERE client_id = clientID;
      UPDATE states SET state_json = JSON_SET(state_json, "$.page", 11) WHERE socket_id = socketID;
      SET responce = JSON_MERGE(responce, dispatchClientInfo(organizationID, clientID));
      SET responce = JSON_MERGE(responce, dispatchDialog(organizationID, dialogID));
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateEntities` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `entitiesID` INT(11), `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8, `entities` JSON) RETURNS JSON NO SQL
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
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 35, "$.bot", JSON_OBJECT("bot_id", botID), "$.entity", JSON_OBJECT("entities_id", entitiesID)) WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, dispatchEntity(organizationID, entitiesID));
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateGroup` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateIntent` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `intentID` INT(11), `groupID` INT(11), `name` VARCHAR(64) CHARSET utf8, `conditions` JSON, `answer` TEXT CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateOrganization` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `organizationID` INT(11), `name` VARCHAR(256) CHARSET utf8, `site` VARCHAR(256) CHARSET utf8, `organizationRoot` BOOLEAN) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateProfile` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `email` VARCHAR(128) CHARSET utf8, `password` VARCHAR(32) CHARSET utf8, `name` VARCHAR(64) CHARSET utf8) RETURNS JSON NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `updateUserProfile` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `userEmail` VARCHAR(128) CHARSET utf8, `userPassword` VARCHAR(32) CHARSET utf8, `userName` VARCHAR(64) CHARSET utf8) RETURNS TINYINT(1) NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `userMessage` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8, `dialogID` INT(11), `message` TEXT CHARSET utf8) RETURNS JSON NO SQL
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
            ELSE SET responce = JSON_MERGE(responce, dispatchClient(clientID, "loadDialog", messages, 0));
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

CREATE DEFINER=`root`@`localhost` FUNCTION `userTelegramState` (`chat` VARCHAR(128) CHARSET utf8, `state` BOOLEAN) RETURNS JSON NO SQL
BEGIN
  DECLARE responce JSON;
  DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_telegram_chat = chat);
  DECLARE page, socketID INT(11);
  DECLARE connectionID varchar(128);
  DECLARE message VARCHAR(226);
  DECLARE done TINYINT(1);
  DECLARE socketsCursor CURSOR FOR SELECT socket_id, socket_connection_id FROM user_sockets_connection WHERE user_id = userID AND socket_connection = 1;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET responce = JSON_ARRAY();
  IF userID IS NOT NULL
    THEN BEGIN
      UPDATE users SET user_telegram_notification = state WHERE user_telegram_chat = chat;
      IF state
        THEN SET message = "Оповещения включены";
        ELSE SET message = "Оповещения выключены";
      END IF;
      OPEN socketsCursor;
        socketsLoop: LOOP
          FETCH socketsCursor INTO socketID, connectionID;
          IF done 
            THEN LEAVE socketsLoop;
          END IF;
          SELECT state_json ->> "$.page" INTO page FROM states WHERE socket_id = socketID;
          UPDATE states SET state_json = JSON_SET(state_json, "$.user.telegram_notification", state) WHERE socket_id = socketID;
          IF page = 13
            THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
              "action", "sendToSocket",
              "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                  JSON_OBJECT(
                    "action", "mergeDeep",
                    "data", JSON_OBJECT(
                      "user", JSON_OBJECT(
                        "telegram_notification", state
                      )
                    )
                  )
                )
              )
            ));
          END IF;
          ITERATE socketsLoop;
        END LOOP;
      CLOSE socketsCursor;
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

CREATE DEFINER=`root`@`localhost` FUNCTION `validRootOperation` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS TINYINT(4) NO SQL
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

CREATE DEFINER=`root`@`localhost` FUNCTION `validStandartOperation` (`userHash` VARCHAR(32) CHARSET utf8, `socketHash` VARCHAR(32) CHARSET utf8) RETURNS TINYINT(1) NO SQL
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

CREATE TABLE `answers` (
  `answer_id` int(11) NOT NULL,
  `answer_text` varchar(2048) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `answer_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `answer_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_id` int(11) NOT NULL,
  `organization_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `answer_after_create` AFTER INSERT ON `answers` FOR EACH ROW BEGIN
  UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = NEW.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_after_delete` AFTER DELETE ON `answers` FOR EACH ROW BEGIN
  UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = OLD.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_after_update` AFTER UPDATE ON `answers` FOR EACH ROW BEGIN
  UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = NEW.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_create` BEFORE INSERT ON `answers` FOR EACH ROW BEGIN
  SET NEW.answer_date_create = NOW();
    SET NEW.answer_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM intents WHERE intent_id = NEW.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_update` BEFORE UPDATE ON `answers` FOR EACH ROW BEGIN
  SET NEW.answer_date_update = NOW();
END
$$
DELIMITER ;

CREATE TABLE `bots` (
  `bot_id` int(11) NOT NULL,
  `bot_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `bot_telegram_key` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `bot_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `bot_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bot_intents_count` int(11) NOT NULL DEFAULT '0',
  `bot_entities_count` int(11) NOT NULL DEFAULT '0',
  `organization_id` int(11) DEFAULT NULL,
  `bot_hash` varchar(32) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `bot_insert` BEFORE INSERT ON `bots` FOR EACH ROW BEGIN
  SET NEW.bot_date_create = NOW();
    SET NEW.bot_date_update = NOW();
    SET NEW.bot_hash = getHash(32);
    SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bot_update` BEFORE INSERT ON `bots` FOR EACH ROW BEGIN
  SET NEW.bot_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `bots_json` (
`bot_json` json
);
CREATE TABLE `bot_entities` (
`entities_json` json
,`organization_id` int(11)
,`bot_id` int(11)
,`group_id` int(11)
);
CREATE TABLE `bot_info` (
`bot_json` json
,`organization_id` int(11)
,`bot_id` int(11)
);
CREATE TABLE `bot_json` (
`bot_json` json
,`dispatch_id` int(11)
,`bot_id` int(11)
,`bot_name` varchar(64)
);

CREATE TABLE `clients` (
  `client_id` int(11) NOT NULL,
  `client_name` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `client_email` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `client_phone` bigint(11) DEFAULT NULL,
  `client_telegram_chat` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `client_username` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `client_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `client_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `organization_id` int(11) NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `client_online` tinyint(1) NOT NULL DEFAULT '0',
  `client_sockets_count` int(11) NOT NULL DEFAULT '0',
  `client_sockets_online_count` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `client_create` BEFORE INSERT ON `clients` FOR EACH ROW BEGIN
  SET NEW.client_date_create = NOW();
    SET NEW.client_date_update = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `client_update` BEFORE UPDATE ON `clients` FOR EACH ROW BEGIN
  SET NEW.client_date_update = NOW();
    SET NEW.client_sockets_online_count = (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = NEW.client_id AND socket_connection = 1);
    IF NEW.client_sockets_online_count = 0 
      THEN SET NEW.client_online = 0;
        ELSE SET NEW.client_online = 1;
    END IF;
    IF NEW.client_online
      THEN UPDATE dialogues SET dialog_active = 1 WHERE client_id = NEW.client_id;
        ELSE UPDATE dialogues SET dialog_active = 0 WHERE client_id = NEW.client_id;
    END IF;
END
$$
DELIMITER ;
CREATE TABLE `clients_json` (
`client_json` json
,`client_id` int(11)
,`client_name` varchar(64)
,`client_username` varchar(128)
,`client_email` varchar(128)
,`client_phone` bigint(11)
,`dialog_id` int(11)
,`organization_id` int(11)
,`client_online` tinyint(1)
,`client_date_create` varchar(19)
,`socket_url` varchar(512)
,`socket_ip` varchar(128)
,`socket_browser_name` varchar(128)
,`socket_browser_version` varchar(128)
,`socket_engine_name` varchar(128)
,`socket_engine_version` varchar(128)
,`socket_os_name` varchar(128)
,`socket_os_version` varchar(128)
,`socket_device_vendor` varchar(128)
,`socket_device_model` varchar(128)
,`socket_device_type` varchar(128)
);
CREATE TABLE `client_bot` (
`bot_id` int(11)
,`client_id` int(11)
,`client_telegram_chat` varchar(128)
);

CREATE TABLE `client_sockets` (
  `client_socket_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `socket_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `client_sockets_after_create` AFTER INSERT ON `client_sockets` FOR EACH ROW BEGIN
  DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets WHERE client_id = NEW.client_id);
    DECLARE onlineSocketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = NEW.client_id AND socket_connection = 1);
    DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM clients WHERE client_id = NEW.client_id);
  UPDATE clients SET client_sockets_count = socketsCount, client_sockets_online_count = onlineSocketsCount WHERE client_id = NEW.client_id;
    UPDATE sockets SET organization_id = organizationID WHERE socket_id = NEW.socket_id;
    UPDATE states SET client_id = NEW.client_id WHERE socket_id = NEW.socket_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `client_sockets_after_delete` AFTER DELETE ON `client_sockets` FOR EACH ROW BEGIN
  DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets WHERE client_id = OLD.client_id);
    DECLARE onlineSocketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = OLD.client_id AND socket_connection = 1);
    UPDATE clients SET client_sockets_count = socketsCount, client_online_sockets_count = onlineSocketsCount WHERE client_id = OLD.client_id;
END
$$
DELIMITER ;
CREATE TABLE `client_sockets_connection` (
`client_id` int(11)
,`socket_id` int(11)
,`socket_connection` tinyint(1)
,`socket_connection_id` varchar(128)
);

CREATE TABLE `conditions` (
  `condition_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `condition_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `condition_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_id` int(11) NOT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `condition_entities` text COLLATE utf8_bin NOT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `condition_after_create` AFTER INSERT ON `conditions` FOR EACH ROW BEGIN
  UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = NEW.intent_id) WHERE intent_id = NEW.intent_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_after_delete` AFTER DELETE ON `conditions` FOR EACH ROW BEGIN
  UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = OLD.intent_id) WHERE intent_id = OLD.intent_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_after_update` AFTER UPDATE ON `conditions` FOR EACH ROW BEGIN
  UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = NEW.intent_id) WHERE intent_id = NEW.intent_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_create` BEFORE INSERT ON `conditions` FOR EACH ROW BEGIN
  SET NEW.condition_date_create = NOW();
    SET NEW.condition_date_update = NOW();
    SET NEW.bot_id = (SELECT bot_id FROM intents WHERE intent_id = NEW.intent_id);
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_update` BEFORE UPDATE ON `conditions` FOR EACH ROW BEGIN
  SET NEW.condition_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `conditions_answers` (
`answer_id` int(11)
,`condition_id` int(11)
,`organization_id` int(11)
,`condition_entities` text
,`bot_id` int(11)
);

CREATE TABLE `dialogues` (
  `dialog_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `dialog_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `dialog_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `dialog_messages_count` int(11) NOT NULL DEFAULT '0',
  `dialog_error` tinyint(1) NOT NULL DEFAULT '0',
  `bot_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `dialog_active` tinyint(1) NOT NULL DEFAULT '0',
  `dialog_bot_work` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `dialog_create` BEFORE INSERT ON `dialogues` FOR EACH ROW BEGIN
  SET NEW.dialog_date_create = NOW();
    SET NEW.dialog_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM clients WHERE client_id = NEW.client_id);
    SET NEW.type_id = (SELECT type_id FROM clients WHERE client_id = NEW.client_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dialog_update` BEFORE UPDATE ON `dialogues` FOR EACH ROW BEGIN
  SET NEW.dialog_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `dialogues_json` (
`dialog_json` json
,`dialog_id` int(11)
,`client_message_text` text
,`user_message_text` text
,`client_id` int(11)
,`user_id` int(11)
,`dialog_date_create` varchar(19)
,`dialog_date_update` varchar(19)
,`dialog_messages_count` int(11)
,`dialog_error` tinyint(1)
,`bot_id` int(11)
,`organization_id` int(11)
,`type_id` int(11)
,`dialog_active` tinyint(1)
,`user_name` varchar(64)
,`client_name` varchar(64)
,`client_username` varchar(128)
,`socket_url` varchar(512)
);
CREATE TABLE `dialog_json` (
`dialog_json` json
,`dialog_id` int(11)
);

CREATE TABLE `dispatches` (
  `dispatch_id` int(11) NOT NULL,
  `dispatch_text` text COLLATE utf8_bin NOT NULL,
  `dispatch_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `dispatch_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  `dispatch_messages_count` int(11) NOT NULL DEFAULT '0',
  `dispatch_delete` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `dispatch_create` BEFORE INSERT ON `dispatches` FOR EACH ROW BEGIN
  SET NEW.dispatch_date_create = NOW();
    SET NEW.dispatch_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dispatch_update` BEFORE UPDATE ON `dispatches` FOR EACH ROW BEGIN
  SET NEW.dispatch_date_update = NOW();
END
$$
DELIMITER ;

CREATE TABLE `dispatch_bots` (
  `dispatch_bot_id` int(11) NOT NULL,
  `dispatch_id` int(11) NOT NULL,
  `bot_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
CREATE TABLE `dispatch_dialogues` (
`dialog_id` int(11)
,`dispatch_id` int(11)
);
CREATE TABLE `dispatch_json` (
`dispatch_json` json
,`organization_id` int(11)
,`dispatch_id` int(11)
,`dispatch_date_create` varchar(19)
,`dispatch_delete` tinyint(1)
,`dispatch_text` text
,`user_id` int(11)
,`dispatch_messages_count` int(11)
,`user_name` varchar(64)
);
CREATE TABLE `dispatch_messages` (
`message_id` int(11)
,`dialog_id` int(11)
,`user_id` int(11)
,`message_date_create` varchar(19)
,`message_date_update` varchar(19)
,`message_text` text
,`message_client` tinyint(1)
,`dispatch_id` int(11)
,`message_api_callback` tinyint(1)
,`message_error` tinyint(1)
,`bot_id` int(11)
,`message_value` text
,`intent_id` int(11)
);

CREATE TABLE `dispatch_types` (
  `dispatch_type_id` int(11) NOT NULL,
  `dispatch_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `entities` (
  `entities_id` int(11) NOT NULL,
  `entities_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `entities_entity_count` int(11) NOT NULL DEFAULT '0',
  `entities_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `entities_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `entities_after_create` AFTER INSERT ON `entities` FOR EACH ROW BEGIN
  IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
      THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = NEW.group_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_after_delete` AFTER DELETE ON `entities` FOR EACH ROW BEGIN
  IF OLD.group_id IS NOT NULL AND OLD.group_id > 0
      THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = OLD.group_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_after_update` AFTER UPDATE ON `entities` FOR EACH ROW BEGIN
  IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
      THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = NEW.group_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_create` BEFORE INSERT ON `entities` FOR EACH ROW BEGIN
  SET NEW.entities_date_create = NOW();
    SET NEW.entities_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_update` BEFORE UPDATE ON `entities` FOR EACH ROW BEGIN
  SET NEW.entities_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `entities_essences` (
`entities_id` int(11)
,`essence_id` int(11)
,`bot_id` int(11)
);
CREATE TABLE `entities_info` (
`entities_json` json
,`bot_id` int(11)
,`entities_id` int(11)
,`group_id` int(11)
,`organization_id` int(11)
);
CREATE TABLE `entities_json` (
`entities_json` json
,`organization_id` int(11)
,`bot_id` int(11)
,`group_id` int(11)
,`entities_id` int(11)
,`entities_name` varchar(64)
,`group_name` varchar(64)
);

CREATE TABLE `entity` (
  `entity_id` int(11) NOT NULL,
  `entity_name` varchar(1024) COLLATE utf8_bin NOT NULL,
  `entities_id` int(11) NOT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `entity_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `entity_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `entity_essences_count` int(11) DEFAULT '0',
  `organization_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `entity_after_delete` AFTER DELETE ON `entity` FOR EACH ROW BEGIN
  UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = OLD.entities_id) WHERE entities_id = OLD.entities_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_after_insert` AFTER INSERT ON `entity` FOR EACH ROW BEGIN
  UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = NEW.entities_id) WHERE entities_id = NEW.entities_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_after_update` AFTER UPDATE ON `entity` FOR EACH ROW BEGIN
  UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = NEW.entities_id) WHERE entities_id = NEW.entities_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_create` BEFORE INSERT ON `entity` FOR EACH ROW BEGIN
  SET NEW.entity_date_create = NOW(),
      NEW.entity_date_update = NOW(),
        NEW.bot_id = (SELECT bot_id FROM entities WHERE entities_id = NEW.entities_id),
        NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_update` BEFORE UPDATE ON `entity` FOR EACH ROW BEGIN
  SET NEW.entity_date_update = NOW();
END
$$
DELIMITER ;

CREATE TABLE `entity_essences` (
  `entity_essence_id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `essence_id` int(11) NOT NULL,
  `entity_essence_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `entities_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `entity_essence_after_delete` AFTER DELETE ON `entity_essences` FOR EACH ROW BEGIN
  DECLARE essencesCount INT(11) DEFAULT (SELECT COUNT(*) FROM entity_essences WHERE entity_id = OLD.entity_id);
    UPDATE entity SET entity_essences_count = essencesCount WHERE entity_id = OLD.entity_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_essences_after_create` AFTER INSERT ON `entity_essences` FOR EACH ROW BEGIN
  DECLARE essencesCount INT(11) DEFAULT (SELECT COUNT(*) FROM entity_essences WHERE entity_id = NEW.entity_id);
    UPDATE entity SET entity_essences_count = essencesCount WHERE entity_id = NEW.entity_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_essences_create` BEFORE INSERT ON `entity_essences` FOR EACH ROW BEGIN
  SET NEW.entity_essence_date_create = NOW(),
      NEW.bot_id = (SELECT bot_id FROM entity WHERE entity_id = NEW.entity_id),
      NEW.entities_id = (SELECT entities_id FROM entity WHERE entity_id = NEW.entity_id),
      NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;

CREATE TABLE `essences` (
  `essence_id` int(11) NOT NULL,
  `essence_value` varchar(1024) COLLATE utf8_bin NOT NULL,
  `essence_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `essence_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `essence_create` BEFORE INSERT ON `essences` FOR EACH ROW BEGIN
  SET NEW.essence_date_create = NOW(),
      NEW.essence_date_update = NOW(),
        NEW.essence_value = LOWER(NEW.essence_value);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `essence_update` BEFORE UPDATE ON `essences` FOR EACH ROW BEGIN
  SET NEW.essence_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `filter_bots_json` (
`bot_json` json
,`bot_id` int(11)
,`bot_name` varchar(64)
,`bot_date_update` varchar(19)
,`bot_telegram_key` varchar(128)
,`organization_id` int(11)
);

CREATE TABLE `groups` (
  `group_id` int(11) NOT NULL,
  `group_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `group_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `group_items_count` int(11) NOT NULL DEFAULT '0',
  `type_id` int(11) DEFAULT NULL,
  `bot_id` int(11) NOT NULL,
  `organization_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `groups_create` BEFORE INSERT ON `groups` FOR EACH ROW BEGIN
  SET NEW.group_date_create = NOW();
  SET NEW.group_date_update = NOW();
  SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `groups_update` BEFORE UPDATE ON `groups` FOR EACH ROW BEGIN
  SET NEW.group_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `groups_json` (
`group_json` json
,`group_id` int(11)
,`group_name` varchar(64)
,`group_items_count` int(11)
,`organization_id` int(11)
,`bot_id` int(11)
,`type_id` int(11)
);
CREATE TABLE `group_info` (
`group_json` json
,`organization_id` int(11)
,`bot_id` int(11)
,`group_id` int(11)
);
CREATE TABLE `group_json` (
`group_json` json
,`organization_id` int(11)
,`group_id` int(11)
,`bot_id` int(11)
,`type_id` int(11)
);

CREATE TABLE `intents` (
  `intent_id` int(11) NOT NULL,
  `intent_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `bot_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `intent_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_conditions_count` int(11) NOT NULL DEFAULT '0',
  `intent_answers_count` int(11) NOT NULL DEFAULT '0',
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `intent_after_create` AFTER INSERT ON `intents` FOR EACH ROW BEGIN
  IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
      THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = NEW.group_id) WHERE group_id = NEW.group_id;
    END IF;
    UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = NEW.bot_id) WHERE bot_id = NEW.bot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_after_delete` AFTER DELETE ON `intents` FOR EACH ROW BEGIN
  IF OLD.group_id IS NOT NULL AND OLD.group_id > 0
      THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = OLD.group_id) WHERE group_id = OLD.group_id;
    END IF;
    UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = OLD.bot_id) WHERE bot_id = OLD.bot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_after_update` AFTER UPDATE ON `intents` FOR EACH ROW BEGIN
  IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
    THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = NEW.group_id) WHERE group_id = NEW.group_id;
  END IF;
  UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = NEW.bot_id) WHERE bot_id = NEW.bot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_create` BEFORE INSERT ON `intents` FOR EACH ROW BEGIN
  SET NEW.intent_date_create = NOW();
    SET NEW.intent_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_update` BEFORE UPDATE ON `intents` FOR EACH ROW BEGIN
  SET NEW.intent_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `intents_json` (
`intent_json` json
,`intent_id` int(11)
,`intent_name` varchar(64)
,`intent_conditions_count` int(11)
,`organization_id` int(11)
,`group_id` int(11)
,`bot_id` int(11)
);
CREATE TABLE `intent_json` (
`intent_json` json
,`intent_id` int(11)
,`organization_id` int(11)
,`group_id` int(11)
,`bot_id` int(11)
);

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `dialog_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `message_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `message_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `message_text` text COLLATE utf8_bin NOT NULL,
  `message_client` tinyint(1) NOT NULL DEFAULT '0',
  `dispatch_id` int(11) DEFAULT NULL,
  `message_api_callback` tinyint(1) NOT NULL DEFAULT '0',
  `message_error` tinyint(1) NOT NULL DEFAULT '0',
  `bot_id` int(11) DEFAULT NULL,
  `message_value` text COLLATE utf8_bin,
  `intent_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `message_after_create` AFTER INSERT ON `messages` FOR EACH ROW BEGIN
  UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages AS m WHERE m.dialog_id = NEW.dialog_id) WHERE dialog_id = NEW.dialog_id;
    IF NEW.dispatch_id IS NOT NULL AND NEW.dispatch_id > 0
      THEN UPDATE dispatches SET dispatch_messages_count = (SELECT COUNT(*) FROM messages WHERE dispatch_id = NEW.dispatch_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_after_delete` AFTER DELETE ON `messages` FOR EACH ROW BEGIN
  UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages WHERE dialog_id = OLD.dialog_id) WHERE dialog_id = OLD.dialog_id;
    IF OLD.dispatch_id IS NOT NULL AND OLD.dispatch_id > 0
      THEN UPDATE dispatches SET dispatch_messages_count = (SELECT COUNT(*) FROM messages WHERE dispatch_id = OLD.dispatch_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_after_update` AFTER UPDATE ON `messages` FOR EACH ROW BEGIN
  UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages WHERE dialog_id = NEW.dialog_id), dialog_error = NEW.message_error WHERE dialog_id = NEW.dialog_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_create` BEFORE INSERT ON `messages` FOR EACH ROW BEGIN
  SET NEW.message_date_create = NOW();
    SET NEW.message_date_update = NOW();
    SET NEW.bot_id = (SELECT bot_id FROM dialogues WHERE dialog_id = NEW.dialog_id);
    IF NEW.dispatch_id IS NOT NULL AND NEW.dispatch_id > 0 
      THEN SET NEW.user_id = (SELECT user_id FROM dispatches WHERE dispatch_id = NEW.dispatch_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_update` BEFORE UPDATE ON `messages` FOR EACH ROW BEGIN
  SET NEW.message_date_update = NOW();
END
$$
DELIMITER ;
CREATE TABLE `message_json` (
`message_json` json
,`dialog_id` int(11)
);

CREATE TABLE `organizations` (
  `organization_id` int(11) NOT NULL,
  `organization_name` varchar(256) COLLATE utf8_bin NOT NULL,
  `organization_site` varchar(256) COLLATE utf8_bin NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `organization_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `organization_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `organization_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `organization_widgets_work` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `insert_organization` BEFORE INSERT ON `organizations` FOR EACH ROW BEGIN
  DECLARE organizationHash VARCHAR(32) DEFAULT getHash(32);
    IF NEW.organization_site REGEXP ".*[[.full-stop.]]..*"
        THEN
          SET NEW.organization_date_create = NOW();
            SET NEW.organization_date_update = NOW();
            hashLoop: LOOP
              IF (SELECT organization_id FROM organizations WHERE organization_hash = organizationHash) > 0
                    THEN 
                        SET organizationHash = getHash(32);
                        ITERATE hashLoop;
                    ELSE LEAVE hashLoop;
                END IF;
            END LOOP;
            SET NEW.organization_hash = organizationHash;
        ELSE 
          SIGNAL SQLSTATE '45000' set message_text="invalid organization site";
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_organization` BEFORE UPDATE ON `organizations` FOR EACH ROW BEGIN
    IF NEW.organization_site REGEXP ".*[[.full-stop.]]..*"
        THEN
            SET NEW.organization_date_update = NOW();
        ELSE 
          SIGNAL SQLSTATE '45000' set message_text="invalid organization site";
    END IF;
END
$$
DELIMITER ;
CREATE TABLE `organizations_json` (
`organization_json` json
,`organization_name` varchar(256)
,`organization_id` int(11)
,`type_id` int(11)
,`organization_site` varchar(256)
);
CREATE TABLE `organization_bots` (
`bot_json` json
,`bot_id` int(11)
,`bot_name` varchar(64)
,`bot_hash` varchar(32)
,`organization_id` int(11)
);
CREATE TABLE `organization_groups` (
`group_json` json
,`organization_id` int(11)
,`type_id` int(11)
,`bot_id` int(11)
);
CREATE TABLE `organization_json` (
`organization_json` json
);
CREATE TABLE `profile_json` (
`profile_json` json
,`organization_json` json
,`user_id` int(11)
);

CREATE TABLE `sockets` (
  `socket_id` int(11) NOT NULL,
  `socket_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `socket_connection` tinyint(1) NOT NULL DEFAULT '1',
  `socket_connection_id` varchar(128) COLLATE utf8_bin NOT NULL,
  `socket_date_create` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `socket_date_disconnect` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `socket_date_update` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `socket_engine_name` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_engine_version` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_os_name` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_os_version` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_device_vendor` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_device_model` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_device_type` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_url` varchar(512) COLLATE utf8_bin NOT NULL,
  `socket_ip` varchar(128) COLLATE utf8_bin NOT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `socket_browser_name` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_browser_version` varchar(128) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `insert_socket` BEFORE INSERT ON `sockets` FOR EACH ROW BEGIN
  DECLARE socketHash VARCHAR(32) DEFAULT getHash(32);
  SET NEW.socket_date_create = NOW();
    SET NEW.socket_date_update = NOW();
    hashLoop: LOOP
      IF (SELECT socket_id FROM sockets WHERE socket_hash = socketHash) > 0
          THEN 
              SET socketHash = getHash(32);
                ITERATE hashLoop;
            ELSE 
              LEAVE hashLoop;
        END IF;
    END LOOP;
    SET NEW.socket_hash = getHash(32);
    IF NEW.socket_connection = 0
      THEN SET NEW.socket_date_disconnect = NOW();
        ELSE SET NEW.socket_date_disconnect = NULL;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `socket_before_delete` BEFORE DELETE ON `sockets` FOR EACH ROW BEGIN 
  DECLARE userID, clientID, socketsCount INT(11);
    SET userID = (SELECT user_id FROM user_sockets WHERE socket_id = OLD.socket_id);
    IF userID IS NOT NULL AND userID > 0
      THEN 
          SET socketsCount = (SELECT COUNT(*) FROM user_sockets WHERE user_id = userID) - 1;
          UPDATE users SET user_sockets_count = socketsCount WHERE user_id = userID;
        ELSE 
          SET clientID = (SELECT client_id FROM client_sockets WHERE socket_id = OLD.socket_id);
            IF clientID IS NOT NULL AND clientID > 0
              THEN 
                  SET socketsCount = (SELECT COUNT(*) FROM client_sockets WHERE client_id = clientID) - 1;
                    UPDATE clients SET client_sockets_count = socketsCount WHERE client_id = clientID;
            END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sockets_after_create` AFTER INSERT ON `sockets` FOR EACH ROW BEGIN
  INSERT INTO states (socket_id) VALUES (NEW.socket_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sockets_after_update` AFTER UPDATE ON `sockets` FOR EACH ROW BEGIN
  DECLARE socketsCount, userID, clientID INT(11);
  IF NEW.organization_id IS NOT NULL AND NEW.organization_id > 0
      THEN 
          IF NEW.type_id = 2
              THEN
                  SET userID = (SELECT user_id FROM user_sockets WHERE socket_id = NEW.socket_id);
                  SET socketsCount = (SELECT COUNT(*) FROM user_sockets WHERE user_id = userID);
                  UPDATE users SET user_sockets_count = socketsCount WHERE user_id = userID;
                ELSEIF NEW.type_id = 1
                  THEN 
                      SET clientID = (SELECT client_id FROM client_sockets WHERE socket_id = NEW.socket_id);
                        SET socketsCount = (SELECT COUNT(*) FROM client_sockets WHERE client_id = clientID);
                        UPDATE clients SET client_sockets_count = socketsCount WHERE client_id = clientID;
      END IF;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_socket` BEFORE UPDATE ON `sockets` FOR EACH ROW BEGIN
  SET NEW.socket_date_update = NOW();
  IF NEW.socket_connection = 0
      THEN 
          SET NEW.socket_date_disconnect = NOW();
    END IF;
END
$$
DELIMITER ;
CREATE TABLE `sockets_states` (
`state_json` json
,`socket_id` int(11)
,`organization_id` int(11)
,`socket_connection` tinyint(1)
);

CREATE TABLE `states` (
  `state_id` int(11) NOT NULL,
  `state_json` json DEFAULT NULL,
  `socket_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `state_date_create` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `state_date_update` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `state_before_update` BEFORE UPDATE ON `states` FOR EACH ROW BEGIN
  SET NEW.state_date_update = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `state_create` BEFORE INSERT ON `states` FOR EACH ROW BEGIN
  SET NEW.state_date_create = NOW(),
      NEW.state_date_update = NOW();      
END
$$
DELIMITER ;

CREATE TABLE `types` (
  `type_id` int(11) NOT NULL,
  `type_name` varchar(64) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `types` (`type_id`, `type_name`) VALUES
(2, 'admin'),
(24, 'bot'),
(23, 'bots'),
(11, 'client'),
(10, 'clients'),
(9, 'dialog'),
(16, 'dispatch'),
(25, 'editbot'),
(19, 'editclient'),
(36, 'editentities'),
(33, 'editgroup'),
(29, 'editintent'),
(21, 'editorganization'),
(7, 'entities'),
(35, 'entity'),
(32, 'group'),
(30, 'groups'),
(28, 'intent'),
(6, 'intents'),
(15, 'newUser'),
(26, 'newbot'),
(34, 'newentities'),
(31, 'newgroup'),
(27, 'newintent'),
(18, 'neworganization'),
(20, 'organization'),
(17, 'organizations'),
(13, 'profile'),
(14, 'profileEdit'),
(3, 'root'),
(8, 'sessions'),
(5, 'telegram'),
(4, 'user'),
(12, 'users'),
(1, 'widget'),
(22, 'widgets');

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `user_email` varchar(128) COLLATE utf8_bin NOT NULL,
  `user_password` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_creator` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `user_state` json DEFAULT NULL,
  `user_telegram_chat` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `user_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_telegram_username` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `user_telegram_notification` tinyint(1) NOT NULL DEFAULT '0',
  `user_web_notifications` tinyint(1) NOT NULL DEFAULT '0',
  `user_online` tinyint(1) NOT NULL DEFAULT '0',
  `user_auth` tinyint(1) NOT NULL DEFAULT '0',
  `user_sockets_count` int(11) NOT NULL DEFAULT '0',
  `user_sockets_online_count` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `insert_user` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
  DECLARE userHash VARCHAR(32) DEFAULT getHash(32);
    DECLARE userPassword VARCHAR(6) DEFAULT getHash(6);
    DECLARE organizationID INT(11);
  IF NEW.user_email REGEXP ".*.@.*[[.full-stop.]]..*"
      THEN 
          SET NEW.user_email = LOWER(NEW.user_email);
          SET NEW.user_date_create = NOW();
            SET NEW.user_date_update = NOW();
            hashLoop: LOOP
              IF (SELECT user_id FROM users WHERE user_hash = userHash) > 0
                  THEN 
                      SET userHash = getHash(32);
                        ITERATE hashLoop;
                  ELSE
                      LEAVE  hashLoop;
                END IF;
            END LOOP;
            passwordLoop: LOOP
              IF (SELECT user_id FROM users WHERE user_password = userPassword) > 0
                  THEN 
                      SET userPassword = getHash(6);
                        ITERATE passwordLoop;
                    ELSE 
                      LEAVE passwordLoop;
                END IF;
            END LOOP;
            SET NEW.user_hash = getHash(32);
            SET NEW.user_password = getHash(6);
        ELSE 
          SIGNAL SQLSTATE '45000' set message_text="invalid email address";
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_user` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
  DECLARE userHash VARCHAR(32);
  IF (NEW.user_email REGEXP ".*.@.*[[.full-stop.]]..*")
      THEN
          IF NEW.user_auth != OLD.user_auth AND NEW.user_auth = 1
              THEN 
                  SET userHash = getHash(32);
                    hashLoop: LOOP
                        IF (SELECT COUNT(*) FROM users WHERE user_hash = userHash) > 0
                            THEN SET userHash = getHash(32);
                            ELSE LEAVE hashLoop;
                        END IF;
                    END LOOP;
                    SET NEW.user_hash = userHash;
            END IF;
            SET NEW.user_date_update = NOW();
            SET NEW.user_sockets_online_count = (SELECT COUNT(*) FROM user_sockets_connection WHERE user_id = NEW.user_id AND socket_connection = 1);
            IF NEW.user_sockets_online_count = 0
              THEN SET NEW.user_online = 0;
                ELSE SET NEW.user_online = 1;
            END IF;
        ELSE 
          SIGNAL SQLSTATE '45000' set message_text="invalid email address";
    END IF;
END
$$
DELIMITER ;
CREATE TABLE `users_json` (
`user_json` json
,`user_name` varchar(64)
,`user_email` varchar(128)
,`user_online` tinyint(1)
,`organization_id` int(11)
);

CREATE TABLE `user_sockets` (
  `user_socket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `socket_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
DELIMITER $$
CREATE TRIGGER `user_socket_after_create` AFTER INSERT ON `user_sockets` FOR EACH ROW BEGIN
  DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
  UPDATE sockets SET organization_id = organizationID WHERE socket_id = NEW.socket_id;
    UPDATE states SET organization_id = organizationID, user_id = NEW.user_id WHERE socket_id = NEW.socket_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_socket_after_delete` AFTER DELETE ON `user_sockets` FOR EACH ROW BEGIN
  DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM user_sockets WHERE user_id = OLD.user_id);
    UPDATE users SET user_sockets_count = socketsCount WHERE user_id = OLD.user_id;
END
$$
DELIMITER ;
CREATE TABLE `user_sockets_connection` (
`user_id` int(11)
,`socket_id` int(11)
,`socket_connection` tinyint(1)
,`socket_connection_id` varchar(128)
);
CREATE TABLE `user_state_information` (
`user_name` varchar(64)
,`user_email` varchar(128)
,`user_date_create` varchar(19)
,`user_date_update` varchar(19)
,`user_creator_id` int(11)
,`user_telegram_username` varchar(128)
,`user_telegram_notification` tinyint(1)
,`user_web_notifications` tinyint(1)
,`user_online` tinyint(1)
,`user_sockets_count` int(11)
,`user_sockets_online_count` int(11)
,`organization_id` int(11)
,`organization_name` varchar(256)
,`user_creator_name` varchar(64)
);
CREATE TABLE `web_push_sockets` (
`socket_connection_id` varchar(128)
,`organization_id` int(11)
,`user_id` int(11)
,`socket_id` int(11)
);
DROP TABLE IF EXISTS `bots_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bots_json`  AS  select json_object('bot_id',`bots`.`bot_id`,'bot_telegram_key',`bots`.`bot_telegram_key`) AS `bot_json` from `bots` where (`bots`.`bot_telegram_key` is not null) ;
DROP TABLE IF EXISTS `bot_entities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bot_entities`  AS  select json_object('bot_id',`entities`.`bot_id`,'entities_name',`entities`.`entities_name`,'entities_id',`entities`.`entities_id`,'group_id',`entities`.`group_id`,'entities_entity_count',`entities`.`entities_entity_count`) AS `entities_json`,`entities`.`organization_id` AS `organization_id`,`entities`.`bot_id` AS `bot_id`,`entities`.`group_id` AS `group_id` from `entities` ;
DROP TABLE IF EXISTS `bot_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bot_info`  AS  select json_object('bot_name',`bots`.`bot_name`,'bot_telegram_key',`bots`.`bot_telegram_key`,'bot_id',`bots`.`bot_id`,'bot_date_create',`bots`.`bot_date_create`,'bot_date_update',`bots`.`bot_date_update`,'bot_intents_count',`bots`.`bot_intents_count`,'bot_entities_count',`bots`.`bot_entities_count`) AS `bot_json`,`bots`.`organization_id` AS `organization_id`,`bots`.`bot_id` AS `bot_id` from `bots` ;
DROP TABLE IF EXISTS `bot_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bot_json`  AS  select json_object('bot_id',`db`.`bot_id`,'bot_name',`b`.`bot_name`) AS `bot_json`,`db`.`dispatch_id` AS `dispatch_id`,`db`.`bot_id` AS `bot_id`,`b`.`bot_name` AS `bot_name` from (`dispatch_bots` `db` left join `bots` `b` on((`b`.`bot_id` = `db`.`bot_id`))) ;
DROP TABLE IF EXISTS `clients_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `clients_json`  AS  select json_object('client_id',`c`.`client_id`,'client_name',`c`.`client_name`,'client_username',`c`.`client_username`,'client_email',`c`.`client_email`,'client_phone',`c`.`client_phone`,'dialog_id',`d`.`dialog_id`,'client_online',`c`.`client_online`,'client_date_create',`c`.`client_date_create`,'socket_url',`s`.`socket_url`,'socket_ip',`s`.`socket_ip`,'socket_browser_name',`s`.`socket_browser_name`,'socket_browser_version',`s`.`socket_browser_version`,'socket_engine_name',`s`.`socket_engine_name`,'socket_engine_version',`s`.`socket_engine_version`,'socket_os_name',`s`.`socket_os_name`,'socket_os_version',`s`.`socket_os_version`,'socket_device_vendor',`s`.`socket_device_vendor`,'socket_device_model',`s`.`socket_device_model`,'socket_device_type',`s`.`socket_device_type`) AS `client_json`,`c`.`client_id` AS `client_id`,`c`.`client_name` AS `client_name`,`c`.`client_username` AS `client_username`,`c`.`client_email` AS `client_email`,`c`.`client_phone` AS `client_phone`,`d`.`dialog_id` AS `dialog_id`,`c`.`organization_id` AS `organization_id`,`c`.`client_online` AS `client_online`,`c`.`client_date_create` AS `client_date_create`,`s`.`socket_url` AS `socket_url`,`s`.`socket_ip` AS `socket_ip`,`s`.`socket_browser_name` AS `socket_browser_name`,`s`.`socket_browser_version` AS `socket_browser_version`,`s`.`socket_engine_name` AS `socket_engine_name`,`s`.`socket_engine_version` AS `socket_engine_version`,`s`.`socket_os_name` AS `socket_os_name`,`s`.`socket_os_version` AS `socket_os_version`,`s`.`socket_device_vendor` AS `socket_device_vendor`,`s`.`socket_device_model` AS `socket_device_model`,`s`.`socket_device_type` AS `socket_device_type` from (((`clients` `c` left join `dialogues` `d` on((`d`.`client_id` = `c`.`client_id`))) left join (select max(`client_sockets`.`socket_id`) AS `max_socket_id`,`client_sockets`.`client_id` AS `client_id` from `client_sockets` group by `client_sockets`.`client_id`) `msi` on((`msi`.`client_id` = `c`.`client_id`))) left join `sockets` `s` on((`s`.`socket_id` = `msi`.`max_socket_id`))) ;
DROP TABLE IF EXISTS `client_bot`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `client_bot`  AS  select `d`.`bot_id` AS `bot_id`,`d`.`client_id` AS `client_id`,`c`.`client_telegram_chat` AS `client_telegram_chat` from (`dialogues` `d` left join `clients` `c` on((`c`.`client_id` = `d`.`client_id`))) where (`c`.`client_telegram_chat` is not null) ;
DROP TABLE IF EXISTS `client_sockets_connection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `client_sockets_connection`  AS  select `cs`.`client_id` AS `client_id`,`cs`.`socket_id` AS `socket_id`,`s`.`socket_connection` AS `socket_connection`,`s`.`socket_connection_id` AS `socket_connection_id` from (`client_sockets` `cs` join `sockets` `s` on((`s`.`socket_id` = `cs`.`socket_id`))) ;
DROP TABLE IF EXISTS `conditions_answers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `conditions_answers`  AS  select `a`.`answer_id` AS `answer_id`,`c`.`condition_id` AS `condition_id`,`c`.`organization_id` AS `organization_id`,`c`.`condition_entities` AS `condition_entities`,`c`.`bot_id` AS `bot_id` from (`conditions` `c` left join `answers` `a` on((`a`.`intent_id` = `c`.`intent_id`))) ;
DROP TABLE IF EXISTS `dialogues_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dialogues_json`  AS  select json_object('dialog_id',`dd`.`dialog_id`,'client_id',`dd`.`client_id`,'client_name',`c`.`client_name`,'client_username',`c`.`client_username`,'user_name',`u`.`user_name`,'user_id',`dd`.`user_id`,'dialog_date_update',`dd`.`dialog_date_update`,'dialog_date_create',`dd`.`dialog_date_create`,'dialog_messages_count',`dd`.`dialog_messages_count`,'dialog_error',`dd`.`dialog_error`,'bot_id',`dd`.`bot_id`,'type_id',`dd`.`type_id`,'dialog_active',`dd`.`dialog_active`,'client_message',`mmc`.`message_text`,'user_message',`mmu`.`message_text`,'socket_url',`s`.`socket_url`) AS `dialog_json`,`dd`.`dialog_id` AS `dialog_id`,`mmc`.`message_text` AS `client_message_text`,`mmu`.`message_text` AS `user_message_text`,`dd`.`client_id` AS `client_id`,`dd`.`user_id` AS `user_id`,`dd`.`dialog_date_create` AS `dialog_date_create`,`dd`.`dialog_date_update` AS `dialog_date_update`,`dd`.`dialog_messages_count` AS `dialog_messages_count`,`dd`.`dialog_error` AS `dialog_error`,`dd`.`bot_id` AS `bot_id`,`dd`.`organization_id` AS `organization_id`,`dd`.`type_id` AS `type_id`,`dd`.`dialog_active` AS `dialog_active`,`u`.`user_name` AS `user_name`,`c`.`client_name` AS `client_name`,`c`.`client_username` AS `client_username`,`s`.`socket_url` AS `socket_url` from (((((((`dialogues` `dd` left join (select `d`.`dialog_id` AS `dialog_id`,max(`mc`.`message_id`) AS `client_message`,max(`mu`.`message_id`) AS `user_message` from ((`dialogues` `d` left join `messages` `mc` on(((`mc`.`dialog_id` = `d`.`dialog_id`) and (`mc`.`message_client` = 1)))) left join `messages` `mu` on(((`mu`.`dialog_id` = `d`.`dialog_id`) and (`mu`.`message_client` = 0)))) group by `d`.`dialog_id`) `lm` on((`lm`.`dialog_id` = `dd`.`dialog_id`))) left join `messages` `mmc` on((`mmc`.`message_id` = `lm`.`client_message`))) left join `messages` `mmu` on((`mmu`.`message_id` = `lm`.`user_message`))) left join `users` `u` on((`u`.`user_id` = `dd`.`user_id`))) left join `clients` `c` on((`c`.`client_id` = `dd`.`client_id`))) left join (select max(`client_sockets`.`socket_id`) AS `max_socket_id`,`client_sockets`.`client_id` AS `client_id` from `client_sockets` group by `client_sockets`.`client_id`) `mcs` on((`mcs`.`client_id` = `c`.`client_id`))) left join `sockets` `s` on((`s`.`socket_id` = `mcs`.`max_socket_id`))) ;
DROP TABLE IF EXISTS `dialog_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dialog_json`  AS  select json_object('dialog_id',`d`.`dialog_id`,'user_id',`d`.`user_id`,'user_name',`u`.`user_name`,'client_id',`d`.`client_id`,'client_name',`c`.`client_name`,'client_username',`c`.`client_username`,'dialog_error',`d`.`dialog_error`,'dialog_active',`d`.`dialog_active`,'dialog_bot_work',`d`.`dialog_bot_work`,'type_id',`d`.`type_id`) AS `dialog_json`,`d`.`dialog_id` AS `dialog_id` from ((`dialogues` `d` left join `clients` `c` on((`c`.`client_id` = `d`.`client_id`))) left join `users` `u` on((`u`.`user_id` = `d`.`user_id`))) ;
DROP TABLE IF EXISTS `dispatch_dialogues`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dispatch_dialogues`  AS  select `d`.`dialog_id` AS `dialog_id`,`dp`.`dispatch_id` AS `dispatch_id` from (((`dialogues` `d` join `dispatch_types` `dt` on((`dt`.`type_id` = `d`.`type_id`))) join `dispatch_bots` `db` on((`db`.`bot_id` = `d`.`bot_id`))) join `dispatches` `dp` on(((`dp`.`dispatch_id` = `dt`.`dispatch_id`) and (`dp`.`dispatch_id` = `db`.`dispatch_id`)))) ;
DROP TABLE IF EXISTS `dispatch_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dispatch_json`  AS  select json_object('dispatch_id',`d`.`dispatch_id`,'dispatch_date_create',`d`.`dispatch_date_create`,'dispatch_text',`d`.`dispatch_text`,'user_id',`d`.`user_id`,'dispatch_messages_count',`d`.`dispatch_messages_count`,'user_name',`u`.`user_name`) AS `dispatch_json`,`d`.`organization_id` AS `organization_id`,`d`.`dispatch_id` AS `dispatch_id`,`d`.`dispatch_date_create` AS `dispatch_date_create`,`d`.`dispatch_delete` AS `dispatch_delete`,`d`.`dispatch_text` AS `dispatch_text`,`d`.`user_id` AS `user_id`,`d`.`dispatch_messages_count` AS `dispatch_messages_count`,`u`.`user_name` AS `user_name` from (`dispatches` `d` left join `users` `u` on((`u`.`user_id` = `d`.`user_id`))) where (`d`.`dispatch_delete` = 0) order by `d`.`dispatch_id` desc ;
DROP TABLE IF EXISTS `dispatch_messages`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dispatch_messages`  AS  select `messages`.`message_id` AS `message_id`,`messages`.`dialog_id` AS `dialog_id`,`messages`.`user_id` AS `user_id`,`messages`.`message_date_create` AS `message_date_create`,`messages`.`message_date_update` AS `message_date_update`,`messages`.`message_text` AS `message_text`,`messages`.`message_client` AS `message_client`,`messages`.`dispatch_id` AS `dispatch_id`,`messages`.`message_api_callback` AS `message_api_callback`,`messages`.`message_error` AS `message_error`,`messages`.`bot_id` AS `bot_id`,`messages`.`message_value` AS `message_value`,`messages`.`intent_id` AS `intent_id` from `messages` where ((`messages`.`dispatch_id` is not null) and (`messages`.`dispatch_id` > 0)) ;
DROP TABLE IF EXISTS `entities_essences`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `entities_essences`  AS  select `e`.`entities_id` AS `entities_id`,`es`.`essence_id` AS `essence_id`,`e`.`bot_id` AS `bot_id` from ((`entity` `e` join `entity_essences` `ee` on((`ee`.`entity_id` = `e`.`entity_id`))) join `essences` `es` on((`es`.`essence_id` = `ee`.`essence_id`))) ;
DROP TABLE IF EXISTS `entities_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `entities_info`  AS  select json_object('entities_id',`e`.`entities_id`,'entities_name',`e`.`entities_name`,'entities_entity_count',`e`.`entities_entity_count`,'group_id',`e`.`group_id`,'bot_id',`e`.`bot_id`,'group_name',`g`.`group_name`,'bot_name',`b`.`bot_name`) AS `entities_json`,`e`.`bot_id` AS `bot_id`,`e`.`entities_id` AS `entities_id`,`e`.`group_id` AS `group_id`,`e`.`organization_id` AS `organization_id` from ((`entities` `e` left join `bots` `b` on((`e`.`bot_id` = `b`.`bot_id`))) left join `groups` `g` on((`g`.`group_id` = `e`.`group_id`))) ;
DROP TABLE IF EXISTS `entities_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `entities_json`  AS  select json_object('entities_id',`e`.`entities_id`,'entities_name',`e`.`entities_name`,'group_id',`e`.`group_id`,'group_name',`g`.`group_name`) AS `entities_json`,`e`.`organization_id` AS `organization_id`,`e`.`bot_id` AS `bot_id`,`e`.`group_id` AS `group_id`,`e`.`entities_id` AS `entities_id`,`e`.`entities_name` AS `entities_name`,`g`.`group_name` AS `group_name` from (`entities` `e` left join `groups` `g` on((`g`.`group_id` = `e`.`group_id`))) ;
DROP TABLE IF EXISTS `filter_bots_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `filter_bots_json`  AS  select json_object('bot_id',`bots`.`bot_id`,'bot_name',`bots`.`bot_name`,'bot_date_update',`bots`.`bot_date_update`,'bot_telegram_key',`bots`.`bot_telegram_key`) AS `bot_json`,`bots`.`bot_id` AS `bot_id`,`bots`.`bot_name` AS `bot_name`,`bots`.`bot_date_update` AS `bot_date_update`,`bots`.`bot_telegram_key` AS `bot_telegram_key`,`bots`.`organization_id` AS `organization_id` from `bots` ;
DROP TABLE IF EXISTS `groups_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `groups_json`  AS  select json_object('group_id',`groups`.`group_id`,'group_name',`groups`.`group_name`,'group_items_count',`groups`.`group_items_count`,'type_id',`groups`.`type_id`) AS `group_json`,`groups`.`group_id` AS `group_id`,`groups`.`group_name` AS `group_name`,`groups`.`group_items_count` AS `group_items_count`,`groups`.`organization_id` AS `organization_id`,`groups`.`bot_id` AS `bot_id`,`groups`.`type_id` AS `type_id` from `groups` ;
DROP TABLE IF EXISTS `group_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `group_info`  AS  select json_object('group_id',`g`.`group_id`,'group_name',`g`.`group_name`,'group_items_count',`g`.`group_items_count`,'type_id',`g`.`type_id`,'bot_id',`g`.`bot_id`,'bot_name',`b`.`bot_name`) AS `group_json`,`g`.`organization_id` AS `organization_id`,`g`.`bot_id` AS `bot_id`,`g`.`group_id` AS `group_id` from (`groups` `g` left join `bots` `b` on((`b`.`bot_id` = `g`.`bot_id`))) ;
DROP TABLE IF EXISTS `group_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `group_json`  AS  select json_object('group_name',`g`.`group_name`,'group_id',`g`.`group_id`,'group_items_count',`g`.`group_items_count`,'type_id',`g`.`type_id`,'bot_id',`g`.`bot_id`,'bot_name',`b`.`bot_name`) AS `group_json`,`g`.`organization_id` AS `organization_id`,`g`.`group_id` AS `group_id`,`g`.`bot_id` AS `bot_id`,`g`.`type_id` AS `type_id` from (`groups` `g` left join `bots` `b` on((`g`.`bot_id` = `b`.`bot_id`))) ;
DROP TABLE IF EXISTS `intents_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `intents_json`  AS  select json_object('intent_id',`intents`.`intent_id`,'intent_name',`intents`.`intent_name`,'intent_conditions_count',`intents`.`intent_conditions_count`,'group_id',`intents`.`group_id`) AS `intent_json`,`intents`.`intent_id` AS `intent_id`,`intents`.`intent_name` AS `intent_name`,`intents`.`intent_conditions_count` AS `intent_conditions_count`,`intents`.`organization_id` AS `organization_id`,`intents`.`group_id` AS `group_id`,`intents`.`bot_id` AS `bot_id` from `intents` ;
DROP TABLE IF EXISTS `intent_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `intent_json`  AS  select json_object('intent_id',`i`.`intent_id`,'intent_name',`i`.`intent_name`,'bot_id',`i`.`bot_id`,'group_name',`g`.`group_name`,'intent_conditions_count',`i`.`intent_conditions_count`,'answer_text',`a`.`answer_text`,'bot_name',`b`.`bot_name`,'group_id',`i`.`group_id`) AS `intent_json`,`i`.`intent_id` AS `intent_id`,`i`.`organization_id` AS `organization_id`,`i`.`group_id` AS `group_id`,`i`.`bot_id` AS `bot_id` from (((`intents` `i` left join `groups` `g` on((`g`.`group_id` = `i`.`group_id`))) left join `answers` `a` on((`a`.`intent_id` = `i`.`intent_id`))) left join `bots` `b` on((`b`.`bot_id` = `i`.`bot_id`))) ;
DROP TABLE IF EXISTS `message_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `message_json`  AS  select json_object('message_text',`m`.`message_text`,'message_client',`m`.`message_client`,'client_id',`d`.`client_id`,'client_name',`c`.`client_name`,'user_id',`m`.`user_id`,'user_name',`u`.`user_name`,'message_date_create',`m`.`message_date_create`,'dialog_id',`m`.`dialog_id`) AS `message_json`,`d`.`dialog_id` AS `dialog_id` from (((`messages` `m` left join `users` `u` on((`u`.`user_id` = `m`.`user_id`))) left join `dialogues` `d` on((`d`.`dialog_id` = `m`.`dialog_id`))) left join `clients` `c` on((`c`.`client_id` = `d`.`client_id`))) order by `m`.`message_id` ;
DROP TABLE IF EXISTS `organizations_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organizations_json`  AS  select json_object('organization_id',`organizations`.`organization_id`,'organization_name',`organizations`.`organization_name`,'organization_site',`organizations`.`organization_site`,'type_id',`organizations`.`type_id`) AS `organization_json`,`organizations`.`organization_name` AS `organization_name`,`organizations`.`organization_id` AS `organization_id`,`organizations`.`type_id` AS `type_id`,`organizations`.`organization_site` AS `organization_site` from `organizations` ;
DROP TABLE IF EXISTS `organization_bots`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organization_bots`  AS  select json_object('bot_id',`bots`.`bot_id`,'bot_name',`bots`.`bot_name`,'bot_hash',`bots`.`bot_hash`) AS `bot_json`,`bots`.`bot_id` AS `bot_id`,`bots`.`bot_name` AS `bot_name`,`bots`.`bot_hash` AS `bot_hash`,`bots`.`organization_id` AS `organization_id` from `bots` ;
DROP TABLE IF EXISTS `organization_groups`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organization_groups`  AS  select json_object('group_id',`groups`.`group_id`,'group_name',`groups`.`group_name`) AS `group_json`,`groups`.`organization_id` AS `organization_id`,`groups`.`type_id` AS `type_id`,`groups`.`bot_id` AS `bot_id` from `groups` ;
DROP TABLE IF EXISTS `organization_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organization_json`  AS  select json_object('organization_id',`organizations`.`organization_id`,'organization_name',`organizations`.`organization_name`) AS `organization_json` from `organizations` ;
DROP TABLE IF EXISTS `profile_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `profile_json`  AS  select json_object('name',`u`.`user_name`,'email',`u`.`user_email`,'telegram_notification',`u`.`user_telegram_notification`,'web_notification',`u`.`user_web_notifications`,'id',`u`.`user_id`) AS `profile_json`,json_object('organization_site',`o`.`organization_site`,'organization_name',`o`.`organization_name`,'organization_id',`o`.`organization_id`) AS `organization_json`,`u`.`user_id` AS `user_id` from (`users` `u` left join `organizations` `o` on((`o`.`organization_id` = `u`.`organization_id`))) ;
DROP TABLE IF EXISTS `sockets_states`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sockets_states`  AS  select `st`.`state_json` AS `state_json`,`s`.`socket_id` AS `socket_id`,`s`.`organization_id` AS `organization_id`,`s`.`socket_connection` AS `socket_connection` from (`sockets` `s` join `states` `st` on((`st`.`socket_id` = `s`.`socket_id`))) ;
DROP TABLE IF EXISTS `users_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `users_json`  AS  select json_object('user_name',`users`.`user_name`,'user_email',`users`.`user_email`,'user_online',`users`.`user_online`) AS `user_json`,`users`.`user_name` AS `user_name`,`users`.`user_email` AS `user_email`,`users`.`user_online` AS `user_online`,`users`.`organization_id` AS `organization_id` from `users` ;
DROP TABLE IF EXISTS `user_sockets_connection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_sockets_connection`  AS  select `u`.`user_id` AS `user_id`,`s`.`socket_id` AS `socket_id`,`s`.`socket_connection` AS `socket_connection`,`s`.`socket_connection_id` AS `socket_connection_id` from ((`user_sockets` `us` join `users` `u` on((`u`.`user_id` = `us`.`user_id`))) join `sockets` `s` on((`s`.`socket_id` = `us`.`socket_id`))) ;
DROP TABLE IF EXISTS `user_state_information`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_state_information`  AS  select `u`.`user_name` AS `user_name`,`u`.`user_email` AS `user_email`,`u`.`user_date_create` AS `user_date_create`,`u`.`user_date_update` AS `user_date_update`,`u`.`user_creator` AS `user_creator_id`,`u`.`user_telegram_username` AS `user_telegram_username`,`u`.`user_telegram_notification` AS `user_telegram_notification`,`u`.`user_web_notifications` AS `user_web_notifications`,`u`.`user_online` AS `user_online`,`u`.`user_sockets_count` AS `user_sockets_count`,`u`.`user_sockets_online_count` AS `user_sockets_online_count`,`o`.`organization_id` AS `organization_id`,`o`.`organization_name` AS `organization_name`,`u2`.`user_name` AS `user_creator_name` from ((`users` `u` left join `organizations` `o` on((`u`.`organization_id` = `o`.`organization_id`))) left join `users` `u2` on((`u2`.`user_id` = `u`.`user_creator`))) ;
DROP TABLE IF EXISTS `web_push_sockets`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `web_push_sockets`  AS  select `usc`.`socket_connection_id` AS `socket_connection_id`,`u`.`organization_id` AS `organization_id`,`u`.`user_id` AS `user_id`,`usc`.`socket_id` AS `socket_id` from (`user_sockets_connection` `usc` join `users` `u` on((`u`.`user_id` = `usc`.`user_id`))) where ((`usc`.`socket_connection` = 1) and (`u`.`user_web_notifications` = 1)) ;


ALTER TABLE `answers`
  ADD PRIMARY KEY (`answer_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `intent_id` (`intent_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `bots`
  ADD PRIMARY KEY (`bot_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `bot_hash` (`bot_hash`);

ALTER TABLE `clients`
  ADD PRIMARY KEY (`client_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `type_id_2` (`type_id`);

ALTER TABLE `client_sockets`
  ADD PRIMARY KEY (`client_socket_id`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `socket_id` (`socket_id`);

ALTER TABLE `conditions`
  ADD PRIMARY KEY (`condition_id`),
  ADD KEY `intent_id` (`intent_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `dialogues`
  ADD PRIMARY KEY (`dialog_id`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `type_id` (`type_id`);

ALTER TABLE `dispatches`
  ADD PRIMARY KEY (`dispatch_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `dispatch_bots`
  ADD PRIMARY KEY (`dispatch_bot_id`),
  ADD KEY `dispatch_id` (`dispatch_id`),
  ADD KEY `bot_id` (`bot_id`);

ALTER TABLE `dispatch_types`
  ADD PRIMARY KEY (`dispatch_type_id`),
  ADD KEY `dispatch_id` (`dispatch_id`),
  ADD KEY `type_id` (`type_id`);

ALTER TABLE `entities`
  ADD PRIMARY KEY (`entities_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `entity`
  ADD PRIMARY KEY (`entity_id`),
  ADD KEY `entities_id` (`entities_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `entity_essences`
  ADD PRIMARY KEY (`entity_essence_id`),
  ADD KEY `entity_id` (`entity_id`),
  ADD KEY `essence_id` (`essence_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `entities_id` (`entities_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `essences`
  ADD PRIMARY KEY (`essence_id`),
  ADD UNIQUE KEY `essence_value` (`essence_value`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `groups`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `intents`
  ADD PRIMARY KEY (`intent_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `dialog_id` (`dialog_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `dispatch_id` (`dispatch_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `intent_id` (`intent_id`);

ALTER TABLE `organizations`
  ADD PRIMARY KEY (`organization_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `organization_creator` (`user_id`);

ALTER TABLE `sockets`
  ADD PRIMARY KEY (`socket_id`),
  ADD UNIQUE KEY `socket_hash` (`socket_hash`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `organization_id` (`organization_id`);

ALTER TABLE `states`
  ADD PRIMARY KEY (`state_id`),
  ADD KEY `socket_id` (`socket_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `client_id` (`client_id`);

ALTER TABLE `types`
  ADD PRIMARY KEY (`type_id`),
  ADD UNIQUE KEY `type_name` (`type_name`);

ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`),
  ADD UNIQUE KEY `user_hash` (`user_hash`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `user_creator` (`user_creator`);

ALTER TABLE `user_sockets`
  ADD PRIMARY KEY (`user_socket_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `socket_id` (`socket_id`);


ALTER TABLE `answers`
  MODIFY `answer_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `bots`
  MODIFY `bot_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `clients`
  MODIFY `client_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `client_sockets`
  MODIFY `client_socket_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `conditions`
  MODIFY `condition_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `dialogues`
  MODIFY `dialog_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `dispatches`
  MODIFY `dispatch_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `dispatch_bots`
  MODIFY `dispatch_bot_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `dispatch_types`
  MODIFY `dispatch_type_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `entities`
  MODIFY `entities_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `entity`
  MODIFY `entity_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `entity_essences`
  MODIFY `entity_essence_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `essences`
  MODIFY `essence_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `groups`
  MODIFY `group_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `intents`
  MODIFY `intent_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `organizations`
  MODIFY `organization_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `sockets`
  MODIFY `socket_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `states`
  MODIFY `state_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `types`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `user_sockets`
  MODIFY `user_socket_id` int(11) NOT NULL AUTO_INCREMENT;


ALTER TABLE `answers`
  ADD CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`intent_id`) REFERENCES `intents` (`intent_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `answers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `answers_ibfk_3` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `bots`
  ADD CONSTRAINT `bots_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `bots_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `clients`
  ADD CONSTRAINT `clients_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `clients_ibfk_3` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `client_sockets`
  ADD CONSTRAINT `client_sockets_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `client_sockets_ibfk_2` FOREIGN KEY (`socket_id`) REFERENCES `sockets` (`socket_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `conditions`
  ADD CONSTRAINT `conditions_ibfk_1` FOREIGN KEY (`intent_id`) REFERENCES `intents` (`intent_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conditions_ibfk_2` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conditions_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `conditions_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `dialogues`
  ADD CONSTRAINT `dialogues_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_3` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_5` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `dispatches`
  ADD CONSTRAINT `dispatches_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dispatches_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `dispatch_bots`
  ADD CONSTRAINT `dispatch_bots_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dispatch_bots_ibfk_2` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatches` (`dispatch_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `dispatch_types`
  ADD CONSTRAINT `dispatch_types_ibfk_1` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatches` (`dispatch_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dispatch_types_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `entities`
  ADD CONSTRAINT `entities_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entities_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entities_ibfk_3` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entities_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `entity`
  ADD CONSTRAINT `entity_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_ibfk_3` FOREIGN KEY (`entities_id`) REFERENCES `entities` (`entities_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `entity_essences`
  ADD CONSTRAINT `entity_essences_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`entity_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_2` FOREIGN KEY (`essence_id`) REFERENCES `essences` (`essence_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_5` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_6` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `essences`
  ADD CONSTRAINT `essences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `groups`
  ADD CONSTRAINT `groups_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_3` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `intents`
  ADD CONSTRAINT `intents_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `intents_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `intents_ibfk_3` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `intents_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`dialog_id`) REFERENCES `dialogues` (`dialog_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_4` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatches` (`dispatch_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_5` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `organizations`
  ADD CONSTRAINT `organizations_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `organizations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `sockets`
  ADD CONSTRAINT `sockets_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `sockets_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `states`
  ADD CONSTRAINT `states_ibfk_1` FOREIGN KEY (`socket_id`) REFERENCES `sockets` (`socket_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `states_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `states_ibfk_3` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `states_ibfk_4` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`user_creator`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `user_sockets`
  ADD CONSTRAINT `user_sockets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_sockets_ibfk_2` FOREIGN KEY (`socket_id`) REFERENCES `sockets` (`socket_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
