%--------------------------------------------------------------------------
% Polyline.m
%--------------------------------------------------------------------------
% Last updated: 3/17/2022 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles 3D polylines composed of vertices.
%--------------------------------------------------------------------------
classdef Polyline < handle
    
    properties
        vertex;         % vertex list
        centroid;       % 
        area;           % double
        length;         % double
        major;          
        minor;
        time;           %
    end
    
    methods
        
        % constructor
        function obj = Polyline()         
            obj.vertex = Vertex();    
            obj.centroid = Vect3(0, 0, 0);
            obj.area = 0;
            obj.length = 0;
            obj.major = Line.empty();
            obj.minor = Line.empty();
            obj.time = 0;
        end
        
        % return length
        function l = GetLength(obj)
            
            % initialize length
            l = 0;
            
            % number of vertices
            n = numel(obj.vertex);
            
            p2 = obj.vertex(1).position;
            
            for i = 2 : n
                
                p1 = p2;
                p2 = obj.vertex(i).position;
                
                l = l + Vect3.Distance(p1, p2);
                
            end
            
        end
        
        function SetCentroid(obj)
            
            % initialize centroid
            obj.centroid = Vect3(0, 0, 0);
            
            % number of vertices
            n = numel(obj.vertex) - 3;
               
            % first point
            v1 = obj.vertex(1).position;

            % initialize
            tarea = 0;
            
            for i = 1 : n

                v2 = obj.vertex(i + 1).position;
                v3 = obj.vertex(i + 2).position;                
                
                % build triangle
                t = Triangle(v1, v2, v3);
                
                c = t.Centroid();
                a = t.Area();
                
                % accumulate centroid
                obj.centroid = Vect3.Add(obj.centroid, Vect3.Scale(c, a));
                
                % accumulate area
                tarea = tarea + a;
                
            end
           
            % finalize centroid
            obj.centroid = Vect3.Scale(obj.centroid, 1 / tarea);
            
        end
        
        % return average curvature
        function c = GetCurvature(obj)
            
            % initialize curvature
            c = 0;
            
            % number of vertices
            n = numel(obj.vertex);
            
            for i = 1 : n

                c = c + obj.vertex(i).curvature;
                
            end
            
            c = c / n;

        end
        
        function v = GetMean(obj)
            
            % initialize mean
            v = Vect3(0, 0, 0);
            
            % number of vertices
            n = numel(obj.vertex);
            
            for i = 1 : n

                v = Vect3.Add(v, obj.vertex(i).position);
                
            end
            
            v = Vect3.Scale(v, 1 / n);
            
        end
        
        %
        function angle = GetAngle(obj)
            
            % DEFINE
            n = Vect3(1, 0, 0);

            t = obj.GetTangent();
            
            angle = acos(Vect3.Dot(Vect3.Normalize(n), Vect3.Normalize(t))) / pi() * 180;

            c = Vect3.Normalize(Vect3.Cross(n, t));

            angle = 90 - angle;
            
            if c.z < 0
                   
                angle = -angle;
                    
            end
            
                     
            

            
