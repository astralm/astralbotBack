module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `sessions` (`session_hash`) VALUES (?)',
		timeout: 1000,
		values: [
			data
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	})
}