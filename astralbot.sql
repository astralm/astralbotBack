-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Июн 23 2017 г., 20:41
-- Версия сервера: 10.1.13-MariaDB
-- Версия PHP: 5.6.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `astralbot_2`
--

-- --------------------------------------------------------

--
-- Структура таблицы `bot_messages`
--

CREATE TABLE `bot_messages` (
  `bot_message_id` int(11) NOT NULL,
  `bot_message` text COLLATE utf8_bin NOT NULL,
  `bot_message_date_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `human_messages`
--

CREATE TABLE `human_messages` (
  `human_message_id` int(11) NOT NULL,
  `human_message` text COLLATE utf8_bin NOT NULL,
  `human_message_date_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `sessions`
--

CREATE TABLE `sessions` (
  `session_id` int(11) NOT NULL,
  `session_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `session_date_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `sessions_status`
--

CREATE TABLE `sessions_status` (
  `session_status_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `sessions_status_view`
--
CREATE TABLE `sessions_status_view` (
`session_id` int(11)
,`session_hash` varchar(32)
,`session_date_create` timestamp
,`status_id` int(11)
,`status_name` varchar(32)
);

-- --------------------------------------------------------

--
-- Структура таблицы `session_bot_messages`
--

CREATE TABLE `session_bot_messages` (
  `session_bot_message_id` int(11) NOT NULL,
  `bot_message_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `session_bot_message_view`
--
CREATE TABLE `session_bot_message_view` (
`session_id` int(11)
,`session_hash` varchar(32)
,`session_date_create` timestamp
,`bot_message_id` int(11)
,`bot_message` text
,`bot_message_date_create` timestamp
);

-- --------------------------------------------------------

--
-- Структура таблицы `session_human_messages`
--

CREATE TABLE `session_human_messages` (
  `session_human_message_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `human_message_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `session_human_messages_view`
--
CREATE TABLE `session_human_messages_view` (
`session_id` int(11)
,`session_hash` varchar(32)
,`session_date_create` timestamp
,`human_message_id` int(11)
,`human_message` text
,`human_message_date_create` timestamp
);

-- --------------------------------------------------------

--
-- Структура таблицы `statuses`
--

CREATE TABLE `statuses` (
  `status_id` int(11) NOT NULL,
  `status_name` varchar(32) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_password` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_name` varchar(32) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `users_sessions`
--

CREATE TABLE `users_sessions` (
  `user_session_id` int(11) NOT NULL,
  `user_session_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_session_date_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `user_sessions_statuses`
--

CREATE TABLE `user_sessions_statuses` (
  `user_session_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `users_sessions_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `user_sessions_statuses_view`
--
CREATE TABLE `user_sessions_statuses_view` (
`user_id` int(11)
,`user_email` varchar(32)
,`user_password` varchar(32)
,`user_name` varchar(32)
,`user_session_id` int(11)
,`user_session_hash` varchar(32)
,`user_session_date_create` timestamp
,`status_id` int(11)
,`status_name` varchar(32)
);

-- --------------------------------------------------------

--
-- Структура для представления `sessions_status_view`
--
DROP TABLE IF EXISTS `sessions_status_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sessions_status_view`  AS  select `s`.`session_id` AS `session_id`,`s`.`session_hash` AS `session_hash`,`s`.`session_date_create` AS `session_date_create`,`st`.`status_id` AS `status_id`,`st`.`status_name` AS `status_name` from ((`sessions_status` `ss` join `sessions` `s` on((`s`.`session_id` = `ss`.`session_id`))) join `statuses` `st` on((`st`.`status_id` = `ss`.`status_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `session_bot_message_view`
--
DROP TABLE IF EXISTS `session_bot_message_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `session_bot_message_view`  AS  select `s`.`session_id` AS `session_id`,`s`.`session_hash` AS `session_hash`,`s`.`session_date_create` AS `session_date_create`,`bm`.`bot_message_id` AS `bot_message_id`,`bm`.`bot_message` AS `bot_message`,`bm`.`bot_message_date_create` AS `bot_message_date_create` from ((`session_bot_messages` `sbm` join `sessions` `s` on((`s`.`session_id` = `sbm`.`session_id`))) join `bot_messages` `bm` on((`bm`.`bot_message_id` = `sbm`.`bot_message_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `session_human_messages_view`
--
DROP TABLE IF EXISTS `session_human_messages_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `session_human_messages_view`  AS  select `s`.`session_id` AS `session_id`,`s`.`session_hash` AS `session_hash`,`s`.`session_date_create` AS `session_date_create`,`hm`.`human_message_id` AS `human_message_id`,`hm`.`human_message` AS `human_message`,`hm`.`human_message_date_create` AS `human_message_date_create` from ((`session_human_messages` `shm` join `sessions` `s` on((`s`.`session_id` = `shm`.`session_id`))) join `human_messages` `hm` on((`hm`.`human_message_id` = `shm`.`human_message_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `user_sessions_statuses_view`
--
DROP TABLE IF EXISTS `user_sessions_statuses_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_sessions_statuses_view`  AS  select `u`.`user_id` AS `user_id`,`u`.`user_email` AS `user_email`,`u`.`user_password` AS `user_password`,`u`.`user_name` AS `user_name`,`us`.`user_session_id` AS `user_session_id`,`us`.`user_session_hash` AS `user_session_hash`,`us`.`user_session_date_create` AS `user_session_date_create`,`s`.`status_id` AS `status_id`,`s`.`status_name` AS `status_name` from (((`user_sessions_statuses` `uss` join `users` `u` on((`u`.`user_id` = `uss`.`user_id`))) join `users_sessions` `us` on((`us`.`user_session_id` = `uss`.`user_session_id`))) join `statuses` `s` on((`s`.`status_id` = `uss`.`status_id`))) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `bot_messages`
--
ALTER TABLE `bot_messages`
  ADD PRIMARY KEY (`bot_message_id`);

--
-- Индексы таблицы `human_messages`
--
ALTER TABLE `human_messages`
  ADD PRIMARY KEY (`human_message_id`);

--
-- Индексы таблицы `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`);

--
-- Индексы таблицы `sessions_status`
--
ALTER TABLE `sessions_status`
  ADD PRIMARY KEY (`session_status_id`),
  ADD KEY `status_id` (`status_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Индексы таблицы `session_bot_messages`
--
ALTER TABLE `session_bot_messages`
  ADD PRIMARY KEY (`session_bot_message_id`),
  ADD KEY `bot_message_id` (`bot_message_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Индексы таблицы `session_human_messages`
--
ALTER TABLE `session_human_messages`
  ADD PRIMARY KEY (`session_human_message_id`),
  ADD KEY `human_message_id` (`human_message_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Индексы таблицы `statuses`
--
ALTER TABLE `statuses`
  ADD PRIMARY KEY (`status_id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Индексы таблицы `users_sessions`
--
ALTER TABLE `users_sessions`
  ADD PRIMARY KEY (`user_session_id`);

--
-- Индексы таблицы `user_sessions_statuses`
--
ALTER TABLE `user_sessions_statuses`
  ADD PRIMARY KEY (`user_session_id`),
  ADD KEY `status_id` (`status_id`),
  ADD KEY `users_sessions_id` (`users_sessions_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `bot_messages`
--
ALTER TABLE `bot_messages`
  MODIFY `bot_message_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `human_messages`
--
ALTER TABLE `human_messages`
  MODIFY `human_message_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `sessions`
--
ALTER TABLE `sessions`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `sessions_status`
--
ALTER TABLE `sessions_status`
  MODIFY `session_status_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `session_bot_messages`
--
ALTER TABLE `session_bot_messages`
  MODIFY `session_bot_message_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `session_human_messages`
--
ALTER TABLE `session_human_messages`
  MODIFY `session_human_message_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `statuses`
--
ALTER TABLE `statuses`
  MODIFY `status_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `users_sessions`
--
ALTER TABLE `users_sessions`
  MODIFY `user_session_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `user_sessions_statuses`
--
ALTER TABLE `user_sessions_statuses`
  MODIFY `user_session_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `sessions_status`
--
ALTER TABLE `sessions_status`
  ADD CONSTRAINT `sessions_status_ibfk_1` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`status_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sessions_status_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `session_bot_messages`
--
ALTER TABLE `session_bot_messages`
  ADD CONSTRAINT `session_bot_messages_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `session_bot_messages_ibfk_2` FOREIGN KEY (`bot_message_id`) REFERENCES `bot_messages` (`bot_message_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `session_human_messages`
--
ALTER TABLE `session_human_messages`
  ADD CONSTRAINT `session_human_messages_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `session_human_messages_ibfk_2` FOREIGN KEY (`human_message_id`) REFERENCES `human_messages` (`human_message_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `user_sessions_statuses`
--
ALTER TABLE `user_sessions_statuses`
  ADD CONSTRAINT `user_sessions_statuses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_sessions_statuses_ibfk_2` FOREIGN KEY (`users_sessions_id`) REFERENCES `users_sessions` (`user_session_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_sessions_statuses_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`status_id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
