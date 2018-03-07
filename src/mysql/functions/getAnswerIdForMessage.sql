BEGIN
    DECLARE messageText, entitiesString, messageSegment, cutResultLeft, searchResult, cutResultRight, essenceString, segmentDuplicate TEXT;
    DECLARE answerID, entitiesID, essenceID, stringLength, organizationID, dialogID, botID, shift, segmentLength, essenceEnd, essenceStart, iterator, iterator2, segmentEssencesLength, searchResultLength, searchEndPoint, essenceInArray, mainEssenceInArray, essenceLength, flagStart, cutLength, startLocate, essencesLength, minStart, searchStartPoint INT(11);
    DECLARE messageArray, essencesPositionArray, segmentEssencesArray, searchResultArray, saveEssences, essence, segmentEssenceArray, cutWeights JSON;
    SET answerID = 0;
    SET saveEssences = JSON_ARRAY();
    SELECT LOWER(message_text), dialog_id INTO messageText, dialogID FROM messages WHERE message_id = messageID;
    SELECT organization_id, bot_id INTO organizationID, botID FROM dialogues WHERE dialog_id = dialogID; 
    SET stringLength = CHAR_LENGTH(messageText);
    IF stringLength > 0
        THEN BEGIN
            SET messageArray = JSON_ARRAY(JSON_ARRAY(0, messageText));
            SET essencesPositionArray = JSON_ARRAY();
            searchLoop: LOOP
                IF JSON_LENGTH(messageArray) = 0
                    THEN LEAVE searchLoop;
                END IF;
                SET messageSegment = JSON_UNQUOTE(JSON_EXTRACT(messageArray, "$[0][1]"));
                SET shift = JSON_UNQUOTE(JSON_EXTRACT(messageArray, "$[0][0]"));
                SET segmentLength = CHAR_LENGTH(messageSegment);
                SET segmentEssencesArray = getEssencesInText(botID, shift, messageSegment);
                SET segmentEssencesLength = JSON_LENGTH(segmentEssencesArray);         
                IF segmentEssencesLength > 0
                    THEN BEGIN
                        SET iterator = 0;
                        cutLoop: LOOP
                            IF iterator >= segmentEssencesLength
                                THEN BEGIN 
                                    LEAVE cutLoop;
                                END;
                            END IF;
                            SET segmentEssenceArray = JSON_EXTRACT(segmentEssencesArray, CONCAT("$[", iterator, "]"));
                            SET essenceStart = JSON_EXTRACT(segmentEssenceArray, "$[1][0]");
                            SET essenceEnd = JSON_EXTRACT(segmentEssenceArray, "$[1][1]");
                            SET searchResultArray = JSON_ARRAY();
                            SET iterator2 = 0;
                            searchInternalLoop: LOOP
                                IF iterator2 >= segmentEssencesLength
                                    THEN LEAVE searchInternalLoop;
                                END IF;
                                SET essence = JSON_EXTRACT(segmentEssencesArray, CONCAT("$[", iterator2, "]"));
                                SET searchStartPoint = JSON_EXTRACT(essence, "$[1][0]");
                                SET searchEndPoint = JSON_EXTRACT(essence, "$[1][1]");
                                IF iterator != iterator2 AND searchStartPoint >= essenceStart AND searchEndPoint <= essenceEnd
                                    THEN SET searchResultArray = JSON_MERGE(searchResultArray, CONCAT(iterator2));
                                END IF;
                                SET iterator2 = iterator2 + 1;
                                ITERATE searchInternalLoop;
                            END LOOP;
                            SET searchResultLength = JSON_LENGTH(searchResultArray);
                            IF searchResultLength > 0
                                THEN BEGIN
                                    SET iterator2 = 0;
                                    deleteEssencesLoop: LOOP
                                        IF iterator2 >= searchResultLength
                                            THEN LEAVE deleteEssencesLoop;
                                        END IF;
                                        SET searchResult = JSON_EXTRACT(searchResultArray, CONCAT("$[", iterator2, "]"));
                                        SET segmentEssencesArray = JSON_REMOVE(segmentEssencesArray, CONCAT("$[", searchResult - iterator2, "]"));
                                        SET iterator2 = iterator2 + 1;
                                        ITERATE deleteEssencesLoop;
                                    END LOOP;
                                END;
                            END IF;
                            SET segmentEssencesLength = JSON_LENGTH(segmentEssencesArray);
                            SET iterator = iterator + 1;
                            ITERATE cutLoop;
                        END LOOP;
                        SET essencesPositionArray = JSON_MERGE(essencesPositionArray, segmentEssencesArray);
                    END;
                END IF;
                SET messageArray = JSON_REMOVE(messageArray, "$[0]");

                SET iterator = 0;
                SET segmentEssencesLength = JSON_LENGTH(segmentEssencesArray);
                SET segmentDuplicate = messageSegment;
                SET cutWeights = JSON_ARRAY();
                cutSegmentLoop: LOOP
                    IF iterator >= segmentEssencesLength
                        THEN LEAVE cutSegmentLoop;
                    END IF;
                    SET essence = JSON_EXTRACT(segmentEssencesArray, CONCAT("$[", iterator, "]"));
                    SET essenceStart = JSON_EXTRACT(essence, "$[1][0]");
                    SET essenceEnd = JSON_EXTRACT(essence, "$[1][1]");
                    SET essenceLength = essenceEnd - essenceStart + 1;
                    SET cutWeights = JSON_SET(cutWeights, CONCAT("$[", iterator, "]"), essenceLength);
                    SET essenceString = SUBSTRING(messageSegment, essenceStart - shift, essenceLength);
                    SET essenceStart = INSTR(segmentDuplicate, essenceString);
                    SET segmentDuplicate = INSERT(segmentDuplicate, essenceStart, essenceLength, "{{$$$}}");
                    SET iterator = iterator + 1;
                    ITERATE cutSegmentLoop;
                END LOOP;
                SET iterator = 0;
                SET startLocate = 0;
                uploadLoop: LOOP
                    IF iterator >= segmentEssencesLength
                        THEN LEAVE uploadLoop;
                    END IF;
                    SET flagStart = INSTR(segmentDuplicate, "{{$$$}}") - 1;
                    IF flagStart > 0
                        THEN BEGIN
                            SET cutResultLeft = LEFT(segmentDuplicate, flagStart);
                            SET cutLength = CHAR_LENGTH(cutResultLeft);
                            SET messageArray = JSON_MERGE(messageArray, JSON_ARRAY(JSON_ARRAY(flagStart + startLocate + shift - cutLength, cutResultLeft)));
                            SET startLocate = startLocate + cutLength + JSON_EXTRACT(cutWeights, CONCAT("$[", iterator, "]"));
                            SET segmentDuplicate = SUBSTRING(segmentDuplicate, cutLength + 8);
                        END;
                        ELSE BEGIN
                            SET startLocate = startLocate + JSON_EXTRACT(cutWeights, CONCAT("$[", iterator, "]"));
                            SET segmentDuplicate = SUBSTRING(segmentDuplicate, 8);
                        END;
                    END IF;
                    IF iterator = segmentEssencesLength - 1 AND CHAR_LENGTH(segmentDuplicate) > 0
                        THEN BEGIN 
                            SET cutLength = CHAR_LENGTH(segmentDuplicate);
                            SET segmentLength = CHAR_LENGTH(messageSegment);
                            SET messageArray = JSON_MERGE(messageArray, JSON_ARRAY(JSON_ARRAY(shift + segmentLength - cutLength, segmentDuplicate)));
                        END;
                    END IF;
                    SET iterator = iterator + 1;
                    ITERATE uploadLoop;
                END LOOP;
                ITERATE searchLoop;
            END LOOP;
        END;
    END IF;
    SET essencesLength = JSON_LENGTH(essencesPositionArray);
    IF essencesLength > 0 AND essencesLength > 1
        THEN BEGIN
            essencesBustLoop: LOOP
                IF essencesLength <= 0
                    THEN LEAVE essencesBustLoop;
                END IF;
                SET iterator = 0;
                findMinEssenceLoop: LOOP
                    IF iterator >= essencesLength
                        THEN LEAVE findMinEssenceLoop;
                    END IF;
                    SET essence = JSON_EXTRACT(essencesPositionArray, CONCAT("$[", iterator, "]"));
                    SET essenceStart = JSON_UNQUOTE(JSON_EXTRACT(essence, "$[1][0]"));
                    SET essenceInArray = iterator;
                    IF iterator = 0
                        THEN BEGIN 
                            SET minStart = essenceStart;
                            SET mainEssenceInArray = essenceInArray;
                        END;
                        ELSE BEGIN
                            IF essenceStart < minStart
                                THEN BEGIN
                                    SET minStart = essenceStart;
                                    SET mainEssenceInArray = essenceInArray;
                                END;
                            END IF;
                        END;
                    END IF;
                    SET iterator = iterator + 1;
                    ITERATE findMinEssenceLoop;
                END LOOP;
                SET saveEssences = JSON_MERGE(saveEssences, JSON_EXTRACT(essencesPositionArray, CONCAT("$[", mainEssenceInArray, "][0]")));
                SET essencesPositionArray = JSON_REMOVE(essencesPositionArray, CONCAT("$[", mainEssenceInArray, "]"));
                SET essencesLength = essencesLength - 1;
                ITERATE essencesBustLoop;
            END LOOP;
        END;
        ELSE SET saveEssences = JSON_ARRAY(JSON_EXTRACT(essencesPositionArray, "$[0][0]"));
    END IF;
    SET essencesLength = JSON_LENGTH(saveEssences);
    IF essencesLength > 0
        THEN BEGIN
            SET iterator = 0;
            findEntitiesLoop: LOOP
                IF iterator >= essencesLength
                    THEN LEAVE findEntitiesLoop;
                END IF;
                SET essenceID = JSON_EXTRACT(saveEssences, CONCAT("$[", iterator, "]"));
                SELECT entities_id INTO entitiesID FROM entities_essences WHERE essence_id = essenceID AND bot_id = botID;
                SET saveEssences = JSON_SET(saveEssences, CONCAT("$[", iterator, "]"), entitiesID);
                SET iterator = iterator + 1;
                ITERATE findEntitiesLoop;
            END LOOP;
            SET entitiesString = REPLACE(REPLACE(REPLACE(saveEssences, "[", ""), "]", ""), " ", "");
            SELECT answer_id INTO answerID FROM conditions_answers WHERE organization_id = organizationID AND bot_id = botID AND condition_entities = entitiesString;
        END;
    END IF;
    RETURN answerID;
END