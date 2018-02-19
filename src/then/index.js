const Err = require('../err');
let Then = (reducer, responce) => {
	(responce && responce[2] && responce[2][0] && responce[2][0].a && (responce = responce[2][0].a)) ||
	(responce && responce[0] && responce[0].a && (responce = responce[0].a)) || (responce = false);
	if (responce){
		console.log("\n");
		console.log("-----------------------------------------------");
		console.log(responce);
		console.log("\n");
		let arr = JSON.parse(responce);
		for (let i = 0; i < arr.length; i++){
			let obj = arr[i];
			reducer.dispatch({
				type: obj.action,
				data: obj.data
			}).then(Then.bind(this, reducer)).catch(Err);
		}
	}
}
module.exports = Then;