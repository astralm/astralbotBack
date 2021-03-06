BEGIN
	DECLARE userID INT(11) DEFAULT (SELECT user_id FROM users WHERE user_hash = userHash);
  DECLARE socketID INT(11) DEFAULT (SELECT socket_id FROM sockets WHERE socket_hash = socketHash);
  DECLARE userSocketConnectedCount INT(11) DEFAULT (SELECT COUNT(*) FROM user_sockets_connection WHERE user_id = userID AND socket_id = socketID AND socket_connection = 1);
  DECLARE userAuth TINYINT(1) DEFAULT (SELECT user_auth FROM users WHERE user_id = userID);
  DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM users WHERE user_id = userID);
  DECLARE organizationType INT(11) DEFAULT (SELECT type_id FROM organizations WHERE organization_id = organizationID);
  IF userSocketConnectedCount > 0 AND userAuth = 1 AND organizationType = 3
  	THEN RETURN 1;
    ELSE RETURN 0;
 	END IF;
END