BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE intentsFilters, removeResult, groups, filterGroups JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    IF validOperation
        THEN BEGIN
            SET filtergroups = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.groups"));
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            SELECT 
                state_json ->> "$.intentsFilters.filters", 
                state_json ->> "$.intentsFilters.groups",
                state_json ->> "$.intentsFilters.limit", 
                state_json ->> "$.intentsFilters.offset", 
                state_json ->> "$.intentsFilters.order", 
                state_json ->> "$.intentsFilters.desc" 
            INTO 
                intentsFilters, 
                groups, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "all" THEN BEGIN 
                    SET intentsFilters = JSON_ARRAY("all");
                    SET groups = JSON_ARRAY();
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET intentsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        intentsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(intentsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET intentsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(intentsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                intentsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(intentsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET intentsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET intentsFilters = JSON_MERGE(intentsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(intentsFilters) = 0
                THEN SET intentsFilters = JSON_ARRAY("all");
            END IF;
            IF filterGroups IS NOT NULL
                THEN SET groups = filterGroups;
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
                "$.intentsFilters.filters", intentsFilters, 
                "$.intentsFilters.groups", groups, 
                "$.intentsFilters.limit", Llimit, 
                "$.intentsFilters.offset", Oofset, 
                "$.intentsFilters.order", Oorder,
                "$.intentsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.intentsFilters" INTO intentsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "intentsFilters", intentsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getIntentsForSocket",
                        "values", JSON_ARRAY(
                            socketID,
                            botID
                        )
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END