// Configure require.js and tell it where to find our modules
require.config({
    baseUrl : '.', // use this base if we don't give absolute paths
    paths : {
        knockout : '/3rdparty/knockout/knockout-3.4.0',
        knockprops : '/lib/knockprops'
    },
});
function truncP(value, precision) {
    var multiplier = Math.pow(10, precision || 0);
    return Math.trunc(value * multiplier) / multiplier;
}




require([
         // we depend on those modules
        'knockout', // lookup 'knockout' in the 'paths' attribute above,
                    // load the script and pass the resulting object as the
                    // first parameter below
        'knockprops' // load 'knockprops' in the 'paths' attribute above etc.

], function(ko) {
    // ko is now the locally available knockout extension
    // the second arg would be knockprops but that is not needed as it registers itself with knockout.utils

    ko.bindingHandlers.hidden = {
      update: function(element, valueAccessor) {
        ko.bindingHandlers.visible.update(element, function() {
          return !ko.utils.unwrapObservable(valueAccessor());
        });
      }
    };
    // this creates the websocket to FG and registers listeners for the named properites
    ko.utils.knockprops.setAliases({
      gmt : "/sim/time/gmt",
      timeWarp : "/sim/time/warp",
      // flight
      pitch : "/orientation/pitch-deg",
      roll : "/orientation/roll-deg",
      heading : "/orientation/heading-magnetic-deg",
      altitude : "/position/altitude-ft",
      latitude : "/position/latitude-deg",
      longitude : "/position/longitude-deg",
      airspeed : "/velocities/airspeed-kt",
      groundspeed : "/velocities/groundspeed-kt",
      slip : "/instrumentation/slip-skid-ball/indicated-slip-skid",
      cg : "/fdm/jsbsim/inertia/cg-x-in",
      weight : "/fdm/jsbsim/inertia/weight-lbs",
      fob_lbs : "/consumables/fuel/total-fuel-lbs",
      eg0_fuelflow : "/engines/engine/fuel-flow_actual",
      eg1_fuelflow : "/engines/engine[1]/fuel-flow_actual",
      eg0_epr : "/engines/engine/epr-actual",
      eg1_epr : "/engines/engine[1]/epr-actual",
      eg0_eprThr : "/ECAM/Upper/EPRthr",
      eg1_eprThr : "/ECAM/Upper/EPRthr[1]",
      eprYLim : "/ECAM/Upper/EPRylim",
      eg0_egt : "/engines/engine/egt-actual",
      eg1_egt : "/engines/engine[1]/egt-actual",
      eg0_n1 : "/engines/engine/n1-actual",
      eg1_n1 : "/engines/engine[1]/n1-actual",
      eg0_n2 : "/engines/engine/n2-actual",
      eg1_n2 : "/engines/engine[1]/n2-actual",
      eg0_n3 : "/engines/engine/n3-actual",
      eg1_n3 : "/engines/engine[1]/n3-actual",
      eg0_n1Thr : "/ECAM/Upper/N1thr",
      eg1_n1Thr : "/ECAM/Upper/N1thr[1]",
      n1yLim : "/ECAM/Upper/N1ylim",
      oat_degc : "/environment/temperature-degc",
      apu_load : "/systems/electrical/extra/apu-load",
      apu_volts : "/systems/electrical/extra/apu-volts",
      apu_hz : "/systems/electrical/extra/apu-hz",
      bleadapu : "/systems/pneumatic/bleedapu",
      eg0_oilpsi : "/engines/engine/oil-psi-actual",
      eg1_oilpsi : "/engines/engine[1]/oil-psi-actual",
      apu_n1 : "/ECAM/Lower/APU-N",
      apu_egt : "/ECAM/Lower/APU-EGT",
      eg0_oilqt : "/engines/engine/oil-qt-actual",
      eg1_oilqt : "/engines/engine[1]/oil-qt-actual",
      eg0_n1Valid : "/systems/fadec/eng1/n1",
      eg0_n2Valid : "/systems/fadec/eng1/n2",
      eg1_n1Valid : "/systems/fadec/eng2/n1",
      eg1_n2Valid : "/systems/fadec/eng2/n2",
      eg0_egtValid : "/systems/fadec/eng1/egt",
      eg1_egtValid : "/systems/fadec/eng2/egt",
      eg0_eprValid : "/systems/fadec/eng1/epr",
      eg1_eprValid : "/systems/fadec/eng2/epr",
      eg0_FFValid : "/systems/fadec/eng1/ff",
      eg1_FFValid : "/systems/fadec/eng2/ff",
      eg0_EGTneedle : "/ECAM/Upper/EGT[0]",
      eg1_EGTneedle : "/ECAM/Upper/EGT[1]",
      eg0_EPRneedle : "/ECAM/Upper/EPR[0]",
      eg1_EPRneedle : "/ECAM/Upper/EPR[1]",
      eg0_N1needle : "/ECAM/Upper/N1[0]",
      eg1_N1needle : "/ECAM/Upper/N1[1]",
      eg0_oilQTneedle : "/ECAM/Lower/Oil-QT[0]",
      eg1_oilQTneedle : "/ECAM/Lower/Oil-QT[1]",
      eg0_oilPSIneedle : "/ECAM/Lower/Oil-PSI[0]",
      eg1_oilPSIneedle : "/ECAM/Lower/Oil-PSI[1]",
      powered1 : "/systems/fadec/powered1",
      powered2 : "/systems/fadec/powered1",
      eng_options : "/options/eng",
      epr_limit : "/controls/engines/epr-limit",
      eprLim_mode : "/controls/engines/thrust-limit",
      eg0N1vib : "/engines/engine/vibration/n1",
      eg0N2vib : "/engines/engine/vibration/n2",
      eg0N3vib : "/engines/engine/vibration/n3",
      eg1N1vib : "/engines/engine[1]/vibration/n1",
      eg1N2vib : "/engines/engine[1]/vibration/n2",
      eg1N3vib : "/engines/engine[1]/vibration/n3"
    });

    ko.bindingHandlers.svgRotate = {
        init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            // This will be called when the binding is first applied to an element
            // Set up any initial state, event handlers, etc. here
        },
        update: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            // This will be called once when the binding is first applied to an element,
            // and again whenever the associated observable changes value.
            // Update the DOM element based on the supplied values here.
            var value = valueAccessor(),
                allBindings = allBindingsAccessor();

            var rotation = ko.utils.unwrapObservable(value);
            var originX = allBindings.originX || 0;
            var originY = allBindings.originY || 0;

            var rotateText = 'rotate(' + (rotation+90) + ', ' + originX + ', ' + originY + ')';

            element.setAttribute('transform', rotateText);
        }
    };

    ko.bindingHandlers.svgNeedle9RotateNO = {
        update: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            // This will be called once when the binding is first applied to an element,
            // and again whenever the associated observable changes value.
            // Update the DOM element based on the supplied values here.
            var value = valueAccessor(),
                allBindings = allBindingsAccessor();
            var itemTransformX = element['inkscape:transform-center-x'];
            var itemTransformY = element['inkscape:transform-center-y'];
            var itemX = element['x'].baseVal.value;
            var itemY = element['y'].baseVal.value;
            var itemHeight = element['height'].baseVal.value;
            var itemWidth = element['width'].baseVal.value;

            var rotation = ko.utils.unwrapObservable(value);


            var rotateText = 'rotate(' + (rotation+90) + ', ' + (itemX+itemWidth) + ', ' + (itemY) + ')';


            element.setAttribute('transform', rotateText);

            element.setAttribute('Note', element.x);
        }
    };
    ko.bindingHandlers.svgNeedle9Rotate = {
        update: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            // This will be called once when the binding is first applied to an element,
            // and again whenever the associated observable changes value.
            // Update the DOM element based on the supplied values here.
            var value = valueAccessor(),
                allBindings = allBindingsAccessor();
            var itemTransformX = element['inkscape:transform-center-x'];
            var itemTransformY = element['inkscape:transform-center-y'];
            var itemX = element['x'].baseVal.value;
            var itemY = element['y'].baseVal.value;
            var itemHeight = element['height'].baseVal.value;
            var itemWidth = element['width'].baseVal.value;

            var rotation = ko.utils.unwrapObservable(value);


            var rotateText = 'rotate(' + (rotation+90) + ', ' + (itemX+itemWidth+39) + ', ' + (itemY) + ')';


            element.setAttribute('transform', rotateText);
            element.setAttribute('Noter', itemTransformX);
            element.setAttribute('Noteb', element['inkscape:transform-center-x']);
        }
    };

    ko.bindingHandlers.svgSetRotation = {
        update: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            // This will be called once when the binding is first applied to an element,
            // and again whenever the associated observable changes value.
            // Update the DOM element based on the supplied values here.
            // http://wiki.flightgear.org/Canvas_Nasal_API#setRotation
            // Rotates the element around the center. The rotation is set on the first transform.
            // setRotation really just combines a rotation with two translations -> translate(-center[0], -center[1]) * rotate * translate(center[0], center[1])
            // You can also have a look in the property browser and check the bounding box (/canvas/by-index/texture[i]/[group[j]+]/path[j]/bounding-box) and use its coordinates to determine the correct center of rotation.
            var value = valueAccessor(),
                allBindings = allBindingsAccessor();
            var itemTransformX = element['inkscape:transform-center-x'];
            var itemTransformY = element['inkscape:transform-center-y'];
            var itemX = element['x'].baseVal.value;
            var itemY = element['y'].baseVal.value;
            var itemHeight = element['height'].baseVal.value;
            var itemWidth = element['width'].baseVal.value;

            var rotation = ko.utils.unwrapObservable(value);


            var rotateText = 'translate(' +(-1*itemX) + ', ' +(-1*itemY)+') rotate(' + (rotation+90) + ', ' + 0 + ', ' + 0 + ') translate(' +(itemX) + ', ' +(itemY)+ ')';


            element.setAttribute('transform', rotateText);
            element.setAttribute('Notea', itemTransformX);
            element.setAttribute('Noteb', element['inkscape:transform-center-x']);
            element.setAttribute('Notec', itemTransformX);
        }
    };
    // knockout stuff - create a ViewModel representing the data of the page
    function ViewModel(params) {
        var self = this;

        ko.utils.knockprops.makeObservablesForAllProperties( self );

        self.trunc0FobLbs = ko.pureComputed(function() {
            return truncP(self.fob_lbs(), 0);
        });

        self.trunc3epr_limit = ko.pureComputed(function() {
            return truncP(self.epr_limit(), 3);
        });


        self.trunc0Egt0 = ko.pureComputed(function() {
            return truncP(self.eg0_egt(), 0);
        });

        self.Eg0egtXX = ko.pureComputed(function() {
            if (self.eg0_egtValid() == 1) {
              return false;
            } else {
              return true;
            }
        });
        self.Eg0eprXX = ko.pureComputed(function() {
            if (self.eg0_eprValid() == 1) {
              return false;
            } else {
              return true;
            }
        });
        self.Eg1eprXX = ko.pureComputed(function() {
            if (self.eg1_eprValid() == 1) {
              return false;
            } else {
              return true;
            }
        });

        self.Eg0OilQtNeedle = ko.pureComputed(function() {
          return self.eg0_oilQTneedle();
        });
        self.Eg1OilQtNeedle = ko.pureComputed(function() {
          return self.eg1_oilQTneedle();
        });
        self.Eg0OilPSINeedle = ko.pureComputed(function() {
          return self.eg0_oilPSIneedle ();
        });
        self.Eg1OilPSINeedle = ko.pureComputed(function() {
          return self.eg1_oilPSIneedle();
        });
        self.Eg0EGTNeedle = ko.pureComputed(function() {
          return self.eg0_EGTneedle();
        });

        self.Eg1EGTNeedle = ko.pureComputed(function() {
          return self.eg1_EGTneedle();
        });

        self.Eg0EPRNeedle = ko.pureComputed(function() {
          return self.eg0_EPRneedle();
        });

        self.Eg1EPRNeedle = ko.pureComputed(function() {
          return self.eg1_EPRneedle();
        });


        self.Eg0N1Needle = ko.pureComputed(function() {
          return self.eg0_N1needle();
        });

        self.Eg1N1Needle = ko.pureComputed(function() {
          return self.eg1_N1needle();
        });


        self.Eg1egtXX = ko.pureComputed(function() {
            if (self.eg1_egtValid() == 1) {
              return false;
            } else {
              return true;
            }
        });
        self.poweredXX = ko.pureComputed(function() {
            if (self.powered1() == 1 || self.powered2() == 1 ) {
              return false;
            } else {
              return true;
            }
        });

        self.Eg0FFXX = ko.pureComputed(function() {
            if (self.eg0_FFValid() == 1) {
              return false;
            } else {
              return true;
            }
        });

        self.Eg1FFXX = ko.pureComputed(function() {
            if (self.eg1_FFValid() == 1) {
              return false;
            } else {
              return true;
            }
        });

        self.N2N3 = ko.pureComputed(function() {
          if (self.eng_options() == 'RR') {
            return true;
          } else {
            return false;
          }
        })

        self.Eg1N2XX = ko.pureComputed(function() {
            if (self.eg1_n2Valid() == 1) {
              return false;
            } else {
              return true;
            }
        });

        self.Eg1N1XX = ko.pureComputed(function() {
            if (self.eg1_n1Valid() == 1) {
              return false;
            } else {
              return true;
            }
        });

        self.Eg0N1XX = ko.pureComputed(function() {
            if (self.eg1_n1Valid() == 1) {
              return false;
            } else {
              return true;
            }
        });

        self.Eg0N2XX = ko.pureComputed(function() {
            if (self.eg1_n2Valid() == 1) {
              return false;
            } else {
              return true;
            }
        });
        
    
        self.trunc0Eg0OilQT = ko.pureComputed(function() {
            return truncP(self.eg0_oilqt(), 0);
        });

        self.oneDecEg0OilQT = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg0_oilqt()-self.trunc0Eg0OilQT())*10, 0));
        });
        
        self.trunc0Eg1OilQT = ko.pureComputed(function() {
            return truncP(self.eg1_oilqt(), 0);
        });

        self.oneDecEg1OilQT = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg1_oilqt()-self.trunc0Eg1OilQT())*10, 0));
        });
          
          
          
          
          
          
        self.trunc0oilPSI0 = ko.pureComputed(function() {
            return truncP(self.eg0_oilpsi(), 0);
        });
        
        self.trunc0oilPSI1 = ko.pureComputed(function() {
            return truncP(self.eg1_oilpsi(), 0);
        });
        
        self.trunc0Egt1 = ko.pureComputed(function() {
            return truncP(self.eg1_egt(), 0);
        });

        self.trunc3Epr0 = ko.pureComputed(function() {
          return truncP(self.eg0_epr(),3);
        })

        self.trunc3Epr1 = ko.pureComputed(function() {
          return truncP(self.eg1_epr(),3);
        })

        self.trunc0Eg0FF = ko.pureComputed(function() {
            return truncP(self.eg0_fuelflow(), 0);
        });


        self.trunc0Eg1FF = ko.pureComputed(function() {
            return truncP(self.eg1_fuelflow(), 0);
        });

        self.trunc0Eg0N1 = ko.pureComputed(function() {
            return truncP(self.eg0_n1(), 0);
        });

        self.oneDecEg0N1 = ko.pureComputed(function() {
            return truncP((self.eg0_n1()-self.trunc0Eg0N1())*10, 0);
        });

        self.trunc0Eg1N1 = ko.pureComputed(function() {
            return truncP(self.eg1_n1(), 0);
        });

        self.oneDecEg1N1 = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg1_n1()-self.trunc0Eg1N1())*10, 0));
        });

        self.trunc0Eg0N2 = ko.pureComputed(function() {
            return truncP(self.eg0_n2(), 0);
        });

        self.oneDecEg0N2 = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg0_n2()-self.trunc0Eg0N2())*10, 0));
        });

        self.trunc0Eg1N2 = ko.pureComputed(function() {
            return truncP(self.eg1_n2(), 0);
        });

        self.oneDecEg1N2 = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg1_n2()-self.trunc0Eg1N2())*10, 0));
        });

        self.oneDecEg0N3 = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg0_n3()-self.trunc0Eg0N3())*10, 0));
        });

        self.oneDecEg1N3 = ko.pureComputed(function() {
            return Math.abs(truncP((self.eg1_n3()-self.trunc0Eg1N3())*10, 0));
        });

        self.trunc0Eg0N3 = ko.pureComputed(function() {
            return truncP(self.eg0_n3(), 0);
        });

        self.oneDecEg0N1 = ko.pureComputed(function() {
            return truncP((self.eg0_n3()-self.trunc0Eg0N3())*10, 0);
        });

        self.trunc0Eg1N3 = ko.pureComputed(function() {
            return truncP(self.eg1_n3(), 0);
        });

        self.oneDecEg0N1 = ko.pureComputed(function() {
            return truncP((self.eg1_n3()-self.trunc0Eg1N3())*10, 0);
        });

        self.N21value = ko.pureComputed(function() {
          if (self.N2N3()) {
            return self.trunc0Eg0N3();
          } else {
            return self.trunc0Eg0N2();
          }
        });

        self.N22value = ko.pureComputed(function() {
          if (self.N2N3()) {
            return self.trunc0Eg1N3();
          } else {
            return self.trunc0Eg1N2();
          }
        });

        self.N21DecValue = ko.pureComputed(function() {
          if (self.N2N3()) {
            return self.oneDecEg0N3() ;
          } else {
            return self.oneDecEg0N2() ;
          }
        });

        self.N22DecValue = ko.pureComputed(function() {
          if (self.N2N3()) {
            return self.oneDecEg1N3() ;
          } else {
            return self.oneDecEg1N2() ;
          }
        });

        self.N22label = ko.pureComputed(function() {
          if (self.N2N3()) {
            return "N3" ;
          } else {
            return "N2" ;
          }
        });

        self.N21label = ko.pureComputed(function() {
          if (self.N2N3()) {
            return "N3" ;
          } else {
            return "N2" ;
          }
        });

        self.trunc0Eg0N1vib = ko.pureComputed(function() {
            return truncP(self.eg0N1vib(), 0);
        });

        self.oneDecEg0N1vib = ko.pureComputed(function() {
            return truncP((self.eg0N1vib()-self.trunc0Eg0N1vib())*10, 0);
        });

        self.trunc0Eg0N2vib = ko.pureComputed(function() {
            return truncP(self.eg0N2vib(), 0);
        });

        self.oneDecEg0N2vib = ko.pureComputed(function() {
            return truncP((self.eg0N2vib()-self.trunc0Eg0N2vib())*10, 0);
        });

        self.trunc0Eg0N3vib = ko.pureComputed(function() {
            return truncP(self.eg0N3vib(), 0);
        });

        self.oneDecEg0N3vib = ko.pureComputed(function() {
            return truncP((self.eg0N3vib()-self.trunc0Eg0N3vib())*10, 0);
        });

        self.trunc0Eg1N1vib = ko.pureComputed(function() {
            return truncP(self.eg1N1vib(), 0);
        });

        self.oneDecEg1N1vib = ko.pureComputed(function() {
            return truncP((self.eg1N1vib()-self.trunc0Eg1N1vib())*10, 0);
        });

        self.trunc0Eg1N2vib = ko.pureComputed(function() {
            return truncP(self.eg1N2vib(), 0);
        });

        self.oneDecEg1N2vib = ko.pureComputed(function() {
            return truncP((self.eg1N2vib()-self.trunc0Eg1N2vib())*10, 0);
        });

        self.trunc0Eg1N3vib = ko.pureComputed(function() {
            return truncP(self.eg1N3vib(), 0);
        });

        self.oneDecEg1N3vib = ko.pureComputed(function() {
            return truncP((self.eg1N3vib()-self.trunc0Eg1N3vib())*10, 0);
        });

    }


    // Create the ViewModel instance and tell knockout to process the data-bind
    // attributes of all elements within our wrapper-div.
    ko.applyBindings(new ViewModel(), document.getElementById('wrapper'));

    // now, every update of a registered property in flightgear gets to our browser
    // through the websocket. Knockprops delivers each change to the associated ko.observable
    // and fires the listeners of the observable. Those listeners trigger the change of the HTML DOM
    // which results in a redraw of the browser window.
});
