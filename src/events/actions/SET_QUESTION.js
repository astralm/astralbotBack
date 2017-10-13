module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `questions` (`session_id`, `question_message`) SELECT s.session_id, ? AS `question_message` FROM `sessions` AS `s` WHERE `session_hash` = ?',
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