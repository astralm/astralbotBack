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
END