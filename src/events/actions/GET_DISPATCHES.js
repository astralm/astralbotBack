module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `dispatches_view`",
		timeout: 1000
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}