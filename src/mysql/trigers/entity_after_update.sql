BEGIN
	UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = NEW.entities_id) WHERE entities_id = NEW.entities_id;
END