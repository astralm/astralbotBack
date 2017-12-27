module.exports = function(data, callback){
	var transporter = this.transporter;
	this.mysql.query({
		sql: "SELECT `user_password` FROM `users` WHERE `user_email` = ?",
		values: [
			data
		]
	}, function(err, responce){
		if(responce && responce[0]){
			transporter.sendMail({
				from: "AstralBot",
				to: data,
				subject: "Востановление пароля",
				text: "Ваш пароль: " + responce[0].user_password
			}, function(error, info){
				if(error){
					callback(false);
				} else {
					callback(true);
				}
			});
		} else {
			callback(false);
		}
	});
}