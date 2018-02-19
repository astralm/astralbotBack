BEGIN
	DECLARE validOperation TINYINT(1) DEFAULT validStandartOperation(userHash, socketHash);
    DECLARE oldEmail, userTelegramUsername VARCHAR(128);
    DECLARE oldName, creatorName VARCHAR(64);
    DECLARE oldPassword VARCHAR(32);
    DECLARE userID, socketID, organizationID, creatorID, userSocketsCount, userSocketsOnlineCount INT(11);
    DECLARE stateJson, userJson JSON;
    DECLARE userDateCreate, userDateUpdate VARCHAR(19);
    DECLARE userTelegramNotification, userWebNotifications, userOnline TINYINT(1);
    DECLARE organizationName VARCHAR(256);
    IF validOperation = 1
    	THEN 
			IF userEmail IS NULL OR userPassword IS NULL OR userName IS NULL
            	THEN
                	SELECT user_email, user_password, user_name INTO oldEmail, oldPassword, oldName FROM users WHERE user_hash = userhash;
                	IF userEmail IS NULL THEN SET userEmail = oldEmail; END IF;
                	IF userPassword IS NULL THEN SET userPassword = oldPassword; END IF;
                	IF userName IS NULL THEN SET userName = oldName; END IF;
            END IF;
			UPDATE users SET user_email = userEmail, user_name = user_name, user_password = userPassword WHERE user_hash = userHash;
            SELECT user_id INTO userID FROM users WHERE user_hash = userHash;
            SELECT socket_id INTO socketID FROM sockets WHERE socket_hash = socketHash;
            SELECT state_json INTO stateJson FROM states WHERE socket_id = socketID;
            SELECT user_name, user_email, user_password INTO userName, userEmail, userPassword FROM users WHERE user_id = userID;
           	SET userJson = JSON_EXTRACT(stateJson, "$.user");
            SET userJson = JSON_SET(userJson, "$.name", userName, "$.email", userEmail);
            SET stateJson = JSON_SET(stateJson, "$.user", userJson);
            UPDATE states SET state_json = stateJson WHERE socket_id = socketID;
            RETURN 1;
    END IF;
    RETURN 0;
END