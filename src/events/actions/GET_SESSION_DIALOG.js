module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT * FROM `session_dialog_view` WHERE `'+(data.session_id ? 'session_id' : 'session_hash')+'` = ? ORDER BY `question_id`',
		timeout: 1000,
		values: [
			+data.session_id || +data.session_hash
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}