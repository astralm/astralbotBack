BEGIN
  DECLARE done TINYINT(1);
  DECLARE dispatches, dispatch, types, bots JSON;
  DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM sockets WHERE socket_id = socketID);
  DECLARE dispatchesCursor CURSOR FOR SELECT dispatch_json FROM dispatch_json WHERE organization_id = organizationID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  SET dispatches = JSON_ARRAY();
  OPEN dispatchesCursor;
    dispatchesLoop: LOOP
      FETCH dispatchesCursor INTO dispatch;
      IF done
        THEN LEAVE dispatchesLoop;
      END IF;
      SET types = getTypesForDispatch(JSON_EXTRACT(dispatch, "$.dispatch_id"));
      SET bots = getBotsForDispatch(JSON_EXTRACT(dispatch, "$.dispatch_id"));
      SET dispatch = JSON_SET(dispatch, "$.types", types, "$.bots", bots);
      SET dispatches = JSON_MERGE(dispatches, dispatch);
      ITERATE dispatchesLoop;
    END LOOP;
  CLOSE dispatchesCursor;
  UPDATE states SET state_json = JSON_SET(state_json, "$.dispatches", dispatches) WHERE socket_id = socketID;
END