
%% Clear Workspace
clear all; %#ok<CLSCR>
close all
clc;
%% Read Video
record = 'R8.mp4';
url = strcat('D:\video_data\',record);
videoReader = vision.VideoFileReader(url);

%% Create Video Player
videoPlayer = vision.VideoPlayer;

%% Create blob analysis object 
%Blob analysis object further filters the detected foreground by rejecting blobs which contain fewer
% than 150 pixels.
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 4,'MaximumBlobArea',600);

%% Create Foreground Detector  (Background Subtraction)
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3,'NumTrainingFrames', 50);

%% Run on first 75 frames to learn background
for i = 1:30
    videoFrame = step(videoReader);    
    step(foregroundDetector,videoFrame);    
end
reset(videoReader); 

%% ROI ellipse

videoFrame = step(videoReader);
h =imshow(videoFrame);
e2 = impoly(gca,[347 32;382 44;393 17;353 5]);
BW1 = createMask(e2,h);

%% Run on first 75 frames to learn background

P = zeros(1,1);
i = 0;

while ~isDone(videoReader)
    i = i + 1;
    
    videoFrame = step(videoReader);
    
    foreground = step(foregroundDetector,videoFrame);
    % Perform morphological filtering
    %cleanForeground = imopen(foreground, strel('Disk',1));
    cleanForeground = foreground ;
    cleanForeground = and(cleanForeground,BW1);
    
    [area,cent,bbox] = step(blobAnalysis, cleanForeground);
    
    if ~isempty(area)        
        [~,I] = max(area);        
        P(i) = area(I);
    else
        P(i) = 0;
    end


    % Display output 
    step(videoPlayer, foreground);
    
    
end




%% release video reader and writer
release(videoPlayer);
release(videoReader);

delete(videoPlayer); % delete will cause the viewer to close

%% Obtain decelration model

subplot(2,2,1);
findpeaks(P,1:i,'MinPeakDistance',20,'MinPeakHeight',60);
[pks,tk] = findpeaks(P,1:i,'MinPeakDistance',20,'MinPeakHeight',60);

%(40)
 
 tk = tk - tk(1);
 tk = tk(2:end);
 
 tk = tk*25/1000;  
 k = 1:length(tk);
 
 c0fun = @(a,b) -acoth((exp(a*2*pi) - cosh(a*b*tk(1)))/sinh(a*b*tk(1))); 
 fun = @(p,k) (1/(p(1)*p(2)))*(c0fun(p(1),p(2)) - asinh(sinh(c0fun(p(1),p(2)))*exp(p(1)*k*2*pi)));
 
 p0 = [0.01 -3];
 
 par = lsqcurvefit(fun,p0,k,tk);
 
 subplot(2,2,2);
 plot(k,tk,'ko',k,fun(par,k),'b-');
 
 a = par(1);
 b = par(2);
 
 %(41)
 
 beta = a*b^2;
 


 
 
 
 


