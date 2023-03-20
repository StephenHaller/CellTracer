%--------------------------------------------------------------------------
% ADatabase.m
%--------------------------------------------------------------------------
% Last updated 10/25/2021 by Stephen Haller
%--------------------------------------------------------------------------
% Handles blinded cell data.
%--------------------------------------------------------------------------
% Public methods you can use:
%
% 1.            n = Count()
% Description:  Return the number of entries (i.e. image sets) in the
%               ADatabase.
%
%
%
% 2.            void = Read(filename)
% Description:  Read the ADatabase .dat file into the ADatabase.
%
%
%
% 3.            void = Write(filename)
% Description:  Write the ADatabase into a ADatabase .dat file.
%
%
%
% 4.            void = Build()
% Description:  Add new entires (i.e. image sets) into the ADatabase. Note: 
%               all .tif files within the ADatabase 'path' will be added. 
%               The program assumes the primary folder containing the file 
%               is the date and the secondrary folder is the type (e.g.
%               .\type\date\*.tif)
%
%
%
% 5.            void = SetPath(pathname)
% Description:  Set datebase working path (note: default is current MATLAB
%               working path).
%
%
%
% 6.            void = CopyFiles(pathname)
% Description:  Copies all the .tif files specified in the ADatabase from
%               the unblided folder hierarchy to a new folder with blinded
%               IDs as names (i.e. 0123456789.tif).
%
%
%
% 7.            ADatabase = GetSubADatabase(types)
% Description:  Returns a new ADatabase containing entries of specified
%               type. Types is a string array containing the types you 
%               want (e.g. ["WT Resting", "PPR (mm)"]); 
%
%
%
% 8.           ADatabase = MergeADatabase(database1, database2)
%--------------------------------------------------------------------------
classdef ADatabase < handle
    
    properties
        path;                   % working directory
        entries;                % set of objects representing cell images
        types;                  % set of cell types (e.g. "WT Resting")
        version;                % ADatabase version
        
        h1;
        h2;
        h3;
        h4;
    end
    
    methods (Static)
        
        function NewDatabase = Merge(Database1, Database2)
            
            NewDatabase = ADatabase();
            
            n = Database1.Count;
            
            % DB1
            for i = 1 : n
                
                e = Database1.entries(i);
                
                NewDatabase.AddEntry(e);
                
            end
            
            n = Database2.Count;
            
            % DB2
            for i = 1 : n
                
                e = Database2.entries(i);
                
                NewDatabase.AddEntry(e);
                
            end
            
        end
        
    end
    
    methods
        
        % constructor
        function obj = ADatabase()
            obj.entries = Entry.empty();
            obj.types = string.empty();
            obj.path = pwd();
            obj.version = 'v1.0';
        end
        
        function Print(obj)
            
            m = length(obj.types);
            
            fprintf("Database (%d types)\n\n", m);
            
            for i = 1 : m
                
                type = obj.types(i);
                
                e = obj.GetEntriesByType(type);

                n = length(e);
                
                fprintf("%-16s:\t\t%d\n", type, n);
                
            end
            
        end

        function test(obj)
            
            F = figure();
            A = axes();
            
            A.XLim = [-50, 50];
            A.YLim = [-50, 50];
            
            A.XLabel.String = sprintf("X (%sm)", char(181));
            A.YLabel.String = sprintf("Y (%sm)", char(181));
            
            
            A.NextPlot = 'Add';
            
            
            %
            type = obj.types(4);
            
            E = obj.GetEntriesByType(type);
            
            n = numel(E);
            
            for i = 1 : n
                
                if isempty(E(i).PolylineSet)
                    
                    fprintf("No\n");
                    continue
                end
                
                data = E(i).GetPosition();
                
                data(:, 2) = data(:, 2) * -1;

                m = size(data, 1);

                c = linspace(0, (m - 1) / 49, m)';
                
                patch([data(:, 1); nan], [data(:, 2); nan], [c; nan], 'EdgeColor','interp');
                
                pause(0.001);
                
            end
            
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        % collate data for printing
        function Collate(obj)
 
            % plot profile initialization
            close all;
            a = axes();
          	a.YDir = 'reverse';
           	a.NextPlot = 'add';
            a.XLim = [0, 500];
          	a.YLim = [0, 500];
            
            obj.h1 = plot(1, 1, 'b');
            obj.h2 = plot(nan, nan, 'r');
            obj.h3 = plot(nan, nan, 'k');
            obj.h4 = text(nan, nan, "", 'BackgroundColor', [1,1,1]);      
            
            % clear screen         
            clc  
            
            % number of types
            m = numel(obj.types);
            
            % for each type
            for i = 1 : m
                
                % get all elements of this type
                elements = obj.GetEntriesByType(obj.types(i));

                % number of these elements
                n = numel(elements);
                
                % set initial values
                k = 0;
                I = zeros(1, 64);
                D = nan(49, 64);                
                c = 1;
                
                % display
                fprintf("Calculating...%4d%%", 0);
                
                % for each of these elements
                for j = 1 : n
                    
                    % Display percentage complete in increments of 10%
                    f = j / n;  
                    
                    if f >= (c / 10)
                        fprintf("%4d%%", c * 10);                                             
                        c = c + 1;                      
                    end
                    
                    
                    % get this element
                    e = elements(j);
                     
                    % get id of this element
                    id = e.id;
                    
                    
                    
                    
                    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< polylines (geo)
                    if ~isempty(e.PolylineSet)
                    %if ~isempty(e.SampleSet)
                        
                        % increment counter
                        k = k + 1;
                        
                        % cache id of element
                        I(k) = id;
                        
                        % get data of element
                        d = obj.GetData(e);
                        
                        
                        
                        % get size of data
                        %b = size(d, 1);
                        
                      
                        % same function?
                        a = zeros(49, 1);
                        t = d(d ~= 0);
                        b = size(t, 1);
                        a(1 : b) = t;                         
                        D(:, k) = a;

                        % same function?
                        %a = zeros(49, 1);
                        %a(1 : b) = d; 
                        %D(:, k) = a;

                      
                        
                    end
                    
                end
                
                % trim buffer
                if k < 64
                    I(:, k + 1 : end) = [];
                    D(:, k + 1 : end) = [];
                end
                
                % combine buffers
                A = [I; D];
                
                % print header
                fprintf("\n");
                fprintf("%s (n = %d)\n", obj.types(i), k);
         
                % print data
                if k > 0
                    obj.PrintData(A);
                end
                
            end
            
        end
        
        
        
        
        
        
        
        
        
        %
        function PrintData(~, data)
            
            n = size(data, 1);          % rows
            m = size(data, 2);          % cols
            
            
            % print "Time"
            fprintf("%12s", "Time");
            
            % Print "IDs"
            for j = 1 : m
                fprintf("%12d", data(1, j));               
            end
            fprintf("\n")
            

            % print line
            for j = 1 : m + 1             
                fprintf("%12s", "------------");             
            end         
            fprintf("\n")
            
            
            
            % print
            for i = 2 : n
                
                % print time
                fprintf("%12.1f", (i - 2) * 0.5);
                
                % print data (notes: zeros are not printed)
                for j = 1 : m
                
                    d = data(i, j);
                    
                    if d ~= 0
                    
                        fprintf("%12.3f", d);  %<<<<<<<<<<<<<<<<<<<<<<<<<<
                        %fprintf("%12.0f", d);
                        
                    else
  
                        fprintf("%12s", "");
                        
                    end
                
                end

                fprintf("\n");
                
            end
            
            
            
            % print mean
            fprintf("\n");                      
            fprintf("%12s", "Mean");
            
            %a = 0;
          
            for j = 1 : m
                
                % get data
                d = data(2 : end, j);
                
                % remove zeros
                d = d(d ~= 0);
                
                %
                %a = a + mean(d);
                
                % print mean
                fprintf("%12.3f", mean(d));
                
            end
            
            %fprintf("%12s", "");
            %fprintf("%12.3f", a / m);
            
            
            
            
            
            
            
            
            % print std
            fprintf("\n");
            fprintf("%12s", "SD");
            
            for j = 1 : m
                
                d = data(2 : end, j);
                
                d = d(d ~= 0);
                
                fprintf("%12.3f", std(d, 0));
                
            end
            
            fprintf("%12s", "");
            fprintf("\n");
            fprintf("\n");
            
        end
        
        
        
        
        
        
        %
        function d = GetData(obj, e)
            
            n = numel(e.SampleSet.samples);
            %n = numel(e.PolylineSet.poly_profiles);
            
            d = zeros(n, 1);
            f = zeros(n, 1);
            
            % check
            %if e.FrameSet.frames.info.XResolution() ~= e.FrameSet.frames.info.XResolution()
                
            %    error("Non-uniform resolution!\n");
                
            %else
                
                unit = 0.21;
                
            %end
            
            for i = 1 : n
                
                
                % Cell Area
                %d(i) = e.SampleSet.samples(i).profile.GetArea() * unit * unit; 
                
                % Cell Length
                d(i) = e.SampleSet.samples(i).profile.GetLength() * unit;
                
                % Plane Length
                %d(i) = e.PolylineSet.poly_planes(i).GetLength() * unit;
                
                % Plane Curvature
                %d(i) = e.PolylineSet.poly_planes(i).GetCurvature() / unit;
                
                % Cell Curvature
                %d(i) = e.PolylineSet.poly_profiles(i).GetCurvature() / unit;
                
                % Plane Angle 
                
