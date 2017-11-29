# A3XX PFD
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var PFD_1 = nil;
var PFD_2 = nil;
var PFD_1_test = nil;
var PFD_2_test = nil;
var PFD1_display = nil;
var PFD2_display = nil;
var elapsedtime = 0;
var ASI = 0;
var ASItrgt = 0;
var ASItrgtdiff = 0;
var ASImax = 0;
var alt = 0;
var altTens = 0;
var state1 = getprop("/systems/thrust/state1");
var state2 = getprop("/systems/thrust/state2");
var ap1 = getprop("/it-autoflight/output/ap1");
var ap2 = getprop("/it-autoflight/output/ap2");
var fd1 = getprop("/it-autoflight/output/fd1");
var fd2 = getprop("/it-autoflight/output/fd2");
var athr = getprop("/it-autoflight/output/athr");
var throttle_mode = getprop("/modes/pfd/fma/throttle-mode");
var pitch_mode = getprop("/modes/pfd/fma/pitch-mode");
var pitch_mode_armed = getprop("/modes/pfd/fma/pitch-mode-armed");
var pitch_mode2_armed = getprop("/modes/pfd/fma/pitch-mode2-armed");
var roll_mode = getprop("/modes/pfd/fma/roll-mode");
var roll_mode_armed = getprop("/modes/pfd/fma/roll-mode-armed");
var thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
var thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
var pitch = getprop("/orientation/pitch-deg");
var roll = getprop("/orientation/roll-deg");
var wow1 = getprop("/gear/gear[1]/wow");
var wow2 = getprop("/gear/gear[2]/wow");
var pitch = 0;
var roll = 0;
var spdTrend_c = 0;
setprop("/instrumentation/pfd/vs-needle", 0);
setprop("/instrumentation/pfd/vs-digit-trans", 0);
setprop("/it-autoflight/input/spd-managed", 0);
setprop("/FMGC/internal/target-ias-pfd", 0);
setprop("/it-autoflight/output/ap1", 0);
setprop("/it-autoflight/output/ap2", 0);
setprop("/it-autoflight/output/fd1", 0);
setprop("/it-autoflight/output/fd2", 0);
setprop("/it-autoflight/output/athr", 0);
setprop("/instrumentation/pfd/alt-diff", 0);
setprop("/instrumentation/pfd/heading-deg", 0);
setprop("/instrumentation/pfd/horizon-pitch", 0);
setprop("/instrumentation/pfd/horizon-ground", 0);
setprop("/instrumentation/pfd/hdg-diff", 0);
setprop("/instrumentation/pfd/heading-scale", 0);
setprop("/instrumentation/pfd/track-deg", 0);
setprop("/instrumentation/pfd/track-hdg-diff", 0);
setprop("/instrumentation/du/du1-test", 0);
setprop("/instrumentation/du/du1-test-time", 0);
setprop("/instrumentation/du/du6-test", 0);
setprop("/instrumentation/du/du6-test-time", 0);
setprop("/it-autoflight/internal/vert-speed-fpm-pfd", 0);
setprop("/position/gear-agl-ft", 0);
setprop("/controls/flight/aileron-input-fast", 0);
setprop("/controls/flight/elevator-input-fast", 0);
setprop("/instrumentation/adirs/adr[0]/active", 0);
setprop("/instrumentation/adirs/adr[1]/active", 0);
setprop("/instrumentation/adirs/adr[2]/active", 0);
setprop("/instrumentation/adirs/ir[0]/aligned", 0);
setprop("/instrumentation/adirs/ir[1]/aligned", 0);
setprop("/instrumentation/adirs/ir[2]/aligned", 0);

