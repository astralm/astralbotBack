module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `sessions` (`session_hash`,`session_'+data.type+'`) VALUES (?,?)',
		timeout: 1000,
		values: [
			data.hash,
			1
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	})
}