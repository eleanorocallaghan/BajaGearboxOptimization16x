classdef gear < handle
    
    properties
        % material properties (in materialOptions)
        materialName
        density %lb/in^3
        bendingFatigueLimit %psi
        contactFatigueLimit %psi
        hardness %unitless
        ultimateTensile %psi
        % facts of life (initialized in gearboxOpti)
        numLoadApplication
        % optimized values (generated/optimized in gearboxOpti and Optimization)
        numTeeth
        diametralPitch %in^-1
        pressureAngle %deg
        gearThickness %in
        % values calculated in this program
        module %in
        pitch %pi
        toothWidth %in
        toothDepth %in
        mass %lb
        tangentLoad %lb
        momentOfInertia %lbin^2
        angVelocity %deg/sec
        kineticEnergy %lbin
        pitchLineVelocity %in/sec
        pitchDiameter %in
        bendingStress %psi
        contactStress %psi
        % values calculated in gearboxOpti
        gearSpeed %rpm
        torque %lbin
        contactRatio %unitless
        bendingStressLifetime %hours
        contactStressLifetime %hours
        allowableBendingStress %psi
        allowableContactStress %psi
        numPittingLoadCycles
        numFatigueLoadCycles
        % static factors (all unitless) (initialized in gearboxOpti)
        overloadFactor
        loadDistribFactor
        rimThicknessFactor
        profileShiftFactor
        sizeFactor
        surfaceConditionFactor
        elasticCoefficient %sqrt(psi)
        bendingSafetyFactor
        pittingSafetyFactor
        temperatureFactor
        reliabilityFactor
        % calculated factors (all unitless) (in gearboxOpti)
        dynamicFactor % calculated in this program
        lewisFactor % calculated from tables in another program
        bendingGeometryFactor
        pittingGeometryFactor
        bendingStressCycleFactor
        pittingStressCycleFactor % calculated in optimization program
        hardnessRatioFactor
    end
    
    methods
        function obj = gear()
        end
        
        function obj = getMaterialProperties(obj)
            [obj.density, obj.hardness, obj.ultimateTensile] = materialOptions(obj.materialName);
        end
        
        function obj = calcModule(obj)
            calcPitchDiameter(obj);
            obj.module = obj.pitchDiameter/obj.numTeeth;
        end
        
        function obj = calcPitch(obj)
            calcModule(obj);
            obj.pitch = obj.module*pi;
        end
        
        function obj = calcMass(obj)
            calcPitchDiameter(obj);
            obj.mass = obj.density * pi * (obj.pitchDiameter/2)^2 * obj.gearThickness;
        end
        
        function obj = calcTangentLoad(obj)
            obj.tangentLoad = obj.torque/(obj.diametralPitch/2);
        end
        
        function obj = calcMomentOfInertia(obj)
            calcMass(obj);
            calcPitchDiameter(obj);
            obj.momentOfInertia = 0.5 * obj.mass * (obj.pitchDiameter/2)^2;
        end
        
        function obj = calcAngVelocity(obj)
            obj.angVelocity = obj.gearSpeed*6;
        end
        
        function obj = calcKineticEnergy(obj)
            calcMomentOfInertia(obj);
            calcAngVelocity(obj);
            obj.kineticEnergy = 0.5 * obj.momentOfInertia * (obj.angVelocity)^2;
        end
        
        function obj = calcPitchLineVelocity(obj)
            calcPitchDiameter(obj);
            obj.pitchLineVelocity = (pi*obj.pitchDiameter*obj.gearSpeed*60);
        end
        
        function obj = calcDynamicFactor(obj)
            calcPitchLineVelocity(obj);
            Qv = 7; % AGMA transmission accuracy level number for baja-type gears
            B = 0.25*((12-Qv)^(2/3));
            A = 50+56*(1-B);
            calculatedDynamicFactor = ((A+sqrt(obj.pitchLineVelocity/60))/A)^B;
            if calculatedDynamicFactor > 1
                obj.dynamicFactor = calculatedDynamicFactor;
            else
                obj.dynamicFactor = 1;
            end
        end
        
        function obj = calcPitchDiameter(obj)
            obj.pitchDiameter = obj.numTeeth/obj.diametralPitch;
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
            calcLewisFactor(obj);
            calcDynamicFactor(obj);
            obj.bendingStress = ((obj.tangentLoad*obj.diametralPitch)/...
                (obj.lewisFactor*obj.gearThickness))*obj.overloadFactor*...
                obj.loadDistribFactor*obj.dynamicFactor*obj.rimThicknessFactor;
        end
        
        function obj = calcContactStress(obj)
            calcTangentLoad(obj);
            calcDynamicFactor(obj);
            calcPitchDiameter(obj);
            obj.contactStress = obj.elasticCoefficient*sqrt(obj.tangentLoad*...
                obj.overloadFactor*obj.dynamicFactor*obj.sizeFactor*...
                (obj.loadDistribFactor/(obj.pitchDiameter*...
                obj.gearThickness))*(obj.surfaceConditionFactor/obj.pittingGeometryFactor));
        end
        
  
    end
    
end