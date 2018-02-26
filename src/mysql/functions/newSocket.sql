BEGIN
    DECLARE socketHash VARCHAR(32);
    DECLARE socketID INT(11);
    DECLARE stateJson JSON;
    DECLARE connectionID VARCHAR(128);
    DECLARE responce JSON;
    SET responce = JSON_ARRAY();
    INSERT INTO sockets (
        type_id, 
        socket_connection_id, 
        socket_engine_name, 
        socket_engine_version, 
        socket_os_version, 
        socket_device_vendor, 
        socket_device_model, 
        socket_device_type,
        socket_browser_name,
        socket_browser_version,
        socket_url, 
        socket_ip, 
        organization_id, 
        socket_os_name
    ) VALUES (
        typeID, 
        socketConnectionID, 
        socketEngineName, 
        socketEngineVersion, 
        socketOsVersion, 
        socketDeviceVendor, 
        socketDeviceModel, 
        socketDeviceType,
        socketBrowserName,
        socketBrowserVersion, 
        socketUrl, 
        socketIP, 
        organizationID, 
        socketOsName
    );
    SELECT socket_hash, socket_id, socket_connection_id INTO socketHash, socketID, connectionID FROM sockets ORDER BY socket_id DESC LIMIT 1;
    SET stateJson = JSON_OBJECT(
        "socket", JSON_OBJECT(
            "hash", socketHash
        )
    );
    UPDATE states SET state_json = stateJson WHERE socket_id = socketID;
    IF typeID = 1 
        THEN SET responce = JSON_MERGE(responce, JSON_OBJECT(
            "action", "sendToSocket",
            "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                    JSON_OBJECT(
                        "action", "setSocketHash",
                        "data", JSON_OBJECT(
                            "newSocketHash", socketHash
                        )
                    ),
                    JSON_OBJECT(
                        "action", "sendInfo"
                    )
                )
            )
        ));
        ELSE SET responce = JSON_MERGE(responce, JSON_OBJECT(
            "action", "sendToSocket",
            "data", JSON_OBJECT(
                "socket", connectionID,
                "data", JSON_ARRAY(
                    JSON_OBJECT(
                        "action", "setState",
                        "data", stateJson
                    ),
                    JSON_OBJECT(
                        "action", "setLocal",
                        "data", JSON_OBJECT(
                            "socket", socketHash
                        )
                    )
                )
            )
        ));
    END IF;
    RETURN responce;
END