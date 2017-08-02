var env = require('./constants/env.js'),
	reducer = require('./reducer.js')(require('mysql').createConnection(env.mysql)),
	Events = require('./creators/index.js'),
	rest = require('express')().use(require('body-parser').json()),
	telegram = new (require('node-telegram-bot-api'))(env.telegram.token, {polling: true}),
	apiai = require('apiai')(env.apiai.token),
	io = require('socket.io')(require('http').createServer().listen(env.ws.port));
telegram.connections = [];
require("./ws/index.js")(
	io, 
	reducer, 
	Events,
	telegram
);
require("./telegram/index.js")(
	telegram,
	apiai,
	reducer,
	Events,
	io
);
require("./rest/index.js")(
	rest,
	reducer,
	Events
);
rest.listen(env.rest.port, function(){
	console.log("rest server start on port " + env.rest.port);
});






