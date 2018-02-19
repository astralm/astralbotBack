BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE organizationsFilters, removeResult JSON;
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
                state_json ->> "$.organizationsFilters.filters", 
                state_json ->> "$.organizationsFilters.limit", 
                state_json ->> "$.organizationsFilters.offset", 
                state_json ->> "$.organizationsFilters.order", 
                state_json ->> "$.organizationsFilters.desc" 
            INTO 
                organizationsFilters,  
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "root" THEN SET removeResult = JSON_REMOVE(
                    organizationsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", "user"))
                );
                WHEN "user" THEN SET removeResult = JSON_REMOVE(
                    organizationsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", "root"))
                );
                WHEN "all" THEN BEGIN 
                    SET organizationsFilters = JSON_ARRAY("all");
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET organizationsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        organizationsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET organizationsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(organizationsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                organizationsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(organizationsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET organizationsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET organizationsFilters = JSON_MERGE(organizationsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(organizationsFilters) = 0
                THEN SET organizationsFilters = JSON_ARRAY("all");
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
                "$.organizationsFilters.filters", organizationsFilters, 
                "$.organizationsFilters.limit", Llimit, 
                "$.organizationsFilters.offset", Oofset, 
                "$.organizationsFilters.order", Oorder,
                "$.organizationsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.organizationsFilters" INTO organizationsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "organizationsFilters", organizationsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getFilterOrganizationsForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END