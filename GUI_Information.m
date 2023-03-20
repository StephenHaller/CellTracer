%--------------------------------------------------------------------------
% GUI_Information.m
%--------------------------------------------------------------------------
% Last updated: 6/10/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles graphical user interface (GUI) for displaying information.
%--------------------------------------------------------------------------
classdef GUI_Information < GUI
    
    properties        
        text;           % array of static text boxes
        height;
    end
    
    methods
        
        % constructor
        function obj = GUI_Information(parent, position)
            
            % call parent constructor
            obj = obj@GUI(parent, position);
            
            x = obj.position(1);
            y = obj.position(2);         
            w = obj.position(3);
            
            obj.height = 20;
            
            obj.text(1) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " File: ");
            obj.text(2) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " Frame: ");
            obj.text(3) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " Resolution: ");                       
            
            obj.text(4) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " Spline"); 
            obj.text(5) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " Length: "); 
            obj.text(6) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " Area: "); 
            
            obj.text(7) = obj.CreateText(obj.TransformPosition([x, y + obj.height * obj.GetCount(), w, obj.height]), " Mouse: ");            
            
            % calculate height;
            obj.position(4) = obj.height * obj.GetCount();
            
        end
        
        % set width
        function obj.SetWidth(obj, width)
            obj.position(3) = width;
            obj.OnResize();
        end
        
        % return number of static text boxes
        function c = GetCount(obj)
            c = numel(obj.text);
        end

        % update information text
        function Update(obj, data)
            
            S = data.GetCurrentSample();
            
            set(obj.text(1), 'String', sprintf(" File: %s", S.frame.info.Filename));
            set(obj.text(2), 'String', sprintf(" Frame: %d of %d", data.id, data.count));
            set(obj.text(3), 'String', sprintf(" Resolution: %d x %d", S.frame.info.Width, S.frame.info.Height));
            
            %set(obj.text(5), 'String', sprintf(" Length: %1.1f um", S.GetLength()));
            %set(obj.text(6), 'String', sprintf(" Area: %1.1f um^2", S.GetArea()));
            
            % temp bullshit
            C = get(gca, 'CurrentPoint');
            x = C(1, 1);
            y = C(1, 2);
            set(obj.text(7), 'String', sprintf(" Mouse: (%1.1f, %1.1f)", x, y));
            
        end
        
        % handle resize
        function OnResize(obj)
            
            x = obj.position(1);
            y = obj.position(2);
            w = obj.position(3);
            
            n = obj.GetCount();
            
            for i = 1 : n
            
                set(obj.text(i), 'Position', obj.TransformPosition([x, y + obj.height * (i - 1), w, obj.height]));

            end
            
        end
        
    end
      
    methods (Static)
        
        function text = CreateText(position, string)
            
            text = uicontrol('Style', 'text',...
                        	 'Position', position,...
                             'String', string,...
                             'BackgroundColor', [0.2, 0.2, 0.2],...
                             'HorizontalAlignment', 'left',...
                             'ForegroundColor', [1.0, 1.0, 1.0],...
                             'FontName', 'Arial',...
                             'FontSize', 10);
                         
        end
        
    end
    
end