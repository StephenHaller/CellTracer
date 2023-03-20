%--------------------------------------------------------------------------
% Vertex.m
%--------------------------------------------------------------------------
% Last updated: 3/23/2022 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles 3D vertices for storing polygon information.
%--------------------------------------------------------------------------
classdef Vertex < handle & matlab.mixin.Copyable
   
    properties
        position;
        normal;
        tangent;
        binormal;
        curvature; 
    end
    
    methods
        
        % constructor
        function obj = Vertex()
            obj.position = Vect3();
            obj.normal = Vect3();
            obj.tangent = Vect3();
            obj.binormal = Vect3();
            obj.curvature = 0;
        end
        
    end
    
end