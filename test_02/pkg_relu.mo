package pkg_relu

function fn_relu
  input Real inp;
  output Real outp;
  
  external "C" outp = computeReLu(inp)
    annotation(
      Include = "#include \"lib_relu.c\"",
      IncludeDirectory = "modelica://pkg_relu/Resources");
      
end fn_relu;


block sys_relu // continuous-time signals
  Modelica.Blocks.Interfaces.RealInput inp "input"
    annotation(Placement(
      transformation(extent = {{-110, -10}, {-90, 10}}),
      iconTransformation(extent = {{-110, -10}, {-90, 10}})));

  Modelica.Blocks.Interfaces.RealOutput outp "output"
    annotation(Placement(
      transformation(extent = {{90, -10}, {110, 10}}),
      iconTransformation(extent = {{90, -10}, {110, 10}})));

  equation 
    outp = fn_relu(inp);

  annotation(
    Icon(graphics = {
      Rectangle(extent = {{-100, 100}, {100, -100}})
    }),
    Diagram(graphics = {
      Rectangle(extent = {{-100, 100}, {100, -100}})
    }),
    coordinateSystem(extent = {{-120, 120}, {120, -120}}));
end sys_relu;


model tb_sys_relu
    
    sys_relu sys_relu_01 annotation(
      Placement(transformation(origin = {40, 0}, extent = {{-20, -20}, {20, 20}})));
    
    Modelica.Blocks.Sources.Sine sine(amplitude = 1, f = 1)  annotation(
      Placement(transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}})));
  
  equation
    
    connect(sine.y, sys_relu_01.inp) annotation(
      Line(points = {{-39, 0}, {20, 0}}, color = {0, 0, 127}));
    annotation(
      experiment(StartTime = 0, StopTime = 3, Tolerance = 1e-06, Interval = 0.006));

end tb_sys_relu;

annotation(
  uses(Modelica(version = "4.0.0")));

end pkg_relu;