var canvas_PFD_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();

			foreach (var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);

				var clip_el = canvas_group.getElementById(key ~ "_clip");
				if (clip_el != nil) {
					clip_el.setVisible(0);
					var tran_rect = clip_el.getTransformedBounds();

					var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
					tran_rect[1], # 0 ys
					tran_rect[2], # 1 xe
					tran_rect[3], # 2 ye
					tran_rect[0]); #3 xs
					#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
					me[key].set("clip", clip_rect);
					me[key].set("clip-frame", canvas.Element.PARENT);
				}
			}
		}
		
		me.AI_horizon_trans = me["AI_horizon"].createTransform();
		me.AI_horizon_rot = me["AI_horizon"].createTransform();
		
		me.AI_horizon_ground_trans = me["AI_horizon_ground"].createTransform();
		me.AI_horizon_ground_rot = me["AI_horizon_ground"].createTransform();
		
		me.AI_horizon_sky_rot = me["AI_horizon_sky"].createTransform();
		
		me.AI_horizon_hdg_trans = me["AI_heading"].createTransform();
		me.AI_horizon_hdg_rot = me["AI_heading"].createTransform();

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return ["FMA_man","FMA_manmode","FMA_flxtemp","FMA_thrust","FMA_lvrclb","FMA_pitch","FMA_pitcharm","FMA_pitcharm2","FMA_roll","FMA_rollarm","FMA_combined","FMA_ctr_msg","FMA_catmode","FMA_cattype","FMA_nodh","FMA_dh","FMA_dhn","FMA_ap","FMA_fd",
		"FMA_athr","FMA_man_box","FMA_flx_box","FMA_thrust_box","FMA_pitch_box","FMA_pitcharm_box","FMA_roll_box","FMA_rollarm_box","FMA_combined_box","FMA_catmode_box","FMA_cattype_box","FMA_cat_box","FMA_dh_box","FMA_ap_box","FMA_fd_box","FMA_athr_box",
		"FMA_Middle1","FMA_Middle2","ASI_max","ASI_scale","ASI_target","ASI_mach","ASI_mach_decimal","ASI_ten_sec","ASI_digit_UP","ASI_digit_DN","ASI_decimal_UP","ASI_decimal_DN","ASI_index","ASI_error","ASI_group","ASI_frame","AI_center","AI_bank","AI_bank_lim",
		"AI_slipskid","AI_horizon","AI_horizon_ground","AI_horizon_sky","AI_stick","AI_stick_pos","AI_heading","AI_agl_g","AI_agl","AI_error","AI_group","FD_roll","FD_pitch","ALT_scale","ALT_target","ALT_target_digit","ALT_one","ALT_two","ALT_three","ALT_four",
		"ALT_five","ALT_digits","ALT_tens","ALT_digit_UP","ALT_digit_DN","ALT_error","ALT_group","ALT_group2","ALT_frame","VS_pointer","VS_box","VS_digit","VS_error","VS_group","QNH","QNH_setting","QNH_std","QNH_box","LOC_pointer","LOC_scale","GS_scale",
		"GS_pointer","CRS_pointer","HDG_target","HDG_scale","HDG_one","HDG_two","HDG_three","HDG_four","HDG_five","HDG_six","HDG_seven","HDG_digit_L","HDG_digit_R","HDG_error","HDG_group","HDG_frame","TRK_pointer"];
	},
	update: func() {
		elapsedtime = getprop("/sim/time/elapsed-sec");
		if (getprop("/systems/electrical/bus/ac1") >= 110 or getprop("/systems/electrical/bus/ac2") >= 110) {
			if (getprop("/systems/acconfig/autoconfig-running") != 1 and getprop("/instrumentation/du/du1-test") != 1) {
				setprop("/instrumentation/du/du1-test", 1);
				setprop("/instrumentation/du/du1-test-time", getprop("/sim/time/elapsed-sec"));
			} else if (getprop("/systems/acconfig/autoconfig-running") == 1 and getprop("/instrumentation/du/du1-test") != 1) {
				setprop("/instrumentation/du/du1-test", 1);
				setprop("/instrumentation/du/du1-test-time", getprop("/sim/time/elapsed-sec") - 35);
			}
		} else {
			setprop("/instrumentation/du/du1-test", 0);
		}
		if (getprop("/systems/electrical/bus/ac1") >= 110 and getprop("/systems/electrical/bus/ac2") >= 110) {
			if (getprop("/systems/acconfig/autoconfig-running") != 1 and getprop("/instrumentation/du/du6-test") != 1) {
				setprop("/instrumentation/du/du6-test", 1);
				setprop("/instrumentation/du/du6-test-time", getprop("/sim/time/elapsed-sec"));
			} else if (getprop("/systems/acconfig/autoconfig-running") == 1 and getprop("/instrumentation/du/du6-test") != 1) {
				setprop("/instrumentation/du/du6-test", 1);
				setprop("/instrumentation/du/du6-test-time", getprop("/sim/time/elapsed-sec") - 35);
			}
		} else {
			setprop("/instrumentation/du/du6-test", 0);
		}
		
		if ((getprop("/systems/electrical/bus/ac1") >= 110 or getprop("/systems/electrical/bus/ac2") >= 110) and getprop("/controls/lighting/DU/du1") > 0) {
			if (getprop("/instrumentation/du/du1-test-time") + 39.5 >= elapsedtime and getprop("/modes/cpt-du-xfr") != 1) {
				PFD_1.page.hide();
				PFD_1_test.page.show();
			} else if (getprop("/instrumentation/du/du2-test-time") + 38.5 >= elapsedtime and getprop("/modes/cpt-du-xfr") == 1) {
				PFD_1.page.hide();
				PFD_1_test.page.show();
			} else {
				PFD_1_test.page.hide();
				PFD_1.page.show();
				PFD_1.update();
			}
		} else {
			PFD_1_test.page.hide();
			PFD_1.page.hide();
		}
		if (getprop("/systems/electrical/bus/ac1") >= 110 and getprop("/systems/electrical/ac1-src") != "RAT" and getprop("/systems/electrical/bus/ac2") >= 110 and getprop("/systems/electrical/ac2-src") != "RAT" and getprop("/controls/lighting/DU/du6") > 0) {
			if (getprop("/instrumentation/du/du6-test-time") + 39.5 >= elapsedtime and getprop("/modes/fo-du-xfr") != 1) {
				PFD_2.page.hide();
				PFD_2_test.page.show();
			} else if (getprop("/instrumentation/du/du5-test-time") + 38.5 >= elapsedtime and getprop("/modes/fo-du-xfr") == 1) {
				PFD_2.page.hide();
				PFD_2_test.page.show();
			} else {
				PFD_2_test.page.hide();
				PFD_2.page.show();
				PFD_2.update();
			}
		} else {
			PFD_2_test.page.hide();
			PFD_2.page.hide();
		}
	},
	updateCommon: func () {
		state1 = getprop("/systems/thrust/state1");
		state2 = getprop("/systems/thrust/state2");
		ap1 = getprop("/it-autoflight/output/ap1");
		ap2 = getprop("/it-autoflight/output/ap2");
		fd1 = getprop("/it-autoflight/output/fd1");
		fd2 = getprop("/it-autoflight/output/fd2");
		athr = getprop("/it-autoflight/output/athr");
		throttle_mode = getprop("/modes/pfd/fma/throttle-mode");
		pitch_mode = getprop("/modes/pfd/fma/pitch-mode");
		pitch_mode_armed = getprop("/modes/pfd/fma/pitch-mode-armed");
		pitch_mode2_armed = getprop("/modes/pfd/fma/pitch-mode2-armed");
		roll_mode = getprop("/modes/pfd/fma/roll-mode");
		roll_mode_armed = getprop("/modes/pfd/fma/roll-mode-armed");
		thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
		thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
		pitch = getprop("/orientation/pitch-deg");
		roll = getprop("/orientation/roll-deg");
		wow1 = getprop("/gear/gear[1]/wow");
		wow2 = getprop("/gear/gear[2]/wow");
		
		# FMA MAN TOGA MCT FLX THR
		if (athr == 1 and (state1 == "TOGA" or state1 == "MCT" or state1 == "MAN THR" or state2 == "TOGA" or state2 == "MCT" or state2 == "MAN THR")) {
			me["FMA_man"].show();
			me["FMA_manmode"].show();
			if (state1 == "TOGA" or state2 == "TOGA") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("TOGA");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			} else if ((state1 == "MCT" or state2 == "MCT") and getprop("/controls/engines/thrust-limit") != "FLX") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("MCT");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1 == "MCT" or state2 == "MCT") and getprop("/controls/engines/thrust-limit") == "FLX") {
				me["FMA_flxtemp"].setText(sprintf("%s", "+" ~ getprop("/FMGC/internal/flex")));
				me["FMA_man_box"].hide();
				me["FMA_flx_box"].show();
				me["FMA_flxtemp"].show();
				me["FMA_manmode"].setText("FLX            ");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			}
		} else {
			me["FMA_man"].hide();
			me["FMA_manmode"].hide();
			me["FMA_man_box"].hide();
			me["FMA_flx_box"].hide();
			me["FMA_flxtemp"].hide();
		}
		
		if (athr == 1 and getprop("/systems/thrust/lvrclb") == 1) {
			me["FMA_lvrclb"].show();
		} else {
			me["FMA_lvrclb"].hide();
		}
	
		# FMA A/THR
		if (athr == 1 and ((state1 == "MAN" or state1 == "CL") and (state2 == "MAN" or state2 == "CL"))) {
			me["FMA_thrust"].show();
			if (getprop("/modes/pfd/fma/throttle-mode-box") == 1 and throttle_mode != " ") {
				me["FMA_thrust_box"].show();
			} else {
				me["FMA_thrust_box"].hide();
			}
		} else {
			me["FMA_thrust"].hide();
			me["FMA_thrust_box"].hide();
		}
		
		me["FMA_thrust"].setText(sprintf("%s", throttle_mode));
		
		# FMA Pitch Roll Common
		me["FMA_combined"].setText(sprintf("%s", pitch_mode));
		
		if (pitch_mode == "LAND" or pitch_mode == "FLARE" or pitch_mode == "ROLL OUT") {
			me["FMA_pitch"].hide();
			me["FMA_roll"].hide();
			me["FMA_pitch_box"].hide();
			me["FMA_roll_box"].hide();
			me["FMA_pitcharm_box"].hide();
			me["FMA_rollarm_box"].hide();
			me["FMA_Middle1"].hide();
			me["FMA_Middle2"].hide();
			if (getprop("/it-fbw/law") == 2) {
				me["FMA_ctr_msg"].setText("USE MAN PITCH TRIM");
				me["FMA_ctr_msg"].setColor(0.7333,0.3803,0);
				me["FMA_ctr_msg"].show();
			} else if (getprop("/it-fbw/law") == 3) {
				me["FMA_ctr_msg"].setText("MAN PITCH TRIM ONLY");
				me["FMA_ctr_msg"].setColor(1,0,0);
				me["FMA_ctr_msg"].show();
			} else {
				me["FMA_ctr_msg"].hide();
			}
			me["FMA_combined"].show();
			if (getprop("/modes/pfd/fma/pitch-mode-box") == 1 and pitch_mode != " ") {
				me["FMA_combined_box"].show();
			} else {
				me["FMA_combined_box"].hide();
			}
		} else {
			me["FMA_combined"].hide();
			me["FMA_combined_box"].hide();
			if (getprop("/it-fbw/law") == 2) {
				me["FMA_ctr_msg"].setText("USE MAN PITCH TRIM");
				me["FMA_ctr_msg"].setColor(0.7333,0.3803,0);
				me["FMA_Middle1"].hide();
				me["FMA_Middle2"].show();
				me["FMA_ctr_msg"].show();
			} else if (getprop("/it-fbw/law") == 3) {
				me["FMA_ctr_msg"].setText("MAN PITCH TRIM ONLY");
				me["FMA_ctr_msg"].setColor(1,0,0);
				me["FMA_Middle1"].hide();
				me["FMA_Middle2"].show();
				me["FMA_ctr_msg"].show();
			} else {
				me["FMA_ctr_msg"].hide();
				me["FMA_Middle1"].show();
				me["FMA_Middle2"].hide();
			}
			
			if (ap1 or ap2 or fd1 or fd2) {
				me["FMA_pitch"].show();
				me["FMA_roll"].show();
			} else {
				me["FMA_pitch"].hide();
				me["FMA_roll"].hide();
			}
			if (getprop("/modes/pfd/fma/pitch-mode-box") == 1 and pitch_mode != " " and (ap1 or ap2 or fd1 or fd2)) {
				me["FMA_pitch_box"].show();
			} else {
				me["FMA_pitch_box"].hide();
			}
			if (pitch_mode_armed == " " and pitch_mode2_armed == " ") {
				me["FMA_pitcharm_box"].hide();
			} else {
				if ((getprop("/modes/pfd/fma/pitch-mode-armed-box") == 1 or getprop("/modes/pfd/fma/pitch-mode2-armed-box") == 1) and (ap1 or ap2 or fd1 or fd2)) {
					me["FMA_pitcharm_box"].show();
				} else {
					me["FMA_pitcharm_box"].hide();
				}
			}
			if (getprop("/modes/pfd/fma/roll-mode-box") == 1 and roll_mode != " " and (ap1 or ap2 or fd1 or fd2)) {
				me["FMA_roll_box"].show();
			} else {
				me["FMA_roll_box"].hide();
			}
			if (getprop("/modes/pfd/fma/roll-mode-armed-box") == 1 and roll_mode_armed != " " and (ap1 or ap2 or fd1 or fd2)) {
				me["FMA_rollarm_box"].show();
			} else {
				me["FMA_rollarm_box"].hide();
			}
		}
		
		if (ap1 or ap2 or fd1 or fd2) {
			me["FMA_pitcharm"].show();
			me["FMA_pitcharm2"].show();
			me["FMA_rollarm"].show();
		} else {
			me["FMA_pitcharm"].hide();
			me["FMA_pitcharm2"].hide();
			me["FMA_rollarm"].hide();
		}
		
		# FMA Pitch
		me["FMA_pitch"].setText(sprintf("%s", pitch_mode));
		me["FMA_pitcharm"].setText(sprintf("%s", pitch_mode_armed));
		me["FMA_pitcharm2"].setText(sprintf("%s", pitch_mode2_armed));
		
		# FMA Roll
		me["FMA_roll"].setText(sprintf("%s", roll_mode));
		me["FMA_rollarm"].setText(sprintf("%s", roll_mode_armed));
		
		# FMA CAT DH
		me["FMA_catmode"].hide();
		me["FMA_cattype"].hide();
		me["FMA_catmode_box"].hide();
		me["FMA_cattype_box"].hide();
		me["FMA_cat_box"].hide();
		me["FMA_nodh"].hide();
		me["FMA_dh_box"].hide();
		
		# FMA AP FD ATHR
		me["FMA_ap"].setText(sprintf("%s", getprop("/modes/pfd/fma/ap-mode")));
		me["FMA_fd"].setText(sprintf("%s", getprop("/modes/pfd/fma/fd-mode")));
		me["FMA_athr"].setText(sprintf("%s", getprop("/modes/pfd/fma/at-mode")));
		
		if ((state1 == "MAN" or state1 == "CL") and (state2 == "MAN" or state2 == "CL")) {
			me["FMA_athr"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["FMA_athr"].setColor(0.0862,0.5176,0.6470);
		}
		
		if (getprop("/modes/pfd/fma/ap-mode-box") == 1 and getprop("/modes/pfd/fma/ap-mode") != " ") {
			me["FMA_ap_box"].show();
		} else {
			me["FMA_ap_box"].hide();
		}
		
		if (getprop("/modes/pfd/fma/fd-mode-box") == 1 and getprop("/modes/pfd/fma/fd-mode") != " ") {
			me["FMA_fd_box"].show();
		} else {
			me["FMA_fd_box"].hide();
		}
		
		if (getprop("/modes/pfd/fma/athr-mode-box") == 1 and getprop("/modes/pfd/fma/at-mode") != " ") {
			me["FMA_athr_box"].show();
		} else {
			me["FMA_athr_box"].hide();
		}
		
		# Airspeed
		# Subtract 30, since the scale starts at 30, but don"t allow less than 0, or more than 420 situations
		if (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") <= 30) {
			ASI = 0;
		} else if (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") >= 420) {
			ASI = 390;
		} else {
			ASI = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") - 30;
		}
		
		if (getprop("/FMGC/internal/maxspeed") <= 30) {
			ASImax = 0 - ASI;
		} else if (getprop("/FMGC/internal/maxspeed") >= 420) {
			ASImax = 390 - ASI;
		} else {
			ASImax = getprop("/FMGC/internal/maxspeed") - 30 - ASI;
		}
		
		me["ASI_scale"].setTranslation(0, ASI * 6.6);
		me["ASI_max"].setTranslation(0, ASImax * -6.6);
		
		if (getprop("/instrumentation/airspeed-indicator/indicated-mach") >= 0.5) {
			me["ASI_mach_decimal"].show();
			me["ASI_mach"].show();
		} else {
			me["ASI_mach_decimal"].hide();
			me["ASI_mach"].hide();
		}
		
		if (getprop("/instrumentation/airspeed-indicator/indicated-mach") >= 0.999) {
			me["ASI_mach"].setText("999");
		} else {
			me["ASI_mach"].setText(sprintf("%3.0f", getprop("/instrumentation/airspeed-indicator/indicated-mach") * 1000));
		}
		
		if (getprop("/it-autoflight/input/spd-managed") == 1) {
			me["ASI_target"].setColor(0.6901,0.3333,0.7450);
			me["ASI_digit_UP"].setColor(0.6901,0.3333,0.7450);
			me["ASI_decimal_UP"].setColor(0.6901,0.3333,0.7450);
			me["ASI_digit_DN"].setColor(0.6901,0.3333,0.7450);
			me["ASI_decimal_DN"].setColor(0.6901,0.3333,0.7450);
		} else {
			me["ASI_target"].setColor(0.0862,0.5176,0.6470);
			me["ASI_digit_UP"].setColor(0.0862,0.5176,0.6470);
			me["ASI_decimal_UP"].setColor(0.0862,0.5176,0.6470);
			me["ASI_digit_DN"].setColor(0.0862,0.5176,0.6470);
			me["ASI_decimal_DN"].setColor(0.0862,0.5176,0.6470);
		}
		
		if (getprop("/FMGC/internal/target-ias-pfd") <= 30) {
			ASItrgt = 0 - ASI;
		} else if (getprop("/FMGC/internal/target-ias-pfd") >= 420) {
			ASItrgt = 390 - ASI;
		} else {
			ASItrgt = getprop("/FMGC/internal/target-ias-pfd") - 30 - ASI;
		}
		
		ASItrgtdiff = getprop("/FMGC/internal/target-ias-pfd") - getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
		
		if (ASItrgtdiff >= -42 and ASItrgtdiff <= 42) {
			me["ASI_target"].setTranslation(0, ASItrgt * -6.6);
			me["ASI_digit_UP"].hide();
			me["ASI_decimal_UP"].hide();
			me["ASI_digit_DN"].hide();
			me["ASI_decimal_DN"].hide();
			me["ASI_target"].show();
		} else if (ASItrgtdiff < -42) {
			if (getprop("/it-autoflight/input/kts-mach") == 1) {
				me["ASI_digit_DN"].setText(sprintf("%3.0f", getprop("/it-autoflight/input/spd-mach") * 1000));
				me["ASI_decimal_UP"].hide();
				me["ASI_decimal_DN"].show();
			} else {
				me["ASI_digit_DN"].setText(sprintf("%3.0f", getprop("/it-autoflight/input/spd-kts")));
				me["ASI_decimal_UP"].hide();
				me["ASI_decimal_DN"].hide();
			}
			me["ASI_digit_DN"].show();
			me["ASI_digit_UP"].hide();
			me["ASI_target"].hide();
		} else if (ASItrgtdiff > 42) {
			if (getprop("/it-autoflight/input/kts-mach") == 1) {
				me["ASI_digit_UP"].setText(sprintf("%3.0f", getprop("/it-autoflight/input/spd-mach") * 1000));
				me["ASI_decimal_UP"].show();
				me["ASI_decimal_DN"].hide();
			} else {
				me["ASI_digit_UP"].setText(sprintf("%3.0f", getprop("/it-autoflight/input/spd-kts")));
				me["ASI_decimal_UP"].hide();
				me["ASI_decimal_DN"].hide();
			}
			me["ASI_digit_UP"].show();
			me["ASI_digit_DN"].hide();
			me["ASI_target"].hide();
		}
		
		me["ASI_ten_sec"].hide();
		
		# Attitude Indicator
		pitch = getprop("/orientation/pitch-deg") or 0;
		roll =  getprop("/orientation/roll-deg") or 0;
		
		me.AI_horizon_trans.setTranslation(0, pitch * 11.825);
		me.AI_horizon_rot.setRotation(-roll * D2R, me["AI_center"].getCenter());
		me.AI_horizon_ground_trans.setTranslation(0, getprop("/instrumentation/pfd/horizon-ground") * 11.825);
		me.AI_horizon_ground_rot.setRotation(-roll * D2R, me["AI_center"].getCenter());
		me.AI_horizon_sky_rot.setRotation(-roll * D2R, me["AI_center"].getCenter());
		
		me["AI_slipskid"].setTranslation(math.clamp(getprop("/instrumentation/slip-skid-ball/indicated-slip-skid"), -7, 7) * -15, 0);
		me["AI_bank"].setRotation(-roll * D2R);
		
		if (getprop("/it-fbw/law") == 0) {
			me["AI_bank_lim"].show();
		} else {
			me["AI_bank_lim"].hide();
		}
		
		if (getprop("/it-autoflight/fd/roll-bar") != nil) {
			me["FD_roll"].setTranslation((getprop("/it-autoflight/fd/roll-bar")) * 2.2, 0);
		}
		if (getprop("/it-autoflight/fd/pitch-bar") != nil) {
			me["FD_pitch"].setTranslation(0, -(getprop("/it-autoflight/fd/pitch-bar")) * 3.8);
		}
		
		me["AI_agl"].setText(sprintf("%s", math.round(getprop("/position/gear-agl-ft"))));
		
		if (getprop("/position/gear-agl-ft") <= getprop("/instrumentation/mk-viii/inputs/arinc429/decision-height")) {
			me["AI_agl"].setColor(0.7333,0.3803,0);
		} else {
			me["AI_agl"].setColor(0.0509,0.7529,0.2941);
		}
		
		if (getprop("/position/gear-agl-ft") <= 2500) {
			me["AI_agl"].show();
		} else {
			me["AI_agl"].hide();
		}
		
		me["AI_agl_g"].setRotation(-roll * D2R);
		
		if ((wow1 or wow2) and getprop("/FMGC/status/phase") != 0 and getprop("/FMGC/status/phase") != 1) {
			me["AI_stick"].show();
			me["AI_stick_pos"].show();
		} else if ((wow1 or wow2) and (getprop("/FMGC/status/phase") == 0 or getprop("/FMGC/status/phase") == 1) and (getprop("/engines/engine[0]/state") == 3 or getprop("/engines/engine[1]/state") == 3)) {
			me["AI_stick"].show();
			me["AI_stick_pos"].show();
		} else {
			me["AI_stick"].hide();
			me["AI_stick_pos"].hide();
		}
		
		me["AI_stick_pos"].setTranslation(getprop("/controls/flight/aileron-input-fast") * 196.8, getprop("/controls/flight/elevator-input-fast") * 151.5);
		
		# Altitude
		me.altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		me.altOffset = me.altitude / 500 - int(me.altitude / 500);
		me.middleAltText = roundaboutAlt(me.altitude / 100);
		me.middleAltOffset = nil;
		if (me.altOffset > 0.5) {
			me.middleAltOffset = -(me.altOffset - 1) * 243.3424;
		} else {
			me.middleAltOffset = -me.altOffset * 243.3424;
		}
		me["ALT_scale"].setTranslation(0, -me.middleAltOffset);
		me["ALT_scale"].update();
		me["ALT_five"].setText(sprintf("%03d", me.middleAltText+10));
		me["ALT_four"].setText(sprintf("%03d", me.middleAltText+5));
		me["ALT_three"].setText(sprintf("%03d", me.middleAltText));
		me["ALT_two"].setText(sprintf("%03d", me.middleAltText-5));
		me["ALT_one"].setText(sprintf("%03d", me.middleAltText-10));
		
		me["ALT_digits"].setText(sprintf("%s", getprop("/instrumentation/altimeter/indicated-altitude-ft-pfd")));
		altTens = num(right(sprintf("%02d", getprop("/instrumentation/altimeter/indicated-altitude-ft")), 2));
		me["ALT_tens"].setTranslation(0, altTens * 1.392);
		
		if (getprop("/instrumentation/pfd/alt-diff") >= -565 and getprop("/instrumentation/pfd/alt-diff") <= 565) {
			me["ALT_target"].setTranslation(0, (getprop("/instrumentation/pfd/alt-diff") / 100) * -48.66856);
			me["ALT_target_digit"].setText(sprintf("%03d", math.round(getprop("/it-autoflight/internal/alt") / 100)));
			me["ALT_digit_UP"].hide();
			me["ALT_digit_DN"].hide();
			me["ALT_target"].show();
		} else if (getprop("/instrumentation/pfd/alt-diff") < -565) {
			if (getprop("/modes/altimeter/std") == 1) {
				if (getprop("/it-autoflight/internal/alt") < 10000) {
					me["ALT_digit_DN"].setText(sprintf("%s", "FL   " ~ getprop("/it-autoflight/internal/alt") / 100));
				} else {
					me["ALT_digit_DN"].setText(sprintf("%s", "FL " ~ getprop("/it-autoflight/internal/alt") / 100));
				}
			} else {
				me["ALT_digit_DN"].setText(sprintf("%5.0f", getprop("/it-autoflight/internal/alt")));
			}
			me["ALT_digit_DN"].show();
			me["ALT_digit_UP"].hide();
			me["ALT_target"].hide();
		} else if (getprop("/instrumentation/pfd/alt-diff") > 565) {
			if (getprop("/modes/altimeter/std") == 1) {
				if (getprop("/it-autoflight/internal/alt") < 10000) {
					me["ALT_digit_UP"].setText(sprintf("%s", "FL   " ~ getprop("/it-autoflight/internal/alt") / 100));
				} else {
					me["ALT_digit_UP"].setText(sprintf("%s", "FL " ~ getprop("/it-autoflight/internal/alt") / 100));
				}
			} else {
				me["ALT_digit_UP"].setText(sprintf("%5.0f", getprop("/it-autoflight/internal/alt")));
			}
			me["ALT_digit_UP"].show();
			me["ALT_digit_DN"].hide();
			me["ALT_target"].hide();
		}
		
		# QNH
		if (getprop("/modes/altimeter/std") == 1) {
			me["QNH"].hide();
			me["QNH_setting"].hide();
			me["QNH_std"].show();
			me["QNH_box"].show();
		} else if (getprop("/modes/altimeter/inhg") == 0) {
			me["QNH_setting"].setText(sprintf("%4.0f", getprop("/instrumentation/altimeter/setting-hpa")));
			me["QNH"].show();
			me["QNH_setting"].show();
			me["QNH_std"].hide();
			me["QNH_box"].hide();
		} else if (getprop("/modes/altimeter/inhg") == 1) {
			me["QNH_setting"].setText(sprintf("%2.2f", getprop("/instrumentation/altimeter/setting-inhg")));
			me["QNH"].show();
			me["QNH_setting"].show();
			me["QNH_std"].hide();
			me["QNH_box"].hide();
		}
		
		# Vertical Speed
		me["VS_pointer"].setRotation(getprop("/instrumentation/pfd/vs-needle") * D2R);
		
		me["VS_box"].setTranslation(0, getprop("/instrumentation/pfd/vs-digit-trans"));
		
		if (getprop("/it-autoflight/internal/vert-speed-fpm-pfd") < 2) {
			me["VS_box"].hide();
		} else {
			me["VS_box"].show();
		}
		
		if (getprop("/it-autoflight/internal/vert-speed-fpm-pfd") < 10) {
			me["VS_digit"].setText(sprintf("%02d", "0" ~ getprop("/it-autoflight/internal/vert-speed-fpm-pfd")));
		} else {
			me["VS_digit"].setText(sprintf("%02d", getprop("/it-autoflight/internal/vert-speed-fpm-pfd")));
		}
		
		# ILS		
		me["LOC_pointer"].setTranslation(getprop("/instrumentation/nav[0]/heading-needle-deflection-norm") * 197, 0);
		
		me["GS_pointer"].setTranslation(0, getprop("/instrumentation/nav[0]/gs-needle-deflection-norm") * -197);
		
		# Heading
		me.heading = getprop("/instrumentation/pfd/heading-scale");
		me.headOffset = me.heading / 10 - int(me.heading / 10);
		me.middleText = roundabout(me.heading / 10);
		me.middleOffset = nil;
		if(me.middleText == 36) {
			me.middleText = 0;
		}
		me.leftText1 = me.middleText == 0?35:me.middleText - 1;
		me.rightText1 = me.middleText == 35?0:me.middleText + 1;
		me.leftText2 = me.leftText1 == 0?35:me.leftText1 - 1;
		me.rightText2 = me.rightText1 == 35?0:me.rightText1 + 1;
		me.leftText3 = me.leftText2 == 0?35:me.leftText2 - 1;
		me.rightText3 = me.rightText2 == 35?0:me.rightText2 + 1;
		if (me.headOffset > 0.5) {
			me.middleOffset = -(me.headOffset - 1) * 98.5416;
		} else {
			me.middleOffset = -me.headOffset * 98.5416;
		}
		me["HDG_scale"].setTranslation(me.middleOffset, 0);
		me["HDG_scale"].update();
		me["HDG_four"].setText(sprintf("%d", me.middleText));
		me["HDG_five"].setText(sprintf("%d", me.rightText1));
		me["HDG_three"].setText(sprintf("%d", me.leftText1));
		me["HDG_six"].setText(sprintf("%d", me.rightText2));
		me["HDG_two"].setText(sprintf("%d", me.leftText2));
		me["HDG_seven"].setText(sprintf("%d", me.rightText3));
		me["HDG_one"].setText(sprintf("%d", me.leftText3));
		
		me["HDG_four"].setFontSize(fontSizeHDG(me.middleText), 1);
		me["HDG_five"].setFontSize(fontSizeHDG(me.rightText1), 1);
		me["HDG_three"].setFontSize(fontSizeHDG(me.leftText1), 1);
		me["HDG_six"].setFontSize(fontSizeHDG(me.rightText2), 1);
		me["HDG_two"].setFontSize(fontSizeHDG(me.leftText2), 1);
		me["HDG_seven"].setFontSize(fontSizeHDG(me.rightText3), 1);
		me["HDG_one"].setFontSize(fontSizeHDG(me.leftText3), 1);
		
		if (getprop("/it-autoflight/custom/show-hdg") == 1 and getprop("/instrumentation/pfd/hdg-diff") >= -23.62 and getprop("/instrumentation/pfd/hdg-diff") <= 23.62) {
			me["HDG_target"].setTranslation((getprop("/instrumentation/pfd/hdg-diff") / 10) * 98.5416, 0);
			me["HDG_digit_L"].hide();
			me["HDG_digit_R"].hide();
			me["HDG_target"].show();
		} else if (getprop("/it-autoflight/custom/show-hdg") == 1 and getprop("/instrumentation/pfd/hdg-diff") < -23.62 and getprop("/instrumentation/pfd/hdg-diff") >= -180) {
			me["HDG_digit_L"].setText(sprintf("%3.0f", getprop("/it-autoflight/input/hdg")));
			me["HDG_digit_L"].show();
			me["HDG_digit_R"].hide();
			me["HDG_target"].hide();
		} else if (getprop("/it-autoflight/custom/show-hdg") == 1 and getprop("/instrumentation/pfd/hdg-diff") > 23.62 and getprop("/instrumentation/pfd/hdg-diff") <= 180) {
			me["HDG_digit_R"].setText(sprintf("%3.0f", getprop("/it-autoflight/input/hdg")));
			me["HDG_digit_R"].show();
			me["HDG_digit_L"].hide();
			me["HDG_target"].hide();
		} else {
			me["HDG_digit_L"].hide();
			me["HDG_digit_R"].hide();
			me["HDG_target"].hide();
		}
		
		me["TRK_pointer"].setTranslation((getprop("/instrumentation/pfd/track-hdg-diff") / 10) * 98.5416, 0);
		
		me["CRS_pointer"].hide();
		
		# AI HDG
		me.AI_horizon_hdg_trans.setTranslation(me.middleOffset, getprop("/instrumentation/pfd/horizon-pitch") * 11.825);
		me.AI_horizon_hdg_rot.setRotation(-roll * D2R, me["AI_center"].getCenter());
		me["AI_heading"].update();
	},
};

