function fig = calibrate(image_folder)
%% CALIBRATE   Do calibration (correction) on image stack
%
%   mbf.calibrate;
%   fig = mbf.calibrate(image_folder);
%
%  --------
%   INPUTS
%  --------
%  image_folder   :     (Optional) Full path of image folder with image
%                          stack to do calibration. (e.g.
%                          'C:/Pictures/Data')
%
%                             -> Can be given as a cell array to do
%                                   multiple at once.
%
%  --------
%   OUTPUT
%  --------
%  fig            :     Handle to UI for figure to preview how correction
%                          looks.
%
%  Creates a new folder in the parent directory of image_folder with the
%  same name as image_folder with '_out' appended. Image stack in that
%  folder will have the correction applied.
%
% By: Max Murphy  v1.0  2019-02-13  Original version (R2017a)

%% PARSE INPUT
if nargin < 1
   image_folder = uigetdir('C:\','Select image stack folder');
   if image_folder == 0
      error('No folder selected. Calibration canceled.');
   end
end

if iscell(image_folder)
   fig = cell(size(image_folder));
   for ii = 1:numel(image_folder)
      fig{ii} = calibrate(image_folder{ii});
   end
   return;
end

%% GET DIMENSIONS
F = dir(fullfile(image_folder,'*'));
F = F(~[F.isdir]); % Remove any folder elements only want files

if isempty(F)
   error('No images located in that folder (%s). Is it correct?',...
      image_folder);
end

A = imread(fullfile(image_folder,F(1).name));
[h,w,nChan] = size(A);

%% IF CORRECTION EXISTS, LOAD IT, OTHERWISE PROMPT FOR CORRECTION
p = mfilename('fullpath');
[funcDir,~,~] = fileparts(p);

calFile = fullfile(funcDir,sprintf('cal-%05gx%05g.mat',h,w));
if exist(calFile,'file')==0
   if ~getCorrection(calFile)
      error('Unable to obtain correction file. Calibration canceled.');
   end
end
cal = load(calFile,'img');

%% APPLY THE CORRECTION AND WRITE TO OUTPUT FOLDER
out_folder = fullfile([image_folder '_out']);
if exist(out_folder,'dir')==0
   mkdir(out_folder);
   
else  % If it already exists, delete and make new (re-apply calibration)
   delete(out_folder);
   mkdir(out_folder);
end

fprintf(1,'Performing correction...%03g%%\n',0);
pct = 0;
N = numel(F);
for ii = 1:N
   if nChan == 1
      A = imread(fullfile(image_folder,F(ii).name));
      B = A - cal.img; % Just subtract correction
      imwrite(B,fullfile(out_folder,F(ii).name));
   else % Otherwise, use LAB color space for median correction
      A = rgb2lab(fullfile(image_folder,F(ii).name));
      B = lab2rgb(A - cal.img); % Just subtract correction
      imwrite(B,fullfile(out_folder,F(ii).name));
   end
   
   
   % Only overwrite when percentage increases:
   frac_done = floor(ii/N * 100); 
   if frac_done > pct
      pct = frac_done;
      fprintf(1,'\b\b\b\b\b%03g%%\n',pct);
   end
end

%% SHOW CORRECTION FIGURE
fig = figure('Name',sprintf('%s: Calibration Preview',image_folder),...
   'Units','Normalized',...
   'Color','w',...
   'Position',[0.1 0.1 0.8 0.8]);

axA = axes(fig,'Units','Normalized',...
   'Position',[0.05 0.05 0.425 0.9],...
   'Color','w',...
   'XColor','w',...
   'XLimMode','manual',...
   'XLim',[0 1],...
   'YColor','w',...
   'YLimMode','manual',...
   'YLim',[0 1],...
   'YDir','reverse',...
   'FontName','Arial',...
   'XTick',[],...
   'YTick',[],...
   'NextPlot','add');

axB = axes(fig,'Units','Normalized',...
   'Position',[0.525 0.05 0.425 0.9],...
   'Color','w',...
   'XColor','w',...
   'XLimMode','manual',...
   'XLim',[0 1],...
   'YColor','w',...
   'YLimMode','manual',...
   'YLim',[0 1],...
   'YDir','reverse',...
   'FontName','Arial',...
   'XTick',[],...
   'YTick',[],...
   'NextPlot','add');

imagesc(axA,[0 1],[0 1],A);
imagesc(axB,[0 1],[0 1],B);


end

