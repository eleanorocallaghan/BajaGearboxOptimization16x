function [density, hardness, ultimateTensile] = materialOptions(name)

if name == 4150
    density = 0.284; %lb/in^3
    hardness = 314; %Brinell
    ultimateTensile = 159541.5; %psi
elseif name == 9310
    density = 0.282;
    hardness = 264;
    ultimateTensile = 217000;%130534; 
elseif name == 61 %Ferrium C61
    density = .28; %IDK what this actually is
    hardness = 627;
    ultimateTensile = 240000;
elseif name == 53 %Pyrowear alloy 53
    density = 1;
    hardness = 627;
   % ultimateTensile = 
%%elseif name == 
end

end