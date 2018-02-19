BEGIN
    IF NEW.organization_site REGEXP ".*[[.full-stop.]]..*"
        THEN
            SET NEW.organization_date_update = NOW();
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid organization site";
    END IF;
END