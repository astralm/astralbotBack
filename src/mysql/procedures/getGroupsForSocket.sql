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
END