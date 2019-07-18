function [gearBox, A1, B1, B2, C1] = gearboxOpti ()

% make a matrix of gears
for i = 1:4
  objarray(i) = gear;
end

% initialize optimized values for gears
values = num2cell([15 41 21 55]);
[objarray.numTeeth] = values{:};
[objarray.diametralPitch] = deal(8);
[objarray.pressureAngle] = deal(20);
[objarray.gearThickness] = deal(0.5);
[objarray.materialName] = deal(4150); %FIX MEEEE

% initialize gearbox stuff
gearBox = gearbox;
gearBox.inputSpeed = 3800;
gearBox.inputTorque = 14.5*12*3.8;

% initialize constant factors
for i = 1:4
    objarray(i) = getMaterialProperties(objarray(i));
end
[objarray.overloadFactor] = deal(1.5);
[objarray.rimThicknessFactor] = deal(1);
[objarray.profileShiftFactor] = deal(1); %FIX MEEEEE
[objarray.sizeFactor] = deal(1);
[objarray.surfaceConditionFactor] = deal(1);
values = num2cell([30*(10^6), 2300, 30*(10^6), 2300]);
[objarray.elasticCoefficient] = values{:};
[objarray.bendingSafetyFactor] = deal(1.7); % from website about fatigue life
[objarray.pittingSafetyFactor] = deal(1.3); % from website about fatigue life
[objarray.temperatureFactor] = deal(1); % unless we get more data
[objarray.reliabilityFactor] = deal(1.25); % from website about fatigue life
[objarray.bendingFatigueLimit] = deal(300000); %FIX MEEEE
[objarray.contactFatigueLimit] = deal(250000); % a reasonable guess, should be fixed though
[objarray.numLoadApplication] = deal(1); % ^
[objarray.bendingGeometryFactor] = deal(0.47); % this is an approximation, should probably be calculated

% calculate gear speeds
objarray(1).gearSpeed = gearBox.inputSpeed;
objarray(2).gearSpeed = objarray(1).gearSpeed/(objarray(2).numTeeth/objarray(1).numTeeth);
objarray(3).gearSpeed = objarray(2).gearSpeed;
objarray(4).gearSpeed = objarray(3).gearSpeed/(objarray(4).numTeeth/objarray(3).numTeeth);

% calculate torques
objarray(1).torque = gearBox.inputTorque;
objarray(2).torque = objarray(1).torque/(objarray(1).numTeeth/objarray(2).numTeeth);
objarray(3).torque = objarray(2).torque;
objarray(4).torque = objarray(3).torque/(objarray(3).numTeeth/objarray(4).numTeeth);

% calculate "dynamic" factors
for i = 1:4
    objarray(i) = calcDynamicFactor(objarray(i));
    objarray(i) = calcLewisFactor(objarray(i));
end

% calculate hardness ratio factor
for i = 1:2 % for A1 and B1
    B1 = 0.00898*(objarray(1).hardness/objarray(2).hardness)-0.00829;
    objarray(i).hardnessRatioFactor = 1 + B1*(objarray(1).numTeeth/objarray(2).numTeeth-1);
end
for i = 3:4 % for B2 and C1
    B1 = 0.00898*(objarray(3).hardness/objarray(4).hardness)-0.00829;
    objarray(i).hardnessRatioFactor = 1 + B1*(objarray(3).numTeeth/objarray(4).numTeeth-1);
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

% overall ratio calculation
gearBox.ratio = (objarray(2).numTeeth/objarray(1).numTeeth)*(objarray(4).numTeeth/objarray(3).numTeeth);

for i = 1:4
    objarray(i).pittingGeometryFactor = ((cosd(objarray(i).pressureAngle)*...
        sind(objarray(i).pressureAngle))/2)*(gearBox.ratio/(gearBox.ratio + 1)); 
end

% calculate calculated stuff
for i = 1:4
    objarray(i) = calcModule(objarray(i));
    objarray(i) = calcPitch(objarray(i));
    objarray(i) = calcMass(objarray(i));
    objarray(i) = calcTangentLoad(objarray(i));
    objarray(i) = calcMomentOfInertia(objarray(i));
    objarray(i) = calcAngVelocity(objarray(i));
    objarray(i) = calcKineticEnergy(objarray(i));
    objarray(i) = calcPitchLineVelocity(objarray(i));
    objarray(i) = calcPitchDiameter(objarray(i));
    objarray(i) = calcBendingStress(objarray(i));
    objarray(i) = calcContactStress(objarray(i));
