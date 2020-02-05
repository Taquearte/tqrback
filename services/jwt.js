'use strict'

var jwt    =require('jwt-simple');
var moment    =require('moment');
var secret    ='MKSoftwareDevelopers2019@Sicario'

exports.createToken = function(user){
	var payload={
		sub: 8888,
		name: user.Nombre,
		surname: user.Usuario,
		empresa: user.Empresa,
		sucursal: user.Sucursal,
		iat:moment().unix(),
		exp: moment().add(1,'days').unix
	};
	return jwt.encode(payload,secret);
};