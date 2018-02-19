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
END