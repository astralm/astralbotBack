BEGIN
	DECLARE essencesCount INT(11) DEFAULT (SELECT COUNT(*) FROM entity_essences WHERE entity_id = OLD.entity_id);
    UPDATE entity SET entity_essences_count = essencesCount WHERE entity_id = OLD.entity_id;
END