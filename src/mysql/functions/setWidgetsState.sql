BEGIN
  DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
  DECLARE organizationID INT(11);
  DECLARE organizationWidgetsWork TINYINT(1);
  DECLARE responce JSON;
  SET responce = JSON_ARRAY();
  IF validOperation
    THEN BEGIN
      SELECT organization_id INTO organizationID FROM sockets WHERE socket_hash = socketHash;
      SELECT organization_widgets_work INTO organizationWidgetsWork FROM organizations WHERE organization_id = organizationID;
      SET organizationWidgetsWork = !organizationWidgetsWork;
      UPDATE organizations SET organization_widgets_work = organizationWidgetsWork WHERE organization_id = organizationID;
      SET responce = JSON_MERGE(responce, dispatchWidgetsState(organizationID));
    END;
  END IF;
  RETURN responce;
END