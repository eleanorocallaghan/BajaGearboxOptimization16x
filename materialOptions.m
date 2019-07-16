function [density, hardness] = materialOptions(name)

if name == 4150
    density = 4;
    hardness = 630;
elseif name == 9310
    density = 1;
    hardness = 1;
elseif name == 6969
    density = 1;
    hardness = 1;
elseif name == 4536
    density = 1;
    hardness = 1;
end

end