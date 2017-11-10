module.exports = function(data, callback){
	this.mysql.query({
		sql: "INSERT INTO `dispatches` (`user_id`, `dispatch_message`, `dispatch_telegram`, `dispatch_widget`, `dispatch_partner`, `dispatch_faq`, `dispatch_sale`, `organization_id`) VALUES (?,?,?,?,?,?,?,?)",
		timeout: 1000,
		values: [
			data.user_id,
			data.dispatch_message,
			data.dispatch_telegram ? 1 : 0,
			data.dispatch_widget ? 1 : 0,
			data.dispatch_partner ? 1 : 0,
			data.dispatch_faq ? 1 : 0,
			data.dispatch_sale ? 1 : 0,
			data.organization_id
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}