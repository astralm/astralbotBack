const env = require("./constants/env.json"),
			mysql = require('mysql').createConnection(env.mysql),
			reducer = new (require("./reducer")),
			io = require('./io')(env.server, reducer),
			nodemailer = require('./nodemailer')(env.nodemailer),
			telegram = require('./telegram')(env.telegram, reducer);
let Then = require('./then'),
		Err = require('./err');
Then = Then.bind(this, reducer);
reducer.initEvents({
	mysql,
	io,
	nodemailer,
	telegram
});
reducer.dispatch({
	type: "Query",
	data: {
		query: "getBotsToServer",
		values: [

		]
	}
}).then(Then).catch(Err);








