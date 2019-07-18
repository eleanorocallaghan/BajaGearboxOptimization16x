function [teethOptions, pressureAngleOptions, allDiametralPitchOptions] = Optimization()

% min and max values
minNumTeeth = 10;
maxNumTeeth = 80;
minIndividualRatio = 2.6;
maxIndividualRatio = 4;
minOverallRatio = 7.05;
maxOverallRatio = 7.15;
minPitchDiameter = 2;
maxPitchDiameter = 8;
maxGearThickness = 2;

% generate possible combinations of teeth
% find all combinations of teeth numbers
count1 = 1;
for i = minNumTeeth:maxNumTeeth
    for j = minNumTeeth:maxNumTeeth
        allcombos(count1, 1) = i;
        allcombos(count1, 2) = j;
        count1 = count1+1;
    end
end

% find combinations of 2 gears teeth with a reasonable reduction
count2 = 1;
for i = 1:size(allcombos, 1)
    A1B1ratio = allcombos(i, 2)/allcombos(i, 1);
    if A1B1ratio < maxIndividualRatio && A1B1ratio > minIndividualRatio
        A1B1options(count2, :) = allcombos(i, :);
        count2 = count2 + 1;
    end
end

% find combinations of 4 gears that give desired overall gearbox reduction
count3 = 1;
for i = 1:size(A1B1options, 1)
    for j = 1:size(A1B1options, 1)
        A1B1ratio = A1B1options(i, 2)/A1B1options(i, 1);
        B2C1ratio = A1B1options(j, 2)/A1B1options(j, 1);
        overallRatio = A1B1ratio*B2C1ratio;
        if overallRatio > minOverallRatio && overallRatio < maxOverallRatio
           teethOptions(count3, :) = [A1B1options(i, 1), A1B1options(i, 2),...
               A1B1options(j, 1), A1B1options(j, 2), overallRatio];
           count3 = count3 + 1;
        end
    end
end

% possible pressure angles
pressureAngleOptions = [14, 20, 25];

% generate possible diametral pitches
count4 = 1;
for i = 1:size(teethOptions, 1)
    for k = minPitchDiameter:0.1:maxPitchDiameter
        pitchDiameter = k;
        allDiametralPitchOptions(count4, 1) = teethOptions(i, 1)/pitchDiameter;
        count4 = count4 + 1;
    end
end
count5 = 1;
for i = 1:allDiametralPitchOptions(end)
    for j = 1:allDiametralPitchOptions(end)
        if abs(allDiametralPitchOptions(i)-allDiametralPitchOptions(j)) > 1
            diametralPitchOptions(count5, 1) = allDiametralPitchOptions(i);
            count5 = count5 + 1;
        end
    end
end

end