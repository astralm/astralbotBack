BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE entitiesFilters, removeResult, groups, filterGroups, responce JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1);
    SET responce = JSON_ARRAY();
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
                state_json ->> "$.entitiesFilters.filters", 
                state_json ->> "$.entitiesFilters.groups",
                state_json ->> "$.entitiesFilters.limit", 
                state_json ->> "$.entitiesFilters.offset", 
                state_json ->> "$.entitiesFilters.order", 
                state_json ->> "$.entitiesFilters.desc" 
            INTO 
                entitiesFilters, 
                groups, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "all" THEN BEGIN 
                    SET entitiesFilters = JSON_ARRAY("all");
                    SET groups = JSON_ARRAY();
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET entitiesFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        entitiesFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(entitiesFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET entitiesFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(entitiesFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                entitiesFilters,
                                JSON_UNQUOTE(JSON_SEARCH(entitiesFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET entitiesFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET entitiesFilters = JSON_MERGE(entitiesFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(entitiesFilters) = 0
                THEN SET entitiesFilters = JSON_ARRAY("all");
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
                "$.entitiesFilters.filters", entitiesFilters, 
                "$.entitiesFilters.groups", groups, 
                "$.entitiesFilters.limit", Llimit, 
                "$.entitiesFilters.offset", Oofset, 
                "$.entitiesFilters.order", Oorder,
                "$.entitiesFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.entitiesFilters" INTO entitiesFilters FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "entitiesFilters", entitiesFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getEntitiesForSocket",
                        "values", JSON_ARRAY(
                            socketID,
                            botID
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END