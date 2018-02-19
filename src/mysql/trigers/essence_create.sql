BEGIN
	SET NEW.essence_date_create = NOW(),
    	NEW.essence_date_update = NOW(),
        NEW.essence_value = LOWER(NEW.essence_value);
END