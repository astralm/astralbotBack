BEGIN
	DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM user_sockets WHERE user_id = OLD.user_id);
    UPDATE users SET user_sockets_count = socketsCount WHERE user_id = OLD.user_id;
END