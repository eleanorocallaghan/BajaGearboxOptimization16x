function [] = Optimization()

% min and max values
minNumTeeth = 10;
maxNumTeeth = 75;
minIndividualRatio = 2.6;
maxIndividualRatio = 4;
minOverallRatio = 7.05;
maxOverallRatio = 7.15;
minPitchDiameter = 2; %in
maxPitchDiameter = 8; %in
maxGearThickness = 1; %in
thicknessIncrement = 0.05; %in
idealLifetime = 50; %hours

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

% remove combinations that aren't coprime
for i = 1:size(A1B1options, 1)
    if iscoprime(A1B1options(i, :)) ~= 1
        A1B1options(i, :) = 0;
    end
end
A1B1options = [nonzeros(A1B1options(:, 1)), nonzeros(A1B1options(:, 2))];

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
pressureAngleOptions = [14; 20; 25];

% generate possible diametral pitches
count4 = 1;
for i = 1:size(teethOptions, 1)
    for k = minPitchDiameter:0.1:maxPitchDiameter
        pitchDiameter = k;
        allDiametralPitchOptions(count4, 1) = teethOptions(i, 1)/pitchDiameter;
        count4 = count4 + 1;
    end
end
allDiametralPitchOptions = round(allDiametralPitchOptions, 1);
diametralPitchOptions = unique(sort(allDiametralPitchOptions, 2), 'rows');

count5 = 1;
for i = 1:size(teethOptions, 1)
    for j = 1:size(pressureAngleOptions, 1)
        for k = 1:size(diametralPitchOptions, 1)
            for m = 1:4
                gearSizes(m) = teethOptions(i, m)/diametralPitchOptions(k);
            end
            gear
            if max(gearSizes) > maxPitchDiameter || min(gearSizes) < minPitchDiameter
                possibleGearBox = 0;
            else
                gearThickness = maxGearThickness;
                possibleGearBox = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchOptions(k), gearThickness];
            end
            calculations = gearboxOpti(possibleGearBox);
            count5 = count5 + 1;
            if calculations ~= 0
                while calculations(3) > idealLifetime
                    possibleGearBox = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchOptions(k), gearThickness-thicknessIncrement];
                    calculations = gearboxOpti(possibleGearBox);
                end
                gearThickness = gearThickness + thicknessIncrement;
                kineticEnergies(count6) = calculations(2);
                combination(count6) = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchOptions(k), gearThickness];
            end
        end
    end
end

clf(figure(1))
figure(1)
plot(combination(7), kineticEnergies)

end