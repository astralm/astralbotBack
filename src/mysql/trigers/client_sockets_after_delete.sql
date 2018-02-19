BEGIN
	DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets WHERE client_id = OLD.client_id);
    DECLARE onlineSocketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = OLD.client_id AND socket_connection = 1);
    UPDATE clients SET client_sockets_count = socketsCount, client_online_sockets_count = onlineSocketsCount WHERE client_id = OLD.client_id;
END