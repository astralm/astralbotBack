BEGIN
    DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE groupsFilters, removeResult JSON;
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
                state_json ->> "$.groupsFilters.filters", 
                state_json ->> "$.groupsFilters.limit", 
                state_json ->> "$.groupsFilters.offset", 
                state_json ->> "$.groupsFilters.order", 
                state_json ->> "$.groupsFilters.desc" 
            INTO 
                groupsFilters, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "intents" THEN SET removeResult = JSON_REMOVE(
                    groupsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", "entities"))
                );
                WHEN "entities" THEN SET removeResult = JSON_REMOVE(
                    groupsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", "intents"))
                );
                WHEN "all" THEN SET groupsFilters = JSON_ARRAY("all");
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET groupsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        groupsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET groupsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(groupsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                groupsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(groupsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET groupsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET groupsFilters = JSON_MERGE(groupsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(groupsFilters) = 0
                THEN SET groupsFilters = JSON_ARRAY("all");
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
                "$.groupsFilters.filters", groupsFilters, 
                "$.groupsFilters.limit", Llimit, 
                "$.groupsFilters.offset", Oofset, 
                "$.groupsFilters.order", Oorder,
                "$.groupsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.groupsFilters" INTO groupsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "groupsFilters", groupsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getGroupsForSocket",
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