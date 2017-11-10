module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `sessions` (`session_hash`,`session_'+data.type+'`,`session_'+data.subject+'`, `organization_id`) VALUES (?,?,?,?)',
		timeout: 1000,
		values: [
			data.hash,
			1,
			1,
			data.organization_id
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	})
}