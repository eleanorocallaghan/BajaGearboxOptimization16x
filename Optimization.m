function [totalTries, topTwentyNoKE, sortedC] = Optimization()

% min and max values
minNumTeeth = 20;
maxNumTeeth = 75;
minOverallRatio = 7.9;
maxOverallRatio = 8.1;
minIndividualRatio = 2.5;
maxIndividualRatio = 3;
minPitchDiameter = 1.5; %in
maxPitchDiameter = 6.5; %in
maxGearThickness = 1; %in
thicknessIncrement = 0.05; %in
idealLifetime = 40; %hours
minContactRatio = 1.2;
inputToOutputDistance = 6.6145; %in

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
pressureAngleOptions = [14.5; 20; 25];

% generate possible diametral pitches
count4 = 1;
for i = 1:size(teethOptions, 1)
    for k = minPitchDiameter:0.1:maxPitchDiameter
        pitchDiameter = k;
        allDiametralPitchOptions(count4, 1) = teethOptions(i, 1)/pitchDiameter;
        count4 = count4 + 1;
    end
end
allDiametralPitchOptions = round(allDiametralPitchOptions, 0);
diametralPitchOptions = unique(sort(allDiametralPitchOptions, 2), 'rows');
count45 = 1;
for i = 1:size(teethOptions, 1)
    for k = minPitchDiameter:0.1:maxPitchDiameter
        pitchDiameter = k;
        allDiametralPitchOptions2(count45, 1) = teethOptions(i, 3)/pitchDiameter;
        count45 = count45 + 1;
    end
end
allDiametralPitchOptions2 = round(allDiametralPitchOptions2, 0);
allDiametralPitchOptions2 = unique(sort(allDiametralPitchOptions2, 2), 'rows');
count475 = 1;
for i = 1:size(diametralPitchOptions, 1)
    for j = 1:size(allDiametralPitchOptions2, 1)
        diametralPitchChoices(count475, 1) = diametralPitchOptions(i, :);
        diametralPitchChoices(count475, 2) = allDiametralPitchOptions2(j, :);
        count475 = count475 + 1;
    end
end
count48 = 1;
for i = 1:size(diametralPitchChoices, 1)
    if min(diametralPitchChoices(i, :)) > 8 || max(diametralPitchChoices(i, :)) < 20
        allDiametralPitchChoices(count48, :) = diametralPitchChoices(i, :);
        count48 = count48 + 1;
    end
end
diametralPitchChoices = allDiametralPitchChoices;

count5 = 1;
totalTries = 1;
for i = 1:size(teethOptions, 1)
    for j = 1:size(pressureAngleOptions, 1)
        for k = 1:size(diametralPitchChoices, 1)
            for m = 1:2
                gearSizes(m) = teethOptions(i, m)/diametralPitchChoices(k, 1);
            end
            for m = 3:4
                gearSizes(m) = teethOptions(i, m)/diametralPitchChoices(k, 2);
            end
            if (max(gearSizes) < maxPitchDiameter) && (min(gearSizes) > minPitchDiameter)
                gearThickness1 = maxGearThickness;
                gearThickness2 = maxGearThickness;
                possibleGearBox = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchChoices(k, :), gearThickness1, gearThickness2];
                [A1, B1, B2, C1, gearBox, calculations] = gearboxOpti(possibleGearBox);
                totalTries = totalTries + 1
                %calculations = [gearBox.totalKE, gearBox.lifetime, A1B1lifetime, B2C1lifetime, A1.contactRatio, B2.contactRatio, inputToOutput, centerDistance2];
                if (gearSizes(2)/2) > ((gearSizes(3) + gearSizes(4))/2)
                    validGearbox = 1;
                else
                    validGearbox = 0;
                end
                if calculations(2)>idealLifetime && A1.contactRatio > minContactRatio && B2.contactRatio > minContactRatio && abs(calculations(7)-inputToOutputDistance) <= 2 && validGearbox == 1
                    while calculations(3) > idealLifetime
                        gearThickness1 = gearThickness1-thicknessIncrement;
                        possibleGearBox = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchChoices(k, :), gearThickness1, gearThickness2];
                        [A1, B1, B2, C1, gearBox, calculations] = gearboxOpti(possibleGearBox);
                    end
                    gearThickness1 = gearThickness1 + thicknessIncrement;
                    while calculations(4) > idealLifetime
                        gearThickness2 = gearThickness2-thicknessIncrement;
                        possibleGearBox = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchChoices(k, :), gearThickness1, gearThickness2];
                        [A1, B1, B2, C1, gearBox, calculations] = gearboxOpti(possibleGearBox);
                    end
                    gearThickness2 = gearThickness2 + thicknessIncrement;
                    if gearThickness1 < maxGearThickness || gearThickness2 < maxGearThickness
                    kineticEnergies(count5, :) = calculations(1);
                    combinations(count5, :) = [teethOptions(i, 1:4), pressureAngleOptions(j), diametralPitchChoices(k, :), gearThickness1, gearThickness2, A1.contactRatio, B2.contactRatio];
                    count5 = count5 + 1;
                    end
                end
            end
        end
    end
end

combinations(:, 12) = kineticEnergies(:);
[~,indx] = sort(combinations(:,12));
sortedC = combinations(indx,:);
topTwenty = sortedC(1:20, :);

clf(figure(1))
figure(1)
plot(min(topTwenty(:, 6), topTwenty(:, 7)), topTwenty(:, 12), 'o')
title(sprintf('Top Twenty Optimized Gears with a %d Hour Lifetime', idealLifetime))
xlabel('Minimum Contact Ratio')
ylabel('Total KE (lbin)')
labels = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'};
text(min(topTwenty(:, 6), topTwenty(:, 7)),topTwenty(:, 12),labels,'VerticalAlignment','bottom','HorizontalAlignment','right')

topTwentyNoKE = topTwenty(:, 1:11);

end