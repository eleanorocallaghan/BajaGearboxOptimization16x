function [teeth] = teethOptions()

    % min and max values
    minNumTeeth = 12;
    maxNumTeeth = 75;
    minOverallRatio = 7.05;
    maxOverallRatio = 7.15;
    minIndividualRatio = 1.5;
    maxIndividualRatio = 2.8;

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

    count7 = 1;
for i = 1:size(teethOptions, 1)
    if teethOptions(i, 2) < teethOptions(i, 4)
        teeth(count7, :) = teethOptions(i, :);
        count7 = count7+1;
    end
end
    
end