var canvas_PFD_1 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_1, canvas_PFD_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		fd1 = getprop("/it-autoflight/output/fd1");
		fd2 = getprop("/it-autoflight/output/fd2");
		pitch_mode = getprop("/modes/pfd/fma/pitch-mode");
		roll_mode = getprop("/modes/pfd/fma/roll-mode");
		pitch = getprop("/orientation/pitch-deg");
		roll = getprop("/orientation/roll-deg");
		wow1 = getprop("/gear/gear[1]/wow");
		wow2 = getprop("/gear/gear[2]/wow");
		
		# Errors
		if (getprop("/instrumentation/adirs/adr[0]/active") == 1) {
			me["ASI_group"].show();
			me["ALT_group"].show();
			me["ALT_group2"].show();
			me["ALT_scale"].show();
			me["VS_group"].show();
			me["ASI_error"].hide();
			me["ASI_frame"].setColor(1,1,1);
			me["ALT_error"].hide();
			me["ALT_frame"].setColor(1,1,1);
			me["VS_error"].hide();
		} else {
			me["ASI_error"].show();
			me["ASI_frame"].setColor(1,0,0);
			me["ALT_error"].show();
			me["ALT_frame"].setColor(1,0,0);
			me["VS_error"].show();
			me["ASI_group"].hide();
			me["ALT_group"].hide();
			me["ALT_group2"].hide();
			me["ALT_scale"].hide();
			me["VS_group"].hide();
		}
		
		if (getprop("/instrumentation/adirs/ir[0]/aligned") == 1) {
			me["AI_group"].show();
			me["HDG_group"].show();
			me["AI_error"].hide();
			me["HDG_error"].hide();
			me["HDG_frame"].setColor(1,1,1);
		} else {
			me["AI_error"].show();
			me["HDG_error"].show();
			me["HDG_frame"].setColor(1,0,0);
			me["AI_group"].hide();
			me["HDG_group"].hide();
		}
		
		# FD
		if (fd1 == 1 and ((!wow1 and !wow2 and roll_mode != " ") or roll_mode != " ") and getprop("/it-autoflight/custom/trk-fpa") == 0 and pitch < 25 and pitch > -13 and roll < 45 and roll > -45) {
			me["FD_roll"].show();
		} else {
			me["FD_roll"].hide();
		}
		
		if (fd1 == 1 and ((!wow1 and !wow2 and pitch_mode != " ") or pitch_mode != " ") and getprop("/it-autoflight/custom/trk-fpa") == 0 and pitch < 25 and pitch > -13 and roll < 45 and roll > -45) {
			me["FD_pitch"].show();
		} else {
			me["FD_pitch"].hide();
		}
		
		# ILS
		if (getprop("/modes/pfd/ILS1") == 1) {
			me["LOC_scale"].show();
			me["GS_scale"].show();
		} else {
			me["LOC_scale"].hide();
			me["GS_scale"].hide();
		}
		
		if (getprop("/modes/pfd/ILS1") == 1 and getprop("/instrumentation/nav[0]/in-range") == 1 and getprop("/instrumentation/nav[0]/nav-loc") == 1 and getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) {
			me["LOC_pointer"].show();
		} else {
			me["LOC_pointer"].hide();
		}
		if (getprop("/modes/pfd/ILS1") == 1 and getprop("/instrumentation/nav[0]/gs-in-range") == 1 and getprop("/instrumentation/nav[0]/has-gs") == 1 and getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) {
			me["GS_pointer"].show();
		} else {
			me["GS_pointer"].hide();
		}
		
		me.updateCommon();
	},
};

