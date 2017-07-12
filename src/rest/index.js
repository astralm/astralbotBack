module.exports = function(rest, reducer, actions){
	rest.post('/', function(request, responce){
		console.log(request.body);
	});
}