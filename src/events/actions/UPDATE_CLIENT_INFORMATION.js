module.exports = function(data, callback){
	var result = Object.keys(data).filter(function(data_item){
		return data_item != "session_id";
	}).map(function(key){
		return key;
	});
	this.mysql.query({
		sql: "UPDATE `clients` SET " + result.map(function(item){
			return item + "=?";
		}).join(", ") + "WHERE `session_id`=?",
		timeout: 1000,
		values: Object.keys(data).filter(function(data_item){
			return data_item != "session_id";
		}).map(function(item){
			return data[item];
		}).concat(data.session_id)
	}, function(err, responce){
		if(callback){
			if(!err){
				callback(responce || null);
			} else {
				callback();
			}
		}
	})
}