BEGIN
  DECLARE validOrganization TINYINT(1) DEFAULT validRootOperation(userHash, socketHash);
  DECLARE Nname, Ssite VARCHAR(256);
  DECLARE connectionID VARCHAR(128);
  DECLARE typeID, socketID, userOrganizationID INT(11);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  IF validOrganization
    THEN BEGIN
      SELECT socket_id, organization_id, socket_connection_id INTO socketID, userOrganizationID, connectionID FROM sockets WHERE socket_hash = socketHash;
      SELECT organization_name, organization_site, type_id INTO Nname, Ssite, typeID FROM organizations WHERE organization_id = organizationID;
      IF name IS NOT NULL
        THEN SET Nname = name;
      END IF;
      IF site IS NOT NULL
        THEN SET Ssite = site;
      END IF;
      IF organizationRoot IS NOT NULL
        THEN BEGIN
          IF organizationRoot
            THEN SET typeID = 3;
            ELSE SET typeID = 4;
          END IF;
        END;
      END IF;
      UPDATE organizations SET organization_name = Nname, organization_site = Ssite, type_id = typeID WHERE organization_id = organizationID;
      UPDATE states SET state_json = JSON_SET(state_json, "$.viewOrganization.organization_name", Nname, "$.viewOrganization.organization_site", Ssite, "$.viewOrganization.type_id", typeID) WHERE socket_id = socketID;
      SET responce = JSON_MERGE(responce, dispatchOrganization(userOrganizationID, organizationID));
      SET responce = JSON_MERGE(responce, JSON_ARRAY(
        JSON_OBJECT(
          "action", "Procedure",
          "data", JSON_OBJECT(
            "query", "dispatchOrganizations",
            "values", JSON_ARRAY(
              userOrganizationID
            )
          )
        ),
        JSON_OBJECT(
          "action", "sendToSocket",
          "data", JSON_OBJECT(
            "socket", connectionID,
            "data", JSON_ARRAY(
              JSON_OBJECT(
                "action", "changePage",
                "data", JSON_OBJECT(
                  "page", CONCAT("app/organization:", organizationID)
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