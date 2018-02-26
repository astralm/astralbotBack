BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE botsFilters, removeResult JSON;
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
                state_json ->> "$.botsFilters.filters", 
                state_json ->> "$.botsFilters.limit", 
                state_json ->> "$.botsFilters.offset", 
                state_json ->> "$.botsFilters.order", 
                state_json ->> "$.botsFilters.desc" 
            INTO 
                botsFilters,  
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
                WHEN "active" THEN SET removeResult = JSON_REMOVE(
                    botsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", "inactive"))
                );
                WHEN "inactive" THEN SET removeResult = JSON_REMOVE(
                    botsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", "active"))
                );
                WHEN "all" THEN BEGIN 
                    SET botsFilters = JSON_ARRAY("all");
                END;
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET botsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        botsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET botsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(botsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                botsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(botsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET botsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET botsFilters = JSON_MERGE(botsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(botsFilters) = 0
                THEN SET botsFilters = JSON_ARRAY("all");
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
                "$.botsFilters.filters", botsFilters, 
                "$.botsFilters.limit", Llimit, 
                "$.botsFilters.offset", Oofset, 
                "$.botsFilters.order", Oorder,
                "$.botsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.botsFilters" INTO botsFilters FROM states WHERE socket_id = socketID;
            RETURN JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "botsFilters", botsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getFilterBotsForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            );
        END;
        ELSE RETURN 0;
    END IF;
END