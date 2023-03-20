%--------------------------------------------------------------------------
% Vect3.m
%--------------------------------------------------------------------------
% Last updated: 3/23/2022 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles 3D vectors.
%--------------------------------------------------------------------------
classdef Vect3 < handle & matlab.mixin.Copyable
    
    properties 
        x;
        y;
        z;
    end
    
    methods
        
        % constructor
        function obj = Vect3(x, y, z)
            
            if nargin == 0
                
                obj.x = 0;
                obj.y = 0;
                obj.z = 0;
                
            else
                
                obj.x = x;
                obj.y = y;
                obj.z = z;
            
            end
            
        end
        
        function SetArray(obj, a)
            
            obj.x = a(1);
            obj.y = a(2);
            obj.z = a(3);
            
        end
        
        function a = GetArray(obj)
        
            a = [obj.x, obj.y, obj.z];
            
        end
        
        function h = Plot(obj)
            
            h = plot(obj.x, obj.y, 'ko');

        end
        
        function Print(obj)
        
            fprintf("Vect3\nX: %12.3f\nY: %12.3f\nZ: %12.3f\n\n", obj.x, obj.y, obj.z);
            
        end
        
    end
    
    methods (Static)
        
        function p = Flip(u)
           
            p = Vect3.Scale(u, -1);
            
        end
        
        function mag = Magnitude(u)
            
            mag = sqrt(u.x * u.x + u.y * u.y + u.z * u.z);
            
        end
        
        function v = Normalize(u)

            v = Vect3.Scale(u, 1 / Vect3.Magnitude(u));
            
        end
        
        function dist = Distance(u, v)
         
            dist = Vect3.Magnitude(Vect3.Sub(u, v));
            
        end
        
        function mean = Mean(u, v)
            
            mean = Vect3.Scale(Vect3.Add(u, v), 0.5);
            
        end
        
        function p = Add(u, v)
            
            p = Vect3(u.x + v.x, u.y + v.y, u.z + v.z);
            
        end
        
        function p = Sub(u, v)
            
            p = Vect3(u.x - v.x, u.y - v.y, u.z - v.z);
            
        end
        
        function p = Scale(u, scale)
            
            p = Vect3(scale * u.x, scale * u.y, scale * u.z);
            
        end
        
        function d = Dot(u, v)
            
            d = u.x * v.x + u.y * v.y + u.z * v.z;
            
        end
        
        function p = Cross(u, v)
            
            c = cross(u.GetArray(), v.GetArray());
            p = Vect3(c(1), c(2), c(3));
            
        end
        
    end
    
end