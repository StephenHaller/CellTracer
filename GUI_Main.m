function main(file)

clc

% build figure
F = figure();
F.Units = 'pixels';
F.Color = [0.15, 0.15, 0.15];
F.DockControls = 'off';
F.Name = 'ChondrocyteTracer v1.0';
F.Position = [120, -120, 1280, 720];
F.MenuBar = 'none';
F.NumberTitle = 'off';
F.ToolBar = 'none';
F.Renderer = 'opengl';

% build GUI elements 
GUI_AXES = GUI_Axes(F, [320, 100, 100, 100]);
GUI_INFO = GUI_Information(F, [10, 10, 300, nan]);
GUI_IO = GUI_InputOutput(F, [800, 10, 200, nan]);

% build database
data = Database();
data.read(file);
data.BuildPlots(GUI_AXES.axes);
GUI_IO.SetData(data);

% callback functions
set(F, 'WindowButtonMotionFcn', @OnMouseMove);
set(F, 'WindowButtonDownFcn', @OnMousePress);
set(F, 'WindowButtonUpFcn', @OnMouseRelease);
set(F, 'WindowScrollWheelFcn', @OnMouseWheel);
set(F, 'WindowKeyPressFcn', @OnKeyboardPress);
set(F, 'SizeChangedFcn', @OnResize);



OnResize();

% temp bullshit
pan = false;
panX = 0;
panY = 0;



















    % handle resize
    function OnResize(~, ~)                      
        GUI_AXES.OnResize();   
        GUI_INFO.OnResize();  
        GUI_IO.OnResize();
    end

    % handle keyboard press
    function OnKeyboardPress(~, eventdata)
   
        
        S = data.GetCurrentSample().profile;
        P = data.GetCurrentSample().plane;

        switch eventdata.Key
            
            case 'return'
                
                if ~S.complete
                
                    % close spline
                    S.points(end) = [];
                    S.segments(end).points(end) = S.points(1);
                    S.closed = true;
                    S.complete = true;
                    S.selected = 0;     
                    data.UpdatePlots();
                    GUI_INFO.Update(data);
                    return;
                end
                
                if ~P.complete
                    
                    P.points(end) = [];
                    P.segments(end) = [];
                    P.complete = true;
                    P.selected = 0;
                    data.UpdatePlots();
                    GUI_INFO.Update(data);
                    return;
                   
                end
                    
            case 'escape'
                
                if P.selected > 0 || P.complete
                    P.reset
                else
                    S.reset();
                end
                
            case 'space'
       
                S.ComputeShit();
           
            case 'downarrow'
                
                data.NextSample();
                
                
            case 'uparrow'
                
                data.PreviousSample();
  
        end
        
        data.UpdatePlots();
        GUI_INFO.Update(data);
        GUI_IO.Update();
    end

    % handle mouse move
    function OnMouseMove(object, eventdata)
      
        % get mouse position
        [x, y] = GUI_AXES.GetMousePosition();
        
        % get profile and plane splines
        S = data.GetCurrentSample().profile;
        P = data.GetCurrentSample().plane;
        

    	% get axes
        A = GUI_AXES.axes;
    
        if pan
           
           	% mouse position
          	C = get(A, 'CurrentPoint');
             
            % x range
            x1 = A.XLim(1);
            x2 = A.XLim(2);
            
            % y range
            y1 = A.YLim(1);
            y2 = A.YLim(2);
 
            % mouse position
            dx = C(1, 1) - panX;
            dy = C(1, 2) - panY;

            panX = C(1, 1);
            panY = C(1, 2);
            
            A.XLim = [x1 - dx; x2 - dx];
            A.YLim = [y1 - dy; y2 - dy];
            
        end
        
        
        % update selected profile vertex
        if S.selected > 0
            
            S.SetSelectedPoint(x, y);    
            data.UpdatePlots();
        
        end
        
        % update selected plane vertex
        if P.selected > 0
            
            P.SetSelectedPoint(x, y);
            data.UpdatePlots();
            
        end
        
        GUI_INFO.Update(data);
        
    end

    % handle mouse press
    function OnMousePress(object, ~)
        
        % get mouse position
        [x, y] = GUI_AXES.GetMousePosition();
        
        % get profile and plane splines
        S = data.GetCurrentSample().profile;
        P = data.GetCurrentSample().plane;
        
        % get mouse press
        switch get(object, 'SelectionType')
            
            % left click
            case 'normal'

                if S.complete
                    
                    if P.complete
                    
                        % get point that was clicked on  
                        i = P.PointHitTest(Vect3(x, y, 0));
            
                        if i > 0
                
                            P.selected = i;
                            P.edit = true;  
                            
                            return;
                
                        end
                                                          
                        % get point that was clicked on  
                        i = S.PointHitTest(Vect3(x, y, 0));
            
                        if i > 0
                
                            S.selected = i;
                            S.edit = true;  
                            
                            return;
                
                        end

                    else
                    
                        P.AddPoint(Vect3(x, y, 0));
                    
                    end                    
                    
                else
                     
                    S.AddPoint(Vect3(x, y, 0));
                    
                end                  
                
                % update plots
                data.UpdatePlots();    
                   
            % right click
            case 'alt'
                    
                    if S.selected > 0
                
                        S.points(end) = [];
                        S.segments(end) = [];
                        S.selected = S.selected - 1;
                        S.SetSelectedPoint(x, y);                   
                        data.UpdatePlots();
                    
                    end
                    
                    if P.selected > 0
                        
                    	P.points(end) = [];
                        P.segments(end) = [];
                        P.selected = P.selected - 1;
                        P.SetSelectedPoint(x, y);                   
                        data.UpdatePlots();
                        
                    end
                 
            % wheel click
            case 'extend'
                    
                    pan = true;
                    panX = C(1,1);
                    panY = C(1,2);
                    
        end
 
    end






    % handle mouse wheel
    function OnMouseWheel(object, eventdata)
        
        % get scroll count
        delta = eventdata.VerticalScrollCount;
        
        %factor = .9;
        
        while delta > 0
            
            data.NextSample();
            delta = delta - 1;
            
