module.exports = function(nodemailer, env){
	var transporter = nodemailer.createTransport({
		host: env.nodemailer.host,
		port: env.nodemailer.port,
		secure: env.nodemailer.secure,
		auth: {
			user: env.nodemailer.user,
			pass: env.nodemailer.pass
		}
	});
	return transporter;
}