%--------------------------------------------------------------------------
% Database.m
%--------------------------------------------------------------------------
% Last updated: 6/10/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles data for cell.
%--------------------------------------------------------------------------
classdef Database < handle
    
    properties        
        samples;                % array of samples
        count;                  % number of samples
        id;                     % index of current sample
        
        h1;                     % image plot
        h2;                     % profile plot 1: points
        h3;                     % profile plot 2: splines
        h6;                     % profile plot 3: tangents
        
        h4;                     % plane plot 1: points
        h5;                     % plane plot 2: splines
        h7;                     % plane plot 3: tangents
        
    end 
    
    methods
        
        % constructor
        function obj = Database()
            obj.samples = Sample.empty();
            obj.id = 0;
            obj.count = 0;            
        end
        
        % return current sample
        function sample = GetCurrentSample(obj)
            sample = obj.samples(obj.id);
        end
        
        % return sample
        function sample = GetSample(obj, i)
            sample = obj.samples(i);
        end
        
        % read multi-image .tif file
        function read(obj, file)
            
            % read image information
            INFO = imfinfo(file);

            % number of images
            n = numel(INFO);

            % initialze samples
            for i = 1 : n
                
                S = Sample();
                S.frame = Frame(INFO(i), imread(file, 'Index', i));
                S.profile = Spline();
                S.plane = Spline();
    
                obj.samples(i) = S;
                
            end  
            
            obj.count = n;
            obj.id = 1;

        end
               
        function NextSample(obj)
            if obj.id < obj.count
                obj.SetSample(obj.id + 1);              
            end
        end
        
        function PreviousSample(obj)
            if obj.id > 1
                obj.SetSample(obj.id - 1);
            end
        end
        
        function SetSample(obj, id)
            obj.id = id;
        end
        
        
        
        
        % builds plots
        function BuildPlots(obj, ax)     
            
            LineWidth = 1.5;
            
            % image plot
            if obj.id > 0
                obj.h1 = imshow(obj.GetCurrentSample().frame.data, 'Parent', ax);
                x = obj.GetCurrentSample().frame.info.Width();
                y = obj.GetCurrentSample().frame.info.Height();
            else
                obj.h1 = imshow(zeros(249, 249), 'Parent', ax);
            end
            
            ax.XLim = [0, x];
            ax.YLim = [0, y];
            
            % profile plots
            obj.h3 = plot(ax, nan, nan, 'm-', 'LineWidth', LineWidth);
            obj.h2 = plot(ax, nan, nan, 'yo', 'LineWidth', LineWidth, 'MarkerFaceColor', [1,1,0]); 
            obj.h6 = plot(ax, nan, nan, 'y--o', 'LineWidth', LineWidth, 'MarkerFaceColor', [1,1,0]); 
            
            % plane plots
            obj.h5 = plot(ax, nan, nan, 'c-', 'LineWidth', LineWidth);
            obj.h4 = plot(ax, nan, nan, 'yo', 'LineWidth', LineWidth, 'MarkerFaceColor', [1,1,0]);
            obj.h7 = plot(ax, nan, nan, 'y--o', 'LineWidth', LineWidth, 'MarkerFaceColor', [1,1,0]); 
            
        end

        % updates plots
        function UpdatePlots(obj)  
            
            % image plot
            obj.h1.CData = obj.GetCurrentSample().frame.data;
            
            % profile plot
            obj.GetCurrentSample().profile.Plot(obj.h2, obj.h3, obj.h6);
            
            % plane plot
            obj.GetCurrentSample().plane.Plot(obj.h4, obj.h5, obj.h7);
            
        end
        
    end
    
end