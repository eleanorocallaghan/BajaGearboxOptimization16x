function [lewisFactor] = calcLewisFactorTables(obj)
pressureAngle = obj.pressureAngle;
numTeeth = obj.numTeeth;
    if pressureAngle == 14.5
        lewisTable = [10, 0.176;...
                  11, 0.192;...  
                  12, 0.210;... 
                  13, 0.223;...
                  14, 0.236;... 
                  15, 0.245;...
                  16, 0.255;...
                  17, 0.264;...
                  18, 0.270;...
                  19, 0.277;...
                  20, 0.283;...
                  22, 0.292;... 
                  24, 0.302;... 
                  26, 0.308;...
                  28, 0.314;... 
                  30, 0.318;... 
                  34, 0.325;... 
                  38, 0.332;... 
                  45, 0.340;... 
                  50, 0.346;... 
                  60, 0.355;... 
                  75, 0.361;...
                  100, 0.368;... 
                  150, 0.375;... 
                  300, 0.382;... 
                  400, 0.390];
    elseif pressureAngle == 20
        lewisTable = [10, 0.201;...
                  11, 0.226;...  
                  12, 0.245;... 
                  13, 0.261;...
                  14, 0.277;... 
                  15, 0.290;...
                  16, 0.296;...
                  17, 0.303;...
                  18, 0.309;...
                  19, 0.314;...
                  20, 0.322;...
                  21, 0.328;... 
                  22, 0.331;... 
                  24, 0.337;... 
                  26, 0.346;...
                  28, 0.353;... 
                  30, 0.359;... 
                  34, 0.371;... 
                  38, 0.384;... 
                  43, 0.397;... 
                  50, 0.409;... 
                  60, 0.422;... 
                  75, 0.435;...
                  100, 0.447;... 
                  150, 0.460;... 
                  300, 0.472;... 
                  400, 0.480];
    elseif pressureAngle == 25
        lewisTable =  [12, 0.277;... 
                  13, 0.293;...
                  14, 0.307;... 
                  15, 0.320;...
                  16, 0.332;...
                  17, 0.342;...
                  18, 0.352;...
                  19, 0.361;...
                  20, 0.369;...
                  21, 0.377;... 
                  22, 0.384;... 
                  24, 0.396;... 
                  26, 0.407;...
                  28, 0.417;... 
                  30, 0.425;... 
                  34, 0.440;... 
                  38, 0.452;... 
                  43, 0.464;... 
                  50, 0.477;... 
                  60, 0.491;... 
                  75, 0.506;...
                  100, 0.521;... 
                  150, 0.537;... 
                  300, 0.554;... 
                  400, 0.566];
    end

[numTeethOff, roundedNumTeethIndex] = min(abs(lewisTable(:, 1)-numTeeth));
    
lewisFactor = lewisTable(roundedNumTeethIndex,2);

end

