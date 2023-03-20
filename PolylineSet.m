%--------------------------------------------------------------------------
% PolylineSet.m
%--------------------------------------------------------------------------
% Last updated: 3/17/2022 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles polyline time series data.
%--------------------------------------------------------------------------
classdef PolylineSet < handle
   
    properties      
        poly_profiles;
        poly_planes;
        name;
        samples;
        profiles;
        planes;
        data_profiles;
        data_planes;
        time;
    end
    
    methods
        
        % constructor
        function obj = PolylineSet(samples)          
            obj.poly_profiles = Polyline.empty();   
            obj.poly_planes = Polyline.empty();
            obj.name = '';
            obj.samples = samples;
            obj.time = [];
        end
        
        % 
        function AddPolyProfile(obj, profile)
            n = numel(obj.poly_profiles);
            obj.poly_profiles(n + 1) = profile;
        end
        
        %
        function AddPolyPlane(obj, plane)
            n = numel(obj.poly_planes);
            obj.poly_planes(n + 1) = plane;
        end
        
        
        
        
        
        
        % read .geo file
        function Read(obj, file)
            
            % check if file exists
            if ~isfile(file)                
                error("'%s' is not a file!\n", file);
                return;              
            end
            
            fprintf("Reading: '%s'... ", file);
            
            % read name
            tmp = split(file, filesep());
            tmp = split(tmp{end}, '.');
            obj.name = tmp{1};
            
            % open file for reading
            fid = fopen(file, 'r');
            
            
            
           
            obj.poly_profiles(1, 64) = Polyline();
            obj.poly_planes(1, 64) = Polyline();
            
            k = 0;
            
            tline = 'start';
            
            while ~isempty(tline)
            
                % Timestep
                if fgetl(fid) == -1
                    break;
                end
                
                k = k + 1;
                
                % Relative Time
                tline = fgetl(fid);
                tmp = split(tline, ':');
                tmp = split(tmp{2}, ' ');
                t = str2double(tmp{2});         
                obj.time = [obj.time, t];
                
                % Vertex Count
                tline = fgetl(fid);
                tmp = split(tline, ':');
                n = str2double(tmp{2}) + 1;

                % profile
                fgetl(fid);
                fgetl(fid);           
                obj.poly_profiles(k) = obj.ReadPolyline(fid, n, t);

                % line
                fgetl(fid);
                fgetl(fid);           
                obj.poly_planes(k) = obj.ReadPolyline(fid, n, t);
            
            
            end
            
            fclose(fid);
            
            obj.poly_profiles(k + 1 : end) = [];
            obj.poly_planes(k + 1 : end) = [];
            
            fprintf("Complete\n");
            
        end
        
        
        function p = ReadPolyline(~, fid, n, t)
            
            % Create Polyline           
            p = Polyline();
            p.time = t;
            
            % initialize
            p.vertex(1, n) = Vertex();
            
            for i = 1 : n
            
                tline = fgetl(fid); 
                d = sscanf(tline, '%16d%16f%16f%16f%16f%16f%16f%16f%16f%16f%16f%16f%16f%16f%16f');

                p.vertex(i).position = Vect3(d(3), d(4), d(5));
                p.vertex(i).normal = Vect3(d(6), d(7), d(8));
                p.vertex(i).tangent = Vect3(d(9), d(10), d(11));
                p.vertex(i).binormal = Vect3(d(12), d(13), d(14));
                p.vertex(i).curvature = d(15);
                
            end

        end
        
        
        
        
        
        
        % write .geo file
        function Write(obj)
            
            fid = fopen([obj.name, 'fuck.geo'], 'w');
            
            n1 = numel(obj.poly_profiles);
            n2 = numel(obj.poly_planes);
            m = obj.samples + 1;

            n = n1;
            
            obj.data_profiles = zeros(n, 3, m);
            obj.data_planes = zeros(n, 3, m);
            obj.time = zeros(n, 1);
            
            for i = 1 : n
               
                t = (i - 1) * 0.5;
                
                fprintf(fid, "Timestep: %d\n", i);
                %fprintf(fid, "Absolute Time: %1.2f\n", t + );
                fprintf(fid, "Relative Time: %1.2f hours\n", t); 
                fprintf(fid, "Vertex Count: %d\n", obj.samples);
                
                obj.time(i) = t;
                
                fprintf(fid, "Cell Profile:\n");
                fprintf(fid, "%16s%16s", 'Segment', 'T-value');
                fprintf(fid, "%16s%16s%16s", 'Position X', 'Position Y', 'Position Z');
                fprintf(fid, "%16s%16s%16s", 'Normal X', 'Normal Y', 'Normal Z');
                fprintf(fid, "%16s%16s%16s", 'Tangent X', 'Tangent Y', 'Tangent Z');
                fprintf(fid, "%16s%16s%16s", 'Binormal X', 'Binormal Y', 'Binormal Z');
                fprintf(fid, "%16s", 'Curvature');
                fprintf(fid, "\n");
                
                % profiles
                for j = 1 : m
                
                    % vertex
                    v = obj.poly_profiles(i).vertex(j);
                    
                    fprintf(fid, "%16d%16.8f", 0, 0);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.position.x, v.position.y, v.position.z);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.normal.x, v.normal.y, v.normal.z);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.tangent.x, v.tangent.y, v.tangent.z);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.binormal.x, v.binormal.y, v.binormal.z);
                    fprintf(fid, "%16.8f", v.curvature);
                    fprintf(fid, "\n");
                    
                    obj.data_profiles(i, 1, j) = v.position.x;
                    obj.data_profiles(i, 2, j) = v.position.y;
                    obj.data_profiles(i, 3, j) = v.position.z;
                    
                end

                fprintf(fid, "Division Plane:\n");
                fprintf(fid, "%16s%16s", 'Segment', 'T-value');
                fprintf(fid, "%16s%16s%16s", 'Position X', 'Position Y', 'Position Z');
                fprintf(fid, "%16s%16s%16s", 'Normal X', 'Normal Y', 'Normal Z');
                fprintf(fid, "%16s%16s%16s", 'Tangent X', 'Tangent Y', 'Tangent Z');
                fprintf(fid, "%16s%16s%16s", 'Binormal X', 'Binormal Y', 'Binormal Z');
                fprintf(fid, "%16s", 'Curvature');
                fprintf(fid, "\n");
                
                % planes
                for j = 1 : m
                
                    % vertex
                    v = obj.poly_planes(i).vertex(j);
                    
                    fprintf(fid, "%16d%16.8f", 0, 0);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.position.x, v.position.y, v.position.z);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.normal.x, v.normal.y, v.normal.z);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.tangent.x, v.tangent.y, v.tangent.z);
                    fprintf(fid, "%16.8f%16.8f%16.8f", v.binormal.x, v.binormal.y, v.binormal.z);
                    fprintf(fid, "%16.8f", v.curvature);
                    fprintf(fid, "\n");
                    
                    obj.data_planes(i, 1, j) = v.position.x;
                    obj.data_planes(i, 2, j) = v.position.y;
                    obj.data_planes(i, 3, j) = v.position.z;
                    
                end
                
            end
            
            fclose(fid);
            
        end
        
        
        
        
    end
    
    methods (Static)
       
        % helper function
        function value = GetValue(line, index)        
            tmp = split(line);        
            value = str2double(tmp{index});        
        end
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % Analysis
    methods 
        
        function PlotTangent(obj)
           
            F = figure();
            A = axes(F);
            A.NextPlot = 'Add';
            A.YLim = [-90, 90];
            A.YTick = (A.YLim(1) : 30 : A.YLim(2));
            
            
            m = numel(obj.poly_planes);
            
            n = Vect3(0, -1, 0);
            d = Vect3(0, 0, 1);
            
            for i = 1 : m
               
                t = obj.poly_planes(i).GetTangent();
                
                x(i) = obj.time(i);
                %y(i) = acos(Vect3.Dot(n, t)) / pi() * 180;
                
                % signed angle
                angle = acos(Vect3.Dot(Vect3.Normalize(n), Vect3.Normalize(t))) / pi() * 180;
                c = Vect3.Cross(n, t);
                
                if Vect3.Dot(d, c) < 0
                   
                    angle = -angle;
                    
                end
                
                y(i) = angle;
                
            end
            
            plot(x, y, 'ko', 'MarkerFaceColor', 'k');
            
            
            
            
            
            T = 0 : 0.01 : obj.time(end);
            n = numel(T);
            
            % time
            for i = 1 : n
                
                t = T(i);
                
                x(i) = t;
                z(i) = interp1(obj.time, y, t, 'spline');
                
            end
            
            plot(x, z, 'k');
            
        end
        
        function Plot(obj)
            
            F = figure();
            A = axes(F);
          	A.NextPlot = 'Add';
            A.DataAspectRatio = [1,1,1];
            A.YDir = 'Reverse';
            A.XLim = [0, 500];
            A.YLim = [0, 500];
            
            % plots
            h1 = plot(A, nan, nan, 'b-o', 'MarkerFaceColor', 'b');
            h2 = plot(A, nan, nan, 'r-o', 'MarkerFaceColor', 'r');
            h3 = plot(A, nan, nan, 'k-o', 'MarkerFaceColor', 'k');
            h4 = plot(A, nan, nan, 'm-o', 'MarkerFaceColor', 'm');
            
            %n = 160+1;           
            %T = linspace(0, obj.time(end), n);
            
            T = 0 : 1 : obj.time(end);
            n = numel(T);
            
            m = obj.samples + 1;
            
            x = zeros(m, 1);
            y = zeros(m, 1);
            
            % time
            for i = 1 : n
                
                t = T(i);
                
                % point
                for j = 1 : m
                    
                    x(j) = interp1(obj.time, obj.data_profiles(:, 1, j), t, 'spline');
                    y(j) = interp1(obj.time, obj.data_profiles(:, 2, j), t, 'spline');
                    %x(j) = obj.data(i, 1, j);
                    %y(j) = obj.data(i, 2, j);
                    
                end
                
                h1.XData = x;
                h1.YData = y;
                
                if rem(t, 0.5) == 0
                   
                    h1.MarkerFaceColor = 'g';
                    
                else
                    
                    h1.MarkerFaceColor = 'b';
                    
                end
                
                
                
                % point
                for j = 1 : m
                    
                    x(j) = interp1(obj.time, obj.data_planes(:, 1, j), t, 'spline');
                    y(j) = interp1(obj.time, obj.data_planes(:, 2, j), t, 'spline');
                    %x(j) = obj.data(i, 1, j);
                    %y(j) = obj.data(i, 2, j);
                    
                end
                
                h2.XData = x;
                h2.YData = y;
                
                if rem(t, 0.5) == 0
                   
                    h2.MarkerFaceColor = 'g';
                    
                else
                    
                    h2.MarkerFaceColor = 'r';
                    
                end
                
                
                
                
                
                
                
                
                pause(0.01);
                
            end
            
            
            
        end
        
    end
    
end