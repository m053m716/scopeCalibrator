function flag = getCorrection(calFile)
%% GETCORRECTION  Get correction offset to apply for calibration of MBF
%
%  flag = mbf.getCorrection;
%  flag = mbf.getCorrection(calFile);
%
%  --------
%   INPUTS
%  --------
%   calFile    :     (optional) Calibration file name. If specified, then
%                       the first image in image stack selected for
%                       obtaining the correction MUST be the same dimension
%                       as parsed from the calibration filename. Format is
%                       'cal-hhhhhxwwwww.mat' where h is height character,
%                       w is width character
%
%  --------
%   OUTPUT
%  --------
%    flag      :     Flag indicating successful completion.
%
% By: Max Murphy  v1.0  2019-02-13  Original version (R2017a)

%% INITIALIZE VARIABLES
flag = false;
h = nan;
w = nan;

%% PARSE INPUT
if nargin == 1
   [~,calFile,~] = fileparts(calFile);
   idx = regexp(calFile,'\d\d\d\d\d');
   h = str2double(calFile(idx(1):(idx(1)+4)));
   w = str2double(calFile(idx(2):(idx(2)+4)));
else
   calFile = 'cal-%05gx%05g.mat';
end

%% GET CORRECTION IMAGE STACK
correction_folder = uigetdir('C:\',...
   'Select folder with CORRECTION image stack');
if correction_folder == 0
   warning('No CORRECTION folder selected.');
   return;
end

%% CHECK THAT IT IS A VALID FOLDER
F = dir(fullfile(correction_folder,'*'));
F = F(~[F.isdir]); % Remove sub-directories
% Get size of first image in that image stack
a = imread(fullfile(F(1).folder,F(1).name));
[hh,ww,~] = size(a);
if ~isnan(h) && ~isnan(w) % Then check dimensions of first image
   returnFlag = false;
   if ~(h == hh)
      warning('Bad HEIGHT dimension (%g; should be %g).',hh,h);
      returnFlag = true;
   end
   
   if ~(w == ww)
      warning('Bad WIDTH dimension (%g; should be %g).',ww,w);
      returnFlag = true;
   end
   
   if returnFlag
      return;
   end
else
   calFile = sprintf(calFile,hh,ww);
end

%% EXTRACT OFFSET IMAGE AND SAVE IT
img = extractCorrectionImage(F,a); 
p = mfilename('full');
[funcDir,~,~] = fileparts(p);
save(fullfile(funcDir,calFile),'img','-v7.3');
flag = true;

%% SUB-FUNCTIONS
   function img = extractCorrectionImage(F,a)
      n = numel(F);
      
      img = zeros(size(a,1),size(a,2),size(a,3),n);
      
      fprintf(1,'Computing correction offset...%03g%%\n',0);
      pct = 0;      
      for i = 1:n
         if (size(a,3) == 1)
            img(:,:,:,i) = imread(fullfile(F(i).folder,F(i).name));
         else
            img(:,:,:,i) = rgb2lab(imread(fullfile(F(i).folder,F(i).name)));
         end
         % Only overwrite when percentage increases:
         frac_done = floor(i/n * 100); 
         if frac_done > pct
            pct = frac_done;
            fprintf(1,'\b\b\b\b\b%03g%%\n',pct);
         end
      end
      img = median(img,4); % Take median across all images for each pixel
   end

end