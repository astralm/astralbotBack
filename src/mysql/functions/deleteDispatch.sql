BEGIN
	DECLARE validOpertaion TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
	DECLARE organizationID INT(11);
	DECLARE responce JSON;
	SET responce = JSON_ARRAY();
	IF validOpertaion
		THEN BEGIN
			SELECT organization_id INTO organizationID FROM sockets WHERE socket_hash = socketHash;
			DELETE FROM dispatches WHERE dispatch_id = dispatchID;
			SET responce = JSON_MERGE(responce, dispatchDispatches(organizationID));
		END;
	END IF;
	RETURN responce;
END