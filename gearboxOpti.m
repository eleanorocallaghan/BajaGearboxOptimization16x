function [gearbox, A1, B1, B2, C1] = gearboxOpti (gearbox, A1, B1, B2, C1)

% overall ratio calculation
gearbox.ratio = (B1.numTeeth/A1.numTeeth)*(C1.numTeeth/B2.numTeeth);

% contact stresses
A1.elasticCoefficient = 30*(10^6); %psi, from Shilgley table 14-8 (pinion)
B1.elasticCoefficient = 2300 %psi;
A1.contactStress = A1.elasticCoefficient*sqrt(A1.tangentLoad*...
    A1.overloadFactor*A1.dynamicFactor*A1.sizeFactor*(A1.loadDistribFactor/...
    (A1.pitchDiameter*A1.gearThickness))(A1.surfaceConditionFactor/A1.geometryFactor));

% total KE
gearbox.totalKE = A1.kineticEnergy + B1.kineticEnergy + B2.kineticEnergy + C1.kineticEnergy;



end