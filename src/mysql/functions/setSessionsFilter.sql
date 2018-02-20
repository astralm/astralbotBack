BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE sessionsFilters, removeResult, bots, filterBots, responce JSON;
    DECLARE socketID, filterLimit, filterOffset, Llimit, Oofset INT(11);
    DECLARE connectionID, filterName VARCHAR(128);
    DECLARE dateStart, dateEnd, filterDateStart, filterDateEnd VARCHAR(19);
    DECLARE filterOrder, Oorder VARCHAR(512);
    DECLARE filterDesc, Ddesc TINYINT(1); 
    SET responce = JSON_ARRAY();
    IF validOperation
    	THEN BEGIN
            SET filterDateStart = DATE(FROM_UNIXTIME(JSON_UNQUOTE(JSON_EXTRACT(filter, "$.dateStart"))));
            SET filterDateEnd = DATE(FROM_UNIXTIME(JSON_UNQUOTE(JSON_EXTRACT(filter, "$.dateEnd"))));
            SET filterbots = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.bots"));
            SET filterName = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.name"));
            SET filterLimit = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.limit"));
            SET filterOffset = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.offset"));
            SET filterOrder = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.order"));
            SET filterDesc = JSON_UNQUOTE(JSON_EXTRACT(filter, "$.desc"));
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
        	SELECT 
                state_json ->> "$.sessionsFilters.filters", 
                state_json ->> "$.sessionsFilters.bots", 
                state_json ->> "$.sessionsFilters.dateStart", 
                state_json ->> "$.sessionsFilters.dateEnd", 
                state_json ->> "$.sessionsFilters.limit", 
                state_json ->> "$.sessionsFilters.offset", 
                state_json ->> "$.sessionsFilters.order", 
                state_json ->> "$.sessionsFilters.desc" 
            INTO 
                sessionsFilters, 
                bots, 
                dateStart, 
                dateEnd, 
                Llimit, 
                Oofset, 
                Oorder, 
                Ddesc 
            FROM states WHERE socket_id = socketID;
            CASE filterName
            	WHEN "free" THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "busy"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "user"))
                    );
                END;
                WHEN "busy" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters, 
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "free"))
                );
                WHEN "error" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "success"))
                );
                WHEN "success" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "error"))
                );
                WHEN "active" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "inactive"))
                );
                WHEN "inactive" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "active"))
                );
                WHEN "widget" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "telegram"))
                );
                WHEN "telegram" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "widget"))
                );
                WHEN "empty" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "notempty"))
                );
                WHEN "notempty" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "empty"))
                );
                WHEN "today" THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "yesterday"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "customdate"))
                    );
                    SET filterDateStart = CURDATE();
                    SET filterDateEnd = CURDATE();
                END;
                WHEN "yesterday" THEN BEGIN
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "today"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "customdate"))
                    );
                    SET filterDateStart = SUBDATE(CURDATE(), 1);
                    SET filterDateEnd = SUBDATE(CURDATE(), 1);
                END;
                WHEN "customdate" THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "today"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters,
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "yesterday"))
                    );
                END;
                WHEN "all" THEN BEGIN 
                    SET sessionsFilters = JSON_ARRAY("all");
                    SET bots = JSON_ARRAY();
                END;
                WHEN "user" THEN SET removeResult = JSON_REMOVE(
                    sessionsFilters,
                    JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "free"))
                );
                ELSE BEGIN END;
            END CASE;
            IF removeResult IS NOT NULL
                THEN SET sessionsFilters = removeResult;
            END IF;
            IF filterName != "all" 
                THEN BEGIN 
                    SET removeResult = JSON_REMOVE(
                        sessionsFilters, 
                        JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", "all"))
                    );
                    IF removeResult IS NOT NULL
                        THEN SET sessionsFilters = removeResult;
                    END IF;
                    IF JSON_CONTAINS(sessionsFilters, JSON_ARRAY(filterName))
                        THEN BEGIN 
                            SET removeResult = JSON_REMOVE(
                                sessionsFilters,
                                JSON_UNQUOTE(JSON_SEARCH(sessionsFilters, "one", filterName))
                            );
                            IF removeResult IS NOT NULL
                                THEN SET sessionsFilters = removeResult;
                            END IF;
                        END;
                        ELSE SET sessionsFilters = JSON_MERGE(sessionsFilters, JSON_QUOTE(filterName));
                    END IF;
                END;
            END IF;
            IF JSON_LENGTH(sessionsFilters) = 0
                THEN SET sessionsFilters = JSON_ARRAY("all");
            END IF;
            IF filterDateStart IS NOT NULL
                THEN SET dateStart = filterDateStart;
            END IF;
            IF filterDateEnd IS NOT NULL
                THEN SET dateEnd = filterDateEnd;
            END IF;
            IF filterBots IS NOT NULL
                THEN SET bots = filterBots;
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
                "$.sessionsFilters.filters", sessionsFilters, 
                "$.sessionsFilters.bots", bots, 
                "$.sessionsFilters.dateStart", dateStart, 
                "$.sessionsFilters.dateEnd", dateEnd, 
                "$.sessionsFilters.limit", Llimit, 
                "$.sessionsFilters.offset", Oofset, 
                "$.sessionsFilters.order", Oorder,
                "$.sessionsFilters.desc", Ddesc
            ) WHERE socket_id = socketID;
            SELECT state_json ->> "$.sessionsFilters" INTO sessionsFilters FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "sessionsFilters", sessionsFilters
                                )
                            )
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "getDialoguesForSocket",
                        "values", JSON_ARRAY(socketID)
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END