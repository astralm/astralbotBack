module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `answers` (`session_id`, `question_id`, `answer_message`) SELECT s.session_id, (SELECT question_id FROM `questions` WHERE `session_id` = s.session_id ORDER BY `question_id` DESC LIMIT 1), ? FROM `sessions` AS `s` WHERE `session_hash` = ?',
		timeout: 1000,
		values: [
			data.message,
			data.hash
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	});
	this.mysql.query({
		sql: 'UPDATE `sessions` SET `session_dialog_update_date`=DATE_FORMAT(NOW(), \'%Y-%d-%m %H:%i:%s\') WHERE `session_hash`=?',
		timeout: 1000,
		values: [
			data.hash
		]
	});
}