module.exports = function(data, callback){
	var _this = this,
		_data = data;
	this.mysql.query({
		sql: 'INSERT INTO `questions` (`session_id`, `question_message`) SELECT s.session_id, ? AS `question_message` FROM `sessions` AS `s` WHERE `session_hash` = ?',
		timeout: 1000,
		values: [
			data.message,
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