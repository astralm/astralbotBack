module.exports = function(data, callback){
	var result = [];
	if(data.filters.indexOf("all") == -1){
		for(var i = 0; i < data.filters.length; i++){
			var filter = data.filters[i];
			switch(filter){
				case "all":
					result = [];
					break;
				case "free":
					result.push({
						name: "user_id",
						value: "0"
					});
					break;
				case "busy":
					result.push({
						name: "user_id",
						symbol: ">",
						value: "0"
					});
					break;
				case "user":
					result.push({
						name: "user_id",
						value: data.user_id
					});
					break;
				case "error":
					result.push({
						name: "session_error",
						value: "1"
					});
					break;
				case "success":
					result.push({
						name: "session_error",
						value: "0"
					});
					break;
				case "active":
					result.push({
						name: "session_status",
						value: "1"
					});
					break;
				case "inactive":
					result.push({
						name: "session_status",
						value: "0"
					});
					break;
				case "faq":
					result.push({
						name: "session_faq",
						value: "1"
					});
					break;
				case "sale":
					result.push({
						name: "session_sale",
						value: "1"
					});
					break;
				case "partner":
					result.push({
						name: "session_partner",
						value: "1"
					});
					break;
				case "telegram":
					result.push({
						name: "session_telegram",
						value: "1"
					});
					break;
				case "widget":
					result.push({
						name: "session_widget",
						value: "1"
					});
					break;
				case "date":
				case "today":
				case "yesterday":
					result.push({
						name: "session_dialog_update_date",
						value: '"' + data.firstDate + '"' + " AND " + '"' + data.secondDate + '"',
						symbol: " BETWEEN "
					});
					break;
			}
		}
	}
	var sql = "SELECT *, DATE_FORMAT(`session_dialog_update_date`, \'%Y-%d-%m %H:%i:%s\') as `session_dialog_update_date_formated` FROM `sessions_info_view`";
	if(result.length > 0){
		sql += " WHERE ";
		var _result = [];
		for(var i = 0; i < result.length; i++){
			var filter = result[i];
			_result.push("`"+filter.name+"`"+(filter.symbol || "=")+filter.value);
		}
		sql += _result.join(" AND ");
	}
	if(data.order){
		sql += " ORDER BY `"+data.order.name+"` ";
		if(data.order.desc){
			sql += "DESC ";
		}
	}
	sql += "LIMIT 50 OFFSET "+data.offset;
	this.mysql.query({
		sql: sql,
		timeout: 1000
	}, function(err, data){
		err ? 
			callback() :
			callback(data || null);
	});
}