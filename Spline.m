%--------------------------------------------------------------------------
% Spline.m
%--------------------------------------------------------------------------
% Last updated: 6/29/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles connected B-spline segments of degree 3.
%--------------------------------------------------------------------------
classdef Spline < handle
    
    properties
        points;                     % points
        segments;                   % segements between points 
        selected;                   % current point selected   
        edit;                       % spline is edited (bool)
        closed;                     % spline is closed (bool)
        complete;                   % spline is complete (bool)
        steps;                      % interpolation steps per segement      
    end
    
    methods
        
        % constructor
        function obj = Spline()
            obj.reset();
        end
        
        % reset spline
        function reset(obj)   
            obj.points = Vect3.empty();
            obj.segments = BSpline.empty();          
            obj.selected = 0;   
            obj.edit = false;
            obj.closed = false; 
            obj.complete = false;
            obj.steps = 16;
        end
        
        % build spline from point set
        function BuildSpline(obj, points, closed)
            
            % reset object
            obj.reset();
            
            % number of points
            n = numel(points);
            
            % add first 2 points
            obj.AddPoint(points(1));
            obj.SetSelectedPoint(points(2).x, points(2).y);
            
            % add remaining points
            for i = 3 : n
                obj.AddPoint(points(i));
            end
            
            if closed
                obj.Close();
            end
            
            % update spline
            obj.Update();
                        
            % complete spline
            obj.complete = true;
            
        end
        
        % close spline
        function Close(obj)
            
            obj.AddPoint(Vect3(0, 0, 0));
            obj.points(end) = [];
            obj.segments(end).points(end) = obj.points(1);   
            obj.selected = 0;
            obj.closed = true;
            
        end

        % return number of points
        function n = GetPointCount(obj)
            n = numel(obj.points);
        end
        
        % return number of segments
        function n = GetSegmentCount(obj)
            n = numel(obj.segments);
        end
        
     	% set point i to position x,y
        function SetPoint(obj, i, x, y)          
            obj.points(i).x = x;
            obj.points(i).y = y;            
        end
        
        % set selected point to position x,y
        function SetSelectedPoint(obj, x, y)         
            obj.points(obj.selected).x = x;
            obj.points(obj.selected).y = y;         
        end
        
        % add point to end of ordered point list
        function AddPoint(obj, point)
            
            % first point requires special treatment
            if obj.selected == 0
                
                obj.points(1) = point;
                obj.points(2) = point.copy();
                obj.selected = 2;
                
            else
                
                obj.selected = obj.selected + 1;
                obj.points(obj.selected) = point;
                
            end            
            
            % build new segment   
            obj.BuildSegment(obj.selected - 1);
            
        end
        
        % build segment
        function BuildSegment(obj, i)
            
            obj.segments(i) = BSpline(3);
            obj.segments(i).AddPoint(obj.points(i));
            obj.segments(i).AddPoint(Vect3(0, 0, 0));
            obj.segments(i).AddPoint(Vect3(0, 0, 0));
            obj.segments(i).AddPoint(obj.points(i + 1));
            
            obj.UpdateSegment(i);
            
        end

        % update segment
        function UpdateSegment(obj, i)
            
            obj.SetPoint2(i);
            obj.SetPoint3(i);

        end
       
        % update all segments
        function Update(obj)          
            m = obj.GetSegmentCount();
            for i = 1 : m
                obj.UpdateSegment(i);
            end          
        end
        
        % return first point index near point
        function index = PointHitTest(obj, point)
            
            % number of points
            n = obj.GetPointCount();
            
            % distance tolerance
            tol = 5;
            
            for i = 1 : n
                
                if Vect3.Distance(point, obj.points(i)) < tol
                    
                    index = i;
                    return 
                    
                end
                
            end
            
            index = 0;
            return
            
        end

    end

    methods
             
        % smoothing function for C1 continuity     
        function SetPoint2(obj, index)
            
            % number of points
            n = obj.GetPointCount();
            
            % point index
            i = index;
            
            if obj.closed  

                b = Vect3.Mean(obj.points(mod(i - 2, n) + 1), obj.points(mod(i, n) + 1));
                p = Vect3.Mean(obj.points(i), Vect3.Mean(obj.points(i), obj.points(mod(i, n) + 1)));
                
            else
                
                % handle first point as sepcial case if spine is open
                if i == 1 
                    
                    if n > 2

                        b = Vect3.Mean(obj.points(i), obj.points(i + 2));                   
                        p = Vect3.Mean(obj.points(i), obj.points(i + 1));
                        
                    else
                        
                        b = Vect3.Mean(obj.points(i), obj.points(i + 1)); 
                        p = Vect3.Mean(obj.points(i), obj.points(i + 1)); 
                        
                    end
                    
                else
                    
                    b = Vect3.Mean(obj.points(i - 1), obj.points(i + 1));
                    p = Vect3.Mean(obj.points(i), Vect3.Mean(obj.points(i), obj.points(i + 1)));
                    
                end
                
            end

            % calculate position
         	obj.segments(index).points(2) = Vect3.Add(Vect3.Scale(Vect3.Sub(p, b), 4/3), b);
            
        end
         
        % smoothing function for C1 continuity   
        function SetPoint3(obj, index)
         
            % number of points
            n = obj.GetPointCount();
            
            % point index
            i = index + 1;
            
            if obj.closed
            
                i = mod(index, n) + 1;
                
                b = Vect3.Mean(obj.points(mod(i - 2, n) + 1), obj.points(mod(i, n) + 1));
                p = Vect3.Mean(obj.points(i), Vect3.Mean(obj.points(i), obj.points(mod(i - 2, n) + 1)));
                
            else
                
                % handle last point as special case in spine is open
                if i == n
                                   
                    if n > 2 
                        
                        b = Vect3.Mean(obj.points(i), obj.points(i - 2));                   
                        p = Vect3.Mean(obj.points(i), obj.points(i - 1));
                        
                    else
                        
                        b = Vect3.Mean(obj.points(i), obj.points(i - 1)); 
                        p = Vect3.Mean(obj.points(i), obj.points(i - 1)); 
                        
                    end
                    
                else
                    
                    b = Vect3.Mean(obj.points(i - 1), obj.points(i + 1));
                    p = Vect3.Mean(obj.points(i), Vect3.Mean(obj.points(i), obj.points(i - 1)));
                    
                end
                
            end
            
            % calculate position
            obj.segments(index).points(3) = Vect3.Add(Vect3.Scale(Vect3.Sub(p, b), 4/3), b);
            
        end

    end
    
	methods 
        
        % return total length of spline
        function length = GetLength(obj)  
            
            n = obj.GetSegmentCount();
            length = 0;
            
            for i = 1 : n
                
                length = length + obj.segments(i).GetLength();
                
            end     
            
        end
        
        % return area of spline
        function area = GetArea(obj)         

            % initialize area
            area = 0;
                
            if obj.closed
                
                % parameters
                tol = 1e-5;
                delta = inf;
                max_iter = 16;
                AP = 0;
                k = 6;
                
                % number of segments
                n = obj.GetSegmentCount();
                
                while delta > tol && k < max_iter
                
                    % initialize area
                    area = 0;
                    
                    % iteration
                    k = k + 1;
                    
                    % sub-divisions
                    m = 2 ^ k;

                    % reference point
                    p0 = obj.segments(1).C(0, 0);

                    % initialize p2 (i.e. first p1)         
                    p2 = obj.segments(1).C(1 / m, 0);
                
                    % loop through each segment
                    for i = 1 : n
                
                        if i > 1
                            s = 1;
                        else
                            s = 2; 
                        end
                    
                        % loop through each point
                        for j = s : m
                    
                            u = j / m;
                        
                            p1 = p2;
                            p2 = obj.segments(i).C(u, 0);
                        
                            % build triangle
                            t = Triangle(p0, p1, p2);

                            % accumulate area
                            area = area + t.Area();
                    
                        end
                
                    end
                
                    % positive (i.e. direction independent)
                    area = abs(area);
                    %fprintf("%2d. Area = %12.3f\n", k, area);
                    
                    % fractional difference
                    delta = abs(area - AP) / AP;
                
                    % save as previous area
                    AP = area;
                    
                end
                
            end
                       
        end
        
        % return centroid of spline
        function centroid = GetCentroid(obj)

            % initialize centroid
            centroid = Vect3(nan, nan, nan);
                
            if obj.closed
                
                % parameters
                tol = 1e-3;                                                % <<< acutal distance
                delta = inf;          
                max_iter = 16;
                C = Vect3(inf, inf, inf);
                k = 6;
                        
                % number of segments
                n = obj.GetSegmentCount();
                
                while delta > tol && k < max_iter
                    
                    % initialize centroid
                    centroid = Vect3(0, 0, 0);
                    
                    % initialize area
                    area = 0;
                
                    % interation
                    k = k + 1;
                
                    % sub-divisions
                    m = 2 ^ k;

                    % reference point
                    p0 = obj.segments(1).C(0, 0);

                    % initialize p2 (i.e. first p1)         
                    p2 = obj.segments(1).C(1 / m, 0);
                
                    % loop through each segment
                    for i = 1 : n
                
                        if i > 1
                            s = 1;
                        else
                            s = 2; 
                        end
                    
                        % loop through each point
                        for j = s : m
                    
                            u = j / m;
                        
                            p1 = p2;
                            p2 = obj.segments(i).C(u, 0);
                        
                            % build triangle
                            t = Triangle(p0, p1, p2);
                        
                            c = t.Centroid();
                            a = t.Area();
                        
                            % accumulate centroid
                            centroid = Vect3.Add(centroid, Vect3.Scale(c, a));
                        
                            % accumulate area
                            area = area + a;
                    
                        end
                
                    end
                
                    % finalize centroid
                    centroid = Vect3.Scale(centroid, 1 / area);

                    delta = Vect3.Distance(centroid, C);

                    % save as previous centorid
                    C = centroid;
                    
                end

            end

        end
    
    end

    methods
        
        % Return major and minor axis line segments
        function [major, minor] = GetAxis(obj)
            
            % calculate centroid
            origin = obj.GetCentroid();
            
            n = 256;
            [x, y] = obj.Resample(n);
            
            p1 = Vect3.empty();
            p2 = Vect3.empty();
            
            length = zeros(n, 1);
            
            for i = 1 : n
                
                point = Vect3(x(i), y(i), 0);
                
                % direction
                direction = Vect3.Normalize(Vect3.Sub(origin, point));
                
                p1(i) = point;
                p2(i) = obj.RayIntersection(Ray(origin, direction));
                
                length(i) = Vect3.Distance(p1(i), p2(i));
                
            end
              
            [~, idx] = max(length);        
            plot(gca, [p1(idx).x, p2(idx).x], [p1(idx).y, p2(idx).y], 'g*-');
            [~, idx] = min(length);
            plot(gca, [p1(idx).x, p2(idx).x], [p1(idx).y, p2(idx).y], 'b*-');

        end

    end
        
        
        
        
        

        
        
        
        
        
        
        
        
        
        
        
        
        

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    methods
        
        function vertex = GetVertex(obj, s, t)
           
            % create vertex
            vertex = Vertex();
            
            % get segment
            S = obj.segments(s);
            
            % fill vertex data
            vertex.position = S.GetPosition(t);
            vertex.normal = S.GetNormal(t);
            vertex.tangent = S.GetTangent(t);
            vertex.binormal = S.GetBinormal(t);
            vertex.curvature = S.GetCurvature(t);
            vertex.segment = s;
            vertex.t = t;
            
        end
        
    end
 
	methods
        
        % Resample the spline, returning a ployline with vertices evenly 
        % distributed at 1/nth of the total spline length. (i.e. the arc 
        % length between adjacent points is constant.        
        function Poly = EvenSample(obj, n, s0, t0, length)
            
            %--------------------------------------------------------------
            % find start point 
            %--------------------------------------------------------------   

            if obj.closed
            
                centroid = obj.GetCentroid();           
                [~, s, t] = obj.RayIntersection(Ray(centroid, Vect3(0, -1, 0)));

                % use first intersection
                s = s(1);
                t = t(1);
                
                % get total length of spline
                length = obj.GetLength();
            
            else

                s = s0;
                t = t0;
                
            end
            
            t0 = t;
            t1 = 1;
            
            % segment length range
            l0 = 0;
            l1 = obj.segments(s).GetArcLength(t0, t1);
            dl = l1 - l0;           
            fprintf("\tsegment = %-3d l0 = %-9.3f l1 = %-9.3f\n", s, l0, l1);
            
            % create polyline
            Poly = Polyline();
            Poly.centroid = obj.GetCentroid();
            Poly.area = obj.GetArea();
            Poly.length = obj.GetLength();
            %[major, minor] = obj.GetAxis();
            %Poly.major = major;
            %Poly.minor = minor;
            
            % add first vertex
            Poly.AddVertex(obj.GetVertex(s, t));            
            fprintf("\tS = %-3d T = %-1.3f \t\t\t\t\t\t\t %5.1f%%\n", s, t, 1 / (n + 1) * 100);
          
            %
            m = obj.GetSegmentCount();
            
            % loop through each sample
            for i = 1 : n
                
                % target length
                L = (i / n) * length;
                
                while L > l1
                    
                    t0 = 0;
                    %t1 = 1;
                    
                    l0 = l0 + dl;
                    s = mod(s, m) + 1;
                    l1 = l1 + obj.segments(s).GetLength();
                    dl = l1 - l0;
                    fprintf("\tsegment = %-3d l0 = %-9.3f l1 = %-9.3f\n", s, l0, l1);
                    
                end                

                % fix target length
                L = L - l0;
                
                % get t value at target length
                t = obj.segments(s).GetTLength(L, t0);
               
                if t < 0
                    t = 1; 
                end
                
                % add vertex
                Poly.AddVertex(obj.GetVertex(s, t)); 
                fprintf("\tS = %-3d T = %-1.3f \t\t\t\t\t\t\t %5.1f%%\n", s, t, (i + 1) / (n + 1) * 100);
                
            end

        end
         
        % return all of the points, segments, and t values for where the
        % ray intersects the spline.
        function [P, S, T] = RayIntersection(obj, ray)
            
            % initialize empty ray intersection data
            H = RayIntersection(Vect3(inf, inf, inf), inf);
            
            % number of segments
            m = obj.GetSegmentCount();
            
            % intialize empty data
            P = Vect3.empty();
            S = nan(m, 1);
            T = nan(m, 1);
            
            % number of iterations
            k = 0;
            
            % loop through each segment
            for i = 1 : m
                
                % get ray intersection
                [I, t] = Spline.RaySegmentIntersection(H, ray, obj.segments(i), 1);
                    
                % ray intersected
                if I.distance > 0 && I.distance < inf
                   
                    % iterate
                    k = k + 1;
                    
                    % positions
                    P(k) = I.position;

                    % segments
                    S(k) = i;
                    
                    % t values
                    T(k) = t;
                    
                end
                
            end
            
            % clip data
            S(isnan(S)) = [];
            T(isnan(T)) = [];

        end
        
        % return all of the points, segments, and t values for where this
        % spline intersects the given spline.
        function [P, S, T] = SplineIntersection(obj, s2)
            
            s1 = obj;
            
            % get segment counts
            n1 = s1.GetSegmentCount();
            n2 = s2.GetSegmentCount();
            
            % initialize empty data
            P = Vect3.empty();
            S = nan(n1, 1);
            T = nan(n1, 1);
            
            % tolerence
            tol = 1e-5;
            max_iter = 6;
            count = 0;
            
            for i = 1 : n1
    
                ss1 = s1.segments(i);
    
                for j = 1 : n2
        
                    ss2 = s2.segments(j);
        
                    k = 5;
        
                    % find intersection
                    I = Spline.SegmentSegmentIntersection(ss2, ss1, k);
                    
                    % position of intersection
                    p = I.position;
                    
                    % no intersection
                    if Vect3.Magnitude(p) == inf
            
                        continue;
            
                    end
        
                    count = count + 1;
                    
                    % history 
                    h = Vect3(0, 0, 0);

                    while k < max_iter && Vect3.Distance(p, h) > tol
            
                        fprintf("%5d. x = %6.3f y = %6.3f z = %6.3f\n", k, p.x, p.y, p.z);
                        
                        k = k + 1;
                        
                        h = p;

                        I = Spline.SegmentSegmentIntersection(ss2, ss1, k);
                        
                        p = I.position;

                    end
        
                    fprintf("Final: x = %6.3f y = %6.3f z = %6.3f\n\n", p.x, p.y, p.z);
                    
                    P(count) = p;
                    S(count) = i;
                    T(count) = I.t;
        
                end
    
            end
            
            S(isnan(S)) = [];
            T(isnan(T)) = [];
            
        end

    end
        
  	methods (Static)

      	% return the ray intersection data and approximant spline t value
        % for where the ray intersects the spline segement.
        function [R, t] = RaySegmentIntersection(H, ray, spline, n)
                    
            % initialize empty ray intersection data
            R = RayIntersection(Vect3(inf, inf, inf), inf);
            t = 0;
            
            % number of line segments
            m = 2 ^ n;
            
            % loop through each line segment
            for i = 1 : m
                
                % values
                t1 = (i - 1) / m;
                t2 = i / m;
                
                % points
                p1 = spline.C(t1, 0);
                p2 = spline.C(t2, 0);

                % intersection
                I = ray.LineIntersection(Line(p1, p2));

                % test intersection
                if I.distance > 0 && I.distance < R.distance
                    
                    R = I;
                    t = (t1 + t2) / 2;                                      % <<< t value is approximant
                    
                end
                
            end

            % tolerence (in real world units)
            tol = 1e-5;
            max_iter = 8;
            
            % refine intersection
            if R.distance < inf
                
                if Vect3.Distance(H.position, R.position) > tol && n < max_iter
                
                    [R, t] = Spline.RaySegmentIntersection(R, ray, spline, n + 1);
                    
                end
                
            end
        
        end
        
        % 
        function I = SegmentSegmentIntersection(S1, S2, n)

            % initialize spline intersection data
            I = SplineIntersection(Vect3(inf, inf, inf), 0, 0);
            
            % number of line segments
            m = 2 ^ n;
            
            % S1
            for i = 1 : m
                
                % values
                t1 = (i - 1) / m;
                t2 = i / m;
                
                % points
                P1 = S1.C(t1, 0);
                P2 = S1.C(t2, 0);
                
                % line segment
                L1 = Line(P1, P2);
                
                % S2
                for j = 1 : m
                    
                    % values
                    t1 = (j - 1) / m;
                    t2 = j / m;
                    
                    % points
                    P1 = S2.C(t1, 0);
                    P2 = S2.C(t2, 0);
                    
                    % line segment
                    L2 = Line(P1, P2);
                    
                    % intersection
                    P = Line.LineIntersection(L1, L2);
                    
                    if Vect3.Magnitude(P) < inf
                        
                        t = (t2 + t1) / 2;                                  % <<< approximant t value for S2
                        
                        I = SplineIntersection(P, 0, t);
                        return;

                    end
                    
                end
                
            end

        end
        
    end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    
        
 
    
    
    

    methods
        
        % update plots
        function Plot(obj, h1, h2, h3)
            
            if obj.GetSegmentCount() < 1
                
                h1.XData = nan;
                h1.YData = nan;
                
                h2.XData = nan;
                h2.YData = nan;
                
                h3.XData = nan;
                h3.YData = nan;
                
                return;
                
            end
                
            %--------------------------------------------------------------
            % Points
            %--------------------------------------------------------------
            
            n = obj.GetPointCount();
            
            x = zeros(n, 1);
            y = zeros(n, 1);
            
            for i = 1 : n
      
                x(i) = obj.points(i).x;
                y(i) = obj.points(i).y;
                
            end
            
            h1.XData = x;
            h1.YData = y;
            
            %--------------------------------------------------------------
            % Segments
            %--------------------------------------------------------------
            
            n = obj.GetSegmentCount();
            m = obj.steps + 2;
            
            c = n * m;
            
            %u = linspace(0, 1, m);
            
            x = zeros(c, 1);
            y = zeros(c, 1);
              
            k = 0;
            
            m = m - 1;
            
            for i = 1 : n
               
                obj.UpdateSegment(i);
                
                for j = 0 : m

                    t = j / m;
                    
                    k = k + 1;
                    
                    p = obj.segments(i).C(t, 0);
                    
                    x(k) = p.x;
                    y(k) = p.y;
                    
                end
                
            end
            
            h2.XData = x;
            h2.YData = y;
         
            return;
            
            %--------------------------------------------------------------
            % Control Points
            %--------------------------------------------------------------
            
            n = obj.GetSegmentCount();
            
            if n > 1
            
                x = [obj.segments(1).points(1).x];
                y = [obj.segments(1).points(1).y];
                
                for i = 1 : n
                
                    x = [x, obj.segments(i).points(2).x, nan, obj.segments(i).points(3).x];  
                    y = [y, obj.segments(i).points(2).y, nan, obj.segments(i).points(3).y]; 
                
                end
                
                if obj.closed 
                    
                    x = [x, obj.segments(1).points(1).x];
                    y = [y, obj.segments(1).points(1).y];
                
                else
                   
                    x = [x, obj.segments(n).points(4).x];
                    y = [y, obj.segments(n).points(4).y];
                    
                end
            
            else

            	x = [obj.segments(1).points(1).x, obj.segments(1).points(2).x, nan, obj.segments(1).points(3).x, obj.segments(1).points(4).x];
                y = [obj.segments(1).points(1).y, obj.segments(1).points(2).y, nan, obj.segments(1).points(3).y, obj.segments(1).points(4).y];
  
            end
            
            h3.XData = x;
            h3.YData = y; 

        end
        
    end
    
end