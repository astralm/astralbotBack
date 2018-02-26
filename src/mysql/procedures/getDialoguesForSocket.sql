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
END