var canvas_PFD_2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_2, canvas_PFD_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		fd1 = getprop("/it-autoflight/output/fd1");
		fd2 = getprop("/it-autoflight/output/fd2");
		pitch_mode = getprop("/modes/pfd/fma/pitch-mode");
		roll_mode = getprop("/modes/pfd/fma/roll-mode");
		pitch = getprop("/orientation/pitch-deg");
		roll = getprop("/orientation/roll-deg");
		wow1 = getprop("/gear/gear[1]/wow");
		wow2 = getprop("/gear/gear[2]/wow");
		
		# Errors
		if (getprop("/instrumentation/adirs/adr[1]/active") == 1) {
			me["ASI_group"].show();
			me["ALT_group"].show();
			me["ALT_group2"].show();
			me["ALT_scale"].show();
			me["VS_group"].show();
			me["ASI_error"].hide();
			me["ASI_frame"].setColor(1,1,1);
			me["ALT_error"].hide();
			me["ALT_frame"].setColor(1,1,1);
			me["VS_error"].hide();
		} else {
			me["ASI_error"].show();
			me["ASI_frame"].setColor(1,0,0);
			me["ALT_error"].show();
			me["ALT_frame"].setColor(1,0,0);
			me["VS_error"].show();
			me["ASI_group"].hide();
			me["ALT_group"].hide();
			me["ALT_group2"].hide();
			me["ALT_scale"].hide();
			me["VS_group"].hide();
		}
		
		if (getprop("/instrumentation/adirs/ir[1]/aligned") == 1) {
			me["AI_group"].show();
			me["HDG_group"].show();
			me["AI_error"].hide();
			me["HDG_error"].hide();
			me["HDG_frame"].setColor(1,1,1);
		} else {
			me["AI_error"].show();
			me["HDG_error"].show();
			me["HDG_frame"].setColor(1,0,0);
			me["AI_group"].hide();
			me["HDG_group"].hide();
		}
		
		# FD
		if (fd2 == 1 and ((!wow1 and !wow2 and roll_mode != " ") or roll_mode != " ") and getprop("/it-autoflight/custom/trk-fpa") == 0 and pitch < 25 and pitch > -13 and roll < 45 and roll > -45) {
			me["FD_roll"].show();
		} else {
			me["FD_roll"].hide();
		}
		
		if (fd2 == 1 and ((!wow1 and !wow2 and pitch_mode != " ") or pitch_mode != " ") and getprop("/it-autoflight/custom/trk-fpa") == 0 and pitch < 25 and pitch > -13 and roll < 45 and roll > -45) {
			me["FD_pitch"].show();
		} else {
			me["FD_pitch"].hide();
		}
		
		# ILS
		if (getprop("/modes/pfd/ILS2") == 1) {
			me["LOC_scale"].show();
			me["GS_scale"].show();
		} else {
			me["LOC_scale"].hide();
			me["GS_scale"].hide();
		}
		
		if (getprop("/modes/pfd/ILS2") == 1 and getprop("/instrumentation/nav[0]/in-range") == 1 and getprop("/instrumentation/nav[0]/nav-loc") == 1 and getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) {
			me["LOC_pointer"].show();
		} else {
			me["LOC_pointer"].hide();
		}
		if (getprop("/modes/pfd/ILS2") == 1 and getprop("/instrumentation/nav[0]/gs-in-range") == 1 and getprop("/instrumentation/nav[0]/has-gs") == 1 and getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) {
			me["GS_pointer"].show();
		} else {
			me["GS_pointer"].hide();
		}
		
		me.updateCommon();
	},
};

