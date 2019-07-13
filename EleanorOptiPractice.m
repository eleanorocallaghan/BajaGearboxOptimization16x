% min and max values
minFaceWidth = 0.2;
maxFaceWidth = 2;
minDiameter = 1.5;
maxDiameter = 8;
minRatio = 2;
maxRatio = 7;
minPitch = 5;
maxPitch = 30;
idealContactRatio = 1.5;

%AGMA bending stress
bendingStress = ((tangentLoad*pitch)/(lewisFactor*toothFaceWidth))*...
    overloadFactor*loadDistribFactor*dynamicFactor*rimThicknessFactor;

contactStress = elasticCoefficient*sqrt(tangentLoad*overloadFactor*...
    dynamicFactor*sizeFactor*(loadDistribFactor/(pinionPitchDiameter*faceWidth))...
    (surfaceConditionFactor/geometryFactor))


