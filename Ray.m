%--------------------------------------------------------------------------
% Ray.m
%--------------------------------------------------------------------------
% Last updated: 6/29/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles 3D rays.
%--------------------------------------------------------------------------
classdef Ray < handle & matlab.mixin.Copyable
    
    properties
        origin;
        direction;
    end
    
    methods
        
        % constructor
        function obj = Ray(origin, direction)
            obj.origin = origin;
            obj.direction = direction;
        end
        
        % Note: only works for 2D lines in the XY plane!
        function data = LineIntersection(obj, L2)

            % ray line segment
            L1 = Line(obj.origin, Vect3.Add(obj.origin, obj.direction));
            
            x1 = L1.p1.x;
            x2 = L1.p2.x;
            x3 = L2.p1.x;
            x4 = L2.p2.x;
            
            y1 = L1.p1.y;
            y2 = L1.p2.y;
            y3 = L2.p1.y;
            y4 = L2.p2.y;

            % parametric value for L1
            tn = (x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4); 
            td = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);    
            t = tn / td;
            
            % parametric value for L2
            un = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
            ud = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);            
            u = un / ud;
            
            if u < 0 || u > 1 || t < 0 || isnan(t) || isnan(u)
                
                % return no intersection
                data = RayIntersection(Vect3(inf, inf, inf), -1);
                
            else
                
                % intersection point
                point = Vect3(x1 + t * (x2 - x1), y1 + t * (y2 - y1), 0);
                
                % intersection distance
                distance = Vect3.Distance(point, obj.origin);
                
                % return intersection
                data = RayIntersection(point, distance);
                
            end

        end
        
    end
    
end