end

% calculate stress cycle factors
for i = 1:2:3 % for A1 and B2 (pinions)
    objarray(i).pittingStressCycleFactor = (objarray(i).elasticCoefficient/sqrt(145.038))*...
        sqrt(((objarray(i).tangentLoad/0.224809)*objarray(i).overloadFactor*...
        objarray(i).dynamicFactor*objarray(i).loadDistribFactor*...
        objarray(i).sizeFactor*objarray(i).surfaceConditionFactor)/...
        ((objarray(i).gearThickness*25.4)*(objarray(i).pitchDiameter*25.4)*...
        objarray(i).pittingGeometryFactor))*((objarray(i).pittingSafetyFactor*...
        objarray(i).temperatureFactor*objarray(i).reliabilityFactor)/...
        ((objarray(i).contactFatigueLimit/145.038)*objarray(i).hardnessRatioFactor));
end
for i = 2:2:4 % for B1 and C1 (gears)
    objarray(i).pittingStressCycleFactor = (objarray(i).elasticCoefficient/sqrt(145.038))*...
        sqrt(((objarray(i).tangentLoad/0.224809)*objarray(i).overloadFactor*...
        objarray(i).dynamicFactor*objarray(i).loadDistribFactor*...
        objarray(i).sizeFactor*objarray(i).surfaceConditionFactor)/...
        ((objarray(i).gearThickness*25.4)*(objarray(i-1).pitchDiameter*25.4)*...
        objarray(i).pittingGeometryFactor))*((objarray(i).pittingSafetyFactor*...
        objarray(i).temperatureFactor*objarray(i).reliabilityFactor)/...
        ((objarray(i).contactFatigueLimit/145.038)*objarray(i).hardnessRatioFactor));
end
for i = 1:4
    objarray(i).bendingStressCycleFactor = ((objarray(i).tangentLoad/0.224809)*...
        objarray(i).overloadFactor*objarray(i).dynamicFactor*...
        objarray(i).loadDistribFactor*objarray(i).sizeFactor*...
        objarray(i).rimThicknessFactor*objarray(i).bendingSafetyFactor*...
        objarray(i).temperatureFactor*objarray(i).reliabilityFactor)/...
        ((objarray(i).bendingFatigueLimit/145.038)*(objarray(i).gearThickness*25.4)*...
        (objarray(i).module*25.4)*objarray(i).bendingGeometryFactor);
end

% calculate number of load cycles
for i = 1:4
    objarray(i).numPittingLoadCycles = (objarray(i).pittingStressCycleFactor/2.466)^(-1/0.056);
end
for i = 1:4
    objarray(i).numFatigueLoadCycles = (objarray(i).bendingStressCycleFactor/6.1514)^(-1/0.1192);
end

% calculate allowable stresses
for i = 1:4
    objarray(i).allowableBendingStress = ((objarray(i).bendingFatigueLimit/145.038)*...
        objarray(i).bendingStressCycleFactor)/(objarray(i).bendingSafetyFactor...
        *objarray(i).temperatureFactor*objarray(i).reliabilityFactor);
    objarray(i).allowableContactStress = ((objarray(i).contactFatigueLimit/145.038)*...
        objarray(i).pittingStressCycleFactor*objarray(i).hardnessRatioFactor)...
        /(objarray(i).pittingSafetyFactor*objarray(i).temperatureFactor*...
        objarray(i).reliabilityFactor);
end

% calculate lifetimes
for i = 1:4
    objarray(i).bendingStressLifetime = objarray(i).numFatigueLoadCycles/...
        (60*objarray(i).gearSpeed*objarray(i).numLoadApplication);
    objarray(i).contactStressLifetime = objarray(i).numPittingLoadCycles/...
        (60*objarray(i).gearSpeed*objarray(i).numLoadApplication);
end

A1 = objarray(1);
B1 = objarray(2);
B2 = objarray(3);
C1 = objarray(4);

% total KE
gearBox.totalKE = A1.kineticEnergy + B1.kineticEnergy + B2.kineticEnergy + C1.kineticEnergy;

matrixOfPossibilities = [gearBox.ratio, A1.numTeeth, B1.numTeeth, ...
    B2.numTeeth, C1.numTeeth, A1.pitchDiameter, B1.pitchDiameter, ...
    B2.pitchDiameter, C1.pitchDiameter];

end