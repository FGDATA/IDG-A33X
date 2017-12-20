# Aircraft Config Center
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

var failReset = func {
	setprop("/systems/failures/prim1", 0);
	setprop("/systems/failures/prim2", 0);
	setprop("/systems/failures/prim3", 0);
	setprop("/systems/failures/sec1", 0);
	setprop("/systems/failures/sec2", 0);
	setprop("/systems/failures/aileron-left", 0);
	setprop("/systems/failures/aileron-right", 0);
	setprop("/systems/failures/elevator-left", 0);
	setprop("/systems/failures/elevator-right", 0);
	setprop("/systems/failures/rudder", 0);
	setprop("/systems/failures/spoiler-l1", 0);
	setprop("/systems/failures/spoiler-l2", 0);
	setprop("/systems/failures/spoiler-l3", 0);
	setprop("/systems/failures/spoiler-l4", 0);
	setprop("/systems/failures/spoiler-l5", 0);
	setprop("/systems/failures/spoiler-l6", 0);
	setprop("/systems/failures/spoiler-r1", 0);
	setprop("/systems/failures/spoiler-r2", 0);
	setprop("/systems/failures/spoiler-r3", 0);
	setprop("/systems/failures/spoiler-r4", 0);
	setprop("/systems/failures/spoiler-r5", 0);
	setprop("/systems/failures/spoiler-r6", 0);
	setprop("/systems/failures/elec-ac-ess", 0);
	setprop("/systems/failures/elec-batt1", 0);
	setprop("/systems/failures/elec-batt2", 0);
	setprop("/systems/failures/elec-galley", 0);
	setprop("/systems/failures/elec-genapu", 0);
	setprop("/systems/failures/elec-gen1", 0);
	setprop("/systems/failures/elec-gen2", 0);
	setprop("/systems/failures/bleed-apu", 0);
	setprop("/systems/failures/bleed-ext", 0);
	setprop("/systems/failures/bleed-eng1", 0);
	setprop("/systems/failures/bleed-eng2", 0);
	setprop("/systems/failures/pack1", 0);
	setprop("/systems/failures/pack2", 0);
	setprop("/systems/failures/hyd-blue", 0);
	setprop("/systems/failures/hyd-green", 0);
	setprop("/systems/failures/hyd-yellow", 0);
	setprop("/systems/failures/ptu", 0);
	setprop("/systems/failures/pump-blue-eng", 0);
	setprop("/systems/failures/pump-blue-elec", 0);
	setprop("/systems/failures/pump-green-eng", 0);
	setprop("/systems/failures/pump-green-eng2", 0);
	setprop("/systems/failures/pump-green-elec", 0);
	setprop("/systems/failures/pump-yellow-eng", 0);
	setprop("/systems/failures/pump-yellow-elec", 0);
	setprop("/systems/failures/tank0pump1", 0);
	setprop("/systems/failures/tank0pump2", 0);
	setprop("/systems/failures/tank1pump1", 0);
	setprop("/systems/failures/tank1pump2", 0);
	setprop("/systems/failures/tank2pump1", 0);
	setprop("/systems/failures/tank2pump2", 0);
	setprop("/systems/failures/fuelmode", 0);
	setprop("/systems/failures/cargo-aft-fire", 0);
	setprop("/systems/failures/cargo-fwd-fire", 0);
}

failReset();
setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
setprop("/systems/acconfig/new-revision", "");
setprop("/systems/acconfig/out-of-date", 0);
setprop("/systems/acconfig/mismatch-code", "0x000");
setprop("/systems/acconfig/mismatch-reason", "XX");
var main_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/main/dialog", "Aircraft/IDG-A33X/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/IDG-A33X/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/IDG-A33X/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/IDG-A33X/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/init/dialog", "Aircraft/IDG-A33X/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/help/dialog", "Aircraft/IDG-A33X/AircraftConfig/help.xml");
var fbw_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fbw/dialog", "Aircraft/IDG-A33X/AircraftConfig/fbw.xml");
var fail_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fail/dialog", "Aircraft/IDG-A33X/AircraftConfig/fail.xml");
var about_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/about/dialog", "Aircraft/IDG-A33X/AircraftConfig/about.xml");
var update_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/update/dialog", "Aircraft/IDG-A33X/AircraftConfig/update.xml");
var error_mismatch = gui.Dialog.new("sim/gui/dialogs/acconfig/error/mismatch/dialog", "Aircraft/IDG-A33X/AircraftConfig/error-mismatch.xml");
spinning.start();
init_dlg.open();

