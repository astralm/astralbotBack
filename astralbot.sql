-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Авг 02 2017 г., 13:52
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
-- База данных: `astralbot_3`
--

-- --------------------------------------------------------

--
-- Структура таблицы `answers`
--

CREATE TABLE `answers` (
  `answer_id` int(11) NOT NULL,
  `answer_message` text CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `answer_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `session_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `questions`
--

CREATE TABLE `questions` (
  `question_id` int(11) NOT NULL,
  `question_message` text CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `question_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `session_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `sessions`
--

CREATE TABLE `sessions` (
  `session_id` int(11) NOT NULL,
  `session_hash` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `session_status` tinyint(1) NOT NULL DEFAULT '1',
  `user_id` int(11) NOT NULL,
  `session_error` tinyint(1) NOT NULL DEFAULT '0',
  `bot_work` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `sessions_info_view`
-- (See below for the actual view)
--
CREATE TABLE `sessions_info_view` (
`question` mediumtext
,`answer` mediumtext
,`session_id` int(11)
,`session_hash` varchar(32)
,`session_status` tinyint(1)
,`user_id` int(11)
,`session_error` tinyint(1)
,`user_name` varchar(32)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `session_dialog_view`
-- (See below for the actual view)
--
CREATE TABLE `session_dialog_view` (
`session_hash` varchar(32)
,`question_id` int(11)
,`question_message` text
,`question_date` timestamp
,`session_id` int(11)
,`answer_id` int(11)
,`answer_message` text
,`answer_date` timestamp
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `session_info_view`
-- (See below for the actual view)
--
CREATE TABLE `session_info_view` (
`session_id` int(11)
,`session_hash` varchar(32)
,`session_status` tinyint(1)
,`user_id` int(11)
,`session_error` tinyint(1)
,`user_name` varchar(32)
);

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(32) NOT NULL,
  `user_password` varchar(32) NOT NULL,
  `user_status` tinyint(1) NOT NULL DEFAULT '0',
  `user_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура для представления `sessions_info_view`
--
DROP TABLE IF EXISTS `sessions_info_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sessions_info_view`  AS  select (select `questions`.`question_message` from `questions` where (`questions`.`session_id` = `s`.`session_id`) order by `questions`.`question_id` desc limit 1) AS `question`,(select `answers`.`answer_message` from `answers` where (`answers`.`session_id` = `s`.`session_id`) order by `answers`.`answer_id` desc limit 1) AS `answer`,`s`.`session_id` AS `session_id`,`s`.`session_hash` AS `session_hash`,`s`.`session_status` AS `session_status`,`s`.`user_id` AS `user_id`,`s`.`session_error` AS `session_error`,`u`.`user_name` AS `user_name` from (`sessions` `s` left join `users` `u` on((`u`.`user_id` = `s`.`user_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `session_dialog_view`
--
DROP TABLE IF EXISTS `session_dialog_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `session_dialog_view`  AS  select `s`.`session_hash` AS `session_hash`,`q`.`question_id` AS `question_id`,`q`.`question_message` AS `question_message`,`q`.`question_date` AS `question_date`,`q`.`session_id` AS `session_id`,`a`.`answer_id` AS `answer_id`,`a`.`answer_message` AS `answer_message`,`a`.`answer_date` AS `answer_date` from ((`sessions` `s` join `questions` `q` on((`q`.`session_id` = `s`.`session_id`))) left join `answers` `a` on((`a`.`question_id` = `q`.`question_id`))) ;

-- --------------------------------------------------------

--
-- Структура для представления `session_info_view`
--
DROP TABLE IF EXISTS `session_info_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `session_info_view`  AS  select `s`.`session_id` AS `session_id`,`s`.`session_hash` AS `session_hash`,`s`.`session_status` AS `session_status`,`s`.`user_id` AS `user_id`,`s`.`session_error` AS `session_error`,`u`.`user_name` AS `user_name` from (`sessions` `s` left join `users` `u` on((`u`.`user_id` = `s`.`user_id`))) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`answer_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Индексы таблицы `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`question_id`),
  ADD KEY `session_id` (`session_id`);

--
-- Индексы таблицы `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD UNIQUE KEY `session_hash` (`session_hash`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `answers`
--
ALTER TABLE `answers`
  MODIFY `answer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;
--
-- AUTO_INCREMENT для таблицы `questions`
--
ALTER TABLE `questions`
  MODIFY `question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;
--
-- AUTO_INCREMENT для таблицы `sessions`
--
ALTER TABLE `sessions`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;
--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `answers`
--
ALTER TABLE `answers`
  ADD CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
