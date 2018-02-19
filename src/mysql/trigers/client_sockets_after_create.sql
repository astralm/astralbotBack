BEGIN
	DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets WHERE client_id = NEW.client_id);
    DECLARE onlineSocketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = NEW.client_id AND socket_connection = 1);
    DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM clients WHERE client_id = NEW.client_id);
	UPDATE clients SET client_sockets_count = socketsCount, client_sockets_online_count = onlineSocketsCount WHERE client_id = NEW.client_id;
    UPDATE sockets SET organization_id = organizationID WHERE socket_id = NEW.socket_id;
    UPDATE states SET client_id = NEW.client_id WHERE socket_id = NEW.socket_id;
END