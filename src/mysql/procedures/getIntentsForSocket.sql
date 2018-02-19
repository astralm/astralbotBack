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
END