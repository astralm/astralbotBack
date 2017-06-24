var env = require('./constants/env.js'),
		reducer = require('./reducer.js')(require('mysql').createConnection(env.mysql)),
		Events = require('./creators/index.js'),
		rest = require('express')();
require("./ws/index.js")(
	require('socket.io')(require('http').createServer().listen(env.ws.port)), 
	reducer, 
	Events
);
require("./rest/index.js")(
	rest,
	reducer,
	Events
);
rest.listen(env.rest.port, function(){
	console.log("rest server start on port " + env.rest.port);
});






