%--------------------------------------------------------------------------
% Triangle.m
%--------------------------------------------------------------------------
% Last updated: 6/29/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles 3D triangles.
%--------------------------------------------------------------------------
classdef Triangle < handle & matlab.mixin.Copyable
    
    properties
        p1;
        p2;
        p3;
    end
    
    methods
        
        % constructor
        function obj = Triangle(p1, p2, p3)
            obj.p1 = p1;
            obj.p2 = p2;
            obj.p3 = p3;
        end
        
        % Note: only works for 2D triangles in the XY plane!
        function area = Area(obj)
            
            m = [obj.p1.x obj.p1.y  1
                 obj.p2.x obj.p2.y  1
                 obj.p3.x obj.p3.y  1];
             
            area = 0.5 * det(m);   
            
        end
        
        function normal = Normal(obj)
            normal = Vect3.Normalize(Vect3.Cross(Vect3.Sub(obj.p2, obj.p1), Vect3.Sub(obj.p3, obj.p1)));
        end
        
        function area = CrossArea(obj)            
            area = 0.5 * Vect3.Magnitude(Vect3.Cross(Vect3.Sub(obj.p2, obj.p1), Vect3.Sub(obj.p3, obj.p1)));           
        end
        
        function centroid = Centroid(obj)           
            centroid = Vect3.Scale(Vect3.Add(obj.p3, Vect3.Add(obj.p1, obj.p2)), 1/3);
        end
        
    end
    
end