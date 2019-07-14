function [gearbox, A1, B1, B2, C1] = gearboxOpti ()

%{
 min and max values
minFaceWidth = 0.2;
maxFaceWidth = 2;
minDiameter = 1.5;
maxDiameter = 8;
minRatio = 2;
maxRatio = 7;
minPitch = 5;
maxPitch = 30;
idealContactRatio = 1.5;
%}

% make a matrix of gears
for i = 1:4
  objarray(i) = gear;
end

% initialize "input" values for gears
[objarray.numTeeth] = num2cell([15 41 21 55]);
[objarray.pitchDiameter] = num2cell([20 40 30 60]);
[objarray.pressureAngle] = deal(20);
[objarray.gearThickness] = deal(0.5);

% initialize constant factors
[objarray.overloadFactor] = deal(1.5);
[objarray.rimThicknessFactor] = deal(1);
[objarray.profileShiftFactor] = deal(1); %FIX MEEEEE
[objarray.sizeFactor] = deal(1);
[objarray.surfaceConditionFactor] = deal(1);
[objarray.geometryFactor] = deal(1); %FIX MEEEEE
[objarray.elasticCoefficient] = num2cell([30*(10^6), 2300, 30*(10^6), 2300]);

% calculate "dynamic" factors
for i = 1:4
    objarray(i) = calcDynamicFactor(objarray(i));
    objarray(i) = calcLoadDistribFactor(objarray(i));
    objarray(i) = calcLewisFactor(objarray(i));
end

% calculate calculated stuff
for i = 1:4
    objarray(i) = calcModule(objarray(i));
    objarray(i) = calcToothWidth(objarray(i));
    objarray(i) = calcToothDepth(objarray(i));
    objarray(i) = calcMass(objarray(i));
    objarray(i) = calcTorque(objarray(i));
    objarray(i) = calcTangentLoad(objarray(i));
    objarray(i) = calcMomentOfInertia(objarray(i));
    objarray(i) = calcAngVelocity(objarray(i));
    objarray(i) = calcKineticEnergy(objarray(i));
    objarray(i) = calcPitchLineVelocity(objarray(i));
    objarray(i) = calcDiametralPitch(objarray(i));
    objarray(i) = calcGearSpeed(objarray(i));
    objarray(i) = calcBendingStress(objarray(i));
    objarray(i) = calcContactStress(objarray(i));
end

A1 = objarray(1);
B1 = objarray(2);
B2 = objarray(3);
C1 = objarray(4);
gearBox = gearbox(A1, B1, B2, C1);

% overall ratio calculation
gearbox.ratio = (B1.numTeeth/A1.numTeeth)*(C1.numTeeth/B2.numTeeth);

% total KE
gearbox.totalKE = A1.kineticEnergy + B1.kineticEnergy + B2.kineticEnergy + C1.kineticEnergy;

matrixOfPossibilities(1, :) = [gearbox.ratio, gearbox.totalKE, ...
    A1.bendingStress, B1.bendingStress, B2.bendingStress, ...
    C1.bendingStress, A1.contactStress, B1.contactStress, ...
    B2.contactStress, C1.contactStress];

end