# A33X Refuel Control Code
# For Boom, and Drogues
# Joshua Davidson (it0uchpods)

#########################################
# Copyright (c) it0uchpods Design Group #
#########################################

var toggleDrogues = func {
	var drogueCmd = getprop("/options/drogue-pos-norm");
	if (drogueCmd < 1) {
		interpolate(getprop("/options/drogue-pos-norm"), 1, 1);
	} else {
		interpolate(getprop("/options/drogue-pos-norm"), 0, 1);
	}
}

var toggleBoom = func {
	var drogueCmd = getprop("/options/drogue-pos-norm");
	if (drogueCmd < 1) {
		interpolate(getprop("/options/drogue-pos-norm"), 1, 5);
	} else {
		interpolate(getprop("/options/drogue-pos-norm"), 0, 5);
	}
}