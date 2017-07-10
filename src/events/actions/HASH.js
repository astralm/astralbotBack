module.exports = function(data, callback){
	var hash = [];
	for (var i = 0; i < 32; i++) {
		var number = Math.ceil(Math.random() * 2);
		var random = (Math.random() * 0xFFF).toString(16)[0];
		number == 1 ?
			random = random.toLowerCase() :
			random = random.toUpperCase();
		hash.push(random);
	}
	hash = hash.join("");
	this.mysql.query({
		sql: 'INSERT INTO `sessions` (`session_hash`) VALUES (?)',
		timeout: 1000,
		values: [
			hash
		]
	}, function(err, data){
		err ? 
			callback() :
			data.affectedRows > 0 ?
				callback(hash) :
				callback();
	});
}