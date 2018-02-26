BEGIN
  DECLARE organization JSON;
  SELECT organization_json INTO organization FROM organizations_json WHERE organization_id = organizationID;
  UPDATE states SET state_json = JSON_SET(state_json, "$.viewOrganization", organization) WHERE socket_id = socketID;
END