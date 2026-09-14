package pkg_cmath_pow


function fn_cmath_pow
    input Real base;
    input Real exponent;
    output Real result;
  
    external "C" result = pow(base, exponent) annotation(
      Include = "#include <math.h>");
  end fn_cmath_pow;

annotation(
  uses(Modelica(version = "4.0.0")));


block sys_cmath_pow     // continuous-time signals
  Modelica.Blocks.Interfaces.RealInput base "base"
    annotation(Placement(
      transformation(extent = {{-110, 30}, {-90, 50}}),
      iconTransformation(extent = {{-110, 30}, {-90, 50}})));

  Modelica.Blocks.Interfaces.RealInput exponent "exponent"
    annotation(Placement(
      transformation(extent = {{-110, -50}, {-90, -30}}),
      iconTransformation(extent = {{-110, -50}, {-90, -30}})));

  Modelica.Blocks.Interfaces.RealOutput result "result"
    annotation(Placement(
      transformation(extent = {{90, -10}, {110, 10}}),
      iconTransformation(extent = {{90, -10}, {110, 10}})));
  
  equation 

    result = fn_cmath_pow(base, exponent);

  annotation(
    Diagram(graphics = 
    {Rectangle(extent = {{-100, 100}, {100, -100}})}, 
    coordinateSystem(extent = {{-120, 120}, {120, -120}})));

end sys_cmath_pow;

model tb_sys_cmath_pow        
// continuous-time signals
  sys_cmath_pow system_pow annotation(
      Placement(transformation(origin = {10, 0}, extent = {{-50, -50}, {50, 50}})));
    
  Modelica.Blocks.Sources.Constant constBase(k = 3)  annotation(
      Placement(transformation(origin = {-70, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant constExponent(k = 2) annotation(
      Placement(transformation(origin = {-70, -20}, extent = {{-10, -10}, {10, 10}})));
    
  equation  

    connect(constBase.y, system_pow.base) annotation(
      Line(points = {{-59, 20}, {-40, 20}}, color = {0, 0, 127}));
    connect(constExponent.y, system_pow.exponent) annotation(
      Line(points = {{-59, -20}, {-40, -20}}, color = {0, 0, 127}));

annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002));
end tb_sys_cmath_pow;


end pkg_cmath_pow;
