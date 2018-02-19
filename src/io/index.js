const io = require('socket.io'),
			express = require('express')(),
			helmet = require('helmet')(),
			ua = require('ua-parser-js');
let Then = require('../then'),
		Err = require('../err');
module.exports = (env, reducer) => {
	Then = Then.bind(this, reducer);
	const server = env.https ?
		require("https").createServer({
			key: `./../constants/${env.keyFile}`,
			cert: `./../constants/${env.certFile}`
		}, express) :
		require("http").createServer(express);
	server.listen(env.port);
	express.use(helmet);
	const sockets = io(server);
	sockets.on("connection", socket => {
		let userAgent = ua(socket.handshake.headers["user-agent"]);
				room = socket.nsp.name,
				url = socket.handshake.headers.origin,
				ip = socket.handshake.address,
				id = socket.id,
				type = socket.handshake.query.type == "admin" ? "2" : "1";
		reducer.dispatch({
			type: "Query",
			data: {
				query: "newSocket",
				values: [
					type,
					id,
					userAgent.engine.name,
					userAgent.engine.varsion,
					userAgent.os.name,
					userAgent.os.version,
					userAgent.device.vendor,
					userAgent.device.model,
					userAgent.device.type,
					userAgent.cpu.architecture,
					userAgent.browser.name,
					userAgent.browser.version,
					url,
					null,
					ip
				]
			}
		}).then(Then).catch(Err);
		socket.on("message", action => {
			reducer.dispatch(action).then(Then).catch(Err);
			socket.on("disconnect", () => {
				reducer.dispatch({
					type: "Query",
					data: {
						query: "socketDisconnect",
						values: [
							socket.id
						]
					}
				}).then(Then).catch(Err);
			});
		});
	});
	return sockets;
}