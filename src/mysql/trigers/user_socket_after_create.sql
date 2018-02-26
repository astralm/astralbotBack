BEGIN
	DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
	UPDATE sockets SET organization_id = organizationID WHERE socket_id = NEW.socket_id;
    UPDATE states SET organization_id = organizationID, user_id = NEW.user_id WHERE socket_id = NEW.socket_id;
END