within OpenBLDC.Blocks;
block CatchStart "Check if motor is rotating and get position"
  // derzeit nur fuer eine Drehrichtung
  extends Modelica.Blocks.Icons.Block;
  parameter Real CatchMinVoltage = 0.5 "Minimum EMF for catch start";
  parameter Real CatchWaitTime = 0.1e-3 "Wait time to prevent jitter";
  Real halltemp(start=0) "Temporary angle for direction detection";
  //HallDecode hallDecodeCorrected "Corrected value if rotation direction is negative";

  Modelica.Blocks.Interfaces.RealInput v[3] "Voltage at motor terminals"
    annotation (Placement(transformation(extent={{-120,-20},{-80,20}})));
  Modelica.Blocks.Interfaces.BooleanOutput running
    "Motor is running and position is actual"
    annotation (Placement(transformation(extent={{90,50},{110,70}})));
  Modelica.Blocks.Interfaces.RealOutput y "electrical angle"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  PhaseDiffVoltage phaseDiffVoltage
    annotation (Placement(transformation(extent={{-76,-10},{-56,10}})));
  HallDecode hallDecode
    annotation (Placement(transformation(extent={{-32,-50},{-12,-30}})));
  Modelica.Blocks.Math.Feedback feedback
    annotation (Placement(transformation(extent={{-26,26},{-6,46}})));
  Modelica.Blocks.Math.MinMax minMax(nu=3)
    annotation (Placement(transformation(extent={{-50,20},{-30,40}})));
  Modelica.Blocks.Math.IntegerChange integerChange
    annotation (Placement(transformation(extent={{24,-50},{44,-30}})));
  Modelica.Blocks.Math.RealToBoolean realToBoolean[3](threshold=fill(0, 3))
    "Emulate hall sensor"
    annotation (Placement(transformation(extent={{-90,-50},{-70,-30}})));
  Modelica.Blocks.Math.BooleanToReal hallReal[3] "Real value of hall sensor"
    annotation (Placement(transformation(extent={{-62,-50},{-42,-30}})));
  Modelica.Blocks.Math.RealToInteger realToInteger
    annotation (Placement(transformation(extent={{-4,-50},{16,-30}})));
  Modelica.Blocks.Logical.And and1
    annotation (Placement(transformation(extent={{58,-42},{78,-22}})));
  Modelica.Blocks.Logical.GreaterThreshold greaterThreshold(threshold=
        CatchMinVoltage)
    annotation (Placement(transformation(extent={{28,26},{48,46}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    k=1,
    y_start=0,
    T=0.1e-3)  annotation (Placement(transformation(extent={{0,26},{20,46}})));
  Modelica.Blocks.Interfaces.RealOutput dir(start=0) "Direction of rotation"
    annotation (Placement(transformation(extent={{90,-70},{110,-50}})));
  Modelica.Blocks.Interfaces.BooleanInput tryToCatch
    annotation (Placement(transformation(extent={{-120,-100},{-80,-60}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot
    annotation (Placement(transformation(extent={{-100,-140},{-80,-120}})));
  Modelica.StateGraph.InitialStep initialStep
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-30,-70})));
  Modelica.StateGraph.TransitionWithSignal transitionStart
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-56,-70})));
  Modelica.StateGraph.Step catchStep1 "Wait for the first transition"
    annotation (Placement(transformation(extent={{-70,-112},{-50,-92}})));
  Modelica.StateGraph.TransitionWithSignal transition1(enableTimer=false)
    annotation (Placement(transformation(extent={{-48,-112},{-28,-92}})));
  Modelica.StateGraph.Step catchStep2 "Wait for the 2nd transition"
    annotation (Placement(transformation(extent={{12,-112},{32,-92}})));
  Modelica.StateGraph.TransitionWithSignal transition2(enableTimer=false)
    annotation (Placement(transformation(extent={{34,-112},{54,-92}})));
  Modelica.StateGraph.StepWithSignal stepWithSignal annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={42,-70})));
  Modelica.StateGraph.Transition transitionDone(enableTimer=true,
    condition=true,
    waitTime=CatchWaitTime/2)
                       annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={12,-70})));
  Modelica.StateGraph.Transition transition(
    condition=true,
    enableTimer=true,
    waitTime=CatchWaitTime)
    annotation (Placement(transformation(extent={{-10,-112},{10,-92}})));
  Modelica.StateGraph.Step wait1
    annotation (Placement(transformation(extent={{-30,-112},{-10,-92}})));
  Modelica.StateGraph.Step wait2
    annotation (Placement(transformation(extent={{52,-112},{72,-92}})));
  Modelica.StateGraph.Transition transition3(
    condition=true,
    enableTimer=true,
    waitTime=CatchWaitTime/2) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={68,-70})));
  Modelica.Blocks.Math.Product product[3]
    annotation (Placement(transformation(extent={{-44,-10},{-24,10}})));
  Modelica.Blocks.Math.RealToBoolean realToBoolean1[
                                                   3](threshold=fill(0, 3))
    "Emulate hall sensor"
    annotation (Placement(transformation(extent={{-16,-10},{4,10}})));
  Modelica.Blocks.Math.BooleanToReal hallReal1[
                                              3] "Real value of hall sensor"
    annotation (Placement(transformation(extent={{12,-10},{32,10}})));
  HallDecode hallDecode1
    annotation (Placement(transformation(extent={{58,-10},{78,10}})));
