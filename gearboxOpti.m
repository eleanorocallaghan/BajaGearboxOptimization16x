function [A1, B1, B2, C1, gearBox, calculations] = gearboxOpti (possibleGearbox)

% make a matrix of gears
for i = 1:4
  objarray(i) = gear;
end

% IF YOU WANT TO USE OPTIMIZATION PROGRAM
% initialize optimized values for gears
values = num2cell(possibleGearbox(1:4));
[objarray.numTeeth] = values{:};
[objarray(1:2).diametralPitch] = deal(possibleGearbox(6));
[objarray(3:4).diametralPitch] = deal(possibleGearbox(7));
[objarray.pressureAngle] = deal(possibleGearbox(5));
[objarray(1:2).gearThickness] = deal(possibleGearbox(8));
[objarray(3:4).gearThickness] = deal(possibleGearbox(9));
[objarray.materialName] = deal(9310); %FIX MEEEE


% % IF YOU WANT TO MANUALLY PUT STUFF IN
% % initialize optimized values for gears
% values = num2cell([25 74 23 62]);
% [objarray.numTeeth] = values{:};
% [objarray(1:2).diametralPitch] = deal(13);
% [objarray(3:4).diametralPitch] = deal(15);
% [objarray.pressureAngle] = deal(25);
% [objarray(1:2).gearThickness] = deal(0.4);
% [objarray(3:4).gearThickness] = deal(0.5);
% [objarray.materialName] = deal(9310); %FIX MEEEE


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
[objarray.profileShiftFactor] = deal(0); %FIX MEEEEE
[objarray.sizeFactor] = deal(1);
[objarray.surfaceConditionFactor] = deal(1);
values = num2cell([2484 2300 2484 2300]);
[objarray.elasticCoefficient] = values{:};
[objarray.bendingSafetyFactor] = deal(1); % from website about fatigue life
[objarray.pittingSafetyFactor] = deal(1); % from website about fatigue life
[objarray.temperatureFactor] = deal(1); % unless we get more data
[objarray.reliabilityFactor] = deal(1.25); % from website about fatigue life
[objarray.bendingFatigueLimit] = deal(217846); 
[objarray.contactFatigueLimit] = deal(217846); 
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

% calculate calculated factors
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

% calculate contact ratios
for i = 1:2 % for A1 and B1 set
    pinionAddendumRadius = (objarray(1).pitchDiameter/2) + objarray(1).module;
    pinionBaseCircleRadius = (objarray(1).pitchDiameter*cosd(objarray(1).pressureAngle))/2;
    gearAddendumRadius = (objarray(2).pitchDiameter/2) + objarray(2).module;
    gearBaseCircleRadius = (objarray(2).pitchDiameter*cosd(objarray(2).pressureAngle))/2;
    centerDistance1 = (objarray(1).numTeeth*objarray(1).module + ...
        objarray(2).numTeeth*objarray(2).module)/2;
    basePitch = (pi*pinionBaseCircleRadius*2)/objarray(1).numTeeth;
    objarray(i).contactRatio = (sqrt(pinionAddendumRadius^2-...
        pinionBaseCircleRadius^2) + sqrt(gearAddendumRadius^2 - ...
        gearBaseCircleRadius^2) - centerDistance1*...
        sind(objarray(i).pressureAngle))/basePitch;
end
for i = 3:4 % for B2 and C1 set
    pinionAddendumRadius = (objarray(3).pitchDiameter/2) + objarray(3).module;
    pinionBaseCircleRadius = (objarray(3).pitchDiameter*cosd(objarray(3).pressureAngle))/2;
    gearAddendumRadius = (objarray(4).pitchDiameter/2) + objarray(4).module;
    gearBaseCircleRadius = (objarray(4).pitchDiameter*cosd(objarray(4).pressureAngle))/2;
    centerDistance2 = (objarray(3).numTeeth*objarray(3).module + ...
        objarray(4).numTeeth*objarray(4).module)/2;
    basePitch = (pi*pinionBaseCircleRadius*2)/objarray(3).numTeeth;
    objarray(i).contactRatio = (sqrt(pinionAddendumRadius^2-...
        pinionBaseCircleRadius^2) + sqrt(gearAddendumRadius^2 - ...
        gearBaseCircleRadius^2) - centerDistance2*...
        sind(objarray(i).pressureAngle))/basePitch;
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
        ((objarray(i).contactFatigueLimit/145.0376)*objarray(i).hardnessRatioFactor));
end
for i = 2:2:4 % for B1 and C1 (gears)
    objarray(i).pittingStressCycleFactor = (objarray(i).elasticCoefficient/sqrt(145.038))*...
        sqrt(((objarray(i).tangentLoad/2.22481)*objarray(i).overloadFactor*...
        objarray(i).dynamicFactor*objarray(i).loadDistribFactor*...
        objarray(i).sizeFactor*objarray(i).surfaceConditionFactor)/...
        ((objarray(i).gearThickness*25.4)*(objarray(i-1).pitchDiameter*25.4)*...
        objarray(i).pittingGeometryFactor))*((objarray(i).pittingSafetyFactor*...
        objarray(i).temperatureFactor*objarray(i).reliabilityFactor)/...
        ((objarray(i).contactFatigueLimit/145.038)*objarray(i).hardnessRatioFactor));
end
for i = 1:4
    objarray(i).bendingStressCycleFactor =((objarray(i).tangentLoad/0.224809)*...
        objarray(i).overloadFactor*objarray(i).dynamicFactor*...
        objarray(i).loadDistribFactor*objarray(i).sizeFactor*...
        objarray(i).rimThicknessFactor*objarray(i).bendingSafetyFactor*...
        objarray(i).temperatureFactor*objarray(i).reliabilityFactor)/...
        ((objarray(i).bendingFatigueLimit/145.037)*(objarray(i).gearThickness*25.4)*...
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

inputToOutput = centerDistance1 + centerDistance2;

% total KE
gearBox.totalKE = A1.kineticEnergy + B1.kineticEnergy + B2.kineticEnergy + C1.kineticEnergy;

% find gearbox lifetime
A1B1lifetime = min([A1.bendingStressLifetime, B1.bendingStressLifetime, A1.contactStressLifetime, B1.contactStressLifetime]);
B2C1lifetime = min([B2.bendingStressLifetime, C1.bendingStressLifetime, B2.contactStressLifetime, C1.contactStressLifetime]);
gearBox.lifetime = min([A1B1lifetime, B2C1lifetime]);

calculations = [gearBox.totalKE, gearBox.lifetime, A1B1lifetime, B2C1lifetime, A1.contactRatio, B2.contactRatio, inputToOutput, centerDistance2];
end