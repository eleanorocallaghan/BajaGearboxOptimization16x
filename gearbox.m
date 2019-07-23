classdef gearbox < handle
    
    properties
        % given values, based on engine and CVT (initialized in
        % gearboxOpti)
        inputSpeed %rpm
        inputTorque %lbin
        % calculated values (in gearboxOpti)
        lifetime %hours
        ratio
        totalKE %lbin
    end
    
    methods
        
        function obj = gearbox()
        end
        
    end
    
end