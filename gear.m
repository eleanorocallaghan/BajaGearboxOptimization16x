classdef gear < handle
    
    properties
        % material properties
        density
        hardness
        % optimized values
        numTeeth
        pitchDiameter
        pressureAngle
        gearThickness
        % calculated values
        module
        toothWidth
        toothDepth
        mass
        torque
        tangentLoad
        momentOfInertia
        angVelocity
        kineticEnergy
        pitchLineVelocity
        diametralPitch
        gearSpeed
        bendingStress
        contactStress
        % factors
        lewisFactor %calculated
        dynamicFactor %calculated
        overloadFactor
        loadDistribFactor
        rimThicknessFactor
        profileShiftFactor
        sizeFactor
        surfaceConditionFactor
        geometryFactor
        elasticCoefficient
    end
    
    methods
        function obj = gear()
        end
        
        function obj = calcModule(obj)
            obj.module = 4; % FIX MEEEEEE
        end
        
        function obj = calcMass(obj)
            obj.mass = obj.density * pi * (obj.pitchDiameter/2)^2 * obj.gearThickness;
        end
        
        function obj = calcTangentLoad(obj)
            obj.tangentLoad = obj.torque/(obj.diametralPitch/2);
        end
        
        function obj = calcMomentOfInertia(obj)
            obj.momentOfInertia = 0.5 * obj.mass * (obj.pitchDiameter/2)^2;
        end
        
        function obj = calcKineticEnergy(obj)
            obj.kineticEnergy = 0.5 * obj.momentOfInertia * (obj.angVelocity)^2;
        end
        
        function obj = calcPitchLineVelocity(obj)
            obj.pitchLineVelocity = (pi*obj.pitchDiameter*obj.gearSpeed)/12; % (ft/min)
        end
        
        function obj = calcDynamicFactor(obj)
            obj.dynamicFactor = (1200 + obj.pitchLineVelocity)/1200;
        end
        
        function obj = calcLoadDistribFactor(obj)
            obj.loadDistribFactor = 2; % FIX MEEEEE
        end
        
        function obj = calcDiametralPitch(obj)
            obj.diametralPitch = obj.numTeeth/obj.pitchDiameter;
        end
        
        function obj = calcLewisFactor(obj)
            %{
            obj.module = obj.pitchDiameter/obj.numTeeth; %pitch diameter in mm
            %obj.toothWidth = ((pi/2)+2*obj.profileShiftFactor*tand(obj.pressureAngle)*obj.module);
            obj.toothWidth = pi*(obj.module)*0.5;
            obj.toothDepth = 2.25*(obj.module);
            obj.diametralPitch = obj.numTeeth/(obj.pitchDiameter); %pitch diameter in
            %obj.lewisFactor = (2*((obj.toothWidth^2)/(4*obj.toothDepth))*obj.diametralPitch)/3;
            obj.lewisFactor = (obj.toothWidth*obj.diametralPitch)/(6*obj.toothDepth);
            %}
            obj.lewisFactor = calcLewisFactorTables(obj);
        end
        
        function obj = calcBendingStress(obj)
            obj.bendingStress = ((obj.tangentLoad*obj.diametralPitch)/...
                (obj.lewisFactor*obj.gearThickness))*obj.overloadFactor*...
                obj.loadDistribFactor*obj.dynamicFactor*obj.rimThicknessFactor;
        end
        
        function obj = calcContactStress(obj)
            obj.contactStress = obj.elasticCoefficient*sqrt(obj.tangentLoad*...
                obj.overloadFactor*obj.dynamicFactor*obj.sizeFactor*...
                (obj.loadDistribFactor/(obj.pitchDiameter*...
                obj.gearThickness))*(obj.surfaceConditionFactor/obj.geometryFactor));
        end
  
    end
    
end