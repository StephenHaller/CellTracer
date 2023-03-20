classdef Entry < handle & matlab.mixin.Copyable
    
    properties   
        id;
        type;
        path;
        date;
        %
        PolylineSet;
        SampleSet;
        FrameSet;
        
    end
    
    methods
    
        function obj = Entry()
            
        end
        
        function data = GetPosition(obj)
            
            % number of time points
            n = numel(obj.PolylineSet.time);

            % unit conversion
            unit = 1 / obj.FrameSet.frames.info.XResolution;

            % get origin
            obj.PolylineSet.poly_profiles(1).SetCentroid();
            origin = obj.PolylineSet.poly_profiles(1).centroid;
            
            % initialize data
            data = zeros(n, 2);
            
            for i = 1 : n
    
                % get centroid
                obj.PolylineSet.poly_profiles(i).SetCentroid();
                centroid = obj.PolylineSet.poly_profiles(i).centroid;
                centroid = Vect3.Sub(centroid, origin);
                
                data(i, :) = [centroid.x, centroid.y] * unit;

            end
            
        end
        
        
        function LoadImages(obj)
            
            obj.FrameSet.Reset();
            
            file = sprintf('.%s%s%s%d.tif', filesep(), "tif", filesep(), obj.id);
   
            % read image information
            INFO = imfinfo(file);
            
            % number of images
            n = numel(INFO);
            
            % initialze samples
            for i = 1 : n

                obj.FrameSet.AddFrame(Frame(INFO(i), imread(file, 'Index', i)));
               
            end  
              
        end
        
        function PlotS(obj, idx)
            
            F = figure();
            A = axes();
            A.NextPlot = 'Add';
            
            
            
            image(obj.FrameSet.frames(idx).data);
            
            % line
            h2 = plot(nan, nan);
            h2.Color = [1, 0, 1];
            h2.LineWidth = 1.5;
            
            % markers
            h1 = plot(nan, nan);
            h1.Color = 'm';
            h1.LineStyle = 'none';
            h1.Marker = 'o';
            h1.MarkerFaceColor = 'm';
            h1.MarkerEdgeColor = 'm';
            
           
            
            
            
            h3 = plot(nan, nan);
            
            obj.SampleSet.samples(idx).profile.Plot(h1, h2, h3);
            
            
            
            
            % line
            h5 = plot(nan, nan);
            h5.Color = [0, 1, 1];
            h5.LineWidth = 1.5;
            
            % markers
            h4 = plot(nan, nan);
            h4.Color = 'c';
            h4.LineStyle = 'none';
            h4.Marker = 'o';
            h4.MarkerFaceColor = 'c';
            h4.MarkerEdgeColor = 'c';
            
            h6 = plot(nan, nan);
            
            
            
            h3 = plot(nan, nan);
            
            obj.SampleSet.samples(idx).plane.Plot(h4, h5, h6);
            
            
            
            
        end
        
        
        
        function Plot(obj)
            
            
            F = figure();
            A = axes();
            
            A.YDir = 'reverse';
            
            A.XLim = [-20, 20];
            A.YLim = [-20, 20];
            
            A.XLabel.String = sprintf("X (%sm)", char(181));
            A.YLabel.String = sprintf("Y (%sm)", char(181));
            
            
            A.NextPlot = 'Add';
      
            
            n = numel(obj.PolylineSet.time);
            
            c1 = [ 0, 176,  80];
            c2 = [95, 240, 240];
            
            % unit conversion
            unit = 1 / obj.FrameSet.frames.info.XResolution;

      
            
            obj.PolylineSet.poly_profiles(1).SetCentroid();
            origin = obj.PolylineSet.poly_profiles(1).centroid;
            
            data = zeros(n, 2);
            
            for i = 1 : n
    
                obj.PolylineSet.poly_profiles(i).SetCentroid();
                centroid = obj.PolylineSet.poly_profiles(i).centroid;
                centroid = Vect3.Sub(centroid, origin);
                
                data(i, :) = [centroid.x, centroid.y] * unit;
                
                color = interp1([0; 1], [c1; c2], (i - 1) / (n - 1)); 
                color = floor(color) / 255;
                
                h = obj.PolylineSet.poly_profiles(i).Plot();
                h.Marker = 'none';
                h.LineWidth = 0.5;
                h.Color = color;
                h.XData = (h.XData - origin.x) * unit;
                h.YData = (h.YData - origin.y) * unit;
         

                %
                h = obj.PolylineSet.poly_planes(i).Plot();
                h.Marker = 'none';
                h.LineWidth = 0.5;
                h.Color = color;
                h.XData = (h.XData - origin.x) * unit;
                h.YData = (h.YData - origin.y) * unit;

            end
            
            plot(data(:, 1), data(:, 2), 'k-');
            plot(data(:, 1), data(:, 2), 'm*');
            
        end
            
        
        
        
        
        
        
        function Plot2(obj)
            
            %
            %F = figure();
            A = axes();
            
            A.YDir = 'reverse';
            
            A.XLim = [-20, 20];
            A.YLim = [-20, 20];
            
            A.XLabel.String = sprintf("X (%sm)", char(181));
            A.YLabel.String = sprintf("Y (%sm)", char(181));
            
            
            A.NextPlot = 'Add';
      
            %
            n = numel(obj.PolylineSet.time);
            
            c1 = [ 0, 176,  80];
            c2 = [95, 240, 240];
            
            % unit conversion
            unit = 1 / obj.FrameSet.frames.info.XResolution;

      
            
            %obj.PolylineSet.poly_profiles(1).SetCentroid();
            %origin = obj.PolylineSet.poly_profiles(1).centroid;
            
            %data = zeros(n, 2);
            
            for i = 1 : n
    
                obj.PolylineSet.poly_profiles(i).SetCentroid();
                origin = obj.PolylineSet.poly_profiles(i).centroid;
                %centroid = Vect3.Sub(centroid, origin);
                
                %data(i, :) = [centroid.x, centroid.y] * unit;
                
                color = interp1([0; 1], [c1; c2], (i - 1) / (n - 1)); 
                color = floor(color) / 255;
                
                h = obj.PolylineSet.poly_profiles(i).Plot();
                h.Marker = 'none';
                h.LineWidth = 0.5;
                h.Color = color;
                h.XData = (h.XData - origin.x) * unit;
                h.YData = (h.YData - origin.y) * unit;
         

                %
                h = obj.PolylineSet.poly_planes(i).Plot();
                h.Marker = 'none';
                h.LineWidth = 0.5;
                h.Color = color;
                h.XData = (h.XData - origin.x) * unit;
                h.YData = (h.YData - origin.y) * unit;

            end
            
            %plot(data(:, 1), data(:, 2), 'k-');
            %plot(data(:, 1), data(:, 2), 'm*');
            
        end
        
        
        
        
        function Plot3(obj)
            
            %
            %F = figure();
