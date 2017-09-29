module.exports = function(data, callback){
	this.mysql.query({
		sql: "INSERT INTO `dispatches` (`user_id`, `dispatch_message`, `dispatch_telegram`, `dispatch_widget`) VALUES (?,?,?,?)",
		timeout: 1000,
		values: [
			data.user_id,
			data.dispatch_message,
			data.dispatch_telegram ? 1 : 0,
			data.dispatch_widget ? 1 : 0
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}