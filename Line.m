%--------------------------------------------------------------------------
% Line.m
%--------------------------------------------------------------------------
% Last updated: 3/23/2022 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles 3D line segments.
%--------------------------------------------------------------------------
classdef Line < handle & matlab.mixin.Copyable
    
    properties
        p1;         % Vect3
        p2;         % Vect3
    end
    
    methods
        
        % constructor
        function obj = Line(p1, p2)
            
            if nargin == 0
                
                obj.p1 = Vect3();
                obj.p2 = Vect3();
                
            else
                
                obj.p1 = p1;
                obj.p2 = p2;
            
            end
            
        end
        
        function length = GetLength(obj)
           
            length = Vect3.Distance(obj.p1, obj.p2);
            
        end
        
        % 
        function x = GetX(obj)
            x = [obj.p1.x; obj.p2.x];
        end
        
        %
        function y = GetY(obj)
            y = [obj.p1.y; obj.p2.y];
        end
        
        % plot
        function h = Plot(obj)
            
            h = plot(obj.GetX(), obj.GetY(), 'b-');
            
        end
        
        function Print(obj)
            
            fprintf("Line:\n");
            obj.p1.Print();
            obj.p2.Print();
            
        end

    end

    methods (Static)

        % Note: only works for 2D lines in the XY plane!
        function point = LineIntersection(L1, L2)

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
            
            if u < 0 || u > 1 || t < 0 || t > 1 || isnan(u) || isnan(t)
                
                % return no intersection
                point = Vect3(inf, inf, inf);
                
            else
                
                % return intersection point
                point = Vect3(x1 + t * (x2 - x1), y1 + t * (y2 - y1), 0);
                
            end

        end

    end
    
end