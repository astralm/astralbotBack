BEGIN
	IF OLD.group_id IS NOT NULL AND OLD.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = OLD.group_id);
    END IF;
END