%             A = axes();
%             
%             A.YDir = 'reverse';
%             
%             A.XLim = [-20, 20];
%             A.YLim = [-20, 20];
%             
%             A.XLabel.String = sprintf("X (%sm)", char(181));
%             A.YLabel.String = sprintf("Y (%sm)", char(181));
%             
%             
%             A.NextPlot = 'Add';
      
            %
            n = numel(obj.PolylineSet.time);
                     
            % unit conversion
            unit = 1 / obj.FrameSet.frames.info.XResolution;

            A = zeros(1025, 3);
            B = zeros(1025, 3);
            
            for i = 1 : n
    
                A = A + obj.PolylineSet.poly_profiles(i).GetArray();
                B = B + obj.PolylineSet.poly_planes(i).GetArray();

            end
            
            A = A / n;
            B = B / n;
            
            
            n = size(A, 1);
            
            P = Polyline();
            L = Polyline();
            
            for i = 1 : n
                
                v = Vertex();              
                v.position = Vect3(A(i, 1), A(i, 2), 0);
                P.vertex(i) = v;
                
                v = Vertex();
                v.position = Vect3(B(i, 1), B(i, 2), 0);
                L.vertex(i) = v;
                
            end
            
            P.SetCentroid();
            origin = P.centroid;
            
            color = [0, 0, 1];
            
            h = P.Plot();
            h.Marker = 'none';
            h.LineWidth = 1;
            h.Color = color;
            h.XData = (h.XData - origin.x) * unit;
            h.YData = (h.YData - origin.y) * unit;
            
            
            color = [1, 0, 0];
            
            h = L.Plot();
            h.Marker = 'none';
            h.LineWidth = 1;
            h.Color = color;
            h.XData = (h.XData - origin.x) * unit;
            h.YData = (h.YData - origin.y) * unit;
    
        end
        
    end
    
end