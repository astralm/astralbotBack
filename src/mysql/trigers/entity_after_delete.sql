BEGIN
	UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = OLD.entities_id) WHERE entities_id = OLD.entities_id;
END