http.load("https://raw.githubusercontent.com/it0uchpods/IDG-A33X/master/revision.txt").done(func(r) setprop("/systems/acconfig/new-revision", r.response));
var revisionFile = (getprop("/sim/aircraft-dir")~"/revision.txt");
var current_revision = io.readfile(revisionFile);

setlistener("/systems/acconfig/new-revision", func {
	if (getprop("/systems/acconfig/new-revision") > current_revision) {
		setprop("/systems/acconfig/out-of-date", 1);
	} else {
		setprop("/systems/acconfig/out-of-date", 0);
	}
});

var mismatch_chk = func {
	if (num(string.replace(getprop("/sim/version/flightgear"),".","")) < 201730) {
		setprop("/systems/acconfig/mismatch-code", "0x121");
		setprop("/systems/acconfig/mismatch-reason", "FGFS version older than 2017.3.0, please update FlightGear");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x121");
	} else if (getprop("/gear/gear[0]/wow") == 0 or getprop("/position/altitude-ft") >= 50000 or getprop("/systems/acconfig/libraries-loaded") == 0) {
		setprop("/systems/acconfig/mismatch-code", "0x223");
		setprop("/systems/acconfig/mismatch-reason", "Aircraft initialization failed");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x223");
	}
}

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	if (getprop("/systems/acconfig/out-of-date") == 1) {
		update_dlg.open();
		print("System: The IDG-A33X is out of date!");
	} 
	mismatch_chk();
	if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/mismatch-code") == "0x000") {
		welcome_dlg.open();
	}
	spinning.stop();
});

var saveSettings = func {
	aircraft.data.add("/options/system/keyboard-mode", "/controls/adirs/skip");
	aircraft.data.save();
}

saveSettings();

var systemsReset = func {
	fbw.fctlInit();
	systems.ELEC.init();
	systems.PNEU.init();
	systems.HYD.init();
	systems.FUEL.init();
	systems.ADIRS.init();
	systems.eng_init();
	systems.autobrake_init();
	fmgc.FMGCinit();
	mcdu1.MCDU_reset();
	mcdu2.MCDU_reset();
	icing.icingInit();
	fmgc.APinit();
	setprop("/it-autoflight/input/fd1", 1);
	setprop("/it-autoflight/input/fd2", 1);
	libraries.ECAMinit();
	libraries.variousReset();
}

################
# Panel States #
################

