A1 = gear;
B1 = gear;
B2 = gear;
C1 = gear;
gearboxv1 = gearbox;

% initialize gears and gearbox

gearMatrix = ["A1" "B1" "B2" "C1"] % this makes it easy to do loops

A1.numTeeth = 15;
A1.pitchDiameter = 30;
B1.numTeeth = 41;
B1.pitchDiameter = 50;
B2.numTeeth = 21;
B2.pitchDiameter = 25;
C1.numTeeth = 55;
C1.pitchDiameter = 60;

%{
 initialize input numbers
for i = gearMatrix(1):gearMatrix(end)
    i.pressureAngle = 20;
    i.gearThickness = 0.5;
end
%}