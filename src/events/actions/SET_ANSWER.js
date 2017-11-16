module.exports = function(data, callback){
	var _this = this,
		_data = data;
	this.mysql.query({
		sql: 'INSERT INTO `answers` (`session_id`, `question_id`, `answer_message`, `user_name`) SELECT s.session_id, (SELECT question_id FROM `questions` WHERE `session_id` = s.session_id ORDER BY `question_id` DESC LIMIT 1), ?, ? FROM `sessions` AS `s` WHERE `session_hash` = ?',
		timeout: 1000,
		values: [
			data.message,
			data.user_name,
			data.hash
		]
	}, function(err, data){
		if(!err){
			_this.mysql.query({
				sql: 'UPDATE `sessions` SET `session_dialog_update_date`=NOW() WHERE `session_hash`=?',
				timeout: 1000,
				values: [
					_data.hash
				]
			});
		}
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	});
}