# Cold and Dark
var colddark = func {
	spinning.start();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	setprop("/controls/gear/brake-left", 1);
	setprop("/controls/gear/brake-right", 1);
	# Initial shutdown, and reinitialization.
	setprop("/controls/engines/engine-start-switch", 1);
	setprop("/controls/engines/engine[0]/cutoff-switch", 1);
	setprop("/controls/engines/engine[1]/cutoff-switch", 1);
	setprop("/controls/flight/slats", 0.000);
	setprop("/controls/flight/flaps", 0.000);
	setprop("/controls/flight/flap-lever", 0);
	setprop("/controls/flight/flap-pos", 0);
	setprop("/controls/flight/flap-txt", " ");
	libraries.flaptimer.stop();
	setprop("/controls/flight/speedbrake-arm", 0);
	setprop("/controls/gear/gear-down", 1);
	setprop("/controls/flight/elevator-trim", 0);
	systemsReset();
	failReset();
	if (getprop("/engines/engine[1]/n2-actual") < 2) {
		colddark_b();
	} else {
		var colddark_eng_off = setlistener("/engines/engine[1]/n2-actual", func {
			if (getprop("/engines/engine[1]/n2-actual") < 2) {
				removelistener(colddark_eng_off);
				colddark_b();
			}
		});
	}
}
var colddark_b = func {
	# Continues the Cold and Dark script, after engines fully shutdown.
	setprop("/controls/APU/master", 0);
	setprop("/controls/APU/start", 0);
	setprop("/controls/bleed/OHP/bleedapu", 0);
	setprop("/controls/electrical/switches/battery1", 0);
	setprop("/controls/electrical/switches/battery2", 0);
	setprop("/controls/gear/brake-left", 0);
	setprop("/controls/gear/brake-right", 0);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Start Eng
var beforestart = func {
	spinning.start();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	setprop("/controls/gear/brake-left", 1);
	setprop("/controls/gear/brake-right", 1);
	# First, we set everything to cold and dark.
	setprop("/controls/engines/engine-start-switch", 1);
	setprop("/controls/engines/engine[0]/cutoff-switch", 1);
	setprop("/controls/engines/engine[1]/cutoff-switch", 1);
	setprop("/controls/flight/slats", 0.000);
	setprop("/controls/flight/flaps", 0.000);
	setprop("/controls/flight/flap-lever", 0);
	setprop("/controls/flight/flap-pos", 0);
	setprop("/controls/flight/flap-txt", " ");
	libraries.flaptimer.stop();
	setprop("/controls/flight/speedbrake-arm", 0);
	setprop("/controls/gear/gear-down", 1);
	setprop("/controls/flight/elevator-trim", 0);
	systemsReset();
	failReset();
	setprop("/controls/APU/master", 0);
	setprop("/controls/APU/start", 0);
	setprop("/controls/bleed/OHP/bleedapu", 0);
	setprop("/controls/electrical/switches/battery1", 0);
	setprop("/controls/electrical/switches/battery2", 0);
	
	# Now the Startup!
	setprop("/controls/electrical/switches/battery1", 1);
	setprop("/controls/electrical/switches/battery2", 1);
	setprop("/controls/electrical/switches/battery3", 1);
	setprop("/controls/APU/master", 1);
	setprop("/controls/APU/start", 1);
	var apu_rpm_chk = setlistener("/systems/apu/rpm", func {
		if (getprop("/systems/apu/rpm") >= 98) {
			removelistener(apu_rpm_chk);
			beforestart_b();
		}
	});
}
var beforestart_b = func {
	# Continue with engine start prep.
	setprop("/controls/fuel/tank0pump1", 1);
	setprop("/controls/fuel/tank0pump2", 1);
	setprop("/controls/fuel/tank0pump3", 1);
	setprop("/controls/fuel/tank1pump1", 1);
	setprop("/controls/fuel/tank1pump2", 1);
	setprop("/controls/fuel/tank2pump1", 1);
	setprop("/controls/fuel/tank2pump2", 1);
	setprop("/controls/fuel/tank2pump3", 1);
	setprop("/controls/electrical/switches/gen-apu", 1);
	setprop("/controls/electrical/switches/galley", 1);
	setprop("/controls/electrical/switches/gen1", 1);
	setprop("/controls/electrical/switches/gen2", 1);
	setprop("/controls/pneumatic/switches/bleedapu", 1);
	setprop("/controls/pneumatic/switches/bleed1", 1);
	setprop("/controls/pneumatic/switches/bleed2", 1);
	setprop("/controls/pneumatic/switches/pack1", 1);
	setprop("/controls/pneumatic/switches/pack2", 1);
	setprop("controls/adirs/ir[0]/knob","1");
	setprop("controls/adirs/ir[1]/knob","1");
	setprop("controls/adirs/ir[2]/knob","1");
	systems.ADIRS.skip(0);
	systems.ADIRS.skip(1);
	systems.ADIRS.skip(2);
	setprop("/controls/adirs/mcducbtn", 1);
	setprop("/controls/lighting/beacon", 1);
	setprop("/controls/lighting/nav-lights-switch", 1);
	setprop("/controls/gear/brake-left", 0);
	setprop("/controls/gear/brake-right", 0);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Taxi
var taxi = func {
	spinning.start();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	setprop("/controls/gear/brake-left", 1);
	setprop("/controls/gear/brake-right", 1);
	# First, we set everything to cold and dark.
	setprop("/controls/engines/engine-start-switch", 1);
	setprop("/controls/engines/engine[0]/cutoff-switch", 1);
	setprop("/controls/engines/engine[1]/cutoff-switch", 1);
	setprop("/controls/flight/slats", 0.000);
	setprop("/controls/flight/flaps", 0.000);
	setprop("/controls/flight/flap-lever", 0);
	setprop("/controls/flight/flap-pos", 0);
	setprop("/controls/flight/flap-txt", " ");
	libraries.flaptimer.stop();
	setprop("/controls/flight/speedbrake-arm", 0);
	setprop("/controls/gear/gear-down", 1);
	setprop("/controls/flight/elevator-trim", 0);
	systemsReset();
	failReset();
	setprop("/controls/APU/master", 0);
	setprop("/controls/APU/start", 0);
	setprop("/controls/electrical/switches/battery1", 0);
	setprop("/controls/electrical/switches/battery2", 0);
	
	# Now the Startup!
	setprop("/controls/electrical/switches/battery1", 1);
	setprop("/controls/electrical/switches/battery2", 1);
	setprop("/controls/electrical/switches/battery3", 1);
	setprop("/controls/APU/master", 1);
	setprop("/controls/APU/start", 1);
	var apu_rpm_chk = setlistener("/systems/apu/rpm", func {
		if (getprop("/systems/apu/rpm") >= 99) {
			removelistener(apu_rpm_chk);
			taxi_b();
		}
	});
}
var taxi_b = func {
	# Continue with engine start prep, and start engine 2.
	setprop("/controls/fuel/tank0pump1", 1);
	setprop("/controls/fuel/tank0pump2", 1);
	setprop("/controls/fuel/tank0pump3", 1);
	setprop("/controls/fuel/tank1pump1", 1);
	setprop("/controls/fuel/tank1pump2", 1);
	setprop("/controls/fuel/tank2pump1", 1);
	setprop("/controls/fuel/tank2pump2", 1);
	setprop("/controls/fuel/tank2pump3", 1);
	setprop("/controls/electrical/switches/gen-apu", 1);
	setprop("/controls/electrical/switches/galley", 1);
	setprop("/controls/electrical/switches/gen1", 1);
	setprop("/controls/electrical/switches/gen2", 1);
	setprop("/controls/pneumatic/switches/bleedapu", 1);
	setprop("/controls/pneumatic/switches/bleed1", 1);
	setprop("/controls/pneumatic/switches/bleed2", 1);
	setprop("/controls/pneumatic/switches/pack1", 1);
	setprop("/controls/pneumatic/switches/pack2", 1);
	setprop("controls/adirs/ir[0]/knob","1");
	setprop("controls/adirs/ir[1]/knob","1");
	setprop("controls/adirs/ir[2]/knob","1");
	systems.ADIRS.skip(0);
	systems.ADIRS.skip(1);
	systems.ADIRS.skip(2);
	setprop("/controls/adirs/mcducbtn", 1);
	setprop("/controls/lighting/beacon", 1);
	setprop("/controls/lighting/nav-lights-switch", 1);
	settimer(taxi_c, 2);
}
var taxi_c = func {
	setprop("/controls/engines/engine-start-switch", 2);
	setprop("/controls/engines/engine[0]/cutoff-switch", 0);
	setprop("/controls/engines/engine[1]/cutoff-switch", 0);
	settimer(func {
		taxi_d();
	}, 10);
}
var taxi_d = func {
	# After Start items.
	setprop("/controls/engines/engine-start-switch", 1);
	setprop("/controls/APU/master", 0);
	setprop("/controls/APU/start", 0);
	setprop("/controls/pneumatic/switches/bleedapu", 0);
	setprop("/controls/lighting/taxi-light-switch", 1);
	setprop("/controls/gear/brake-left", 0);
	setprop("/controls/gear/brake-right", 0);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Takeoff
var takeoff = func {
	# The same as taxi, except we set some things afterwards.
	taxi();
	var eng_one_chk_c = setlistener("/engines/engine[0]/state", func {
		if (getprop("/engines/engine[0]/state") == 3) {
			removelistener(eng_one_chk_c);
			setprop("/controls/lighting/strobe", 1);
			setprop("/controls/lighting/landing-lights[1]", 1);
			setprop("/controls/lighting/landing-lights[2]", 1);
			setprop("/controls/flight/speedbrake-arm", 1);
			setprop("/controls/flight/flaps", 0.290);
			setprop("/controls/flight/slats", 0.666);
			setprop("/controls/flight/flap-lever", 1);
			setprop("/controls/flight/flap-pos", 2);
			setprop("/controls/flight/flap-txt", "1+F");
			libraries.flaptimer.start();
			setprop("/controls/flight/elevator-trim", -0.07);
			systems.arm_autobrake(3);
		}
	});
}
