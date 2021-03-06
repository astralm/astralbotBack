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
END