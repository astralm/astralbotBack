module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT *, DATE_FORMAT(`question_date`, \'%Y-%d-%m %H:%i:%s\') AS `question_date_formated`, DATE_FORMAT(`answer_date`, \'%Y-%d-%m %H:%i:%s\') AS `answer_date_formated` FROM `session_dialog_view` WHERE `'+(data.session_id ? 'session_id' : 'session_hash')+'` = ? ORDER BY `question_id`',
		values: [
			data.session_id ? +data.session_id : data.session_hash
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}