%             % mouse position
%           	C = get(A, 'CurrentPoint');
%              
%             % x range
%             x1 = A.XLim(1);
%             x2 = A.XLim(2);
%             
%             % y range
%             y1 = A.YLim(1);
%             y2 = A.YLim(2);
%             
%             % 
%             width = x2 - x1;
%             height = y2 - y1;
%  
%             % center of plot
%             cx = (x1 + x2) / 2;
%             cy = (y1 + y2) / 2;
%             
%             % mouse position
%             px = C(1, 1);
%             py = C(1, 2);
%             
%             % mid point between mouse and center
%             mx = (px + cx) / 2;
%             my = (py + cy) / 2;
%             
%             %A.XLim = [x1 - width * factor, x2 + width * factor];
%             %A.YLim = [y1 - height * factor, y2 + height * factor];
% 
%             A.XLim = [mx - 1/factor * (width / 2), mx + 1/factor * (width / 2)];
%             A.YLim = [my - 1/factor * (height / 2), my + 1/factor * (height / 2)];
%             
%             delta = delta - 1;
            
        end
        
        while delta < 0
            
            
             
            data.PreviousSample();
            delta = delta + 1;
            
%              % mouse position
%           	C = get(A, 'CurrentPoint');
%              
%             % x range
%             x1 = A.XLim(1);
%             x2 = A.XLim(2);
%             
%             % y range
%             y1 = A.YLim(1);
%             y2 = A.YLim(2);
%             
%             % 
%             width = x2 - x1;
%             height = y2 - y1;
%  
%             % center of plot
%             cx = (x1 + x2) / 2;
%             cy = (y1 + y2) / 2;
%             
%             % mouse position
%             px = C(1, 1);
%             py = C(1, 2);
%             
%             % mid point between mouse and center
%             mx = (px + cx) / 2;
%             my = (py + cy) / 2;
%             
%             %A.XLim = [x1 - width * factor, x2 + width * factor];
%             %A.YLim = [y1 - height * factor, y2 + height * factor];
%             A.XLim = [mx - factor * (width / 2), mx + factor * (width / 2)];
%             A.YLim = [my - factor * (height / 2), my + factor * (height / 2)];
% 
%             
%             delta = delta + 1;
            
            
        end
        
     	data.UpdatePlots();
        GUI_INFO.Update(data);
        GUI_IO.Update();
        
    end

    % handle mouse release
    function OnMouseRelease(~, ~)

        S = data.GetCurrentSample().profile;
        P = data.GetCurrentSample().plane;
        
        if S.complete
            
            S.selected = 0;
            S.edit = false;
            
        end
        
        if P.complete
            
            P.selected = 0;
            P.edit = false;
            
        end

        %pan = false;
        
    end

end