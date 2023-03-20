classdef FrameSet < handle
    
    properties
        frames;
    end
    
    methods
        
        function obj = FrameSet()
            obj.frames = Frame.empty();
        end
        
        function AddFrame(obj, frame)
        
            n = numel(obj.frames);
            obj.frames(n + 1) = frame;
            
        end
        
        function Reset(obj)
            
            obj.frames = Frame.empty();
            
        end
        
    end
    
end