# Airbus A3XX FBW/Flight Control Computer System
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

# If All PRIMs Fail, Alternate Law

var fctlInit = func {
	setprop("/controls/fctl/turb-damp", 1);
	setprop("/controls/fctl/prim1", 1);
	setprop("/controls/fctl/prim2", 1);
	setprop("/controls/fctl/prim3", 1);
	setprop("/controls/fctl/sec1", 1);
	setprop("/controls/fctl/sec2", 1);
	setprop("/systems/fctl/turb-damp", 0);
	setprop("/systems/fctl/prim1", 0);
	setprop("/systems/fctl/prim2", 0);
	setprop("/systems/fctl/prim3", 0);
	setprop("/systems/fctl/sec1", 0);
	setprop("/systems/fctl/sec2", 0);
	setprop("/it-fbw/degrade-law", 0);
}

setprop("/it-fbw/roll-back", 0);
setprop("/it-fbw/spd-hold", 0);

###################
# Update Function #
###################

var update_loop = func {
	var turbdamp_sw = getprop("/controls/fctl/turb-damp");
	var prim1_sw = getprop("/controls/fctl/prim1");
	var prim2_sw = getprop("/controls/fctl/prim2");
	var prim3_sw = getprop("/controls/fctl/prim3");
	var sec1_sw = getprop("/controls/fctl/sec1");
	var sec2_sw = getprop("/controls/fctl/sec2");
	var prim1_fail = getprop("/systems/failures/prim1");
	var prim2_fail = getprop("/systems/failures/prim2");
	var prim3_fail = getprop("/systems/failures/prim3");
	var sec1_fail = getprop("/systems/failures/sec1");
	var sec2_fail = getprop("/systems/failures/sec2");
	var ac_ess = getprop("/systems/electrical/bus/ac-ess");
	
	if (turbdamp_sw and ac_ess >= 110) {
		setprop("/systems/fctl/turb-damp", 1);
	} else {
		setprop("/systems/fctl/turb-damp", 0);
	}
	
	if (prim1_sw and !prim1_fail and ac_ess >= 110) {
		setprop("/systems/fctl/prim1", 1);
		setprop("/systems/failures/spoiler-l5", 0);
		setprop("/systems/failures/spoiler-r5", 0);
		setprop("/systems/failures/rudder", 0);
	} else {
		setprop("/systems/fctl/prim1", 0);
		setprop("/systems/failures/spoiler-l5", 1);
		setprop("/systems/failures/spoiler-r5", 1);
		if (!sec1_sw or sec1_fail) {
			setprop("/systems/failures/rudder", 1);
		}
	}
	
	if (prim2_sw and !prim2_fail and ac_ess >= 110) {
		setprop("/systems/fctl/prim2", 1);
		setprop("/systems/failures/spoiler-l4", 0);
		setprop("/systems/failures/spoiler-r4", 0);
	} else {
		setprop("/systems/fctl/prim2", 0);
		setprop("/systems/failures/spoiler-l4", 1);
		setprop("/systems/failures/spoiler-r4", 1);
	}
	
	if (prim3_sw and !prim3_fail and ac_ess >= 110) {
		setprop("/systems/fctl/prim3", 1);
		setprop("/systems/failures/spoiler-l1", 0);
		setprop("/systems/failures/spoiler-r1", 0);
		setprop("/systems/failures/spoiler-l2", 0);
		setprop("/systems/failures/spoiler-r2", 0);
	} else {
		setprop("/systems/fctl/prim3", 0);
		setprop("/systems/failures/spoiler-l1", 1);
		setprop("/systems/failures/spoiler-r1", 1);
		setprop("/systems/failures/spoiler-l2", 1);
		setprop("/systems/failures/spoiler-r2", 1);
	}
	
	if (sec1_sw and !sec1_fail and ac_ess >= 110) {
		setprop("/systems/fctl/sec1", 1);
		setprop("/systems/failures/spoiler-l6", 0);
		setprop("/systems/failures/spoiler-r6", 0);
		setprop("/systems/failures/rudder", 0);
	} else {
		setprop("/systems/fctl/sec1", 0);
		setprop("/systems/failures/spoiler-l6", 1);
		setprop("/systems/failures/spoiler-r6", 1);
		if (!prim1_sw or prim1_fail) {
			setprop("/systems/failures/rudder", 1);
		}
	}
	
	if (sec2_sw and !sec2_fail and ac_ess >= 110) {
		setprop("/systems/fctl/sec2", 1);
		setprop("/systems/failures/spoiler-l3", 0);
		setprop("/systems/failures/spoiler-r3", 0);
	} else {
		setprop("/systems/fctl/sec2", 0);
		setprop("/systems/failures/spoiler-l3", 1);
		setprop("/systems/failures/spoiler-r3", 1);
	}
	
	var turbdamp = getprop("/systems/fctl/turb-damp");
	var prim1 = getprop("/systems/fctl/prim1");
	var prim2 = getprop("/systems/fctl/prim2");
	var prim3 = getprop("/systems/fctl/prim3");
	var sec1 = getprop("/systems/fctl/sec1");
	var sec2 = getprop("/systems/fctl/sec2");
	var law = getprop("/it-fbw/law");
	
	# Degrade logic, all failures which degrade FBW need to go here. -JD
	if (getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
		if (!prim1 and !prim2 and !prim3) {
			if (law == 0) {
				setprop("/it-fbw/degrade-law", 1);
			}
		}
		if (getprop("/systems/electrical/bus/ac-ess") >= 110 and getprop("/systems/hydraulic/blue-psi") >= 1500 and getprop("/systems/hydraulic/green-psi") < 1500 and getprop("/systems/hydraulic/yellow-psi") < 1500) {
			if (law == 0 or law == 1) {
				setprop("/it-fbw/degrade-law", 2);
			}
		}
		if (getprop("/systems/electrical/bus/ac-ess") < 110 or (getprop("/systems/hydraulic/blue-psi") < 1500 and getprop("/systems/hydraulic/green-psi") < 1500 and getprop("/systems/hydraulic/yellow-psi") < 1500)) {
			setprop("/it-fbw/degrade-law", 3);
		}
	}
	
	if (getprop("/controls/gear/gear-down") == 1 and getprop("/it-autoflight/output/ap1") == 0 and getprop("/it-autoflight/output/ap2") == 0) {
		if (law == 1) {
			setprop("/it-fbw/degrade-law", 2);
		}
	}
	
	var law = getprop("/it-fbw/law");
	
	# Mech Backup can always return to direct, if it can.
	if (law == 3 and getprop("/systems/electrical/bus/ac-ess") >= 110 and getprop("/systems/hydraulic/blue-psi") >= 1500) {
		setprop("/it-fbw/degrade-law", 2);
	}
	
}
	
