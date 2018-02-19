BEGIN
  SET NEW.entity_essence_date_create = NOW(),
  		NEW.bot_id = (SELECT bot_id FROM entity WHERE entity_id = NEW.entity_id),
      NEW.entities_id = (SELECT entities_id FROM entity WHERE entity_id = NEW.entity_id),
      NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END