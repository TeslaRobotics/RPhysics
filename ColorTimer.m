
%% Clear Workspace
clear all; %#ok<CLSCR>
close all
clc;
%% Read Video
record = 'R2.mp4';
url = strcat('D:\video_data\',record);
videoReader = vision.VideoFileReader(url);

%% Create Video Player
videoPlayer = vision.VideoPlayer;

%% Create blob analysis object 
%Blob analysis object further filters the detected foreground by rejecting blobs which contain fewer
% than 150 pixels.
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', false, ...
    'AreaOutputPort', false, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 40);

%% ROI ellipse

videoFrame = step(videoReader);
h =imshow(videoFrame);
e2 = impoly(gca,[354 100;369 64;395 80;373 111]);
BW1 = createMask(e2,h);

%% Run on first 75 frames to learn background

P = zeros(1,1);
i = 0;

while ~isDone(videoReader)
    i = i + 1;
    
    videoFrame = step(videoReader);
    
    r = videoFrame(:,:,1);
    g = videoFrame(:,:,2);
    b = videoFrame(:,:,3);
    f = g - r/2 - b/2 ;
    bw = f>0.03;
    bw = and(bw,BW1); 
    
    P(i) = sum(sum(bw)); 

    % Display output 
    step(videoPlayer, bw);
    
    
end




%% release video reader and writer
release(videoPlayer);
release(videoReader);

delete(videoPlayer); % delete will cause the viewer to close

%% Obtain decelration model

plot(P);


[pks,xdata] = findpeaks(P,1:i,'MinPeakDistance',40,'MinPeakHeight',300)
xdata = xdata - xdata(1);
xdata = xdata*25/1000; 
ydata = 0:(length(xdata)-1);

T0 = xdata(2);

fun = @(k,xdata) (1+(k/2)*(T0^2))*xdata/T0 - (k/2)*xdata.^2;
k0 = 0;

k = lsqcurvefit(fun,k0,xdata,ydata)

times = linspace(xdata(1),xdata(end));
plot(xdata,ydata,'ko',times,fun(k,times),'b-')
legend('Data','Fitted exponential')
title('Data and Fitted Curve')

% k1 = 8.3471e-07  0.0013 in seconds
% k2 = 5.8182e-07  9.3091e-04
% k3 = 1.2025e-06
% k4 = 1.1947e-06
% k5 = 7.6236e-07
% k6 = 8.7783e-07
% k7 = 1.1771e-06
% k8 = 7.2487e-07
% k9 = 1.2431e-06
% k10 = 9.5246e-07
% k11 = 7.1183e-07

% mean 9.3303e-07

