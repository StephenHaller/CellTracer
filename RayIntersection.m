%--------------------------------------------------------------------------
% RayIntersection.m
%--------------------------------------------------------------------------
% Last updated: 6/29/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles data for 3D ray intersections.
%--------------------------------------------------------------------------
classdef RayIntersection < handle & matlab.mixin.Copyable
    
    properties
        position;
        distance;
    end
    
    methods
        
        % constructor
        function obj = RayIntersection(position, distance)
            obj.position = position;
            obj.distance = distance;
        end
        
    end
    
end