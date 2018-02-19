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
END