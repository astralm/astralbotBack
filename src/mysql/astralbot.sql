-- phpMyAdmin SQL Dump
-- version 4.7.5
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Фев 19 2018 г., 11:41
-- Версия сервера: 5.7.20
-- Версия PHP: 7.1.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `astralbot`
--

-- --------------------------------------------------------

--
-- Структура таблицы `answers`
--

CREATE TABLE `answers` (
  `answer_id` int(11) NOT NULL,
  `answer_text` varchar(2048) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `answer_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `answer_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_id` int(11) NOT NULL,
  `organization_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `answers`
--
DELIMITER $$
CREATE TRIGGER `answer_after_create` AFTER INSERT ON `answers` FOR EACH ROW BEGIN
	UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = NEW.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_after_delete` AFTER DELETE ON `answers` FOR EACH ROW BEGIN
	UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = OLD.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_after_update` AFTER UPDATE ON `answers` FOR EACH ROW BEGIN
	UPDATE intents SET intent_answers_count = (SELECT COUNT(*) FROM answers WHERE intent_id = NEW.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_create` BEFORE INSERT ON `answers` FOR EACH ROW BEGIN
	SET NEW.answer_date_create = NOW();
    SET NEW.answer_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM intents WHERE intent_id = NEW.intent_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `answer_update` BEFORE UPDATE ON `answers` FOR EACH ROW BEGIN
	SET NEW.answer_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `bots`
--

CREATE TABLE `bots` (
  `bot_id` int(11) NOT NULL,
  `bot_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `bot_telegram_key` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `bot_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `bot_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bot_intents_count` int(11) NOT NULL DEFAULT '0',
  `bot_entities_count` int(11) NOT NULL DEFAULT '0',
  `organization_id` int(11) DEFAULT NULL,
  `bot_hash` varchar(32) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `bots`
--
DELIMITER $$
CREATE TRIGGER `bot_insert` BEFORE INSERT ON `bots` FOR EACH ROW BEGIN
	SET NEW.bot_date_create = NOW();
    SET NEW.bot_date_update = NOW();
    SET NEW.bot_hash = getHash(32);
    SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bot_update` BEFORE INSERT ON `bots` FOR EACH ROW BEGIN
	SET NEW.bot_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `bots_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `bots_json` (
`bot_json` json
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `bot_entities`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `bot_entities` (
`entities_json` json
,`organization_id` int(11)
,`bot_id` int(11)
,`group_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `bot_info`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `bot_info` (
`bot_json` json
,`organization_id` int(11)
,`bot_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `bot_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `bot_json` (
`bot_json` json
,`dispatch_id` int(11)
,`bot_id` int(11)
,`bot_name` varchar(64)
);

-- --------------------------------------------------------

--
-- Структура таблицы `clients`
--

CREATE TABLE `clients` (
  `client_id` int(11) NOT NULL,
  `client_name` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `client_email` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `client_phone` bigint(11) DEFAULT NULL,
  `client_telegram_chat` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `client_username` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `client_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `client_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `organization_id` int(11) NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `client_online` tinyint(1) NOT NULL DEFAULT '0',
  `client_sockets_count` int(11) NOT NULL DEFAULT '0',
  `client_sockets_online_count` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `clients`
--
DELIMITER $$
CREATE TRIGGER `client_create` BEFORE INSERT ON `clients` FOR EACH ROW BEGIN
	SET NEW.client_date_create = NOW();
    SET NEW.client_date_update = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `client_update` BEFORE UPDATE ON `clients` FOR EACH ROW BEGIN
	SET NEW.client_date_update = NOW();
    SET NEW.client_sockets_online_count = (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = NEW.client_id AND socket_connection = 1);
    IF NEW.client_sockets_online_count = 0 
    	THEN SET NEW.client_online = 0;
        ELSE SET NEW.client_online = 1;
    END IF;
    IF NEW.client_online
    	THEN UPDATE dialogues SET dialog_active = 1 WHERE client_id = NEW.client_id;
        ELSE UPDATE dialogues SET dialog_active = 0 WHERE client_id = NEW.client_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `clients_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `clients_json` (
`client_json` json
,`client_id` int(11)
,`client_name` varchar(64)
,`client_username` varchar(128)
,`client_email` varchar(128)
,`client_phone` bigint(11)
,`dialog_id` int(11)
,`organization_id` int(11)
,`client_online` tinyint(1)
,`client_date_create` varchar(19)
,`socket_url` varchar(512)
,`socket_ip` varchar(128)
,`socket_browser_name` varchar(128)
,`socket_browser_version` varchar(128)
,`socket_engine_name` varchar(128)
,`socket_engine_version` varchar(128)
,`socket_os_name` varchar(128)
,`socket_os_version` varchar(128)
,`socket_device_vendor` varchar(128)
,`socket_device_model` varchar(128)
,`socket_device_type` varchar(128)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `client_bot`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `client_bot` (
`bot_id` int(11)
,`client_id` int(11)
,`client_telegram_chat` varchar(128)
);

-- --------------------------------------------------------

--
-- Структура таблицы `client_sockets`
--

CREATE TABLE `client_sockets` (
  `client_socket_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `socket_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `client_sockets`
--
DELIMITER $$
CREATE TRIGGER `client_sockets_after_create` AFTER INSERT ON `client_sockets` FOR EACH ROW BEGIN
	DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets WHERE client_id = NEW.client_id);
    DECLARE onlineSocketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = NEW.client_id AND socket_connection = 1);
    DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM clients WHERE client_id = NEW.client_id);
	UPDATE clients SET client_sockets_count = socketsCount, client_sockets_online_count = onlineSocketsCount WHERE client_id = NEW.client_id;
    UPDATE sockets SET organization_id = organizationID WHERE socket_id = NEW.socket_id;
    UPDATE states SET client_id = NEW.client_id WHERE socket_id = NEW.socket_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `client_sockets_after_delete` AFTER DELETE ON `client_sockets` FOR EACH ROW BEGIN
	DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets WHERE client_id = OLD.client_id);
    DECLARE onlineSocketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM client_sockets_connection WHERE client_id = OLD.client_id AND socket_connection = 1);
    UPDATE clients SET client_sockets_count = socketsCount, client_online_sockets_count = onlineSocketsCount WHERE client_id = OLD.client_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `client_sockets_connection`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `client_sockets_connection` (
`client_id` int(11)
,`socket_id` int(11)
,`socket_connection` tinyint(1)
,`socket_connection_id` varchar(128)
);

-- --------------------------------------------------------

--
-- Структура таблицы `conditions`
--

CREATE TABLE `conditions` (
  `condition_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `condition_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `condition_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_id` int(11) NOT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `condition_entities` text COLLATE utf8_bin NOT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `conditions`
--
DELIMITER $$
CREATE TRIGGER `condition_after_create` AFTER INSERT ON `conditions` FOR EACH ROW BEGIN
	UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = NEW.intent_id) WHERE intent_id = NEW.intent_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_after_delete` AFTER DELETE ON `conditions` FOR EACH ROW BEGIN
	UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = OLD.intent_id) WHERE intent_id = OLD.intent_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_after_update` AFTER UPDATE ON `conditions` FOR EACH ROW BEGIN
	UPDATE intents SET intent_conditions_count = (SELECT COUNT(*) FROM conditions WHERE intent_id = NEW.intent_id) WHERE intent_id = NEW.intent_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_create` BEFORE INSERT ON `conditions` FOR EACH ROW BEGIN
	SET NEW.condition_date_create = NOW();
    SET NEW.condition_date_update = NOW();
    SET NEW.bot_id = (SELECT bot_id FROM intents WHERE intent_id = NEW.intent_id);
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `condition_update` BEFORE UPDATE ON `conditions` FOR EACH ROW BEGIN
	SET NEW.condition_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `conditions_answers`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `conditions_answers` (
`answer_id` int(11)
,`condition_id` int(11)
,`organization_id` int(11)
,`condition_entities` text
,`bot_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `dialogues`
--

CREATE TABLE `dialogues` (
  `dialog_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `dialog_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `dialog_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `dialog_messages_count` int(11) NOT NULL DEFAULT '0',
  `dialog_error` tinyint(1) NOT NULL DEFAULT '0',
  `bot_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `dialog_active` tinyint(1) NOT NULL DEFAULT '0',
  `dialog_bot_work` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `dialogues`
--
DELIMITER $$
CREATE TRIGGER `dialog_create` BEFORE INSERT ON `dialogues` FOR EACH ROW BEGIN
	SET NEW.dialog_date_create = NOW();
    SET NEW.dialog_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM clients WHERE client_id = NEW.client_id);
    SET NEW.type_id = (SELECT type_id FROM clients WHERE client_id = NEW.client_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dialog_update` BEFORE UPDATE ON `dialogues` FOR EACH ROW BEGIN
	SET NEW.dialog_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `dialogues_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `dialogues_json` (
`dialog_json` json
,`dialog_id` int(11)
,`client_message_text` text
,`user_message_text` text
,`client_id` int(11)
,`user_id` int(11)
,`dialog_date_create` varchar(19)
,`dialog_date_update` varchar(19)
,`dialog_messages_count` int(11)
,`dialog_error` tinyint(1)
,`bot_id` int(11)
,`organization_id` int(11)
,`type_id` int(11)
,`dialog_active` tinyint(1)
,`user_name` varchar(64)
,`client_name` varchar(64)
,`client_username` varchar(128)
,`socket_url` varchar(512)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `dialog_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `dialog_json` (
`dialog_json` json
,`dialog_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `dispatches`
--

CREATE TABLE `dispatches` (
  `dispatch_id` int(11) NOT NULL,
  `dispatch_text` text COLLATE utf8_bin NOT NULL,
  `dispatch_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `dispatch_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  `dispatch_messages_count` int(11) NOT NULL DEFAULT '0',
  `dispatch_delete` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `dispatches`
--
DELIMITER $$
CREATE TRIGGER `dispatch_create` BEFORE INSERT ON `dispatches` FOR EACH ROW BEGIN
	SET NEW.dispatch_date_create = NOW();
    SET NEW.dispatch_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dispatch_update` BEFORE UPDATE ON `dispatches` FOR EACH ROW BEGIN
	SET NEW.dispatch_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `dispatch_bots`
--

CREATE TABLE `dispatch_bots` (
  `dispatch_bot_id` int(11) NOT NULL,
  `dispatch_id` int(11) NOT NULL,
  `bot_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `dispatch_dialogues`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `dispatch_dialogues` (
`dialog_id` int(11)
,`dispatch_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `dispatch_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `dispatch_json` (
`dispatch_json` json
,`organization_id` int(11)
,`dispatch_id` int(11)
,`dispatch_date_create` varchar(19)
,`dispatch_delete` tinyint(1)
,`dispatch_text` text
,`user_id` int(11)
,`dispatch_messages_count` int(11)
,`user_name` varchar(64)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `dispatch_messages`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `dispatch_messages` (
`message_id` int(11)
,`dialog_id` int(11)
,`user_id` int(11)
,`message_date_create` varchar(19)
,`message_date_update` varchar(19)
,`message_text` text
,`message_client` tinyint(1)
,`dispatch_id` int(11)
,`message_api_callback` tinyint(1)
,`message_error` tinyint(1)
,`bot_id` int(11)
,`message_value` text
,`intent_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `dispatch_types`
--

CREATE TABLE `dispatch_types` (
  `dispatch_type_id` int(11) NOT NULL,
  `dispatch_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `entities`
--

CREATE TABLE `entities` (
  `entities_id` int(11) NOT NULL,
  `entities_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `entities_entity_count` int(11) NOT NULL DEFAULT '0',
  `entities_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `entities_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `entities`
--
DELIMITER $$
CREATE TRIGGER `entities_after_create` AFTER INSERT ON `entities` FOR EACH ROW BEGIN
	IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = NEW.group_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_after_delete` AFTER DELETE ON `entities` FOR EACH ROW BEGIN
	IF OLD.group_id IS NOT NULL AND OLD.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = OLD.group_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_after_update` AFTER UPDATE ON `entities` FOR EACH ROW BEGIN
	IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM entities WHERE group_id = NEW.group_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_create` BEFORE INSERT ON `entities` FOR EACH ROW BEGIN
	SET NEW.entities_date_create = NOW();
    SET NEW.entities_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entities_update` BEFORE UPDATE ON `entities` FOR EACH ROW BEGIN
	SET NEW.entities_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `entities_essences`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `entities_essences` (
`entities_id` int(11)
,`essence_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `entities_info`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `entities_info` (
`entities_json` json
,`bot_id` int(11)
,`entities_id` int(11)
,`group_id` int(11)
,`organization_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `entities_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `entities_json` (
`entities_json` json
,`organization_id` int(11)
,`bot_id` int(11)
,`group_id` int(11)
,`entities_id` int(11)
,`entities_name` varchar(64)
,`group_name` varchar(64)
);

-- --------------------------------------------------------

--
-- Структура таблицы `entity`
--

CREATE TABLE `entity` (
  `entity_id` int(11) NOT NULL,
  `entity_name` varchar(1024) COLLATE utf8_bin NOT NULL,
  `entities_id` int(11) NOT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `entity_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `entity_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `entity_essences_count` int(11) DEFAULT '0',
  `organization_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `entity`
--
DELIMITER $$
CREATE TRIGGER `entity_after_delete` AFTER DELETE ON `entity` FOR EACH ROW BEGIN
	UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = OLD.entities_id) WHERE entities_id = OLD.entities_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_after_insert` AFTER INSERT ON `entity` FOR EACH ROW BEGIN
	UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = NEW.entities_id) WHERE entities_id = NEW.entities_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_after_update` AFTER UPDATE ON `entity` FOR EACH ROW BEGIN
	UPDATE entities SET entities_entity_count = (SELECT COUNT(*) FROM entity WHERE entities_id = NEW.entities_id) WHERE entities_id = NEW.entities_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_create` BEFORE INSERT ON `entity` FOR EACH ROW BEGIN
	SET NEW.entity_date_create = NOW(),
    	NEW.entity_date_update = NOW(),
        NEW.bot_id = (SELECT bot_id FROM entities WHERE entities_id = NEW.entities_id),
        NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_update` BEFORE UPDATE ON `entity` FOR EACH ROW BEGIN
	SET NEW.entity_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `entity_essences`
--

CREATE TABLE `entity_essences` (
  `entity_essence_id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `essence_id` int(11) NOT NULL,
  `entity_essence_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bot_id` int(11) DEFAULT NULL,
  `entities_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `entity_essences`
--
DELIMITER $$
CREATE TRIGGER `entity_essence_after_delete` AFTER DELETE ON `entity_essences` FOR EACH ROW BEGIN
	DECLARE essencesCount INT(11) DEFAULT (SELECT COUNT(*) FROM entity_essences WHERE entity_id = OLD.entity_id);
    UPDATE entity SET entity_essences_count = essencesCount WHERE entity_id = OLD.entity_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_essences_after_create` AFTER INSERT ON `entity_essences` FOR EACH ROW BEGIN
	DECLARE essencesCount INT(11) DEFAULT (SELECT COUNT(*) FROM entity_essences WHERE entity_id = NEW.entity_id);
    UPDATE entity SET entity_essences_count = essencesCount WHERE entity_id = NEW.entity_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entity_essences_create` BEFORE INSERT ON `entity_essences` FOR EACH ROW BEGIN
  SET NEW.entity_essence_date_create = NOW(),
  		NEW.bot_id = (SELECT bot_id FROM entity WHERE entity_id = NEW.entity_id),
      NEW.entities_id = (SELECT entities_id FROM entity WHERE entity_id = NEW.entity_id),
      NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `essences`
--

CREATE TABLE `essences` (
  `essence_id` int(11) NOT NULL,
  `essence_value` varchar(1024) COLLATE utf8_bin NOT NULL,
  `essence_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `essence_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `essences`
--
DELIMITER $$
CREATE TRIGGER `essence_create` BEFORE INSERT ON `essences` FOR EACH ROW BEGIN
	SET NEW.essence_date_create = NOW(),
    	NEW.essence_date_update = NOW(),
        NEW.essence_value = LOWER(NEW.essence_value);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `essence_update` BEFORE UPDATE ON `essences` FOR EACH ROW BEGIN
	SET NEW.essence_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `filter_bots_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `filter_bots_json` (
`bot_json` json
,`bot_id` int(11)
,`bot_name` varchar(64)
,`bot_date_update` varchar(19)
,`bot_telegram_key` varchar(128)
,`organization_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `groups`
--

CREATE TABLE `groups` (
  `group_id` int(11) NOT NULL,
  `group_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `group_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `group_items_count` int(11) NOT NULL DEFAULT '0',
  `type_id` int(11) DEFAULT NULL,
  `bot_id` int(11) NOT NULL,
  `organization_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `groups`
--
DELIMITER $$
CREATE TRIGGER `groups_create` BEFORE INSERT ON `groups` FOR EACH ROW BEGIN
	SET NEW.group_date_create = NOW();
  SET NEW.group_date_update = NOW();
  SET NEW.organization_id = (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `groups_update` BEFORE UPDATE ON `groups` FOR EACH ROW BEGIN
	SET NEW.group_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `groups_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `groups_json` (
`group_json` json
,`group_id` int(11)
,`group_name` varchar(64)
,`group_items_count` int(11)
,`organization_id` int(11)
,`bot_id` int(11)
,`type_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `group_info`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `group_info` (
`group_json` json
,`organization_id` int(11)
,`bot_id` int(11)
,`group_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `group_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `group_json` (
`group_json` json
,`organization_id` int(11)
,`group_id` int(11)
,`bot_id` int(11)
,`type_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `intents`
--

CREATE TABLE `intents` (
  `intent_id` int(11) NOT NULL,
  `intent_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `bot_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `intent_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `intent_conditions_count` int(11) NOT NULL DEFAULT '0',
  `intent_answers_count` int(11) NOT NULL DEFAULT '0',
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `intents`
--
DELIMITER $$
CREATE TRIGGER `intent_after_create` AFTER INSERT ON `intents` FOR EACH ROW BEGIN
	IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = NEW.group_id) WHERE group_id = NEW.group_id;
    END IF;
    UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = NEW.bot_id) WHERE bot_id = NEW.bot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_after_delete` AFTER DELETE ON `intents` FOR EACH ROW BEGIN
	IF OLD.group_id IS NOT NULL AND OLD.group_id > 0
    	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = OLD.group_id) WHERE group_id = OLD.group_id;
    END IF;
    UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = OLD.bot_id) WHERE bot_id = OLD.bot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_after_update` AFTER UPDATE ON `intents` FOR EACH ROW BEGIN
	IF NEW.group_id IS NOT NULL AND NEW.group_id > 0
  	THEN UPDATE groups SET group_items_count = (SELECT COUNT(*) FROM intents WHERE group_id = NEW.group_id) WHERE group_id = NEW.group_id;
  END IF;
  UPDATE bots SET bot_intents_count = (SELECT COUNT(*) FROM intents WHERE bot_id = NEW.bot_id) WHERE bot_id = NEW.bot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_create` BEFORE INSERT ON `intents` FOR EACH ROW BEGIN
	SET NEW.intent_date_create = NOW();
    SET NEW.intent_date_update = NOW();
    SET NEW.organization_id = (SELECT organization_id FROM bots WHERE bot_id = NEW.bot_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `intent_update` BEFORE UPDATE ON `intents` FOR EACH ROW BEGIN
	SET NEW.intent_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `intents_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `intents_json` (
`intent_json` json
,`intent_id` int(11)
,`intent_name` varchar(64)
,`intent_conditions_count` int(11)
,`organization_id` int(11)
,`group_id` int(11)
,`bot_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `intent_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `intent_json` (
`intent_json` json
,`intent_id` int(11)
,`organization_id` int(11)
,`group_id` int(11)
,`bot_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `dialog_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `message_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `message_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `message_text` text COLLATE utf8_bin NOT NULL,
  `message_client` tinyint(1) NOT NULL DEFAULT '0',
  `dispatch_id` int(11) DEFAULT NULL,
  `message_api_callback` tinyint(1) NOT NULL DEFAULT '0',
  `message_error` tinyint(1) NOT NULL DEFAULT '0',
  `bot_id` int(11) DEFAULT NULL,
  `message_value` text COLLATE utf8_bin,
  `intent_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `messages`
--
DELIMITER $$
CREATE TRIGGER `message_after_create` AFTER INSERT ON `messages` FOR EACH ROW BEGIN
	UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages AS m WHERE m.dialog_id = NEW.dialog_id) WHERE dialog_id = NEW.dialog_id;
    IF NEW.dispatch_id IS NOT NULL AND NEW.dispatch_id > 0
    	THEN UPDATE dispatches SET dispatch_messages_count = (SELECT COUNT(*) FROM messages WHERE dispatch_id = NEW.dispatch_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_after_delete` AFTER DELETE ON `messages` FOR EACH ROW BEGIN
	UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages WHERE dialog_id = OLD.dialog_id) WHERE dialog_id = OLD.dialog_id;
    IF OLD.dispatch_id IS NOT NULL AND OLD.dispatch_id > 0
    	THEN UPDATE dispatches SET dispatch_messages_count = (SELECT COUNT(*) FROM messages WHERE dispatch_id = OLD.dispatch_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_after_update` AFTER UPDATE ON `messages` FOR EACH ROW BEGIN
	UPDATE dialogues SET dialog_messages_count = (SELECT COUNT(*) FROM messages WHERE dialog_id = NEW.dialog_id), dialog_error = NEW.message_error WHERE dialog_id = NEW.dialog_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_create` BEFORE INSERT ON `messages` FOR EACH ROW BEGIN
	SET NEW.message_date_create = NOW();
    SET NEW.message_date_update = NOW();
    SET NEW.bot_id = (SELECT bot_id FROM dialogues WHERE dialog_id = NEW.dialog_id);
    IF NEW.dispatch_id IS NOT NULL AND NEW.dispatch_id > 0 
    	THEN SET NEW.user_id = (SELECT user_id FROM dispatches WHERE dispatch_id = NEW.dispatch_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `message_update` BEFORE UPDATE ON `messages` FOR EACH ROW BEGIN
	SET NEW.message_date_update = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `message_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `message_json` (
`message_json` json
,`dialog_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `organizations`
--

CREATE TABLE `organizations` (
  `organization_id` int(11) NOT NULL,
  `organization_name` varchar(256) COLLATE utf8_bin NOT NULL,
  `organization_site` varchar(256) COLLATE utf8_bin NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `organization_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `organization_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `organization_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `organization_widgets_work` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `organizations`
--
DELIMITER $$
CREATE TRIGGER `insert_organization` BEFORE INSERT ON `organizations` FOR EACH ROW BEGIN
	DECLARE organizationHash VARCHAR(32) DEFAULT getHash(32);
    IF NEW.organization_site REGEXP ".*[[.full-stop.]]..*"
        THEN
        	SET NEW.organization_date_create = NOW();
            SET NEW.organization_date_update = NOW();
            hashLoop: LOOP
            	IF (SELECT organization_id FROM organizations WHERE organization_hash = organizationHash) > 0
                    THEN 
                        SET organizationHash = getHash(32);
                        ITERATE hashLoop;
                    ELSE LEAVE hashLoop;
                END IF;
            END LOOP;
            SET NEW.organization_hash = organizationHash;
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid organization site";
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_organization` BEFORE UPDATE ON `organizations` FOR EACH ROW BEGIN
    IF NEW.organization_site REGEXP ".*[[.full-stop.]]..*"
        THEN
            SET NEW.organization_date_update = NOW();
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid organization site";
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `organizations_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `organizations_json` (
`organization_json` json
,`organization_name` varchar(256)
,`organization_id` int(11)
,`type_id` int(11)
,`organization_site` varchar(256)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `organization_bots`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `organization_bots` (
`bot_json` json
,`bot_id` int(11)
,`bot_name` varchar(64)
,`bot_hash` varchar(32)
,`organization_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `organization_groups`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `organization_groups` (
`group_json` json
,`organization_id` int(11)
,`type_id` int(11)
,`bot_id` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `organization_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `organization_json` (
`organization_json` json
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `profile_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `profile_json` (
`profile_json` json
,`organization_json` json
,`user_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `sockets`
--

CREATE TABLE `sockets` (
  `socket_id` int(11) NOT NULL,
  `socket_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `socket_connection` tinyint(1) NOT NULL DEFAULT '1',
  `socket_connection_id` varchar(128) COLLATE utf8_bin NOT NULL,
  `socket_date_create` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `socket_date_disconnect` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `socket_date_update` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `socket_engine_name` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_engine_version` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_os_name` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_os_version` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_device_vendor` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_device_model` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_device_type` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_url` varchar(512) COLLATE utf8_bin NOT NULL,
  `socket_ip` varchar(128) COLLATE utf8_bin NOT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `socket_browser_name` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `socket_browser_version` varchar(128) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `sockets`
--
DELIMITER $$
CREATE TRIGGER `insert_socket` BEFORE INSERT ON `sockets` FOR EACH ROW BEGIN
	DECLARE socketHash VARCHAR(32) DEFAULT getHash(32);
	SET NEW.socket_date_create = NOW();
    SET NEW.socket_date_update = NOW();
    hashLoop: LOOP
    	IF (SELECT socket_id FROM sockets WHERE socket_hash = socketHash) > 0
        	THEN 
            	SET socketHash = getHash(32);
                ITERATE hashLoop;
            ELSE 
            	LEAVE hashLoop;
        END IF;
    END LOOP;
    SET NEW.socket_hash = getHash(32);
    IF NEW.socket_connection = 0
    	THEN SET NEW.socket_date_disconnect = NOW();
        ELSE SET NEW.socket_date_disconnect = NULL;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `socket_before_delete` BEFORE DELETE ON `sockets` FOR EACH ROW BEGIN 
	DECLARE userID, clientID, socketsCount INT(11);
    SET userID = (SELECT user_id FROM user_sockets WHERE socket_id = OLD.socket_id);
    IF userID IS NOT NULL AND userID > 0
    	THEN 
        	SET socketsCount = (SELECT COUNT(*) FROM user_sockets WHERE user_id = userID) - 1;
        	UPDATE users SET user_sockets_count = socketsCount WHERE user_id = userID;
        ELSE 
        	SET clientID = (SELECT client_id FROM client_sockets WHERE socket_id = OLD.socket_id);
            IF clientID IS NOT NULL AND clientID > 0
            	THEN 
                	SET socketsCount = (SELECT COUNT(*) FROM client_sockets WHERE client_id = clientID) - 1;
                    UPDATE clients SET client_sockets_count = socketsCount WHERE client_id = clientID;
            END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sockets_after_create` AFTER INSERT ON `sockets` FOR EACH ROW BEGIN
	INSERT INTO states (socket_id) VALUES (NEW.socket_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sockets_after_update` AFTER UPDATE ON `sockets` FOR EACH ROW BEGIN
	DECLARE socketsCount, userID, clientID INT(11);
	IF NEW.organization_id IS NOT NULL AND NEW.organization_id > 0
    	THEN 
        	IF NEW.type_id = 2
            	THEN
                	SET userID = (SELECT user_id FROM user_sockets WHERE socket_id = NEW.socket_id);
                	SET socketsCount = (SELECT COUNT(*) FROM user_sockets WHERE user_id = userID);
                	UPDATE users SET user_sockets_count = socketsCount WHERE user_id = userID;
                ELSEIF NEW.type_id = 1
                	THEN 
                    	SET clientID = (SELECT client_id FROM client_sockets WHERE socket_id = NEW.socket_id);
                        SET socketsCount = (SELECT COUNT(*) FROM client_sockets WHERE client_id = clientID);
                        UPDATE clients SET client_sockets_count = socketsCount WHERE client_id = clientID;
			END IF;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_socket` BEFORE UPDATE ON `sockets` FOR EACH ROW BEGIN
	SET NEW.socket_date_update = NOW();
	IF NEW.socket_connection = 0
    	THEN 
        	SET NEW.socket_date_disconnect = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `sockets_states`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `sockets_states` (
`state_json` json
,`socket_id` int(11)
,`organization_id` int(11)
,`socket_connection` tinyint(1)
);

-- --------------------------------------------------------

--
-- Структура таблицы `states`
--

CREATE TABLE `states` (
  `state_id` int(11) NOT NULL,
  `state_json` json DEFAULT NULL,
  `socket_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `state_date_create` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `state_date_update` varchar(19) COLLATE utf8_bin DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `states`
--
DELIMITER $$
CREATE TRIGGER `state_before_update` BEFORE UPDATE ON `states` FOR EACH ROW BEGIN
	SET NEW.state_date_update = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `state_create` BEFORE INSERT ON `states` FOR EACH ROW BEGIN
	SET NEW.state_date_create = NOW(),
    	NEW.state_date_update = NOW();      
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `types`
--

CREATE TABLE `types` (
  `type_id` int(11) NOT NULL,
  `type_name` varchar(64) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Дамп данных таблицы `types`
--

INSERT INTO `types` (`type_id`, `type_name`) VALUES
(2, 'admin'),
(24, 'bot'),
(23, 'bots'),
(11, 'client'),
(10, 'clients'),
(9, 'dialog'),
(16, 'dispatch'),
(25, 'editbot'),
(19, 'editclient'),
(36, 'editentities'),
(33, 'editgroup'),
(29, 'editintent'),
(21, 'editorganization'),
(7, 'entities'),
(35, 'entity'),
(32, 'group'),
(30, 'groups'),
(28, 'intent'),
(6, 'intents'),
(15, 'newUser'),
(26, 'newbot'),
(34, 'newentities'),
(31, 'newgroup'),
(27, 'newintent'),
(18, 'neworganization'),
(20, 'organization'),
(17, 'organizations'),
(13, 'profile'),
(14, 'profileEdit'),
(3, 'root'),
(8, 'sessions'),
(5, 'telegram'),
(4, 'user'),
(12, 'users'),
(1, 'widget'),
(22, 'widgets');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `user_email` varchar(128) COLLATE utf8_bin NOT NULL,
  `user_password` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_date_create` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_date_update` varchar(19) COLLATE utf8_bin NOT NULL,
  `user_creator` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `user_state` json DEFAULT NULL,
  `user_telegram_chat` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `user_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_telegram_username` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `user_telegram_notification` tinyint(1) NOT NULL DEFAULT '0',
  `user_web_notifications` tinyint(1) NOT NULL DEFAULT '0',
  `user_online` tinyint(1) NOT NULL DEFAULT '0',
  `user_auth` tinyint(1) NOT NULL DEFAULT '0',
  `user_sockets_count` int(11) NOT NULL DEFAULT '0',
  `user_sockets_online_count` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `users`
--
DELIMITER $$
CREATE TRIGGER `insert_user` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
	DECLARE userHash VARCHAR(32) DEFAULT getHash(32);
    DECLARE userPassword VARCHAR(6) DEFAULT getHash(6);
    DECLARE organizationID INT(11);
	IF NEW.user_email REGEXP ".*.@.*[[.full-stop.]]..*"
    	THEN 
        	SET NEW.user_email = LOWER(NEW.user_email);
        	SET NEW.user_date_create = NOW();
            SET NEW.user_date_update = NOW();
            hashLoop: LOOP
            	IF (SELECT user_id FROM users WHERE user_hash = userHash) > 0
                	THEN 
                    	SET userHash = getHash(32);
                        ITERATE hashLoop;
                	ELSE
                    	LEAVE  hashLoop;
                END IF;
            END LOOP;
            passwordLoop: LOOP
            	IF (SELECT user_id FROM users WHERE user_password = userPassword) > 0
                	THEN 
                    	SET userPassword = getHash(6);
                        ITERATE passwordLoop;
                   	ELSE 
                    	LEAVE passwordLoop;
                END IF;
            END LOOP;
            SET NEW.user_hash = getHash(32);
            SET NEW.user_password = getHash(6);
            IF NEW.user_creator IS NOT NULL
            	THEN 
                	SELECT organization_id INTO organizationID FROM users WHERE user_id = NEW.user_creator;
                    SET NEW.organization_id = organizationID;
            END IF;
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid email address";
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_user` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
	DECLARE userHash VARCHAR(32);
	IF (NEW.user_email REGEXP ".*.@.*[[.full-stop.]]..*")
    	THEN
        	IF NEW.user_auth != OLD.user_auth AND NEW.user_auth = 1
            	THEN 
                	SET userHash = getHash(32);
                    hashLoop: LOOP
                        IF (SELECT COUNT(*) FROM users WHERE user_hash = userHash) > 0
                            THEN SET userHash = getHash(32);
                            ELSE LEAVE hashLoop;
                        END IF;
                    END LOOP;
                    SET NEW.user_hash = userHash;
            END IF;
            SET NEW.user_date_update = NOW();
            SET NEW.user_sockets_online_count = (SELECT COUNT(*) FROM user_sockets_connection WHERE user_id = NEW.user_id AND socket_connection = 1);
            IF NEW.user_sockets_online_count = 0
            	THEN SET NEW.user_online = 0;
                ELSE SET NEW.user_online = 1;
            END IF;
        ELSE 
        	SIGNAL SQLSTATE '45000' set message_text="invalid email address";
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `users_json`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `users_json` (
`user_json` json
,`user_name` varchar(64)
,`user_email` varchar(128)
,`user_online` tinyint(1)
,`organization_id` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `user_sockets`
--

CREATE TABLE `user_sockets` (
  `user_socket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `socket_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Триггеры `user_sockets`
--
DELIMITER $$
CREATE TRIGGER `user_socket_after_create` AFTER INSERT ON `user_sockets` FOR EACH ROW BEGIN
	DECLARE organizationID INT(11) DEFAULT (SELECT organization_id FROM users WHERE user_id = NEW.user_id);
	UPDATE sockets SET organization_id = organizationID WHERE socket_id = NEW.socket_id;
    UPDATE states SET organization_id = organizationID, user_id = NEW.user_id WHERE socket_id = NEW.socket_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_socket_after_delete` AFTER DELETE ON `user_sockets` FOR EACH ROW BEGIN
	DECLARE socketsCount INT(11) DEFAULT (SELECT COUNT(*) FROM user_sockets WHERE user_id = OLD.user_id);
    UPDATE users SET user_sockets_count = socketsCount WHERE user_id = OLD.user_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `user_sockets_connection`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `user_sockets_connection` (
`user_id` int(11)
,`socket_id` int(11)
,`socket_connection` tinyint(1)
,`socket_connection_id` varchar(128)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `user_state_information`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `user_state_information` (
`user_name` varchar(64)
,`user_email` varchar(128)
,`user_date_create` varchar(19)
,`user_date_update` varchar(19)
,`user_creator_id` int(11)
,`user_telegram_username` varchar(128)
,`user_telegram_notification` tinyint(1)
,`user_web_notifications` tinyint(1)
,`user_online` tinyint(1)
,`user_sockets_count` int(11)
,`user_sockets_online_count` int(11)
,`organization_id` int(11)
,`organization_name` varchar(256)
,`user_creator_name` varchar(64)
);

-- --------------------------------------------------------

--
-- Структура для представления `bots_json`
--
DROP TABLE IF EXISTS `bots_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bots_json`  AS  select json_object('bot_id',`bots`.`bot_id`,'bot_telegram_key',`bots`.`bot_telegram_key`) AS `bot_json` from `bots` where (`bots`.`bot_telegram_key` is not null) ;

-- --------------------------------------------------------

--
-- Структура для представления `bot_entities`
--
DROP TABLE IF EXISTS `bot_entities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bot_entities`  AS  select json_object('bot_id',`entities`.`bot_id`,'entities_name',`entities`.`entities_name`,'entities_id',`entities`.`entities_id`,'group_id',`entities`.`group_id`,'entities_entity_count',`entities`.`entities_entity_count`) AS `entities_json`,`entities`.`organization_id` AS `organization_id`,`entities`.`bot_id` AS `bot_id`,`entities`.`group_id` AS `group_id` from `entities` ;

-- --------------------------------------------------------

--
-- Структура для представления `bot_info`
--
DROP TABLE IF EXISTS `bot_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bot_info`  AS  select json_object('bot_name',`bots`.`bot_name`,'bot_telegram_key',`bots`.`bot_telegram_key`,'bot_id',`bots`.`bot_id`,'bot_date_create',`bots`.`bot_date_create`,'bot_date_update',`bots`.`bot_date_update`,'bot_intents_count',`bots`.`bot_intents_count`,'bot_entities_count',`bots`.`bot_entities_count`) AS `bot_json`,`bots`.`organization_id` AS `organization_id`,`bots`.`bot_id` AS `bot_id` from `bots` ;

-- --------------------------------------------------------

--
-- Структура для представления `bot_json`
--
DROP TABLE IF EXISTS `bot_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bot_json`  AS  select json_object('bot_id',`db`.`bot_id`,'bot_name',`b`.`bot_name`) AS `bot_json`,`db`.`dispatch_id` AS `dispatch_id`,`db`.`bot_id` AS `bot_id`,`b`.`bot_name` AS `bot_name` from (`dispatch_bots` `db` left join `bots` `b` on((`b`.`bot_id` = `db`.`bot_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `clients_json`
--
DROP TABLE IF EXISTS `clients_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `clients_json`  AS  select json_object('client_id',`c`.`client_id`,'client_name',`c`.`client_name`,'client_username',`c`.`client_username`,'client_email',`c`.`client_email`,'client_phone',`c`.`client_phone`,'dialog_id',`d`.`dialog_id`,'client_online',`c`.`client_online`,'client_date_create',`c`.`client_date_create`,'socket_url',`s`.`socket_url`,'socket_ip',`s`.`socket_ip`,'socket_browser_name',`s`.`socket_browser_name`,'socket_browser_version',`s`.`socket_browser_version`,'socket_engine_name',`s`.`socket_engine_name`,'socket_engine_version',`s`.`socket_engine_version`,'socket_os_name',`s`.`socket_os_name`,'socket_os_version',`s`.`socket_os_version`,'socket_device_vendor',`s`.`socket_device_vendor`,'socket_device_model',`s`.`socket_device_model`,'socket_device_type',`s`.`socket_device_type`) AS `client_json`,`c`.`client_id` AS `client_id`,`c`.`client_name` AS `client_name`,`c`.`client_username` AS `client_username`,`c`.`client_email` AS `client_email`,`c`.`client_phone` AS `client_phone`,`d`.`dialog_id` AS `dialog_id`,`c`.`organization_id` AS `organization_id`,`c`.`client_online` AS `client_online`,`c`.`client_date_create` AS `client_date_create`,`s`.`socket_url` AS `socket_url`,`s`.`socket_ip` AS `socket_ip`,`s`.`socket_browser_name` AS `socket_browser_name`,`s`.`socket_browser_version` AS `socket_browser_version`,`s`.`socket_engine_name` AS `socket_engine_name`,`s`.`socket_engine_version` AS `socket_engine_version`,`s`.`socket_os_name` AS `socket_os_name`,`s`.`socket_os_version` AS `socket_os_version`,`s`.`socket_device_vendor` AS `socket_device_vendor`,`s`.`socket_device_model` AS `socket_device_model`,`s`.`socket_device_type` AS `socket_device_type` from (((`clients` `c` left join `dialogues` `d` on((`d`.`client_id` = `c`.`client_id`))) left join (select max(`client_sockets`.`socket_id`) AS `max_socket_id`,`client_sockets`.`client_id` AS `client_id` from `client_sockets` group by `client_sockets`.`client_id`) `msi` on((`msi`.`client_id` = `c`.`client_id`))) left join `sockets` `s` on((`s`.`socket_id` = `msi`.`max_socket_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `client_bot`
--
DROP TABLE IF EXISTS `client_bot`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `client_bot`  AS  select `d`.`bot_id` AS `bot_id`,`d`.`client_id` AS `client_id`,`c`.`client_telegram_chat` AS `client_telegram_chat` from (`dialogues` `d` left join `clients` `c` on((`c`.`client_id` = `d`.`client_id`))) where (`c`.`client_telegram_chat` is not null) ;

-- --------------------------------------------------------

--
-- Структура для представления `client_sockets_connection`
--
DROP TABLE IF EXISTS `client_sockets_connection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `client_sockets_connection`  AS  select `cs`.`client_id` AS `client_id`,`cs`.`socket_id` AS `socket_id`,`s`.`socket_connection` AS `socket_connection`,`s`.`socket_connection_id` AS `socket_connection_id` from (`client_sockets` `cs` join `sockets` `s` on((`s`.`socket_id` = `cs`.`socket_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `conditions_answers`
--
DROP TABLE IF EXISTS `conditions_answers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `conditions_answers`  AS  select `a`.`answer_id` AS `answer_id`,`c`.`condition_id` AS `condition_id`,`c`.`organization_id` AS `organization_id`,`c`.`condition_entities` AS `condition_entities`,`c`.`bot_id` AS `bot_id` from (`conditions` `c` left join `answers` `a` on((`a`.`intent_id` = `c`.`intent_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `dialogues_json`
--
DROP TABLE IF EXISTS `dialogues_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dialogues_json`  AS  select json_object('dialog_id',`dd`.`dialog_id`,'client_id',`dd`.`client_id`,'client_name',`c`.`client_name`,'client_username',`c`.`client_username`,'user_name',`u`.`user_name`,'user_id',`dd`.`user_id`,'dialog_date_update',`dd`.`dialog_date_update`,'dialog_date_create',`dd`.`dialog_date_create`,'dialog_messages_count',`dd`.`dialog_messages_count`,'dialog_error',`dd`.`dialog_error`,'bot_id',`dd`.`bot_id`,'type_id',`dd`.`type_id`,'dialog_active',`dd`.`dialog_active`,'client_message',`mmc`.`message_text`,'user_message',`mmu`.`message_text`,'socket_url',`s`.`socket_url`) AS `dialog_json`,`dd`.`dialog_id` AS `dialog_id`,`mmc`.`message_text` AS `client_message_text`,`mmu`.`message_text` AS `user_message_text`,`dd`.`client_id` AS `client_id`,`dd`.`user_id` AS `user_id`,`dd`.`dialog_date_create` AS `dialog_date_create`,`dd`.`dialog_date_update` AS `dialog_date_update`,`dd`.`dialog_messages_count` AS `dialog_messages_count`,`dd`.`dialog_error` AS `dialog_error`,`dd`.`bot_id` AS `bot_id`,`dd`.`organization_id` AS `organization_id`,`dd`.`type_id` AS `type_id`,`dd`.`dialog_active` AS `dialog_active`,`u`.`user_name` AS `user_name`,`c`.`client_name` AS `client_name`,`c`.`client_username` AS `client_username`,`s`.`socket_url` AS `socket_url` from (((((((`dialogues` `dd` left join (select `d`.`dialog_id` AS `dialog_id`,max(`mc`.`message_id`) AS `client_message`,max(`mu`.`message_id`) AS `user_message` from ((`dialogues` `d` left join `messages` `mc` on(((`mc`.`dialog_id` = `d`.`dialog_id`) and (`mc`.`message_client` = 1)))) left join `messages` `mu` on(((`mu`.`dialog_id` = `d`.`dialog_id`) and (`mu`.`message_client` = 0)))) group by `d`.`dialog_id`) `lm` on((`lm`.`dialog_id` = `dd`.`dialog_id`))) left join `messages` `mmc` on((`mmc`.`message_id` = `lm`.`client_message`))) left join `messages` `mmu` on((`mmu`.`message_id` = `lm`.`user_message`))) left join `users` `u` on((`u`.`user_id` = `dd`.`user_id`))) left join `clients` `c` on((`c`.`client_id` = `dd`.`client_id`))) left join (select max(`client_sockets`.`socket_id`) AS `max_socket_id`,`client_sockets`.`client_id` AS `client_id` from `client_sockets` group by `client_sockets`.`client_id`) `mcs` on((`mcs`.`client_id` = `c`.`client_id`))) left join `sockets` `s` on((`s`.`socket_id` = `mcs`.`max_socket_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `dialog_json`
--
DROP TABLE IF EXISTS `dialog_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dialog_json`  AS  select json_object('dialog_id',`d`.`dialog_id`,'user_id',`d`.`user_id`,'user_name',`u`.`user_name`,'client_id',`d`.`client_id`,'client_name',`c`.`client_name`,'client_username',`c`.`client_username`,'dialog_error',`d`.`dialog_error`,'dialog_active',`d`.`dialog_active`,'dialog_bot_work',`d`.`dialog_bot_work`,'type_id',`d`.`type_id`) AS `dialog_json`,`d`.`dialog_id` AS `dialog_id` from ((`dialogues` `d` left join `clients` `c` on((`c`.`client_id` = `d`.`client_id`))) left join `users` `u` on((`u`.`user_id` = `d`.`user_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `dispatch_dialogues`
--
DROP TABLE IF EXISTS `dispatch_dialogues`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dispatch_dialogues`  AS  select `d`.`dialog_id` AS `dialog_id`,`dp`.`dispatch_id` AS `dispatch_id` from (((`dialogues` `d` join `dispatch_types` `dt` on((`dt`.`type_id` = `d`.`type_id`))) join `dispatch_bots` `db` on((`db`.`bot_id` = `d`.`bot_id`))) join `dispatches` `dp` on(((`dp`.`dispatch_id` = `dt`.`dispatch_id`) and (`dp`.`dispatch_id` = `db`.`dispatch_id`)))) ;

-- --------------------------------------------------------

--
-- Структура для представления `dispatch_json`
--
DROP TABLE IF EXISTS `dispatch_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dispatch_json`  AS  select json_object('dispatch_id',`d`.`dispatch_id`,'dispatch_date_create',`d`.`dispatch_date_create`,'dispatch_text',`d`.`dispatch_text`,'user_id',`d`.`user_id`,'dispatch_messages_count',`d`.`dispatch_messages_count`,'user_name',`u`.`user_name`) AS `dispatch_json`,`d`.`organization_id` AS `organization_id`,`d`.`dispatch_id` AS `dispatch_id`,`d`.`dispatch_date_create` AS `dispatch_date_create`,`d`.`dispatch_delete` AS `dispatch_delete`,`d`.`dispatch_text` AS `dispatch_text`,`d`.`user_id` AS `user_id`,`d`.`dispatch_messages_count` AS `dispatch_messages_count`,`u`.`user_name` AS `user_name` from (`dispatches` `d` left join `users` `u` on((`u`.`user_id` = `d`.`user_id`))) where (`d`.`dispatch_delete` = 0) order by `d`.`dispatch_id` desc ;

-- --------------------------------------------------------

--
-- Структура для представления `dispatch_messages`
--
DROP TABLE IF EXISTS `dispatch_messages`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dispatch_messages`  AS  select `messages`.`message_id` AS `message_id`,`messages`.`dialog_id` AS `dialog_id`,`messages`.`user_id` AS `user_id`,`messages`.`message_date_create` AS `message_date_create`,`messages`.`message_date_update` AS `message_date_update`,`messages`.`message_text` AS `message_text`,`messages`.`message_client` AS `message_client`,`messages`.`dispatch_id` AS `dispatch_id`,`messages`.`message_api_callback` AS `message_api_callback`,`messages`.`message_error` AS `message_error`,`messages`.`bot_id` AS `bot_id`,`messages`.`message_value` AS `message_value`,`messages`.`intent_id` AS `intent_id` from `messages` where ((`messages`.`dispatch_id` is not null) and (`messages`.`dispatch_id` > 0)) ;

-- --------------------------------------------------------

--
-- Структура для представления `entities_essences`
--
DROP TABLE IF EXISTS `entities_essences`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `entities_essences`  AS  select `e`.`entities_id` AS `entities_id`,`es`.`essence_id` AS `essence_id` from ((`entity` `e` join `entity_essences` `ee` on((`ee`.`entity_id` = `e`.`entity_id`))) join `essences` `es` on((`es`.`essence_id` = `ee`.`essence_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `entities_info`
--
DROP TABLE IF EXISTS `entities_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `entities_info`  AS  select json_object('entities_id',`e`.`entities_id`,'entities_name',`e`.`entities_name`,'entities_entity_count',`e`.`entities_entity_count`,'group_id',`e`.`group_id`,'bot_id',`e`.`bot_id`,'group_name',`g`.`group_name`,'bot_name',`b`.`bot_name`) AS `entities_json`,`e`.`bot_id` AS `bot_id`,`e`.`entities_id` AS `entities_id`,`e`.`group_id` AS `group_id`,`e`.`organization_id` AS `organization_id` from ((`entities` `e` left join `bots` `b` on((`e`.`bot_id` = `b`.`bot_id`))) left join `groups` `g` on((`g`.`group_id` = `e`.`group_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `entities_json`
--
DROP TABLE IF EXISTS `entities_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `entities_json`  AS  select json_object('entities_id',`e`.`entities_id`,'entities_name',`e`.`entities_name`,'group_id',`e`.`group_id`,'group_name',`g`.`group_name`) AS `entities_json`,`e`.`organization_id` AS `organization_id`,`e`.`bot_id` AS `bot_id`,`e`.`group_id` AS `group_id`,`e`.`entities_id` AS `entities_id`,`e`.`entities_name` AS `entities_name`,`g`.`group_name` AS `group_name` from (`entities` `e` left join `groups` `g` on((`g`.`group_id` = `e`.`group_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `filter_bots_json`
--
DROP TABLE IF EXISTS `filter_bots_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `filter_bots_json`  AS  select json_object('bot_id',`bots`.`bot_id`,'bot_name',`bots`.`bot_name`,'bot_date_update',`bots`.`bot_date_update`,'bot_telegram_key',`bots`.`bot_telegram_key`) AS `bot_json`,`bots`.`bot_id` AS `bot_id`,`bots`.`bot_name` AS `bot_name`,`bots`.`bot_date_update` AS `bot_date_update`,`bots`.`bot_telegram_key` AS `bot_telegram_key`,`bots`.`organization_id` AS `organization_id` from `bots` ;

-- --------------------------------------------------------

--
-- Структура для представления `groups_json`
--
DROP TABLE IF EXISTS `groups_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `groups_json`  AS  select json_object('group_id',`groups`.`group_id`,'group_name',`groups`.`group_name`,'group_items_count',`groups`.`group_items_count`,'type_id',`groups`.`type_id`) AS `group_json`,`groups`.`group_id` AS `group_id`,`groups`.`group_name` AS `group_name`,`groups`.`group_items_count` AS `group_items_count`,`groups`.`organization_id` AS `organization_id`,`groups`.`bot_id` AS `bot_id`,`groups`.`type_id` AS `type_id` from `groups` ;

-- --------------------------------------------------------

--
-- Структура для представления `group_info`
--
DROP TABLE IF EXISTS `group_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `group_info`  AS  select json_object('group_id',`g`.`group_id`,'group_name',`g`.`group_name`,'group_items_count',`g`.`group_items_count`,'type_id',`g`.`type_id`,'bot_id',`g`.`bot_id`,'bot_name',`b`.`bot_name`) AS `group_json`,`g`.`organization_id` AS `organization_id`,`g`.`bot_id` AS `bot_id`,`g`.`group_id` AS `group_id` from (`groups` `g` left join `bots` `b` on((`b`.`bot_id` = `g`.`bot_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `group_json`
--
DROP TABLE IF EXISTS `group_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `group_json`  AS  select json_object('group_name',`g`.`group_name`,'group_id',`g`.`group_id`,'group_items_count',`g`.`group_items_count`,'type_id',`g`.`type_id`,'bot_id',`g`.`bot_id`,'bot_name',`b`.`bot_name`) AS `group_json`,`g`.`organization_id` AS `organization_id`,`g`.`group_id` AS `group_id`,`g`.`bot_id` AS `bot_id`,`g`.`type_id` AS `type_id` from (`groups` `g` left join `bots` `b` on((`g`.`bot_id` = `b`.`bot_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `intents_json`
--
DROP TABLE IF EXISTS `intents_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `intents_json`  AS  select json_object('intent_id',`intents`.`intent_id`,'intent_name',`intents`.`intent_name`,'intent_conditions_count',`intents`.`intent_conditions_count`,'group_id',`intents`.`group_id`) AS `intent_json`,`intents`.`intent_id` AS `intent_id`,`intents`.`intent_name` AS `intent_name`,`intents`.`intent_conditions_count` AS `intent_conditions_count`,`intents`.`organization_id` AS `organization_id`,`intents`.`group_id` AS `group_id`,`intents`.`bot_id` AS `bot_id` from `intents` ;

-- --------------------------------------------------------

--
-- Структура для представления `intent_json`
--
DROP TABLE IF EXISTS `intent_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `intent_json`  AS  select json_object('intent_id',`i`.`intent_id`,'intent_name',`i`.`intent_name`,'bot_id',`i`.`bot_id`,'group_name',`g`.`group_name`,'intent_conditions_count',`i`.`intent_conditions_count`,'answer_text',`a`.`answer_text`,'bot_name',`b`.`bot_name`,'group_id',`i`.`group_id`) AS `intent_json`,`i`.`intent_id` AS `intent_id`,`i`.`organization_id` AS `organization_id`,`i`.`group_id` AS `group_id`,`i`.`bot_id` AS `bot_id` from (((`intents` `i` left join `groups` `g` on((`g`.`group_id` = `i`.`group_id`))) left join `answers` `a` on((`a`.`intent_id` = `i`.`intent_id`))) left join `bots` `b` on((`b`.`bot_id` = `i`.`bot_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `message_json`
--
DROP TABLE IF EXISTS `message_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `message_json`  AS  select json_object('message_text',`m`.`message_text`,'message_client',`m`.`message_client`,'client_id',`d`.`client_id`,'client_name',`c`.`client_name`,'user_id',`m`.`user_id`,'user_name',`u`.`user_name`,'message_date_create',`m`.`message_date_create`,'dialog_id',`m`.`dialog_id`) AS `message_json`,`d`.`dialog_id` AS `dialog_id` from (((`messages` `m` left join `users` `u` on((`u`.`user_id` = `m`.`user_id`))) left join `dialogues` `d` on((`d`.`dialog_id` = `m`.`dialog_id`))) left join `clients` `c` on((`c`.`client_id` = `d`.`client_id`))) order by `m`.`message_id` ;

-- --------------------------------------------------------

--
-- Структура для представления `organizations_json`
--
DROP TABLE IF EXISTS `organizations_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organizations_json`  AS  select json_object('organization_id',`organizations`.`organization_id`,'organization_name',`organizations`.`organization_name`,'organization_site',`organizations`.`organization_site`,'type_id',`organizations`.`type_id`) AS `organization_json`,`organizations`.`organization_name` AS `organization_name`,`organizations`.`organization_id` AS `organization_id`,`organizations`.`type_id` AS `type_id`,`organizations`.`organization_site` AS `organization_site` from `organizations` ;

-- --------------------------------------------------------

--
-- Структура для представления `organization_bots`
--
DROP TABLE IF EXISTS `organization_bots`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organization_bots`  AS  select json_object('bot_id',`bots`.`bot_id`,'bot_name',`bots`.`bot_name`,'bot_hash',`bots`.`bot_hash`) AS `bot_json`,`bots`.`bot_id` AS `bot_id`,`bots`.`bot_name` AS `bot_name`,`bots`.`bot_hash` AS `bot_hash`,`bots`.`organization_id` AS `organization_id` from `bots` ;

-- --------------------------------------------------------

--
-- Структура для представления `organization_groups`
--
DROP TABLE IF EXISTS `organization_groups`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organization_groups`  AS  select json_object('group_id',`groups`.`group_id`,'group_name',`groups`.`group_name`) AS `group_json`,`groups`.`organization_id` AS `organization_id`,`groups`.`type_id` AS `type_id`,`groups`.`bot_id` AS `bot_id` from `groups` ;

-- --------------------------------------------------------

--
-- Структура для представления `organization_json`
--
DROP TABLE IF EXISTS `organization_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organization_json`  AS  select json_object('organization_id',`organizations`.`organization_id`,'organization_name',`organizations`.`organization_name`) AS `organization_json` from `organizations` ;

-- --------------------------------------------------------

--
-- Структура для представления `profile_json`
--
DROP TABLE IF EXISTS `profile_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `profile_json`  AS  select json_object('name',`u`.`user_name`,'email',`u`.`user_email`,'telegram_notification',`u`.`user_telegram_notification`) AS `profile_json`,json_object('organization_site',`o`.`organization_site`,'organization_name',`o`.`organization_name`,'organization_id',`o`.`organization_id`) AS `organization_json`,`u`.`user_id` AS `user_id` from (`users` `u` left join `organizations` `o` on((`o`.`organization_id` = `u`.`organization_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `sockets_states`
--
DROP TABLE IF EXISTS `sockets_states`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sockets_states`  AS  select `st`.`state_json` AS `state_json`,`s`.`socket_id` AS `socket_id`,`s`.`organization_id` AS `organization_id`,`s`.`socket_connection` AS `socket_connection` from (`sockets` `s` join `states` `st` on((`st`.`socket_id` = `s`.`socket_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `users_json`
--
DROP TABLE IF EXISTS `users_json`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `users_json`  AS  select json_object('user_name',`users`.`user_name`,'user_email',`users`.`user_email`,'user_online',`users`.`user_online`) AS `user_json`,`users`.`user_name` AS `user_name`,`users`.`user_email` AS `user_email`,`users`.`user_online` AS `user_online`,`users`.`organization_id` AS `organization_id` from `users` ;

-- --------------------------------------------------------

--
-- Структура для представления `user_sockets_connection`
--
DROP TABLE IF EXISTS `user_sockets_connection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_sockets_connection`  AS  select `u`.`user_id` AS `user_id`,`s`.`socket_id` AS `socket_id`,`s`.`socket_connection` AS `socket_connection`,`s`.`socket_connection_id` AS `socket_connection_id` from ((`user_sockets` `us` join `users` `u` on((`u`.`user_id` = `us`.`user_id`))) join `sockets` `s` on((`s`.`socket_id` = `us`.`socket_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `user_state_information`
--
DROP TABLE IF EXISTS `user_state_information`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_state_information`  AS  select `u`.`user_name` AS `user_name`,`u`.`user_email` AS `user_email`,`u`.`user_date_create` AS `user_date_create`,`u`.`user_date_update` AS `user_date_update`,`u`.`user_creator` AS `user_creator_id`,`u`.`user_telegram_username` AS `user_telegram_username`,`u`.`user_telegram_notification` AS `user_telegram_notification`,`u`.`user_web_notifications` AS `user_web_notifications`,`u`.`user_online` AS `user_online`,`u`.`user_sockets_count` AS `user_sockets_count`,`u`.`user_sockets_online_count` AS `user_sockets_online_count`,`o`.`organization_id` AS `organization_id`,`o`.`organization_name` AS `organization_name`,`u2`.`user_name` AS `user_creator_name` from ((`users` `u` left join `organizations` `o` on((`u`.`organization_id` = `o`.`organization_id`))) left join `users` `u2` on((`u2`.`user_id` = `u`.`user_creator`))) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`answer_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `intent_id` (`intent_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `bots`
--
ALTER TABLE `bots`
  ADD PRIMARY KEY (`bot_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `bot_hash` (`bot_hash`);

--
-- Индексы таблицы `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`client_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `type_id_2` (`type_id`);

--
-- Индексы таблицы `client_sockets`
--
ALTER TABLE `client_sockets`
  ADD PRIMARY KEY (`client_socket_id`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `socket_id` (`socket_id`);

--
-- Индексы таблицы `conditions`
--
ALTER TABLE `conditions`
  ADD PRIMARY KEY (`condition_id`),
  ADD KEY `intent_id` (`intent_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `dialogues`
--
ALTER TABLE `dialogues`
  ADD PRIMARY KEY (`dialog_id`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `type_id` (`type_id`);

--
-- Индексы таблицы `dispatches`
--
ALTER TABLE `dispatches`
  ADD PRIMARY KEY (`dispatch_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `dispatch_bots`
--
ALTER TABLE `dispatch_bots`
  ADD PRIMARY KEY (`dispatch_bot_id`),
  ADD KEY `dispatch_id` (`dispatch_id`),
  ADD KEY `bot_id` (`bot_id`);

--
-- Индексы таблицы `dispatch_types`
--
ALTER TABLE `dispatch_types`
  ADD PRIMARY KEY (`dispatch_type_id`),
  ADD KEY `dispatch_id` (`dispatch_id`),
  ADD KEY `type_id` (`type_id`);

--
-- Индексы таблицы `entities`
--
ALTER TABLE `entities`
  ADD PRIMARY KEY (`entities_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `entity`
--
ALTER TABLE `entity`
  ADD PRIMARY KEY (`entity_id`),
  ADD KEY `entities_id` (`entities_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `entity_essences`
--
ALTER TABLE `entity_essences`
  ADD PRIMARY KEY (`entity_essence_id`),
  ADD KEY `entity_id` (`entity_id`),
  ADD KEY `essence_id` (`essence_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `entities_id` (`entities_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `essences`
--
ALTER TABLE `essences`
  ADD PRIMARY KEY (`essence_id`),
  ADD UNIQUE KEY `essence_value` (`essence_value`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `intents`
--
ALTER TABLE `intents`
  ADD PRIMARY KEY (`intent_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `dialog_id` (`dialog_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `dispatch_id` (`dispatch_id`),
  ADD KEY `bot_id` (`bot_id`),
  ADD KEY `intent_id` (`intent_id`);

--
-- Индексы таблицы `organizations`
--
ALTER TABLE `organizations`
  ADD PRIMARY KEY (`organization_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `organization_creator` (`user_id`);

--
-- Индексы таблицы `sockets`
--
ALTER TABLE `sockets`
  ADD PRIMARY KEY (`socket_id`),
  ADD UNIQUE KEY `socket_hash` (`socket_hash`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Индексы таблицы `states`
--
ALTER TABLE `states`
  ADD PRIMARY KEY (`state_id`),
  ADD KEY `socket_id` (`socket_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `client_id` (`client_id`);

--
-- Индексы таблицы `types`
--
ALTER TABLE `types`
  ADD PRIMARY KEY (`type_id`),
  ADD UNIQUE KEY `type_name` (`type_name`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`),
  ADD UNIQUE KEY `user_hash` (`user_hash`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `user_creator` (`user_creator`);

--
-- Индексы таблицы `user_sockets`
--
ALTER TABLE `user_sockets`
  ADD PRIMARY KEY (`user_socket_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `socket_id` (`socket_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `answers`
--
ALTER TABLE `answers`
  MODIFY `answer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT для таблицы `bots`
--
ALTER TABLE `bots`
  MODIFY `bot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT для таблицы `clients`
--
ALTER TABLE `clients`
  MODIFY `client_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT для таблицы `client_sockets`
--
ALTER TABLE `client_sockets`
  MODIFY `client_socket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT для таблицы `conditions`
--
ALTER TABLE `conditions`
  MODIFY `condition_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT для таблицы `dialogues`
--
ALTER TABLE `dialogues`
  MODIFY `dialog_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT для таблицы `dispatches`
--
ALTER TABLE `dispatches`
  MODIFY `dispatch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT для таблицы `dispatch_bots`
--
ALTER TABLE `dispatch_bots`
  MODIFY `dispatch_bot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT для таблицы `dispatch_types`
--
ALTER TABLE `dispatch_types`
  MODIFY `dispatch_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT для таблицы `entities`
--
ALTER TABLE `entities`
  MODIFY `entities_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT для таблицы `entity`
--
ALTER TABLE `entity`
  MODIFY `entity_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT для таблицы `entity_essences`
--
ALTER TABLE `entity_essences`
  MODIFY `entity_essence_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37182;

--
-- AUTO_INCREMENT для таблицы `essences`
--
ALTER TABLE `essences`
  MODIFY `essence_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT для таблицы `groups`
--
ALTER TABLE `groups`
  MODIFY `group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT для таблицы `intents`
--
ALTER TABLE `intents`
  MODIFY `intent_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT для таблицы `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=659;

--
-- AUTO_INCREMENT для таблицы `organizations`
--
ALTER TABLE `organizations`
  MODIFY `organization_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT для таблицы `sockets`
--
ALTER TABLE `sockets`
  MODIFY `socket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2823;

--
-- AUTO_INCREMENT для таблицы `states`
--
ALTER TABLE `states`
  MODIFY `state_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2812;

--
-- AUTO_INCREMENT для таблицы `types`
--
ALTER TABLE `types`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT для таблицы `user_sockets`
--
ALTER TABLE `user_sockets`
  MODIFY `user_socket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1918;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `answers`
--
ALTER TABLE `answers`
  ADD CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`intent_id`) REFERENCES `intents` (`intent_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `answers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `answers_ibfk_3` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `bots`
--
ALTER TABLE `bots`
  ADD CONSTRAINT `bots_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `bots_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `clients`
--
ALTER TABLE `clients`
  ADD CONSTRAINT `clients_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `clients_ibfk_3` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `client_sockets`
--
ALTER TABLE `client_sockets`
  ADD CONSTRAINT `client_sockets_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `client_sockets_ibfk_2` FOREIGN KEY (`socket_id`) REFERENCES `sockets` (`socket_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `conditions`
--
ALTER TABLE `conditions`
  ADD CONSTRAINT `conditions_ibfk_1` FOREIGN KEY (`intent_id`) REFERENCES `intents` (`intent_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conditions_ibfk_2` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conditions_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `conditions_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `dialogues`
--
ALTER TABLE `dialogues`
  ADD CONSTRAINT `dialogues_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_3` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dialogues_ibfk_5` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `dispatches`
--
ALTER TABLE `dispatches`
  ADD CONSTRAINT `dispatches_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dispatches_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `dispatch_bots`
--
ALTER TABLE `dispatch_bots`
  ADD CONSTRAINT `dispatch_bots_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dispatch_bots_ibfk_2` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatches` (`dispatch_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `dispatch_types`
--
ALTER TABLE `dispatch_types`
  ADD CONSTRAINT `dispatch_types_ibfk_1` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatches` (`dispatch_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dispatch_types_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `entities`
--
ALTER TABLE `entities`
  ADD CONSTRAINT `entities_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entities_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entities_ibfk_3` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entities_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `entity`
--
ALTER TABLE `entity`
  ADD CONSTRAINT `entity_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_ibfk_3` FOREIGN KEY (`entities_id`) REFERENCES `entities` (`entities_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `entity_essences`
--
ALTER TABLE `entity_essences`
  ADD CONSTRAINT `entity_essences_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`entity_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_2` FOREIGN KEY (`essence_id`) REFERENCES `essences` (`essence_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_5` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entity_essences_ibfk_6` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `essences`
--
ALTER TABLE `essences`
  ADD CONSTRAINT `essences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `groups_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_3` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `intents`
--
ALTER TABLE `intents`
  ADD CONSTRAINT `intents_ibfk_1` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `intents_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `intents_ibfk_3` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `intents_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`dialog_id`) REFERENCES `dialogues` (`dialog_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_4` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatches` (`dispatch_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_5` FOREIGN KEY (`bot_id`) REFERENCES `bots` (`bot_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `organizations`
--
ALTER TABLE `organizations`
  ADD CONSTRAINT `organizations_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `organizations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `sockets`
--
ALTER TABLE `sockets`
  ADD CONSTRAINT `sockets_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `types` (`type_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `sockets_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `states`
--
ALTER TABLE `states`
  ADD CONSTRAINT `states_ibfk_1` FOREIGN KEY (`socket_id`) REFERENCES `sockets` (`socket_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `states_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `states_ibfk_3` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `states_ibfk_4` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`organization_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`user_creator`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `user_sockets`
--
ALTER TABLE `user_sockets`
  ADD CONSTRAINT `user_sockets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_sockets_ibfk_2` FOREIGN KEY (`socket_id`) REFERENCES `sockets` (`socket_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
