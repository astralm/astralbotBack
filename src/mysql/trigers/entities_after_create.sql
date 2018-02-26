BEGIN
	IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = NEW.group_id);
    END IF;
END