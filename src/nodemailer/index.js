const nodemailer = require('nodemailer');
module.exports = env => {
	let transporter = nodemailer.createTransport({
		host: env.host,
		port: env.port,
		secure: env.secure,
		auth: {
			user: env.user,
			pass: env.pass
		}
	});
	return transporter;
}