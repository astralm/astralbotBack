module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `sessions_info_view`",
		tiemout: 1000
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}