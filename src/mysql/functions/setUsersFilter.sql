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
END