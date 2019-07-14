%object creation
for i = 1:4
  objarray(i) = gear;
end

%assigning the same value to each object. Use deal:
[objarray.pitchLineVelocity] = deal(0.5);

%assigning different values to each object. 
%Convert array of values to cell array, then convert cell array to comma-separated list:
values = num2cell([1 2 3 4]);
[objarray.pitchDiameter] = values{:};

for i = 1:4
objarray(i) = calcDynamicFactor(objarray(i));
end

%{
%add a constant to each property. 
%convert list of values to array. add value. convert array to cell array. convert cell array to comma-separated list:
values = num2cell([objarray.Value] + 0.6);
[objarray.Value] = values{:};
%}