%             
%             % DEFINE
%             n = Vect3(0, 1, 0);
% 
%             t = obj.GetTangent();
%             
%             angle = acos(Vect3.Dot(Vect3.Normalize(n), Vect3.Normalize(t))) / pi() * 180;
% 
%             c = Vect3.Normalize(Vect3.Cross(n, t));
%          
%             angle = 90 - angle;
% 
%             if c.z > 0
%                    
%                 angle = -angle;
%                     
%             end
            
        end
        
        % return number of vertices
        function n = GetVertexCount(obj)
            n = numel(obj.vertex);
        end

        % add vertex to vertex list
        function AddVertex(obj, vertex)
            n = obj.GetVertexCount();
            obj.vertex(n + 1) = vertex;
        end
        
        % flip order of vertex list
        function Flip(obj)         
            obj.vertex = flip(obj.vertex);          
        end
        
        % return average tangent vector
        function tangent = GetTangent(obj)
            
            n = obj.GetVertexCount();
            
            tangent = Vect3(0, 0, 0);
            
            for i = 1 : n
               
                tangent = Vect3.Add(tangent, Vect3.Normalize(obj.vertex(i).tangent));
                
            end
            
            tangent = Vect3.Scale(tangent, 1 / n);
            
        end
        
        %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<       
        function SetAxisFast(obj)
           
           % tic();
            
            % origin
            O = obj.centroid.GetArray();
            
            % points
            A = obj.GetArray();
            A(end, :) = [];

            % number of points
            n = size(A, 1);
            
            %
            D = O - A;           
            M = sqrt(sum(D .^ 2, 2));           
            N = D ./ M;
            
            % initialize
            data = zeros(n, n);
            
            for i = 1 : n
                
                a = repmat(N(i, :), [n, 1]);

                data(:, i) = dot(a, N, 2);
                
            end
            
            % each column of data contains one vector dotted with
            % everyother vector
            % dim 1 is vector 2
            % dim 2 is vector 1
            
            [~, id] = min(data);
          
            
            L = M + M(id);
            
            [~, m] = max(L);
            id1 = m;
            id2 = id(m);    
            obj.major = Line(Vect3(A(id1, 1), A(id1, 2), A(id1, 3)), Vect3(A(id2, 1), A(id2, 2), A(id2, 3)));
          
            
            [~, m] = min(L);
            id1 = m;
            id2 = id(m);    
            obj.minor = Line(Vect3(A(id1, 1), A(id1, 2), A(id1, 3)), Vect3(A(id2, 1), A(id2, 2), A(id2, 3)));
          
            
            
            %toc();
            
           % obj.Plot();
            
        end
        
        % calculate and cache major and minor axes
        function SetAxis(obj)
            
          
            
            % origin
            origin = obj.centroid;
            
            % number of points on polygon
            n = obj.GetVertexCount() - 1;
            
            % initialize
            p1 = Vect3.empty();
            p2 = Vect3.empty();    
            
            l = zeros(n, 1);
            
            for i = 1 : n
                
                % polygon point
                point = obj.vertex(i).position;
                
                % calculate direction
                direction = Vect3.Normalize(Vect3.Sub(origin, point));
                
                p1(i) = point;
                p2(i) = obj.RayIntersection(Ray(origin, direction));
                
                l(i) = Vect3.Distance(p1(i), p2(i));
                
            end
            
            % major
            [~, i] = max(l);           
            obj.major = Line(p1(i), p2(i));
            
            % minor
            [~, i] = min(l);
            obj.minor = Line(p1(i), p2(i));           
            
   
            
        end
        
        %
        function point = RayIntersection(obj, ray)
            
            % number of segments on polygon
            n = obj.GetVertexCount() - 1;
            
            % initialize
            point = Vect3(nan, nan, nan);
            
            L = Line();
            
            for i = 1 : n
               
                L.p1 = obj.vertex(i).position;
                L.p2 = obj.vertex(i + 1).position;
                
                I = ray.LineIntersection(L);
                
                if I.distance > 0
                    
                    point = I.position;
                    return;
                    
                end
                
            end
            
        end
        
        
        
        
        function A = GetArray(obj)
            
            % vertex count
            n = numel(obj.vertex);

            % initialize
            A = zeros(n, 3);
            
            for i = 1 : n
                
                A(i, 1) = obj.vertex(i).position.x;
                A(i, 2) = obj.vertex(i).position.y;
                A(i, 3) = obj.vertex(i).position.z;
                
            end
            
        end
        
        
        
        function Print(obj)
            
            n = numel(obj.vertex);
            
            fprintf("Polyline Information:\n");
            fprintf("Vertex Count:\t%d\n", n);
            
            % initialize
            x = zeros(n, 1);
            y = zeros(n, 1);
            z = zeros(n, 1);
            
            for i = 1 : n
                
                x(i) = obj.vertex(i).position.x;
                y(i) = obj.vertex(i).position.y;
                z(i) = obj.vertex(i).position.z;
                
                fprintf("%12.3f%12.3f%12.3f\n", x(i), y(i), z(i));
                
            end
            
            
            
        end
        
        %
        function h = Plot(obj)
            
            %a = axes();
            %a.NextPlot = 'Add';
            
            % number of vertices
            n = numel(obj.vertex);
            
            x = zeros(n, 1);
            y = zeros(n, 1);
            
            for i = 1 : n
                
                x(i) = obj.vertex(i).position.x;
                y(i) = obj.vertex(i).position.y;
                
            end

            h = plot(x, y, 'bo-');
            
            return;
            
            % centroid
            x = obj.centroid.x;
            y = obj.centroid.y;
            h = plot(a, x, y, 'r*');
            
            % angle
            angle = obj.GetAxisAngle();
            text(a, x, y, sprintf("   %1.1f degrees", angle));
            
            
            % long
            x = obj.major.GetX();
            y = obj.major.GetY();
            h = plot(a, x, y, 'g-');
            
            % short
            x = obj.minor.GetX();
            y = obj.minor.GetY();
            h = plot(a, x, y, 'g--');

            
        end
        
        % angle between major and minor axis
        function a = GetAxisAngle(obj)
            
            u = Vect3.Sub(obj.major.p1, obj.major.p2);
            v = Vect3.Sub(obj.minor.p1, obj.minor.p2);
          
            a = acos(Vect3.Dot(u, v) / (Vect3.Magnitude(u) * Vect3.Magnitude(v))) / pi * 180;
    
            if a > 90
                
                a = 180 - a;
                
            end
            
        end
        
        % ratio of major and minor axis
        function r = GetAxisRatio(obj)
            
            r = obj.major.GetLength() / obj.minor.GetLength();

        end
    
    end
    
end