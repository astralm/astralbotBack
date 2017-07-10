-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Июл 10 2017 г., 10:55
-- Версия сервера: 10.1.21-MariaDB
-- Версия PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
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
-- Структура таблицы `sessions`
--

CREATE TABLE `sessions` (
  `session_id` int(11) NOT NULL,
  `session_hash` varchar(32) COLLATE utf8_bin NOT NULL,
  `session_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

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
-- Дублирующая структура для представления `user`
-- (See below for the actual view)
--
CREATE TABLE `user` (
`user_id` int(11)
,`user_name` varchar(32)
,`user_email` varchar(32)
,`user_password` varchar(32)
,`session_id` int(11)
,`session_hash` varchar(32)
,`session_date` timestamp
,`status_id` int(11)
,`user_status_date` timestamp
);

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_email` varchar(32) COLLATE utf8_bin NOT NULL,
  `user_password` varchar(32) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `user_sessions`
--

CREATE TABLE `user_sessions` (
  `user_session_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `user_session_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `user_sessions_status_view`
-- (See below for the actual view)
--
CREATE TABLE `user_sessions_status_view` (
`user_id` int(11)
,`user_name` varchar(32)
,`user_email` varchar(32)
,`user_password` varchar(32)
,`session_id` int(11)
,`session_hash` varchar(32)
,`session_date` timestamp
,`status_id` int(11)
,`user_status_date` timestamp
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `user_sessions_view`
-- (See below for the actual view)
--
CREATE TABLE `user_sessions_view` (
`user_id` int(11)
,`user_name` varchar(32)
,`user_email` varchar(32)
,`user_password` varchar(32)
,`session_id` int(11)
,`session_hash` varchar(32)
,`session_date` timestamp
);

-- --------------------------------------------------------

--
-- Структура таблицы `user_statuses`
--

CREATE TABLE `user_statuses` (
  `user_status_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `user_status_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура для представления `user`
--
DROP TABLE IF EXISTS `user`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user`  AS  select `usv`.`user_id` AS `user_id`,`usv`.`user_name` AS `user_name`,`usv`.`user_email` AS `user_email`,`usv`.`user_password` AS `user_password`,`usv`.`session_id` AS `session_id`,`usv`.`session_hash` AS `session_hash`,`usv`.`session_date` AS `session_date`,`us`.`status_id` AS `status_id`,`us`.`user_status_date` AS `user_status_date` from (`user_sessions_view` `usv` join `user_statuses` `us` on((`us`.`user_id` = `usv`.`user_id`))) order by `us`.`user_status_date` desc limit 1 ;

-- --------------------------------------------------------

--
-- Структура для представления `user_sessions_status_view`
--
DROP TABLE IF EXISTS `user_sessions_status_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_sessions_status_view`  AS  select `usv`.`user_id` AS `user_id`,`usv`.`user_name` AS `user_name`,`usv`.`user_email` AS `user_email`,`usv`.`user_password` AS `user_password`,`usv`.`session_id` AS `session_id`,`usv`.`session_hash` AS `session_hash`,`usv`.`session_date` AS `session_date`,`us`.`status_id` AS `status_id`,`us`.`user_status_date` AS `user_status_date` from (`user_sessions_view` `usv` left join `user_statuses` `us` on((`us`.`user_id` = `usv`.`user_id`))) order by `us`.`user_status_date` desc limit 1 ;

-- --------------------------------------------------------

--
-- Структура для представления `user_sessions_view`
--
DROP TABLE IF EXISTS `user_sessions_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_sessions_view`  AS  select `u`.`user_id` AS `user_id`,`u`.`user_name` AS `user_name`,`u`.`user_email` AS `user_email`,`u`.`user_password` AS `user_password`,`s`.`session_id` AS `session_id`,`s`.`session_hash` AS `session_hash`,`s`.`session_date` AS `session_date` from ((`user_sessions` `us` join `users` `u` on((`u`.`user_id` = `us`.`user_id`))) join `sessions` `s` on((`s`.`session_id` = `us`.`session_id`))) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD UNIQUE KEY `session_hash` (`session_hash`);

--
-- Индексы таблицы `statuses`
--
ALTER TABLE `statuses`
  ADD PRIMARY KEY (`status_id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`);

--
-- Индексы таблицы `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`user_session_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Индексы таблицы `user_statuses`
--
ALTER TABLE `user_statuses`
  ADD PRIMARY KEY (`user_status_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status_id` (`status_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `sessions`
--
ALTER TABLE `sessions`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
--
-- AUTO_INCREMENT для таблицы `statuses`
--
ALTER TABLE `statuses`
  MODIFY `status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `user_session_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;
--
-- AUTO_INCREMENT для таблицы `user_statuses`
--
ALTER TABLE `user_statuses`
  MODIFY `user_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_sessions_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `user_statuses`
--
ALTER TABLE `user_statuses`
  ADD CONSTRAINT `user_statuses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_statuses_ibfk_2` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`status_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
