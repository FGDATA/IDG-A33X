# A330 Main Libraries
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

print("-----------------------------------------------------------------------------");
print("Copyright (c) 2017 Joshua Davidson (it0uchpods)");
print("-----------------------------------------------------------------------------");

# Dimmers
setprop("/controls/lighting/ndl-norm", 1);
setprop("/controls/lighting/ndr-norm", 1);
setprop("/controls/lighting/upper-norm", 1);

# Lights
setprop("/sim/model/lights/nose-lights", 0);
setprop("/sim/model/lights/turnoffsw", 0);
setprop("/controls/lighting/turnoff-light-switch", 0);
setprop("/controls/lighting/leftturnoff", 0);
setprop("/controls/lighting/rightturnoff", 0);

# Oil Qty
var qty1 = math.round((rand() * 5 ) + 20, 0.1);
var qty2 = math.round((rand() * 5 ) + 20, 0.1);
setprop("/engines/engine[0]/oil-qt-actual", qty1);
setprop("/engines/engine[1]/oil-qt-actual", qty2);

##########
# Lights #
##########
var beacon_switch = props.globals.getNode("/controls/switches/beacon", 2);
var beacon = aircraft.light.new("/sim/model/lights/beacon", [0.1, 1], "/controls/lighting/beacon");
var strobe_switch = props.globals.getNode("/controls/switches/strobe", 2);
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.06, 0.05, 1], "/controls/lighting/strobe");
var tail_strobe_switch = props.globals.getNode("/controls/switches/tailstrobe", 2);
var tail_strobe = aircraft.light.new("/sim/model/lights/tailstrobe", [0.1, 1], "/controls/lighting/strobe");
var logo_lights = getprop("/sim/model/lights/logo-lights");
var nav_lights = props.globals.getNode("/sim/model/lights/nav-lights");
var wow = getprop("/gear/gear[2]/wow");
var slats = getprop("/controls/flight/slats");
var gear = getprop("/gear/gear[0]/position-norm");
var nose_lights = getprop("/sim/model/lights/nose-lights");
var left_turnoff_light = props.globals.getNode("/controls/lighting/leftturnoff");
var right_turnoff_light = props.globals.getNode("/controls/lighting/rightturnoff");
var settingT = getprop("/controls/lighting/taxi-light-switch");
var settingTurnoff = getprop("/controls/lighting/turnoff-light-switch");
var setting = getprop("/controls/lighting/nav-lights-switch");
var land = getprop("/controls/lighting/landing-lights[1]");

###################
# Tire Smoke/Rain #
###################

var tiresmoke_system = aircraft.tyresmoke_system.new(0, 1, 2);
aircraft.rain.init();

##########
# Sounds #
##########

