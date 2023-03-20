%--------------------------------------------------------------------------
% GUI_Axes.m
%--------------------------------------------------------------------------
% Last updated: 6/10/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles graphical user interface (GUI) for the plotting axes.
%--------------------------------------------------------------------------
classdef GUI_Axes < GUI
    
    properties        
        axes; 
    end
    
    methods
       
        % constructor
        function obj = GUI_Axes(parent, position)
            
            % call parent constructor
            obj = obj@GUI(parent, position); 
            
            % axes properties
            obj.axes = axes(obj.parent);
            obj.axes.NextPlot = 'add';
            obj.axes.Units = 'pixels';
            obj.axes.Color = [0.25, 0.25, 0.25];
            obj.axes.Position = obj.TransformPosition(obj.position);
            obj.axes.XLimMode = 'manual';
            obj.axes.YLimMode = 'manual';
               
            % grid shit
            obj.ToggleGridOn();
            obj.axes.Layer = 'top';
            obj.axes.GridColorMode = 'manual';
            obj.axes.GridColor = [0, 1, 1];
            obj.axes.MinorGridColor = [0, 1, 1];
            obj.axes.GridAlpha = 0.5;
            obj.axes.MinorGridAlpha = 0.5;
            
        end
        
        function ResetProperties(obj)            
            
        end
        
        function ToggleGridOn(obj)            
            obj.axes.YMinorGrid = 'on';
            obj.axes.XMinorGrid = 'on';           
            obj.axes.XGrid = 'on';
            obj.axes.YGrid = 'on';
        end
        
        function ToggleGridOff(obj)            
            obj.axes.YMinorGrid = 'off';
            obj.axes.XMinorGrid = 'off';
            obj.axes.XGrid = 'off';
            obj.axes.YGrid = 'off';         
        end
 
        % handle resize
        function OnResize(obj)
            
            obj.position(4) = obj.parent.Position(4) - 200;
            obj.position(3) = obj.position(4);
            
            obj.axes.Position = obj.TransformPosition(obj.position);
            
        end
        
        % return mouse position in axes coordinates
        function [x, y] = GetMousePosition(obj)           
            c = get(obj.axes, 'CurrentPoint');      
            x = c(1, 1);
            y = c(1, 2);           
        end
        
    end
    
end