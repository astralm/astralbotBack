BEGIN
    DECLARE messageText, entitiesString TEXT;
    DECLARE answerID, entitiesID, essenceID, stringLength, organizationID, dialogID, botID, lastLocate, essenceLength INT(11);
    DECLARE essenceValue VARCHAR(1024);
    DECLARE done TINYINT(1);
    DECLARE essencesCursor CURSOR FOR SELECT essence_value, essence_id, CHAR_LENGTH(essence_value) FROM essences;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SET entitiesString = "";
    SET answerID = 0;
    SELECT message_text, dialog_id INTO messageText, dialogID FROM messages WHERE message_id = messageID;
    SELECT organization_id, bot_id INTO organizationID, botID FROM dialogues WHERE dialog_id = dialogID; 
    SET stringLength = CHAR_LENGTH(messageText);
    IF stringLength > 0
        THEN BEGIN
            searchLoop: LOOP
                OPEN essencesCursor;
                    essencesLoop: LOOP
                        FETCH essencesCursor INTO essenceValue, essenceID, essenceLength;
                        SET lastLocate = LOCATE(essenceValue, messageText);
                        IF done OR lastLocate > 0
                            THEN LEAVE essencesLoop;
                        END IF;
                        ITERATE essencesLoop;
                    END LOOP;
                CLOSE essencesCursor;
                IF lastLocate = 0
                    THEN LEAVE searchLoop;
                END IF;
                SET messageText = SUBSTRING(messageText, lastLocate + essenceLength);
                SELECT entities_id INTO entitiesID FROM entities_essences WHERE essence_id = essenceID;
                IF entitiesID IS NOT NULL
                    THEN BEGIN 
                        SET entitiesString = CONCAT(entitiesString, ",", entitiesID);
                    END;
                END IF;
                ITERATE searchLoop;
            END LOOP;
        END;
        SET stringLength = CHAR_LENGTH(entitiesString);
        IF stringLength > 0
            THEN BEGIN
                SET entitiesString = RIGHT(entitiesString, stringLength - 1);
                UPDATE messages SET message_value = entitiesString WHERE message_id = messageID;
                SELECT answer_id INTO answerID FROM conditions_answers WHERE condition_entities = entitiesString AND organization_id = organizationID AND bot_id = botID LIMIT 1;
            END;
        END IF;
    END IF;
    RETURN answerID;
END