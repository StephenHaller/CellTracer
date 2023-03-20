%--------------------------------------------------------------------------
% SplineIntersection.m
%--------------------------------------------------------------------------
% Last updated: 6/29/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles data for 3D spline intersection.
%--------------------------------------------------------------------------
classdef SplineIntersection < handle & matlab.mixin.Copyable
    
    properties
        position;
        segment;
        t;
    end
    
    methods
        
        % constructor
        function obj = SplineIntersection(position, segment, t)
            obj.position = position;
            obj.segment = segment;
            obj.t = t;
        end
        
    end
    
end