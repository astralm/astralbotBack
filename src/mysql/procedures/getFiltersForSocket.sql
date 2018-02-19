BEGIN
    DECLARE sessionsFilters, usersFilters, dispatchesFilters, organizationsFilters, sessions, clientsFilters, botsFilters, intentsFilters, groupsFilters, entitiesFilters JSON;
    DECLARE query varchar(1024);
    DECLARE connectionID VARCHAR(128);
  DECLARE userID INT(11);
    SELECT socket_connection_id INTO connectionID FROM sockets WHERE socket_id = socketID;
    SELECT 
        state_json ->> "$.sessionsFilters", 
        state_json ->> "$.usersFilters", 
        state_json ->> "$.dispatchesFilters", 
        state_json ->> "$.organizationsFilters", 
        state_json ->> "$.clientsFilters",
        state_json ->> "$.botsFilters",
        state_json ->> "$.intentsFilters",
        state_json ->> "$.groupsFilters",
        state_json ->> "$.entitiesFilters"
    INTO 
        sessionsFilters, 
        usersFilters, 
        dispatchesFilters, 
        organizationsFilters, 
        clientsFilters,
        botsFilters,
        intentsFilters,
        groupsFilters,
        entitiesFilters
    FROM states WHERE socket_id = socketID;
    SELECT user_id INTO userID FROM user_sockets WHERE socket_id = socketID;

    IF sessionsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.sessionsFilters" INTO sessionsFilters FROM states WHERE user_id = userID AND state_json ->> "$.sessionsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF sessionsFilters IS NULL
                THEN SET sessionsFilters = JSON_OBJECT(
                    "order", "dialog_id",
                    "limit", 50,
                    "offset", 0,
                    "desc", 1,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.sessionsFilters", sessionsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF usersFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.usersFilters" INTO usersFilters FROM states WHERE user_id = userID AND state_json ->> "$.usersFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF usersFilters IS NULL
                THEN SET usersFilters = JSON_OBJECT(
                    "order", "user_name",
                    "limit", 50,
                    "offset", 0,
                    "desc", 1,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.usersFilters", usersFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF organizationsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.organizationsFilters" INTO organizationsFilters FROM states WHERE user_id = userID AND state_json ->> "$.organizationsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF organizationsFilters IS NULL
                THEN SET organizationsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "organization_id",
                    "desc", 1,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.organizationsFilters", organizationsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF dispatchesFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.dispatchesFilters" INTO dispatchesFilters FROM states WHERE user_id = userID AND state_json ->> "$.dispatchesFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF dispatchesFilters IS NULL
                THEN SET dispatchesFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "dispatch_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.dispatchesFilters", dispatchesFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF clientsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.clientsFilters" INTO clientsFilters FROM states WHERE user_id = userID AND state_json ->> "$.clientsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF clientsFilters IS NULL
                THEN SET clientsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "client_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.clientsFilters", clientsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF botsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.botsFilters" INTO botsFilters FROM states WHERE user_id = userID AND state_json ->> "$.botsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF botsFilters IS NULL
                THEN SET botsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "bot_date_update",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.botsFilters", botsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF intentsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.intentsFilters" INTO intentsFilters FROM states WHERE user_id = userID AND state_json ->> "$.intentsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF intentsFilters IS NULL
                THEN SET intentsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "intent_id",
                    "desc", 0,
                    "groups", JSON_ARRAY(),
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.intentsFilters", intentsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF groupsFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.groupsFilters" INTO groupsFilters FROM states WHERE user_id = userID AND state_json ->> "$.groupsFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF groupsFilters IS NULL
                THEN SET groupsFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "group_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all")
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.groupsFilters", groupsFilters) WHERE socket_id = socketID;
        END;
    END IF;

    IF entitiesFilters IS NULL
        THEN BEGIN
            SELECT state_json ->> "$.entitiesFilters" INTO entitiesFilters FROM states WHERE user_id = userID AND state_json ->> "$.entitiesFilters" IS NOT NULL ORDER BY state_id DESC LIMIT 1;
            IF entitiesFilters IS NULL
                THEN SET entitiesFilters = JSON_OBJECT(
                    "limit", 50,
                    "offset", 0,
                    "order", "entities_id",
                    "desc", 0,
                    "filters", JSON_ARRAY("all"),
                    "groups", JSON_ARRAY()
                );
            END IF;
            UPDATE states SET state_json = JSON_SET(state_json, "$.entitiesFilters", entitiesFilters) WHERE socket_id = socketID;
        END;
    END IF;
END