%                 A = e.PolylineSet.poly_profiles(i).GetArray();
%                 obj.h1.XData = A(:, 1);
%                 obj.h1.YData = A(:, 2);
%  
%                 A = e.PolylineSet.poly_planes(i).GetArray();
%                 obj.h2.XData = A(:, 1);
%                 obj.h2.YData = A(:, 2);
%  
%                 t = e.PolylineSet.poly_planes(i).GetTangent();
%                 o = e.PolylineSet.poly_planes(i).GetMean();
%                 
%                 s = 50;
%                 l = Line(Vect3.Sub(o, Vect3.Scale(t, s)), Vect3.Add(o, Vect3.Scale(t, s)));                
%                 obj.h3.XData = l.GetX();
%                 obj.h3.YData = l.GetY();
%                 
%                 
%                 angle = e.PolylineSet.poly_planes(i).GetAngle();
%                 obj.h4.String = sprintf("%1.1f%s", angle, char(176));
%                 obj.h4.Position = o.GetArray();
%                 
%                 d(i) = angle;
% 
%                 pause(0.001);
                
                
                
                % Pinching  

                %d(i) = e.SampleSet.samples(i).DivisionPlane;
                %f(i) = e.SampleSet.samples(i).CellPinching;
                %f(i) = e.SampleSet.samples(i).CellSeperation;
             
                % minor
                
                %e.PolylineSet.poly_profiles(i).SetCentroid();
                %tic()
                %e.PolylineSet.poly_profiles(i).SetAxisFast();
                %toc()
                %e.PolylineSet.poly_profiles(i).GetAxisAngle();
                %d(i) = e.PolylineSet.poly_profiles(i).GetAxisAngle();
                %d(i) = e.PolylineSet.poly_profiles(i).GetAxisRatio();
                
               
            end
            
            
            %idx = find(d == 1);
            %d(idx) = idx;
            return;
           
            
            
            if sum(f ~= 0) > 0
                
            
                %
                idx1 = find(d == 1);
                
                if isempty(idx1)
                   
                    idx1 = 1;
                    
                end
                
                idx2 = find(f == 1);
               
                idx1 = idx1(1);
                idx2 = idx2(1);
              
                ts = idx2 - idx1;
                
                d(idx1 : idx2) = ts; 
                
            else
                
                d(:) = 0;
                           
            end

        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        % reset ADatabase values
        function Reset(obj)
            obj.entries = Entry.empty();
            obj.types = string.empty();
            obj.path = pwd();
        end
        
        % load
        function Load(obj)
            
            obj.SetPath("./tif");
            %obj.LoadTif();
            
            obj.SetPath("./geo");
            obj.LoadGeo();
            
            obj.SetPath("./dat");
            obj.LoadDat();
            
        end
        
        function LoadTif(obj)
            
            % get path file(s)
            tmp = dir(obj.path);
            
            % number of file(s)
            n = numel(tmp);
            
            fprintf("Tif file(s)\n");
            
            for i = 1 : n
                
                t = tmp(i);
                
                if ~t.isdir
                    
                    file = sprintf("%s%s%s", t.folder, filesep(), t.name);
                    
                    if isfile(file)
                        
                        fprintf("Reading: '%s'... ", file);
                        
                        % get id
                        name = split(t.name, '.');
                        id = str2double(name{1});
                        
                        % get element by id
                        e = obj.GetEntryByID(id);
                        
                        % read image information
                        INFO = imfinfo(file.char());
                        
                        frame = Frame();
                        frame.info = INFO(1);
                        
                        e.FrameSet = FrameSet();
                        e.FrameSet.AddFrame(frame);
                        
                        fprintf("Complete\n");
                        
                    end
                
                end
                
            end
            
            fprintf('\n');
            
        end
        
        % load .dat file(s)
        function LoadDat(obj)
            
            % get path file(s)
            tmp = dir(obj.path);
            
            % number of file(s)
            n = numel(tmp);
            
            fprintf("Dat file(s)\n");
            
            for i = 1 : n
                
                t = tmp(i);
                
                if ~t.isdir
                    
                    file = sprintf("%s%s%s", t.folder, filesep(), t.name);
                    
                    if isfile(file)
                        
                        fprintf("Reading: '%s'... ", file);
                        
                        % get id
                        name = split(t.name, '.');
                        id = str2double(name{1});
                        
                        % get element by id
                        e = obj.GetEntryByID(id);
                        
                        % read dat
                        [S, SS, Samples, DivisionPlanes, CellSeperations, CellPinchings, Difficults] = ReadFile(file);
                        
              
                        e.SampleSet = SampleSet();
                        
                        count = numel(S);
                     
                        
                        for j = 1 : count
                            
                            sample = Sample();
                            
                            sample.profile = S(j);
                            sample.plane = SS(j);
                            
                            %
                            sample.DivisionPlane = DivisionPlanes(j);
                            sample.CellSeperation = CellSeperations(j);
                            sample.CellPinching = CellPinchings(j);
                            sample.Difficult = Difficults(j);
                            
                            e.SampleSet.AddSample(sample);
                            
                        end
                        
                        fprintf("Complete\n");
                        
                    end
                
                end
                
            end
            
            fprintf('\n');
            
        end
        
        % load .geo files
        function LoadGeo(obj)
            
            % get path file(s)
            tmp = dir(obj.path);
            
            % number of file(s)
            n = numel(tmp);
            
            fprintf("Geo file(s)\n");
            
            for i = 1 : n
                
                t = tmp(i);
                
                if (~t.isdir && ~strcmp(t.name(1), '.')) 
                    
                  
                    file = sprintf("%s%s%s", t.folder, filesep(), t.name);
                    
                    if isfile(file)
                        
                        % get id
                        name = split(t.name, '.');
                        id = str2double(name{1});
                        
                        %fprintf("%d\n", id);
                        
                        % get element by id
                        e = obj.GetEntryByID(id);
                        
                        % read polyline
                        e.PolylineSet = PolylineSet(1024);
                        e.PolylineSet.Read(file);  
                        
                    end
                
                end
                
            end
            
            fprintf('\n');
            
        end
        
        function PrintSets(obj)
            
            m = numel(obj.types);
            
            for i = 1 : m
                
                elements = obj.GetEntriesByType(obj.types(i));
                
                n = numel(elements);
                
                fprintf("%s\n", obj.types(i));
                
                for j = 1 : n
                    
                    e = elements(j);
                     
                    id = e.id;
                    
                    
                    
                    %if ~isempty(e.PolylineSet)
                    if ~isempty(e.SampleSet)
                        
                        fprintf("%4d.\t%d", j, id);
                        %fprintf(" geo");
                        fprintf("\n");
                        
                    end
                    
                    
                    
                end
                
            end
    
      	end
    
    end
    
    

    
    % public methods
    methods (Access = public)
        
        %
        function Check(obj, path)
        
            tmp = dir(path);
            
            n = numel(tmp);
            
            k = 0;
            
            data = ADatabase();
            
            for i = 3 : n
            
                if ~tmp(i).isdir
                    
                    k = k + 1;
                    
                    name = tmp(i).name;
                    
                    t = split(name, '.');
                    
                    id = str2double(t{1});
                    
                    entry = obj.GetEntryByID(id);
                    
                    type = entry.type;
                    
                    data.UniqueType(type);
                    
                    fprintf('%4d.\tID = %d\t TYPE = %s\n', k, id, type);
                    
                    data.AddEntry(entry);
                    
                end
                
            end
            
            data.Write("test.dat");
            
        end
        
        %
        function SetPath(obj, path)
           
            obj.path = path;
            
        end
        
        function PrintID(obj)
            
            n = obj.Count();
            
            for i = 1 : n
                
                fprintf("%d\n", obj.entries(i).id);
                
            end
            
        end
        
        % 
        function db = GetSubADatabase(obj, types)
            
            % create new ADatabase
            db = ADatabase();
            
            n = numel(types);
            
            count = 0;
            
            for i = 1 : n
               
                db.types(i) = types(i);
                
                e = obj.GetEntriesByType(types(i));
                
                m = numel(e);
                
                for j = 1 : m
                    
                    count = count + 1;
                    db.entries(count) = e(j).copy();
                    
                end
                
            end
            
        end
        
        % 
        function CopyFiles(obj, path)
            
            % make new directoy
            mkdir(path);
            
            n = obj.Count();
            
         	for i = 1 : n
                
                % copy image with new id 
                tmp = obj.entries(i).path;
                
                tmp(strfind(tmp, '\')) = '/';           % Mac Fix
                
                f1 = sprintf('%s%s', obj.path, tmp(2 : end));
                f2 = sprintf('%s%s%d%s', path, filesep, obj.entries(i).id, '.tif');
                
            
                % copy file
                if ~isfile(f2) && isfile(f1)
                    copyfile(f1, f2);
                end
                
         	end
                
        end
        
        % build ADatabase
        function Build(obj)
            
            % check if working directory exists
            if isfolder(obj.path)
                
                fprintf("Building ADatabase %s...\n\n", obj.version);
                
                % read images
                obj.ReadFolder(obj.path);
                
                fprintf("\nComplete\n\n");
                
            else
                
                error("''%s'' is not a valid directoy", obj.path);

            end

        end
 
        % read ADatabase
        function Read(obj, file)
            
            % open file
            fid = fopen(file, 'r');
            
            % version
            str = fgetl(fid);
            tmp = split(str, 'v');
            obj.version = sprintf('v%s', tmp{end});

            % number of entries
        	fgetl(fid);
            str = fgetl(fid);
            tmp = split(str, ':');
            n = str2double(tmp{end});
            
            % number of types
            str = fgetl(fid);
            tmp = split(str, ':');
            m = str2double(tmp{end});
            
            % skip lines
            for i = 1 : m
               fgetl(fid);
            end

            fgetl(fid);
            
            % read entries
            for i = 1 : n
                
                % create entry
                E = Entry();
                
                % entry
                fgetl(fid);
                
                % id
                str = fgetl(fid);
                tmp = split(str, ':');
                E.id = str2double(tmp{end});
                
                % type
                str = fgetl(fid);
                tmp = split(str, ':');
                tmp = tmp{end};
                type = tmp(3:end-1);
                E.type = type;
                obj.UniqueType(type);
                
                % path
                str = fgetl(fid);
                tmp = split(str, ':');
                tmp = tmp{end};
                E.path = tmp(3:end-1);
                                              
                % date
                %tmp = split(E.path, filesep);
                %date = tmp{end - 1};
                %E.date = date;
                
                % space
                fgetl(fid);
                
                obj.AddEntry(E);
                
            end
            
            % close file
            fclose(fid);
            
        end
        
    	% write ADatabase
        function Write(obj, file)
            
            % open file
            fid = fopen(file, 'w');
            
            % write header
            fprintf(fid, "ADatabase %s\n", obj.version);
            fprintf(fid, "\n");
            fprintf(fid, "Entries: %d\n", obj.Count());
            fprintf(fid, "Types: %d\n", numel(obj.types));
            
            n = numel(obj.types);
            for i = 1 : n
                count = numel(obj.GetEntriesByType(i));
                fprintf(fid, "%32s%16d\n", sprintf("'%s'", obj.types(i)), count);
            end
            fprintf(fid, "\n");
            
            n = obj.Count();
            for i = 1 : n
                obj.WriteEntry(fid, i);
            end
            
            % close file
            fclose(fid);
            
        end

        % return set of entries by type
      	function e = GetEntriesByType(obj, type)
            
            if isnumeric(type)
                type = obj.types(type);
            end
            
            e = Entry.empty();
            
            count = 0;
            
            n = obj.Count();
            
            for i = 1 : n
                
                if strcmp(obj.entries(i).type, type)
                   
                    count = count + 1;
                    e(count) = obj.entries(i);
                    
                end
                
            end
            
        end
        
     	% return entry by blinded id number
        function e = GetEntryByID(obj, id)
            
            idx = obj.idToIdx(id);
            
            if ~isempty(idx)
            
                e = obj.entries(idx);
                
            else
               
                error("Entry with id: %d not found", id);
                
            end
            
        end
        
        % is id
        function bool = IsEntryByID(obj, id)
            
            if ~isempty(obj.idToIdx(id))
                
                bool = 1;
                
            else
                
                bool = 0;
                
            end
            
        end
        
      	% return number of entries in ADatabase
        function count = Count(obj)
            
            count = numel(obj.entries);
            
        end
        
    end
    
    % private methods
    methods (Access = private)
 
        % recursively read folders and add entries
        function ReadFolder(obj, path)
            
            fprintf("Reading %s\n", path);
            
            tmp = dir(path);
            
            n = size(tmp);
            
            for i = 3 : n
               
                if tmp(i).isdir
                    
                    % read subfolder
                    obj.ReadFolder(sprintf('%s%s%s', tmp(i).folder, filesep, tmp(i).name));
                    
                else
                    
                    % get file name
                    str1 = split(tmp(i).name, '.');
       
                    % check if file is tif
                    if strcmp(str1{end}, 'tif')
                        
                        % create entry
                        E = Entry();
                        E.id = obj.GenerateID();
                        
                        % get cell type from parent folder
                        str2 = split(tmp(i).folder, filesep);
                        type = str2{end - 1};
                        
                        % add type
                        obj.UniqueType(type);
                        E.type = type;
                        
                        % add date
                        date = str2{end};
                        E.date = date;
                        
                        %E.path = ['.\', str2{end - 1}, '\', str2{end}, '\', tmp(i).name];
                        %E.path = sprintf('.%s%s%s%s%s%s', filesep, type, filesep, date, filesep, tmp(i).name);
                        E.path = sprintf('.%s%s%s%s%s%s', '\', type, '\', date, '\', tmp(i).name);
                        
                        % add entry
                        if ~obj.DoesEntryExist(E.path)
                            
                            fprintf("\tAdding entry %4d: %s as %d\n", obj.Count() + 1, E.path, E.id);
                            
                            obj.AddEntry(E);
                            
                        end
                        
                    end
                    
                end
                
            end
        
        end
        
        % 
        function bool = DoesEntryExist(obj, path)
           
            bool = false;
            
            n = obj.Count();
            
            for i = 1 : n
               
                if strcmp(path, obj.entries(i).path)
                    
                    bool = true;
                    return;
                    
                end
                
            end
            
        end
                
        % generate unique random 10 digit id number
        function id = GenerateID(obj)
            
            % first attempt
            id = floor(rand() * 1000000000);
            
            while ~obj.UniqueID(id)
                
                % try again
                id = floor(rand() * 1000000000);
                
            end
            
        end
        
     	% check if id is unique
        function bool = UniqueID(obj, id)
           
            bool = true;
            
            n = obj.Count();
            
            for i = 1 : n
               
                if obj.entries(i).id == id
                    
                    bool = false;
                    return;
                    
                end
                
            end
 
        end
                
        % check if type is unique
        function bool = UniqueType(obj, type)
            
            bool = true;
            
            n = numel(obj.types);
            
            for i = 1 : n
                
                if strcmp(obj.types(i), type)
                    
                    bool = false;
                    return;
                    
                end
                
            end
            
            % add type
            obj.types(n + 1) = type;
            
        end
        
        % add entry to ADatabase
     	function AddEntry(obj, entry)
            
            n = obj.Count();
            
            % check if entry already exists
            for i = 1 : n
                
                if entry.id == obj.entries(i).id
                    
                    fprintf("%d already in database\n", entry.id);
                    
                    return;
                    
                end
                
            end
         
            
            obj.entries(n + 1) = entry;  
            
        end
        
        % write entry
        function WriteEntry(obj, fid, i)
            
            entry = obj.entries(i);
            
            fprintf(fid, "Entry: %d\n", i);
            fprintf(fid, "id: %d\n", entry.id);
            fprintf(fid, "type: %s\n", sprintf("'%s'", entry.type));
            fprintf(fid, "path: %s\n", sprintf("'%s'", entry.path));
            fprintf(fid, "\n");
            
        end
        
        % get absolute filename of entry
        function file = GetFile(obj, id)
            
            E = obj.entries(obj.idToIdx(id));

            file = sprintf('%s%s', obj.path, E.path(2 : end));
            
        end
        
        % convert blinded id to ADatabase id
        function idx = idToIdx(obj, id)
        
            idx = [];
            
            n = obj.Count();
            
            for i = 1 : n
                
                if obj.entries(i).id == id
                   
                    idx = i;
                    return;
                    
                end
                
            end
            
        end

    end
    
end