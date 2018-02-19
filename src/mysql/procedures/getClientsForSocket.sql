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
END