var env = require('./constants/env.js'),
	reducer = require('./reducer.js')(require('mysql').createConnection(env.mysql), require('./nodemailer/index.js')(require('nodemailer'), env)),
	Events = require('./creators/index.js'),
	telegram = new (require('node-telegram-bot-api'))(env.telegram.token, {polling: true}),
	apiai = require('apiai')(env.apiai.token),
	io = require('socket.io')(require('http').createServer().listen(env.ws.port));
telegram.connections = [];
require("./ws/index.js")(
	io, 
	reducer, 
	Events,
	telegram,
	apiai
);
require("./telegram/index.js")(
	telegram,
	apiai,
	reducer,
	Events,
	io
);