equation
  when catchStep1.active then
    halltemp = hallDecode.y[1];
  end when;
  when catchStep2.active then
    dir = if mod(hallDecode.y[1] - halltemp, 6) < 3 then mod(hallDecode.y[1] - halltemp, 6) else mod(hallDecode.y[1] - halltemp, 6) - 6;
    //dir = mod(hallDecode.y[1] - halltemp, 6);
  end when;
  product.u2 = fill(dir,3);
  // Correction of decoded hall value in case dir = -1
  // hallDecodeCorrected.u = dir * phaseDiffVoltage.y;
  // connect(hallDecodeCorrected.y[1], y);

  connect(v, phaseDiffVoltage.u) annotation (Line(
      points={{-100,0},{-76,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(phaseDiffVoltage.y, realToBoolean.u) annotation (Line(
      points={{-56,0},{-52,0},{-52,-20},{-98,-20},{-98,-40},{-92,-40}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realToBoolean.y, hallReal.u) annotation (Line(
      points={{-69,-40},{-64,-40}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(hallReal.y, hallDecode.u) annotation (Line(
      points={{-41,-40},{-32,-40}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(minMax.yMax, feedback.u1) annotation (Line(
      points={{-29,36},{-24,36}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(minMax.yMin, feedback.u2) annotation (Line(
      points={{-29,24},{-16,24},{-16,28}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(hallDecode.y[1], realToInteger.u) annotation (Line(
      points={{-12,-40},{-6,-40}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realToInteger.y, integerChange.u) annotation (Line(
      points={{17,-40},{22,-40}},
      color={255,127,0},
      smooth=Smooth.None));
  connect(greaterThreshold.y, and1.u1) annotation (Line(
      points={{49,36},{52,36},{52,-32},{56,-32}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(integerChange.y, and1.u2) annotation (Line(
      points={{45,-40},{56,-40}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(feedback.y, firstOrder.u) annotation (Line(
      points={{-7,36},{-2,36}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(greaterThreshold.u, firstOrder.y) annotation (Line(
      points={{26,36},{21,36}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(catchStep1.outPort[1], transition1.inPort) annotation (Line(
      points={{-49.5,-102},{-42,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(catchStep2.outPort[1], transition2.inPort) annotation (Line(
      points={{32.5,-102},{40,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(and1.y, transition2.condition) annotation (Line(
      points={{79,-32},{84,-32},{84,-120},{44,-120},{44,-114}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(and1.y, transition1.condition) annotation (Line(
      points={{79,-32},{84,-32},{84,-120},{-38,-120},{-38,-114}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(stepWithSignal.outPort[1], transitionDone.inPort) annotation (Line(
      points={{31.5,-70},{16,-70}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(stepWithSignal.active, running) annotation (Line(
      points={{42,-59},{42,-52},{86,-52},{86,60},{100,60}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(transitionDone.outPort, initialStep.inPort[1]) annotation (Line(
      points={{10.5,-70},{-19,-70}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(transition1.outPort, wait1.inPort[1]) annotation (Line(
      points={{-36.5,-102},{-31,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(wait1.outPort[1], transition.inPort) annotation (Line(
      points={{-9.5,-102},{-4,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(transition.outPort, catchStep2.inPort[1]) annotation (Line(
      points={{1.5,-102},{11,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(initialStep.outPort[1], transitionStart.inPort) annotation (Line(
      points={{-40.5,-70},{-52,-70}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(transitionStart.outPort, catchStep1.inPort[1]) annotation (Line(
      points={{-57.5,-70},{-76,-70},{-76,-102},{-71,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(tryToCatch, transitionStart.condition) annotation (Line(
      points={{-100,-80},{-84,-80},{-84,-54},{-56,-54},{-56,-58}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(transition2.outPort,wait2. inPort[1]) annotation (Line(
      points={{45.5,-102},{51,-102}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(wait2.outPort[1], transition3.inPort) annotation (Line(
      points={{72.5,-102},{78,-102},{78,-70},{72,-70}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(transition3.outPort, stepWithSignal.inPort[1]) annotation (Line(
      points={{66.5,-70},{53,-70}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(phaseDiffVoltage.y, product.u1) annotation (Line(
      points={{-56,0},{-50,0},{-50,6},{-46,6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(phaseDiffVoltage.y, minMax.u[1:3]) annotation (Line(
      points={{-56,0},{-54,0},{-54,25.3333},{-50,25.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(product.y, realToBoolean1.u) annotation (Line(
      points={{-23,0},{-18,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(realToBoolean1.y, hallReal1.u) annotation (Line(
      points={{5,0},{10,0}},
      color={255,0,255},
      smooth=Smooth.None));
  connect(hallReal1.y, hallDecode1.u) annotation (Line(
      points={{33,0},{58,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(hallDecode1.y[1], y) annotation (Line(
      points={{78,0},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -140},{100,100}}), graphics), Icon(coordinateSystem(extent={{-100,-140},
            {100,100}})));
end CatchStart;
