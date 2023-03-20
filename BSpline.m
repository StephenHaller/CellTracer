%--------------------------------------------------------------------------
% BSpline.m
%--------------------------------------------------------------------------
% Last updated: 6/29/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Class handles B-splines of specified degree, but optimized for degree 3.
%--------------------------------------------------------------------------
classdef BSpline < handle
    
    properties
        points;
        degree;
    end
    
    properties (Constant)
        tt = [0, 0, 0, 0, 1, 1, 1, 1];                                      % <<< temporary optimization 
    end
    
    methods
        
        % constructor
        function obj = BSpline(degree)
            obj.points = Vect3.empty();
            obj.degree = degree;        
        end
        
        % return number of control points (note: n = v - 1)
        function v = GetControlPointCount(obj)
            v = numel(obj.points);
        end
        
        % return number of knots (note: m = v - 1)
        function v = GetKnotCount(obj)
            v = obj.degree + obj.GetControlPointCount() + 1;
        end
        
        % add point to end of ordered point list
        function AddPoint(obj, point)
            n = obj.GetControlPointCount();
            obj.points(n + 1) = point;
        end
        
    end
    
    methods
        
        % return length of spline using specified tolerance
        function l = GetLength(obj)
            
          	% tolerance (i.e. max fractional change between interations)
            tol = 1e-5;
            
            % get length
            l = obj.Length(5, tol, 0, 0, 1);
    
        end
        
        % return arc length of spline using specified tolerance and range
        function l = GetArcLength(obj, t0, t1)
            
            % tolerance (i.e. max fractional change between interations)
            tol = 1e-5;
            
            % get length
            l = obj.Length(5, tol, 0, t0, t1);
            
        end
        
        % recursively calculate length of spline using specified tolerance
        function l = Length(obj, n, tol, lp, t0, t1)
            
            % max number of interations
            max_iter = 10;
            
            if n > max_iter
                l = lp;
                return;
            end
            
            % integration steps
            m = 2 ^ n;
            
            % initialize length
            l = 0;
            
            % initialize p2 (i.e. first p1)
            p2 = obj.C(t0, 0);
            
            % range of t
            dt = t1 - t0;
            
            for i = 1 : m

                t = (i / m) * dt + t0;
                
                p1 = p2;
                p2 = obj.C(t, 0);
                
                l = l + Vect3.Distance(p1, p2); 
                
            end
            
            % check tolerance
            if abs(l - lp) / lp > tol
                
                % calculate length
                l = obj.Length(n + 1, tol, l, t0, t1);
                
            end
            
        end
        
        % return parametric value t at specified arc length starting at t0
        function t = GetTLength(obj, length, t0) 
        
            % specified length outside of spline length
            if length < 0 || length > obj.GetLength()
                
                t = -1;
                return;
                
            end
                
            % tolerance (i.e. max fractional change between interations)
            tol = 1e-5;
            
            % get t value
            t = obj.TLength(tol, length, t0);
            
        end
        
        % iteratively calcualte t value 
        function t = TLength(obj, tol, length, t0)

            u0 = t0;
            u1 = 1;
            delta = inf;
            max_iter = 64;
            k = 0;
            length_tol = 1e-5;
           
            while delta > tol && k < max_iter
                
                % iteration
                k = k + 1;
            
                % calculate t
                t = (u0 + u1) / 2;
                
                % calculate length at t
                L = obj.Length(5, length_tol, 0, t0, t);
            
                % fractional difference
                delta = abs(L - length) / length;
                
                if L > length
                    
                    u1 = t;
                    
                else
                    
                    u0 = t;
                    
                end
            
            end

        end
        
    end
    
    methods
         
        % return curvature
        function k = GetCurvature(obj, t)
           
            % get first derivative
            s = obj.C(t, 1);
            
            % get second derivative
            ss = obj.C(t, 2);
            
            % calculate binormal vector
            b = Vect3.Cross(s, ss);
            
            % calculate curvature
            k = Vect3.Magnitude(b) / (Vect3.Magnitude(s) ^ 3);
            
        end
        
        % return position
        function v = GetPosition(obj, t)
            v = obj.C(t, 0);
        end
        
        % return unit tangent vector
        function v = GetTangent(obj, t)   
            s = obj.C(t, 1);
            v = Vect3.Normalize(s);           
        end
        
        % return unit binormal vector
        function v = GetBinormal(obj, t)
            s = obj.C(t, 1);
            ss = obj.C(t, 2);
            v = Vect3.Normalize(Vect3.Cross(s, ss));
        end
        
        % return unit normal vector
        function v = GetNormal(obj, t)
            s = obj.C(t, 1);
            ss = obj.C(t, 2);
            bn = Vect3.Normalize(Vect3.Cross(s, ss));
            tn = Vect3.Normalize(s);
            v = Vect3.Cross(bn, tn);
        end
        
    end
    
    methods
        
        % return knot function value  
        function u = t(obj, i)    

            p = obj.degree;
            m = obj.GetKnotCount() - 1;

            if i <= p              
                u = 0;
            elseif i >= (m - p)            
                u = 1;
            else            
                u = (i - p) / (m - 2 * p);   
            end

        end

        % return point on curve at t of derivative order k
        function c = C(obj, t, k)
            
            p = obj.degree;
            n = obj.GetControlPointCount() - 1;
                 
            if t < 1
                
                % initialize point
                c = Vect3(0, 0, 0);
            
                % summation
                for i = 0 : n - k
                
                    % basis function
                    N = obj.BasisFast(i + k, p - k, t);                     % <<< temporary optimization      
                    c = Vect3.Add(c, Vect3.Scale(obj.P(i, k, p), N));   
                
                end
            
            else
                
                % handle (t = 1) as special case
                c = obj.P(n - k, k, p);
                
            end
           
        end       
        
        % return control point
        function point = P(obj, i, k, p)
            
            if k > 0
                
                v = (p - k + 1) / (obj.t(i + p + 1) - obj.t(i + k));
                point = Vect3.Scale(Vect3.Sub(obj.P(i + 1, k - 1, p), obj.P(i, k - 1, p)), v);
                
            else

                point = obj.points(i + 1);
                
            end
            
        end
        
        % return basis function value (optimized)
        function N = BasisFast(obj, i, p, t)
            
            i = i + 1;
            
            if p > 0
                
                %
                N1 = obj.BasisFast(i - 1, p - 1, t);
                if N1 == 0
                    M1 = 0;
                else
                    M1 = (t - obj.tt(i)) / (obj.tt(i + p) - obj.tt(i));               
                end
                
                %
                N2 = obj.BasisFast(i, p - 1, t);
                if N2 == 0
                    M2 = 0;
                else
                    tmp = i + p + 1;
                    M2 = (obj.tt(tmp) - t) / (obj.tt(tmp) - obj.tt(i + 1));                   
                end
                
                %
                N = M1 * N1 + M2 * N2;
                return;

            else
                
                if obj.tt(i) <= t && t < obj.tt(i + 1)               
                    N = 1;  
                    return;
                else               
                    N = 0; 
                    return;
                end
                
            end
            
        end
        
        % return basis function value
        function N = Basis(obj, i, p, t)
            
            if p > 0
                
                %
                N1 = obj.Basis(i, p - 1, t);
                if N1 == 0
                    M1 = 0;
                else
                    M1 = (t - obj.t(i)) / (obj.t(i + p) - obj.t(i));               
                end
                
                %
                N2 = obj.Basis(i + 1, p - 1, t);
                if N2 == 0
                    M2 = 0;
                else
                    M2 = (obj.t(i + p + 1) - t) / (obj.t(i + p + 1) - obj.t(i + 1));                   
                end
                
                %
                N = M1 * N1 + M2 * N2;

            else
                
                if obj.t(i) <= t && t < obj.t(i + 1)               
                    N = 1;                  
                else               
                    N = 0;                   
                end
                
            end 
            
        end  
        
    end
    
    methods
        
        function DebugPrint(obj)
            
            fprintf("B-Spline Debug Info:\n");
            fprintf("--------------------\n");
            fprintf("p:       %d\n", obj.degree);
            fprintf("n:       %d\n", obj.GetControlPointCount() - 1);
            fprintf("m:       %d\n", obj.GetKnotCount() - 1);
            
            fprintf("Control Points (n + 1 = %d)\n", obj.GetControlPointCount());
            
            n = obj.GetControlPointCount() - 1;
            
            for i = 0 : n
                p = obj.points(i + 1);
                fprintf("   %2d %6.3f %6.3f %6.3f\n", i, p.x, p.y, p.z);
            end
            
            fprintf("Knots (m + 1 = %d)\n", obj.GetKnotCount());
            
            m = obj.GetKnotCount() - 1;
            
            for i = 0 : m
                fprintf("   %2d %6.3f \n", i, obj.t(i));
            end    
            
            fprintf("Length: %6.3f\n", obj.GetLength());
            
        end

        function DebugPlot(obj)

            % create figure
            f = figure();
            
            % create axes
            ax = axes(f);
            ax.NextPlot = 'add';
            ax.DataAspectRatio = [1,1,1];
            ax.Clipping = 'off';
            ax.Visible = 'off';
            ax.Position = [0, 0, 1, 1];
            
            %--------------------------------------------------------------
            % Control Points
            %--------------------------------------------------------------
            
            % gather control points
            n = obj.GetControlPointCount();
            
            x = zeros(n, 1);
            y = zeros(n, 1);
            z = zeros(n, 1);
            labels = string.empty();
            
            for i = 1 : n               
                x(i) = obj.points(i).x;
                y(i) = obj.points(i).y;
                z(i) = obj.points(i).z;
                labels(i) = sprintf("\nP%d", i - 1);
            end
            
            % plot control points
            plot3(ax, x, y, z, 'ko--');
            text(ax, x, y, z, labels);
            
            
            
            %--------------------------------------------------------------
            % spline
            %--------------------------------------------------------------
            
            steps = 128;
  
            m = steps + 2;
            u = linspace(0, 1, m);
            
            x = zeros(m, 1);
            y = zeros(m, 1);
            z = zeros(m, 1);
            
            for i = 1 : m
                
                p = obj.C(u(i), 0);
                x(i) = p.x;
                y(i) = p.y;
                z(i) = p.z;
                
            end
         
            % plot spline
            plot3(ax, x, y, z, 'bo-', 'MarkerFaceColor', [0, 0, 1], 'MarkerSize', 3);
            
      
            
            
            i = floor(steps / 2);

            scale = 0.25;

            %--------------------------------------------------------------
            % tangent
            %--------------------------------------------------------------

            tn = obj.GetTangent(u(i));

            DX = tn.x;
            DY = tn.y;
            DZ = tn.z;
            
            X = [x(i) - scale * DX, x(i), x(i) + scale * DX];
            Y = [y(i) - scale * DY, y(i), y(i) + scale * DY];
            Z = [z(i) - scale * DZ, z(i), z(i) + scale * DZ];
            plot3(ax, X, Y, Z, 'r--', 'LineWidth', 1.5);
            
            X = [x(i), x(i) + scale * DX];
            Y = [y(i), y(i) + scale * DY];
            Z = [z(i), z(i) + scale * DZ];
            plot3(ax, X, Y, Z, 'r-', 'LineWidth', 1.5);
        
            %--------------------------------------------------------------
            % normal
            %--------------------------------------------------------------

            nn = obj.GetNormal(u(i));

            DX = nn.x;
            DY = nn.y;
            DZ = nn.z;
            
            X = [x(i) - scale * DX, x(i), x(i) + scale * DX];
            Y = [y(i) - scale * DY, y(i), y(i) + scale * DY];
            Z = [z(i) - scale * DZ, z(i), z(i) + scale * DZ];
            plot3(ax, X, Y, Z, 'g--', 'LineWidth', 1.5);
            
            X = [x(i), x(i) + scale * DX];
            Y = [y(i), y(i) + scale * DY];
            Z = [z(i), z(i) + scale * DZ];
            plot3(ax, X, Y, Z, 'g-', 'LineWidth', 1.5);
            
            %--------------------------------------------------------------
            % binormal
            %--------------------------------------------------------------
            
            bn = obj.GetBinormal(u(i));
            
            DX = bn.x;
            DY = bn.y;
            DZ = bn.z;
            
            X = [x(i) - scale * DX, x(i), x(i) + scale * DX];
            Y = [y(i) - scale * DY, y(i), y(i) + scale * DY];
            Z = [z(i) - scale * DZ, z(i), z(i) + scale * DZ];
            plot3(ax, X, Y, Z, 'b--', 'LineWidth', 1.5);
            
            X = [x(i), x(i) + scale * DX];
            Y = [y(i), y(i) + scale * DY];
            Z = [z(i), z(i) + scale * DZ];
            plot3(ax, X, Y, Z, 'b-', 'LineWidth', 1.5);
            
            %--------------------------------------------------------------
            % curvature
            %--------------------------------------------------------------
            
            k = obj.GetCurvature(u(i));

            text(ax, x(i), y(i), sprintf('\nk = %1.3f', k));
                        
        end
        
    end
    
end