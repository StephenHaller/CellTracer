%--------------------------------------------------------------------------
% Frame.m
%--------------------------------------------------------------------------
% Last updated: 6/10/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles an image frame.
%--------------------------------------------------------------------------
classdef Frame < handle
    
    properties      
        info;
        data;      
    end
    
    methods
        
        % constructor
        function obj = Frame(info, data)
            
            if nargin == 0
                
                obj.info = [];
                obj.data = [];
                
            else
            
                obj.info = info;
                obj.data = data;
            
            end
            
        end
        
        % return width
        function w = width(obj)
            w = size(obj.data, 2);
        end
        
        % return height
        function h = height(obj)
            h = size(obj.data, 1);
        end
        
        % plot image for debugging
        function DebugPlot(obj)
            figure();
            imshow(obj.data);
        end
        
    end
    
end