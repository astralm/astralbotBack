module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT `bot_work` FROM `sessions` WHERE " + (data.session_id ? "`session_id`" : "`session_hash`") + " = ?",
		values: [
			data.session_id ? data.session_id : data.session_hash
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	});
}