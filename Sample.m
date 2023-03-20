classdef Sample < handle
    
    properties
        frame;              % Frame frame
        profile;            % Spline profile
        plane;              % Spline plane 
        DivisionPlane;
        CellSeperation;
        CellPinching;
        Difficult;
    end
    
    methods
        
        function obj = Sample()
            obj.frame = Frame.empty();
            obj.profile = Spline.empty();
            obj.plane = Spline.empty();
            obj.DivisionPlane = false;
            obj.CellSeperation = false;
            obj.CellPinching = false;  
            obj.Difficult = false;
        end
        
        function length = GetLength(obj)
            length = obj.profile.GetLength();
        end
        
        function area = GetArea(obj)
            area = obj.profile.GetArea();
        end
        
    end
    
end