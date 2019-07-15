function [gearBox, A1, B1, B2, C1] = gearboxOpti ()

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
values = num2cell([15 41 21 55]);
[objarray.numTeeth] = values{:};
values = num2cell([20 40 30 60]);
[objarray.pitchDiameter] = values{:};
[objarray.pressureAngle] = deal(20);
[objarray.gearThickness] = deal(0.5);
[objarray.materialName] = deal(4130); %FIX MEEEE

% initialize constant factors
for i = 1:4
    objarray(i) = getMaterialProperties(objarray(i));
end
[objarray.overloadFactor] = deal(1.5);
[objarray.rimThicknessFactor] = deal(1);
[objarray.profileShiftFactor] = deal(1); %FIX MEEEEE
[objarray.sizeFactor] = deal(1);
[objarray.surfaceConditionFactor] = deal(1);
[objarray.geometryFactor] = deal(1); %FIX MEEEEE
values = num2cell([30*(10^6), 2300, 30*(10^6), 2300]);
[objarray.elasticCoefficient] = values{:};

% calculate "dynamic" factors
for i = 1:4
    objarray(i) = calcDynamicFactor(objarray(i));
    objarray(i) = calcLewisFactor(objarray(i));
end

% calculate load distribution factors
for i = 1:2:3 % only for A1 and B2 (pinions)
    Cmc = 1; % face load distribution factor for uncrowned teeth
    if (objarray(i).gearThickness/(10*objarray(i).pitchDiameter)) < 0.05
        value = 0.05;
    else
        value = objarray(i).gearThickness/(10*objarray(i).pitchDiameter);
    end
    Cpf = (value)-0.025;
    Cpm = 1; % for straddle mounted pinion w/out significant offset on shaft
    A = 0.127; % for commercial, enclosed gearboxes
    B = 0.0158; % ^
    C = (-0.93)*(10^(-4)); % ^
    Cma = A + B*objarray(i).gearThickness + C*(objarray(i).gearThickness)^2;
    Ce = 1; % for gearing not adjusted at assembly
    objarray(i).loadDistribFactor = 1 + Cmc*(Cpf*Cpm + Cma*Ce);
end
for i = 2:2:4 % only for B1 and C1 (gears), done differently because they need to use pinion pitch diameters
    Cmc = 1; % face load distribution factor for uncrowned teeth
    if (objarray(i).gearThickness/(10*objarray(i-1).pitchDiameter)) < 0.05
        value = 0.05;
    else
        value = objarray(i).gearThickness/(10*objarray(i-1).pitchDiameter);
    end
    Cpf = (value)-0.025;
    Cpm = 1; % for straddle mounted pinion w/out significant offset on shaft
    A = 0.127; % for commercial, enclosed gearboxes
    B = 0.0158; % ^
    C = (-0.93)*(10^(-4)); % ^
    Cma = A + B*objarray(i).gearThickness + C*(objarray(i).gearThickness)^2;
    Ce = 1; % for gearing not adjusted at assembly
    objarray(i).loadDistribFactor = 1 + Cmc*(Cpf*Cpm + Cma*Ce);
end

gearBox = gearbox;

% overall ratio calculation
gearBox.ratio = (objarray(2).numTeeth/objarray(1).numTeeth)*(objarray(4).numTeeth/objarray(3).numTeeth);

% calculate geometry factor
for i = 1:4
    objarray(i).geometryFactor = ((cosd(objarray(i).pressureAngle)*...
        sind(objarray(i).pressureAngle))/2)*(gearBox.ratio/(gearBox.ratio + 1)); 
end

% calculate calculated stuff
for i = 1:4
    objarray(i) = calcModule(objarray(i));
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

% total KE
gearBox.totalKE = A1.kineticEnergy + B1.kineticEnergy + B2.kineticEnergy + C1.kineticEnergy;

matrixOfPossibilities = [gearBox.ratio, gearBox.totalKE, ...
    A1.bendingStress, B1.bendingStress, B2.bendingStress, ...
    C1.bendingStress, A1.contactStress, B1.contactStress, ...
    B2.contactStress, C1.contactStress]

end