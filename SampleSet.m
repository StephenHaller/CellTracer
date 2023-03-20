classdef SampleSet < handle
    
    properties
        samples;
    end
    
    methods
        
        function obj = SampleSet()
            obj.samples = Sample.empty();
        end
        
        function AddSample(obj, sample)
        
            n = numel(obj.samples);
            obj.samples(n + 1) = sample;
            
        end
        
    end
    
end