# A33X Refuel Control Code
# For Boom, and Drogues
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var refeulInit = func {
	setprop("/options/boom-pos-norm", 0);
	setprop("/options/drogue-pos-norm", 0);
}

var toggleBoom = func {
	var drogueCmd = getprop("/options/boom-pos-norm");
	if (drogueCmd < 1) {
		interpolate("/options/boom-pos-norm", 1, 5);
	} else {
		interpolate("/options/boom-pos-norm", 0, 5);
	}
}

var toggleDrogues = func {
	var drogueCmd = getprop("/options/drogue-pos-norm");
	if (drogueCmd < 1) {
		interpolate("/options/drogue-pos-norm", 1, 1);
	} else {
		interpolate("/options/drogue-pos-norm", 0, 1);
	}
}