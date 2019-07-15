classdef gear < handle
    
    properties
        % material properties
        materialName
        density % 
        hardness
        % facts of life
        numPittingLoadCycles
        numFatigueLoadCycles
        numLoadApplication
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
        gearSpeed %rpm
        bendingStress
        contactStress
        bendingFatigueLimit
        contactFatigueLimit
        bendingStressLifetime
        contactStressLifetime
        allowableBendingStress
        allowableContactStress
        % factors
        lewisFactor %calculated
        dynamicFactor %calculated
        overloadFactor
        loadDistribFactor
        rimThicknessFactor
        profileShiftFactor
        sizeFactor
        surfaceConditionFactor
        bendingGeometryFactor
        pittingGeometryFactor
        elasticCoefficient
        bendingStressCycleFactor
        pittingStressCycleFactor
        hardnessRatioFactor
        bendingSafetyFactor
        pittingSafetyFactor
        temperatureFactor
        reliabilityFactor
    end
    
    methods
        function obj = gear()
        end
        
        function obj = getMaterialProperties(obj)
            [obj.density, obj.hardness] = materialOptions(obj.materialName);
        end
        
        function obj = calcModule(obj)
            obj.module = 4; % FIX MEEEEEE
        end
        
        function obj = calcMass(obj)
            obj.mass = obj.density * pi * (obj.pitchDiameter/2)^2 * obj.gearThickness;
        end
        
        function obj = calcTorque(obj)
            obj.torque = 3800; %FIX MEEEEE
        end
        
        function obj = calcTangentLoad(obj)
            calcTorque(obj)
            calcDiametralPitch(obj);
            obj.tangentLoad = obj.torque/(obj.diametralPitch/2);
        end
        
        function obj = calcMomentOfInertia(obj)
            calcMass(obj);
            obj.momentOfInertia = 0.5 * obj.mass * (obj.pitchDiameter/2)^2;
        end
        
        function obj = calcAngVelocity(obj)
            obj.angVelocity = 14; %FIX MEEEE
        end
        
        function obj = calcGearSpeed(obj)
            obj.gearSpeed = 3; %FIX MEEEEE
        end
        
        function obj = calcKineticEnergy(obj)
            calcMomentOfInertia(obj);
            calcAngVelocity(obj);
            obj.kineticEnergy = 0.5 * obj.momentOfInertia * (obj.angVelocity)^2;
        end
        
        function obj = calcPitchLineVelocity(obj)
            calcGearSpeed(obj);
            obj.pitchLineVelocity = (pi*obj.pitchDiameter*obj.gearSpeed)/12; % (ft/min)
        end
        
        function obj = calcDynamicFactor(obj)
            calcPitchLineVelocity(obj);
            Qv = 7; % AGMA transmission accuracy level number for baja-type gears
            B = 0.25*((12-Qv)^(2/3));
            A = 50+56*(1-B);
            calculatedDynamicFactor = ((A+sqrt(obj.pitchLineVelocity))/A)^B;
            if calculatedDynamicFactor > 1
                obj.dynamicFactor = calculatedDynamicFactor;
            else
                obj.dynamicFactor = 1;
            end
        end
        
        function obj = calcDiametralPitch(obj)
            obj.diametralPitch = obj.numTeeth/obj.pitchDiameter;
        end
        
        function obj = calcLewisFactor(obj)
            
%             obj.module = obj.pitchDiameter/obj.numTeeth; %pitch diameter in mm
%             obj.toothWidth = ((pi/2)+2*obj.profileShiftFactor*tand(obj.pressureAngle)*obj.module);
            obj.toothWidth = pi*(obj.module)*0.5;
            obj.toothDepth = 2.25*(obj.module);
%             obj.diametralPitch = obj.numTeeth/(obj.pitchDiameter); %pitch diameter in
%             obj.lewisFactor = (2*((obj.toothWidth^2)/(4*obj.toothDepth))*obj.diametralPitch)/3;
%             obj.lewisFactor = (obj.toothWidth*obj.diametralPitch)/(6*obj.toothDepth);
            
            obj.lewisFactor = calcLewisFactorTables(obj);
        end
        
        function obj = calcBendingStress(obj)
            calcTangentLoad(obj);
            calcDiametralPitch(obj);
            calcLewisFactor(obj);
            calcDynamicFactor(obj);
            obj.bendingStress = ((obj.tangentLoad*obj.diametralPitch)/...
                (obj.lewisFactor*obj.gearThickness))*obj.overloadFactor*...
                obj.loadDistribFactor*obj.dynamicFactor*obj.rimThicknessFactor;
        end
        
        function obj = calcContactStress(obj)
            calcTangentLoad(obj);
            calcDynamicFactor(obj);
            obj.contactStress = obj.elasticCoefficient*sqrt(obj.tangentLoad*...
                obj.overloadFactor*obj.dynamicFactor*obj.sizeFactor*...
                (obj.loadDistribFactor/(obj.pitchDiameter*...
                obj.gearThickness))*(obj.surfaceConditionFactor/obj.geometryFactor));
        end
        
  
    end
    
end