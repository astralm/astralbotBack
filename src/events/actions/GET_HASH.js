module.exports = function(data, callback){
	var hash = [];
	for (var i = 0; i < 32; i++){
		var number = Math.ceil(Math.random() * 2),
			char = (Math.random() * 0xFFF).toString(16)[0];
		char = number == 1 ? char.toLowerCase() : char.toUpperCase();
		hash.push(char);
	}
	hash = hash.join("");
	this.mysql.query({
		sql:'INSERT INTO `sessions` (session_hash) VALUES (?)',
		timeout: 1000,
		values: [
			hash
		] 
	}, (err, data) => {
		err ? 
			callback(err) :
			callback(hash)
	});
}