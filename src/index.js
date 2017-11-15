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
	telegram_partner = new (require('node-telegram-bot-api'))(env.telegram.partner, {polling: true}),
	telegram_sale = new (require('node-telegram-bot-api'))(env.telegram.sale, {polling: true}),
	telegram_faq = new (require('node-telegram-bot-api'))(env.telegram.faq, {polling: true}),
	telegram_notifications = new (require('node-telegram-bot-api'))(env.telegram.notifications, {polling: true}),
	apiai_partner = require('apiai')(env.apiai.partner),
	apiai_faq = require('apiai')(env.apiai.faq),
	apiai_sale = require('apiai')(env.apiai.sale),
	ua = require('ua-parser-js');
app.use(helmet());
telegram_partner.connections = [];
telegram_sale.connections = [];
telegram_faq.connections = [];
require("./ws/index.js")(
	io, 
	reducer, 
	Events,
	ua,
	{
		partner: telegram_partner,
		sale: telegram_sale,
		faq: telegram_faq
	},
	{
		partner: apiai_partner,
		sale: apiai_sale,
		faq: apiai_faq
	},
	telegram_notifications
);
require("./telegram/index.js")(
	telegram_partner,
	apiai_partner,
	reducer,
	Events,
	io,
	"partner",
	telegram_notifications
);
require("./telegram/index.js")(
	telegram_faq,
	apiai_faq,
	reducer,
	Events,
	io,
	"faq",
	telegram_notifications
);
require("./telegram/index.js")(
	telegram_sale,
	apiai_sale,
	reducer,
	Events,
	io,
	"sale",
	telegram_notifications
);
require("./telegram/notification.js")(
	reducer,
	Events,
	telegram_notifications,
	io
);




