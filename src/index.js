var fs = require('fs'),
	env = require('./constants/env.js'),
	app = require('express')(),
	helmet = require('helmet'),
	io = require('socket.io')(env.ws.https ? 
		require('https').createServer({
			key: fs.readFileSync('./src/constants/privkey.pem'),
			cert: fs.readFileSync('./src/constants/fullchain.pem')
		}, app).listen(env.ws.port) :
		require("http").createServer().listen(env.ws.port)
	),
	reducer = require('./reducer.js')(require('mysql').createConnection(env.mysql), require('./nodemailer/index.js')(require('nodemailer'), env)),
	Events = require('./creators/index.js'),
	telegram = new (require('node-telegram-bot-api'))(env.telegram.token, {polling: true}),
	apiai = require('apiai')(env.apiai.token);
app.use(helmet());
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






