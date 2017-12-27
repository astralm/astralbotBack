module.exports = function(data, callback){
	this.mysql.query({
		sql: "UPDATE `sessions` SET `session_status` = ? WHERE `"+(data.session_id ? "session_id" : "session_hash")+"` = ?",
		values: [
			0,
			data.session_id ? +data.session_id : data.session_hash
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	});
}