%object creation
for i = 1:4
  objarray(i) = gear;
end

%assigning the same value to each object. Use deal:
%[objarray.pitchLineVelocity] = deal(0.5);

%assigning different values to each object. 
%Convert array of values to cell array, then convert cell array to comma-separated list:

[objarray(1).pitchDiameter] = 40000;
objarray(1)


%{
for i = 1:4
objarray(i) = calcDynamicFactor(objarray(i));
end
%}

%{
%add a constant to each property. 
%convert list of values to array. add value. convert array to cell array. convert cell array to comma-separated list:
values = num2cell([objarray.Value] + 0.6);
[objarray.Value] = values{:};
%}