var fbw_loop = func {
	
	var ail = getprop("/controls/flight/aileron");
	
	if (ail > 0.4 or ail < -0.4) {
		setprop("/it-fbw/roll-lim", "67");
		if (getprop("/it-fbw/roll-back") == 1 and getprop("/orientation/roll-deg") <= 33.5 and getprop("/orientation/roll-deg") >= -33.5) {
			setprop("/it-fbw/roll-back", 0);
		}
		if (getprop("/it-fbw/roll-back") == 0 and (getprop("/orientation/roll-deg") > 33.5 or getprop("/orientation/roll-deg") < -33.5)) {
			setprop("/it-fbw/roll-back", 1);
		}
	} else if (ail < 0.05 and ail > -0.05) {
		setprop("/it-fbw/roll-lim", "33");
		if (getprop("/it-fbw/roll-back") == 1 and getprop("/orientation/roll-deg") <= 33.5 and getprop("/orientation/roll-deg") >= -33.5) {
			setprop("/it-fbw/roll-back", 0);
		}
	}

	if (getprop("/it-fbw/override") == 0) {
		var degrade = getprop("/it-fbw/degrade-law");
		if (degrade == 0) {
			if (getprop("/it-fbw/law") != 0) {
				setprop("/it-fbw/law", 0);
			}
		} else if (degrade == 1) {
			if (getprop("/it-fbw/law") != 1) {
				setprop("/it-fbw/law", 1);
			}
		} else if (degrade == 2) {
			if (getprop("/it-fbw/law") != 2) {
				setprop("/it-fbw/law", 2);
			}
		} else if (degrade == 3) {
			if (getprop("/it-fbw/law") != 3) {
				setprop("/it-fbw/law", 3);
			}
		}
	}
	
	if (getprop("/it-fbw/law") != 0) {
		if (getprop("/it-autoflight/output/ap1") == 1) {
			setprop("/it-autoflight/input/ap1", 0);
		}
		if (getprop("/it-autoflight/output/ap2") == 1) {
			setprop("/it-autoflight/input/ap2", 0);
		}
	}
}

###########################
# Various Other Functions #
###########################

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/it-fbw/override", 0);
	setprop("/it-fbw/law", 0);
	updatet.start();
	fbwt.start();
});

##########
# Timers #
##########
var updatet = maketimer(0.1, update_loop);
var fbwt = maketimer(0.03, fbw_loop);
