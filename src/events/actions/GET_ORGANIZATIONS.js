module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `organizations`"
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}