var canvas_PFD_1_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_1_test]};
		m.init(canvas_group, file);

		return m;
	},
};

var canvas_PFD_2_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_2_test]};
		m.init(canvas_group, file);

		return m;
	},
};

setprop("/testing", 0); # REMOVE WHEN PFD FINISHED

setlistener("sim/signals/fdm-initialized", func {
	PFD1_display = canvas.new({
		"name": "PFD1",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	PFD2_display = canvas.new({
		"name": "PFD2",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	PFD1_display.addPlacement({"node": "pfd1.screen"});
	PFD2_display.addPlacement({"node": "pfd2.screen"});
	var group_pfd1 = PFD1_display.createGroup();
	var group_pfd1_test = PFD1_display.createGroup();
	var group_pfd2 = PFD2_display.createGroup();
	var group_pfd2_test = PFD2_display.createGroup();

	PFD_1 = canvas_PFD_1.new(group_pfd1, "Aircraft/IDG-A33X/Models/Instruments/PFD/res/pfd.svg");
	PFD_1_test = canvas_PFD_1_test.new(group_pfd1_test, "Aircraft/IDG-A33X/Models/Instruments/Common/res/du-test.svg");
	PFD_2 = canvas_PFD_2.new(group_pfd2, "Aircraft/IDG-A33X/Models/Instruments/PFD/res/pfd.svg");
	PFD_2_test = canvas_PFD_2_test.new(group_pfd2_test, "Aircraft/IDG-A33X/Models/Instruments/Common/res/du-test.svg");
	
	PFD_update.start();
});

var PFD_update = maketimer(0.05, func {
	canvas_PFD_base.update();
});

var showPFD1 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(PFD1_display);
}

var showPFD2 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(PFD2_display);
}

var roundabout = func(x) {
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x) ;
};

var roundaboutAlt = func(x) {
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x*0.2) : 5 + 5 * int(x*0.2) ;
};

var fontSizeHDG = func(input) {
	var test = input / 3;
	if (test == int(test)) {
		return 42;
	} else {
		return 32;
	}
};
