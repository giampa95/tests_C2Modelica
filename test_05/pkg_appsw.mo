package pkg_appsw
  "Modelica wrapper around a precompiled AUTOSAR-Classic-inspired 'App SW'
   dynamic library (see Resources/C). The DLL keeps its own global C state
   (SWC1/SWC2 interfaces + internal variables); class_appsw exposes its
   constructor/destructor/step as external C functions, sys_appsw is the
   discrete-time block built on top of class_appsw, and tb_sys_appsw is a
   testbench exercising it."

  class class_appsw
    "Modelica class wrapping the precompiled App SW DLL. Holds no data of
     its own (the DLL itself is the single, global instance - see
     Resources/C/include/appsw.h) and exists purely to group the
     constructor/destructor/step functions that talk to it."

    impure function constructor
      "One-time initialization of the App SW (forces an internal reset)."
      external "C" constructor()
        annotation(
          Library = "appsw",
          LibraryDirectory = "modelica://pkg_appsw/Resources/Build");
    end constructor;

    impure function destructor
      "One-time finalization/cleanup of the App SW."
      external "C" destructor()
        annotation(
          Library = "appsw",
          LibraryDirectory = "modelica://pkg_appsw/Resources/Build");
    end destructor;

    impure function step
      "One reactivation of the App SW."
      input Real time
        "Current simulation time. Accepted here for interface completeness
         / logging / tracing only: the underlying C doStep() is purely
         reactive to 'eventFlags' and has no need for the simulation time,
         so it is intentionally NOT forwarded to the external call below.";
      input Integer eventFlags
        "Bitmask of the discrete event(s) active at this instant: bit 0
         (value 1) = eventClockA (time-based, periodic), bit 1 (value 2) =
         eventG (event-based, save gain), bit 2 (value 4) = eventR
         (event-based, reset). More than one bit may be set at once - this
         is how two or three events occurring at the very same simulation
         instant are handled together, in a single call. Modelica has no
         unsigned integer type, so this is a plain (non-negative, by
         convention) Integer - see EventMaskType in datatypes.h.";
      input Real R_SWC1_value "Value input read by SWC1.";
      input Real R_SWC1_gain "Gain input read by SWC1.";
      output Real P_SWC1_valueGained "SWC1_value * SWC1_gain (SWC1's provided output).";
      output Real PR_SWC2_counter
        "SWC2's free-running counter, provided as a Real (its native type
         on the C side is uint8).";
      external "C" doStep(eventFlags, R_SWC1_value, R_SWC1_gain, P_SWC1_valueGained, PR_SWC2_counter)
        annotation(
          Library = "appsw",
          LibraryDirectory = "modelica://pkg_appsw/Resources/Build");
    end step;
  end class_appsw;


  block sys_appsw "Block model of the App SW. Wraps class_appsw with the event logic
         needed to drive it from a Modelica simulation."         // discrete-time signals
    // --- Data Inputs ---
    Modelica.Blocks.Interfaces.RealInput R_SWC1_value "Value input, forwarded to the App SW's R_SWC1_value on every reactivation." annotation(
      Placement(transformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, 34}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealInput R_SWC1_gain "Gain input, forwarded to the App SW's R_SWC1_gain on every reactivation." annotation(
      Placement(transformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, -34}, extent = {{-10, -10}, {10, 10}})));
    // --- Trigger / Event Inputs ---
    Modelica.Blocks.Interfaces.BooleanInput eventClockA "Rising edge requests an eventClockA reactivation (periodic clock trigger)." annotation(
      Placement(transformation(origin = {-50, 100}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    Modelica.Blocks.Interfaces.BooleanInput eventG "Rising edge requests an eventG reactivation (SWC1_SaveGain)." annotation(
      Placement(transformation(origin = {0, 100}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    Modelica.Blocks.Interfaces.BooleanInput eventR "Rising edge requests an eventR reactivation (SWC1_ResetGain, SWC2_ResetCounter)." annotation(
      Placement(transformation(origin = {50, 100}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    // --- Data Outputs ---
    discrete Modelica.Blocks.Interfaces.RealOutput P_SWC1_valueGained "SWC1's computed value*gain." annotation(
      Placement(transformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 34}, extent = {{-10, -10}, {10, 10}})));
    discrete Modelica.Blocks.Interfaces.RealOutput PR_SWC2_counter "SWC2's free-running counter (as Real)." annotation(
      Placement(transformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, -34}, extent = {{-10, -10}, {10, 10}})));
  protected
    constant Integer EVENT_CLOCKA_BIT = 1 "Must match EVENT_CLOCKA_BIT in Resources/C/include/scheduler_events.h.";
    constant Integer EVENT_G_BIT = 2 "Must match EVENT_G_BIT in Resources/C/include/scheduler_events.h.";
    constant Integer EVENT_R_BIT = 4 "Must match EVENT_R_BIT in Resources/C/include/scheduler_events.h.";
    discrete Integer eventFlags(start = 0) "Combined bitmask passed to class_appsw.step() - see EVENT_*_BIT above.";
  initial algorithm
    class_appsw.constructor();
  algorithm
// A single combined "when" over all three trigger conditions ensures
// class_appsw.step() is called exactly ONCE per event instant, even if
// two (or all three) of eventClockA/eventG/eventR coincide exactly.
    when {eventClockA, eventG, eventR} then
      eventFlags := (if edge(eventClockA) then EVENT_CLOCKA_BIT else 0) + (if edge(eventG) then EVENT_G_BIT else 0) + (if edge(eventR) then EVENT_R_BIT else 0);
      (P_SWC1_valueGained, PR_SWC2_counter) := class_appsw.step(time, eventFlags, R_SWC1_value, R_SWC1_gain);
    end when;
    when terminal() then
      class_appsw.destructor();
    end when;
    annotation(
      Icon(coordinateSystem(extent = {{-120, -120}, {120, 120}}), graphics = {Rectangle(extent = {{-100, -100}, {100, 100}}), 
      Text(extent = {{-90, -20}, {90, 10}}, textString = "appsw"),
      Text(extent = {{-90, -65}, {90, -35}}, textString = "App SW (DLL)")}));
      
  end sys_appsw;


  model tb_sys_appsw
    "Testbench for sys_appsw: exercises value/gain inputs and all three event
     requests (eventClockA, eventG, eventR)."

    sys_appsw sys_appsw_01
      annotation(Placement(transformation(origin = {20, -20}, extent = {{-72, -72}, {72, 72}})));

    Modelica.Blocks.Sources.Ramp value_source(height = 9, duration = 8, offset = 1, startTime = 0)
      "SWC1's value input: ramps from 1 to 10 over the simulation."
      annotation(Placement(transformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}})));

    Modelica.Blocks.Sources.Step gain_source(height = 2, offset = 1, startTime = 3.2)
      "SWC1's gain input: 1 before t=3s, 3 afterwards (only takes effect
       once latched by the next eventG)."
      annotation(Placement(transformation(origin = {-110, -40}, extent = {{-10, -10}, {10, 10}})));
  
    Modelica.Blocks.Sources.BooleanPulse eventClockA_source(period = 0.5, startTime = 0.5, width = 50) 
      annotation(Placement(transformation(origin = {-10, 70}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  
    Modelica.Blocks.Sources.BooleanPulse eventG_source(period = 1.5, width = 5, startTime = 0.2)
      annotation(Placement(transformation(origin = {20, 70}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));

    Modelica.Blocks.Sources.BooleanStep eventR_source(startTime = 6.05)
      annotation(Placement(transformation(origin = {50, 70}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Discrete.Sampler sampler1(samplePeriod = 0.5) annotation(
      Placement(transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Discrete.Sampler sampler2(samplePeriod = 0.5) annotation(
      Placement(transformation(origin = {-70, -40}, extent = {{-10, -10}, {10, 10}})));
  equation
    connect(value_source.y, sampler1.u) annotation(
      Line(points = {{-98, 0}, {-82, 0}}, color = {0, 0, 127}));
    connect(sampler2.u, gain_source.y) annotation(
      Line(points = {{-82, -40}, {-98, -40}}, color = {0, 0, 127}));
    connect(sys_appsw_01.R_SWC1_gain, sampler2.y) annotation(
      Line(points = {{-40, -40}, {-58, -40}}, color = {0, 0, 127}));
    connect(sampler1.y, sys_appsw_01.R_SWC1_value) annotation(
      Line(points = {{-58, 0}, {-40, 0}}, color = {0, 0, 127}));
    connect(eventClockA_source.y, sys_appsw_01.eventClockA) annotation(
      Line(points = {{-10, 60}, {-10, 40}}, color = {255, 0, 255}));
    connect(eventG_source.y, sys_appsw_01.eventG) annotation(
      Line(points = {{20, 60}, {20, 40}}, color = {255, 0, 255}));
    connect(eventR_source.y, sys_appsw_01.eventR) annotation(
      Line(points = {{50, 59}, {50, 40}}, color = {255, 0, 255}));
    annotation(
      experiment(StartTime = 0, StopTime = 10, Tolerance = 1e-06, Interval = 0.01),
      Diagram(coordinateSystem(extent = {{-120, 80}, {100, -100}})));
  end tb_sys_appsw;

  annotation(
    uses(Modelica(version = "4.0.0"))
  );

end pkg_appsw;