setlistener("/sim/sounde/btn1", func {
	if (!getprop("/sim/sounde/btn1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/btn1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/oh-btn", func {
	if (!getprop("/sim/sounde/oh-btn")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/oh-btn").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/btn3", func {
	if (!getprop("/sim/sounde/btn3")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/btn3").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/knb1", func {
	if (!getprop("/sim/sounde/knb1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/knb1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/switch1", func {
	if (!getprop("/sim/sounde/switch1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/switch1").setBoolValue(0);
	}, 0.05);
});

setlistener("/controls/switches/seatbelt-sign", func {
	props.globals.getNode("/sim/sounde/seatbelt-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("/sim/sounde/seatbelt-sign").setBoolValue(0);
	}, 2);
});

setlistener("/controls/switches/no-smoking-sign", func {
	props.globals.getNode("/sim/sounde/no-smoking-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("/sim/sounde/no-smoking-sign").setBoolValue(0);
	}, 1);
});

#########
# Doors #
#########

# Front doors
var doorl1 = aircraft.door.new("/sim/model/door-positions/doorl1", 2);
var doorr1 = aircraft.door.new("/sim/model/door-positions/doorr1", 2);

# Middle doors (A321 only)
var doorl2 = aircraft.door.new("/sim/model/door-positions/doorl2", 2);
var doorr2 = aircraft.door.new("/sim/model/door-positions/doorr2", 2);
var doorl3 = aircraft.door.new("/sim/model/door-positions/doorl3", 2);
var doorr3 = aircraft.door.new("/sim/model/door-positions/doorr3", 2);

# Rear doors
var doorl4 = aircraft.door.new("/sim/model/door-positions/doorl4", 2);
var doorr4 = aircraft.door.new("/sim/model/door-positions/doorr4", 2);

# Cargo holds
var cargobulk = aircraft.door.new("/sim/model/door-positions/cargobulk", 2.5);
var cargoaft = aircraft.door.new("/sim/model/door-positions/cargoaft", 2.5);
var cargofwd = aircraft.door.new("/sim/model/door-positions/cargofwd", 2.5);

# Seat armrests in the flight deck (unused)
var armrests = aircraft.door.new("/sim/model/door-positions/armrests", 2);

# door opener/closer
var triggerDoor = func(door, doorName, doorDesc) {
	if (getprop("/sim/model/door-positions/" ~ doorName ~ "/position-norm") > 0) {
		gui.popupTip("Closing " ~ doorDesc ~ " door");
		door.toggle();
	} else {
		if (getprop("/velocities/groundspeed-kt") > 5) {
			gui.popupTip("You cannot open the doors while the aircraft is moving!!!");
		} else {
			gui.popupTip("Opening " ~ doorDesc ~ " door");
			door.toggle();
		}
	}
};

#######################
# Various Other Stuff #
#######################
 
setlistener("/sim/signals/fdm-initialized", func {
	fbw.fctlInit();
	systems.ELEC.init();
	systems.PNEU.init();
	systems.HYD.init();
	systems.FUEL.init();
	systems.ADIRS.init();
	systems.eng_init();
	systems.fire_init();
	systems.autobrake_init();
  	fmgc.APinit();			
	fmgc.FMGCinit();
	mcdu1.MCDU_init();
	mcdu2.MCDU_init();
	systemsLoop.start();
	libraries.CVR.start();
	icing.icingInit();
	lightsLoop.start();
	var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/IDG-A33X/Systems/autopilot-dlg.xml");
	setprop("/it-autoflight/input/fd1", 1);
	setprop("/it-autoflight/input/fd2", 1);
	libraries.ECAMinit();
	libraries.variousReset();
});

var systemsLoop = maketimer(0.1, func {
	systems.ELEC.loop();
	systems.PNEU.loop();
	systems.HYD.loop();
	systems.FUEL.loop();
	systems.ADIRS.loop();

	if ((getprop("/controls/pneumatic/switches/groundair") or getprop("/controls/switches/cart")) and ((getprop("/velocities/groundspeed-kt") > 2) or getprop("/controls/gear/brake-parking") == 0)) {
		setprop("/controls/switches/cart", 0);
		setprop("/controls/pneumatic/switches/groundair", 0);
	}

	if (getprop("/velocities/groundspeed-kt") > 15) {
		setprop("/systems/shake/effect", 1);
	} else {
		setprop("/systems/shake/effect", 0);
	}
	
	if (getprop("/it-autoflight/custom/show-hdg") == 0 and getprop("/it-autoflight/output/lat") != 4) {
		setprop("/it-autoflight/input/hdg", math.round(getprop("/orientation/heading-magnetic-deg")));
	}
	
	if (getprop("/gear/gear[1]/gear-tilt-deg") < 40) {
		setprop("/gear/gear[3]/wowa", 1);
	} else {
		setprop("/gear/gear[3]/wowa", 0);
	}
	if (getprop("/gear/gear[2]/gear-tilt-deg") < 40) {
		setprop("/gear/gear[4]/wowa", 1);
	} else {
		setprop("/gear/gear[4]/wowa", 0);
	}
	
	if ((getprop("/sim/replay/time") == 0) or (getprop("/sim/replay/time") == nil)) {
		setprop("/aircraft/wingflex-enable", 1);
	} else {
		setprop("/aircraft/wingflex-enable", 0);
	}
});

canvas.Text._lastText = canvas.Text["_lastText"];
canvas.Text.setText = func (text) {
	if (text == me._lastText) {return me;}
	me._lastText = text;
	me.set("text", typeof(text) == 'scalar' ? text : "");
};
canvas.Element._lastVisible = nil;
canvas.Element.show = func () {
	if (1 == me._lastVisible) {return me;}
	me._lastVisible = 1;
	me.setBool("visible", 1);
};
canvas.Element.hide = func () {
	if (0 == me._lastVisible) {return me;}
	me._lastVisible = 0;
	me.setBool("visible", 0);
};
canvas.Element.setVisible = func (vis) {
	if (vis == me._lastVisible) {return me;}
	me._lastVisible = vis;
	me.setBool("visible", vis);
};

# In air, flaps 1 is slats only. On ground, it is slats and flaps.

setprop("/controls/flight/flap-lever", 0);
setprop("/controls/flight/flap-pos", 0);
setprop("/controls/flight/flap-txt", " ");

controls.flapsDown = func(step) {
	if (step == 1) {
		if (getprop("/controls/flight/flap-lever") == 0) {
			if (getprop("/velocities/airspeed-kt") <= 100) {
				setprop("/controls/flight/flaps", 0.290);
				setprop("/controls/flight/slats", 0.666);
				setprop("/controls/flight/flap-lever", 1);
				setprop("/controls/flight/flap-pos", 2);
				setprop("/controls/flight/flap-txt", "1+F");
				flaptimer.start();
				return;
			} else {
				setprop("/controls/flight/flaps", 0.000);
				setprop("/controls/flight/slats", 0.666);
				setprop("/controls/flight/flap-lever", 1);
				setprop("/controls/flight/flap-pos", 1);
				setprop("/controls/flight/flap-txt", "1");
				flaptimer.stop();
				return;
			}
		} else if (getprop("/controls/flight/flap-lever") == 1) {
			setprop("/controls/flight/flaps", 0.596);
			setprop("/controls/flight/slats", 0.814);
			setprop("/controls/flight/flap-lever", 2);
			setprop("/controls/flight/flap-pos", 3);
			setprop("/controls/flight/flap-txt", "2");
			flaptimer.stop();
			return;
		} else if (getprop("/controls/flight/flap-lever") == 2) {
			setprop("/controls/flight/flaps", 0.645);
			setprop("/controls/flight/slats", 0.814);
			setprop("/controls/flight/flap-lever", 3);
			setprop("/controls/flight/flap-pos", 4);
			setprop("/controls/flight/flap-txt", "3");
			flaptimer.stop();
			return;
		} else if (getprop("/controls/flight/flap-lever") == 3) {
			setprop("/controls/flight/flaps", 1.000);
			setprop("/controls/flight/slats", 1.000);
			setprop("/controls/flight/flap-lever", 4);
			setprop("/controls/flight/flap-pos", 5);
			setprop("/controls/flight/flap-txt", "FULL");
			flaptimer.stop();
			return;
		}
	} else if (step == -1) {
		if (getprop("/controls/flight/flap-lever") == 4) {
			setprop("/controls/flight/flaps", 0.645);
			setprop("/controls/flight/slats", 0.814);
			setprop("/controls/flight/flap-lever", 3);
			setprop("/controls/flight/flap-pos", 4);
			setprop("/controls/flight/flap-txt", "3");
			flaptimer.stop();
			return;
		} else if (getprop("/controls/flight/flap-lever") == 3) {
			setprop("/controls/flight/flaps", 0.596);
			setprop("/controls/flight/slats", 0.814);
			setprop("/controls/flight/flap-lever", 2);
			setprop("/controls/flight/flap-pos", 3);
			setprop("/controls/flight/flap-txt", "2");
			flaptimer.stop();
			return;
		} else if (getprop("/controls/flight/flap-lever") == 2) {
			if (getprop("/velocities/airspeed-kt") <= 100) {
				setprop("/controls/flight/flaps", 0.290);
				setprop("/controls/flight/slats", 0.666);
				setprop("/controls/flight/flap-lever", 1);
				setprop("/controls/flight/flap-pos", 2);
				setprop("/controls/flight/flap-txt", "1+F");
				flaptimer.start();
				return;
			} else {
				setprop("/controls/flight/flaps", 0.000);
				setprop("/controls/flight/slats", 0.666);
				setprop("/controls/flight/flap-lever", 1);
				setprop("/controls/flight/flap-pos", 1);
				setprop("/controls/flight/flap-txt", "1");
				flaptimer.stop();
				return;
			}
		} else if (getprop("/controls/flight/flap-lever") == 1) {
			setprop("/controls/flight/flaps", 0.000);
			setprop("/controls/flight/slats", 0.000);
			setprop("/controls/flight/flap-lever", 0);
			setprop("/controls/flight/flap-pos", 0);
			setprop("/controls/flight/flap-txt", " ");
			flaptimer.stop();
			return;
		}
	} else {
		return 0;
	}
}

var flaptimer = maketimer(0.5, func {
	if (getprop("/controls/flight/flap-pos") == 2 and getprop("/velocities/airspeed-kt") >= 208) {
		setprop("/controls/flight/flaps", 0.000);
		setprop("/controls/flight/slats", 0.666);
		setprop("/controls/flight/flap-lever", 1);
		setprop("/controls/flight/flap-pos", 1);
		setprop("/controls/flight/flap-txt", "1");
		flaptimer.stop();
	}
});

var lightsLoop = maketimer(0.2, func {
	gear = getprop("/gear/gear[0]/position-norm");
	nose_lights = getprop("/sim/model/lights/nose-lights");
	settingT = getprop("/controls/lighting/taxi-light-switch");
	
	# nose lights
	
	if (settingT == 0.5 and gear > 0.9 and (getprop("/systems/electrical/bus/ac1") > 0 or getprop("/systems/electrical/bus/ac2") > 0)) {
		setprop("/sim/model/lights/nose-lights", 0.85);
	} else if (settingT == 1 and gear > 0.9 and (getprop("/systems/electrical/bus/ac1") > 0 or getprop("/systems/electrical/bus/ac2") > 0)) {
		setprop("/sim/model/lights/nose-lights", 1);
	} else {
		setprop("/sim/model/lights/nose-lights", 0);
	}
	
	# turnoff lights
	settingTurnoff = getprop("/controls/lighting/turnoff-light-switch");
	left_turnoff_light = props.globals.getNode("/controls/lighting/leftturnoff");
	right_turnoff_light = props.globals.getNode("/controls/lighting/rightturnoff");
	
	if (settingTurnoff == 1 and gear > 0.9 and getprop("/systems/electrical/bus/ac1") > 0) {
		left_turnoff_light.setBoolValue(1);
	} else {
		left_turnoff_light.setBoolValue(0);
	}
	
	if (settingTurnoff == 1 and gear > 0.9 and getprop("/systems/electrical/bus/ac2") > 0) {
		right_turnoff_light.setBoolValue(1);
	} else {
		right_turnoff_light.setBoolValue(0);
	}
	
	# logo and navigation lights
	setting = getprop("/controls/lighting/nav-lights-switch");
	nav_lights = props.globals.getNode("/sim/model/lights/nav-lights");
	logo_lights = props.globals.getNode("/sim/model/lights/logo-lights");
	wow = getprop("/gear/gear[2]/wow");
	slats = getprop("/controls/flight/slats");
	
	if (getprop("/systems/electrical/bus/ac1") > 0 or getprop("/systems/electrical/bus/ac2") > 0) {
		setprop("/systems/electrical/nav-lights-power", 1);
	} else { 
		setprop("/systems/electrical/nav-lights-power", 0);
	}
	
	if (setting == 0 and logo_lights == 1) {
		 logo_lights.setBoolValue(0);
	} else if (setting == 1 or setting == 2 and (getprop("/systems/electrical/bus/ac1") > 0 or getprop("/systems/electrical/bus/ac2") > 0)) {
		if ((wow) or (!wow and slats > 0)) {
			logo_lights.setBoolValue(1);
		} else {
			logo_lights.setBoolValue(0);
		}
	} else {
		logo_lights.setBoolValue(0);
	}

	if (setting == 1 or setting == 2 and (getprop("/systems/electrical/bus/ac1") > 0 or getprop("/systems/electrical/bus/ac2") > 0 or getprop("/systems/electrical/bus/dc1") > 0 or getprop("/systems/electrical/bus/dc2") > 0)) {
		nav_lights.setBoolValue(1);
	} else {
		nav_lights.setBoolValue(0);
	}
	
	# landing lights
	land = getprop("/controls/lighting/landing-lights[1]");
	
	if (land == 1) {
		setprop("/sim/rendering/als-secondary-lights/use-landing-light", 1);
		setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 1);
	} else {
		setprop("/sim/rendering/als-secondary-lights/use-landing-light", 0);
		setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 0);
	}
});

var lTray = func {
	var lTrayCMD = getprop("/controls/tray/lefttrayext");
	if (lTrayCMD < 0.5) {
		interpolate("/controls/tray/lefttrayext", 0.5, 0.5);
	} else if (lTrayCMD == 0.5) {
		interpolate("/controls/tray/lefttrayext", 1.0, 0.5);
	} else {
		interpolate("/controls/tray/lefttrayext", 0.0, 1.0);
	}
}

var rTray = func {
	var rTrayCMD = getprop("/controls/tray/righttrayext");
	if (rTrayCMD < 0.5) {
		interpolate("/controls/tray/righttrayext", 0.5, 0.5);
	} else if (rTrayCMD == 0.5) {
		interpolate("/controls/tray/righttrayext", 1.0, 0.5);
	} else {
		interpolate("/controls/tray/righttrayext", 0.0, 1.0);
	}
}

var l1Pedal = func {
	var lPedalCMD = getprop("/controls/footrest-cpt[0]");
	if (lPedalCMD < 1.0) {
		interpolate("/controls/footrest-cpt[0]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-cpt[0]", 0.0, 0.5);
	}
}

var l2Pedal = func {
	var l2PedalCMD = getprop("/controls/footrest-cpt[1]");
	if (l2PedalCMD < 1.0) {
		interpolate("/controls/footrest-cpt[1]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-cpt[1]", 0.0, 0.5);
	}
}

var r1Pedal = func {
	var rPedalCMD = getprop("/controls/footrest-fo[0]");
	if (rPedalCMD < 1.0) {
		interpolate("/controls/footrest-fo[0]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-fo[0]", 0.0, 0.5);
	}
}

var r2Pedal = func {
	var r2PedalCMD = getprop("/controls/footrest-fo[1]");
	if (r2PedalCMD < 1.0) {
		interpolate("/controls/footrest-fo[1]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-fo[1]", 0.0, 0.5);
	}
}

if (getprop("/controls/flight/auto-coordination") == 1) {
	setprop("/controls/flight/auto-coordination", 0);
	gui.popupTip("System: Auto Coordination has been turned off for this session.");
	print("System: Auto Coordination has been turned off for this session.");
}

setprop("/systems/acconfig/libraries-loaded", 1);
