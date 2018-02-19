BEGIN
    DECLARE dispatchText TEXT DEFAULT (SELECT dispatch_text FROM dispatches WHERE dispatch_id = dispatchID);
    DECLARE done INT(1) DEFAULT 0;
    DECLARE dialogID INT(11);
    DECLARE dispatchDialoguesCursor CURSOR FOR SELECT dialog_id FROM dispatch_dialogues WHERE dispatch_id = dispatchID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN dispatchDialoguesCursor;
    	dialoguesLoop: LOOP
        	FETCH dispatchDialoguesCursor INTO dialogID;
            IF done = 1 
            	THEN LEAVE dialoguesLoop;
            END IF;
            INSERT INTO messages (dialog_id, message_text, dispatch_id) VALUES (dialogID, dispatchText, dispatchID);
        END LOOP;
    CLOSE dispatchDialoguesCursor;
END