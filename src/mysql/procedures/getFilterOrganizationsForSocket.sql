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
END