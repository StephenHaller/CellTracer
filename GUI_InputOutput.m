%--------------------------------------------------------------------------
% GUI_InputOutput.m
%--------------------------------------------------------------------------
% Last updated: 6/10/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles graphical user interface (GUI) for inputs and outputs.
%--------------------------------------------------------------------------
classdef GUI_InputOutput < GUI
   
    properties
        pushbutton;         % array of pushbuttons
        height;
        stride;
        path;
        data;
    end
    
    methods
        
        % constructor
        function obj = GUI_InputOutput(parent, position)
            
            % call parent constructor
            obj = obj@GUI(parent, position);
            
            % get current path
            obj.path = pwd();
            obj.data = Database.empty();
            
        	x = obj.position(1);
            y = obj.position(2);
            w = obj.position(3);
            
            obj.height = 25;
            obj.stride = 10;
            
            obj.pushbutton(1) = obj.CreatePushbutton(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Next");
            obj.pushbutton(2) = obj.CreatePushbutton(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Export");
            
            obj.pushbutton(3) = obj.CreateCheckbox(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Division Plane");
            obj.pushbutton(4) = obj.CreateCheckbox(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Daughter Cell Seperation");
            obj.pushbutton(5) = obj.CreateCheckbox(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Daughter Cell Pinching");
            
         	obj.pushbutton(6) = obj.CreateCheckbox(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Difficult");
            
            obj.pushbutton(7) = obj.CreateCheckbox(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Cell (on/off)");
            obj.pushbutton(8) = obj.CreateCheckbox(obj.TransformPosition([x, y + (obj.height + obj.stride) * obj.GetCount(), w, obj.height]), "Division Plane (on/off)");
            
            set(obj.pushbutton(7), 'value', 1);
            set(obj.pushbutton(8), 'value', 1);
            
            % callback functions
            set(obj.pushbutton(1), 'Callback', @obj.ImportCallback);
            set(obj.pushbutton(2), 'Callback', @obj.ExportCallback);
            set(obj.pushbutton(3), 'Callback', @obj.DivisionPlaneCallback);
            set(obj.pushbutton(4), 'Callback', @obj.CellSeperationCallback);
            set(obj.pushbutton(5), 'Callback', @obj.CellPinchingCallback);
            set(obj.pushbutton(6), 'Callback', @obj.DifficultCallback);
            set(obj.pushbutton(7), 'Callback', @obj.CellVisibleCallback);
            set(obj.pushbutton(8), 'Callback', @obj.PlaneVisibleCallback);

        end
        
        function SetData(obj, data)
            obj.data = data;
        end
        
        % return number of pushbuttons
        function c = GetCount(obj)
            c = numel(obj.pushbutton);
        end
        
        function SetWidth(obj, width)
            obj.position(3) = width;
            obj.OnResize();
        end
        
        function OnResize(obj)
            
            x = obj.parent.Position(3) - obj.position(3) - obj.stride;
            y = obj.position(2);
            w = obj.position(3);
                       
            n = obj.GetCount();
            
            for i = 1 : n
            
                set(obj.pushbutton(i), 'Position', obj.TransformPosition([x, y + (obj.height + obj.stride) * (i - 1), w, obj.height]));

            end
            
        end
        
        function Update(obj)
            
            set(obj.pushbutton(3), 'value', obj.data.GetCurrentSample().DivisionPlane);
            set(obj.pushbutton(4), 'value', obj.data.GetCurrentSample().CellSeperation);
            set(obj.pushbutton(5), 'value', obj.data.GetCurrentSample().CellPinching);
            set(obj.pushbutton(6), 'value', obj.data.GetCurrentSample().Difficult);
            
        end
        
    end
    
    methods (Static)
        
        function pushbutton = CreatePushbutton(position, string)
            
            pushbutton = uicontrol('Style', 'pushbutton',...
                        	       'Position', position,...
                                   'String', string,...
                                   'BackgroundColor', [0.2, 0.2, 0.2],...
                                   'ForegroundColor', [1.0, 1.0, 1.0],...
                                   'FontName', 'Arial',...
                                   'FontSize', 10);
            
        end
        
        function checkbox = CreateCheckbox(position, string)
            
            checkbox = uicontrol('Style', 'checkbox',...
                        	     'Position', position,...
                                 'String', string,...
                                 'BackgroundColor', [0.2, 0.2, 0.2],...
                                 'ForegroundColor', [1.0, 1.0, 1.0],...
                                 'FontName', 'Arial',...
                                 'FontSize', 10);
                               
        end
        
    end
    
    methods 
        
        function DifficultCallback(obj, object, ~)
            obj.data.GetCurrentSample().Difficult = get(object, 'value');
        end
        
        function CellVisibleCallback(obj, object, ~)
            obj.data.h2.Visible = get(object, 'value');
            obj.data.h3.Visible = get(object, 'value');
            obj.data.h6.Visible = get(object, 'value');
        end
        
        function PlaneVisibleCallback(obj, object, ~)
            obj.data.h4.Visible = get(object, 'value');
            obj.data.h5.Visible = get(object, 'value');
            obj.data.h7.Visible = get(object, 'value');
        end
        
        function DivisionPlaneCallback(obj, object, ~)      
            obj.data.GetCurrentSample().DivisionPlane = get(object, 'value');            
        end
        
        function CellSeperationCallback(obj, object, ~)      
            obj.data.GetCurrentSample().CellSeperation = get(object, 'value');            
        end
        
        function CellPinchingCallback(obj, object, ~)      
            obj.data.GetCurrentSample().CellPinching = get(object, 'value');            
        end
        
        
        %
        function ImportCallback(obj, ~, ~)
            
            close all
            clear
            clc
            
            
            % get file
            [file, dir, filter] = uigetfile('*.tif');
            
            if filter > 0
                
                name = [dir, file];

                GUI_Main(name)
            
                
            end

            
        end
        
        function ExportCallback(obj, ~, ~)
           
            %
            str = obj.data.GetCurrentSample().frame.info.Filename;
            tmp = split(str, '\');
            tmp = tmp{end};
            tmp = split(tmp,  '.');
            tmp = tmp{1};
            
            
            filename = sprintf('%s.dat', tmp);
            
            fid = fopen(filename, 'w');
           
            n = obj.data.count;
            
            fprintf(fid, "Header\n");
            fprintf(fid, "Count: %d\n", n);
            fprintf(fid, "\n");
            
            for i = 1 : n
                
                % get sample
                S = obj.data.GetSample(i);
                
                fprintf(fid, "Sample: %d\n", i);
                fprintf(fid, "DivisionPlane: %d\n", S.DivisionPlane);
                fprintf(fid, "CellSeperation: %d\n", S.CellSeperation);
                fprintf(fid, "CellPinching: %d\n", S.CellPinching);
                fprintf(fid, "Difficult: %d\n", S.Difficult);
                
                %
                fprintf(fid, "Profile: %s\n", 'closed');
                P = S.profile;
                m = P.GetPointCount();
                for j = 1 : m
                    x = P.points(j).x;
                    y = P.points(j).y;
                    fprintf(fid, "v %18.6f %18.6f\n", x, y); 
                end
                
                
                %
                fprintf(fid, "Plane: %s\n", 'open');
                P = S.plane;
                m = P.GetPointCount();
                for j = 1 : m
                    x = P.points(j).x;
                    y = P.points(j).y;
                    fprintf(fid, "v %18.6f %18.6f\n", x, y); 
                end
                               
                fprintf(fid, "\n");

            end
            
            fclose(fid);
            
        end
        
    end
    
end