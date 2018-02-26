BEGIN
    DECLARE validOpertation TINYINT(1) DEFAULT validRootOperation(userHash, socketHash);
    DECLARE userID, socketID, organizationID, newOrganizationID INT(11);
    DECLARE connectionID VARCHAR(128);
    DECLARE organizations, responce, organization JSON;
    SET responce = JSON_ARRAY();
    IF validOpertation
        THEN BEGIN
            SELECT user_id, organization_id INTO userID, organizationID FROM users WHERE user_hash = userHash;
            SELECT socket_id, socket_connection_id INTO socketID, connectionID FROM sockets WHERE socket_hash = socketHash;
            IF organizationRoot
                THEN SET organizationRoot = 3;
                ELSE SET organizationRoot = 4;
            END IF;
            INSERT INTO organizations (organization_name, organization_site, type_id, user_id) VALUES (organizationName, organizationSite, organizationRoot, userID);
            SELECT organization_id INTO newOrganizationID FROM organizations ORDER BY organization_id DESC LIMIT 1;
            CALL getOrganizationForSocket(socketID, newOrganizationID);
            UPDATE states SET state_json = JSON_SET(state_json, "$.page", 21) WHERE socket_id = socketID;
            SELECT state_json ->> "$.viewOrganization" INTO organization FROM states WHERE socket_id = socketID;
            SET responce = JSON_MERGE(responce, JSON_ARRAY(
                JSON_OBJECT(
                    "action", "Procedure",
                    "data", JSON_OBJECT(
                        "query", "dispatchOrganizations",
                        "values", JSON_ARRAY(
                            organizationID
                        )
                    )
                ),
                JSON_OBJECT(
                    "action", "sendToSocket",
                    "data", JSON_OBJECT(
                        "socket", connectionID,
                        "data", JSON_ARRAY(
                            JSON_OBJECT(
                                "action", "merge",
                                "data", JSON_OBJECT(
                                    "viewOrganization", organization
                                )
                            ),
                            JSON_OBJECT(
                                "action", "changePage",
                                "data", JSON_OBJECT(
                                    "page", CONCAT("app/organization:", newOrganizationID)
                                )
                            )
                        )
                    )
                )
            ));
        END;
    END IF;
    RETURN responce;
END