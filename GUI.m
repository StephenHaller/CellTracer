%--------------------------------------------------------------------------
% GUI.m
%--------------------------------------------------------------------------
% Last updated: 6/10/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles base graphical user interface (GUI) shit.
%--------------------------------------------------------------------------
classdef GUI < handle
    
    properties
        parent;
        position;
    end
    
    methods
        
        function obj = GUI(parent, position)
            obj.parent = parent;
         	obj.position = position;
        end
        
        % transforms matlab coordinates (button-left) to windows coordinates (top-left) 
        function p = TransformPosition(obj, p)          
            p(2) = obj.parent.Position(4) - p(2) - p(4) + 1;
        end
        
    end
    
end