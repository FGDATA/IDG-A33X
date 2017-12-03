# A3XX Autobrake
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

setprop("/controls/autobrake/active", 0);
setprop("/controls/autobrake/mode", 0);

setlistener("/sim/signals/fdm-initialized", func {
	var thr1 = 0;
	var thr2 = 0;
	var wow0 = getprop("/gear/gear[0]/wow");
	var gnd_speed = getprop("/velocities/groundspeed-kt");
});

var autobrake_init = func {
	setprop("/controls/autobrake/active", 0);
	setprop("/controls/autobrake/mode", 0);
}

# Override FG's generic brake, so we can use toe brakes to disconnect autobrake
controls.applyBrakes = func(v, which = 0) {
	if (getprop("/systems/acconfig/autoconfig-running") != 1) {
		wow0 = getprop("/gear/gear[0]/wow");
		if (getprop("/controls/autobrake/mode") != 0 and wow0 == 1 and getprop("/controls/autobrake/active") == 1) {
			arm_autobrake(0);
		}
		if (which <= 0) {
			interpolate("/controls/gear/brake-left", v, 0.5);
		}
		if (which >= 0) {
			interpolate("/controls/gear/brake-right", v, 0.5);
		}
	}
}

# Set autobrake mode
var arm_autobrake = func(mode) {
	wow0 = getprop("/gear/gear[0]/wow");
	if (mode == 0) { # OFF
		absChk.stop();
		if (getprop("/controls/autobrake/active") == 1) {
			setprop("/controls/autobrake/active", 0);
			setprop("/controls/gear/brake-left", 0);
			setprop("/controls/gear/brake-right", 0);
		}
		setprop("/controls/autobrake/mode", 0);
	} else if (mode == 1 and wow0 != 1) { # LO
		setprop("/controls/autobrake/mode", 1);
		absChk.start();
	} else if (mode == 2 and wow0 != 1) { # MED
		setprop("/controls/autobrake/mode", 2);
		absChk.start();
	} else if (mode == 3 and wow0 == 1) { # MAX
		setprop("/controls/autobrake/mode", 3);
		absChk.start();
	}
}

# Autobrake enable if armed
var absChk = maketimer(0.2, func {
	thr1 = getprop("/controls/engines/engine[0]/throttle");
	thr2 = getprop("/controls/engines/engine[1]/throttle");
	wow0 = getprop("/gear/gear[0]/wow");
	gnd_speed = getprop("/velocities/groundspeed-kt");
	if (gnd_speed > 60) {
		if (getprop("/controls/autobrake/mode") != 0 and thr1 < 0.15 and thr2 < 0.15 and wow0 == 1) {
			setprop("/controls/autobrake/active", 1);
			if (getprop("/controls/autobrake/mode") == 1) { # LO
				interpolate("/controls/gear/brake-left", 0.4, 0.5);
				interpolate("/controls/gear/brake-right", 0.4, 0.5);
			} else if (getprop("/controls/autobrake/mode") == 2) { # MED
				interpolate("/controls/gear/brake-left", 0.65, 0.5);
				interpolate("/controls/gear/brake-right", 0.65, 0.5);
			} else if (getprop("/controls/autobrake/mode") == 3) { # MAX
				interpolate("/controls/gear/brake-left", 0.9, 0.5);
				interpolate("/controls/gear/brake-right", 0.9, 0.5);
			}
		} else {
			setprop("/controls/autobrake/active", 0);
			setprop("/controls/gear/brake-left", 0);
			setprop("/controls/gear/brake-right", 0);
		}
	}
});
