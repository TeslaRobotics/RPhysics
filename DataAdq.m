
%% Clear Workspace
clear all; %#ok<CLSCR>
close all
clc;

ballTimes = cell(1,1);
rotorTimes = cell(1,1);

for iVid = 1:11
    %% Read Video
    %record = 'R8.mp4';
    url = strcat('D:\video_data\R',num2str(iVid));
    url = strcat(url,'.mp4');
    videoReader = vision.VideoFileReader(url);
    
    %% Create Video Player
    videoPlayer = vision.VideoPlayer;
    
    %% Create blob analysis object
    %Blob analysis object further filters the detected foreground by rejecting blobs which contain fewer
    % than 150 pixels.
    blobAnalysisBall = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
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
    e2Ball = impoly(gca,[347 32;382 44;393 17;353 5]);
    BW1Ball = createMask(e2Ball,h);
    
    e2Rotor = impoly(gca,[354 100;369 64;395 80;373 111]);
    BW1Rotor = createMask(e2Rotor,h);
    
    %% Run on first 75 frames to learn background
    
    ballT = zeros(1,1);
    rotorT = zeros(1,1);
    
    i = 0;
    
    while ~isDone(videoReader)
        i = i + 1;
        
        videoFrame = step(videoReader);
        
        r = videoFrame(:,:,1);
        g = videoFrame(:,:,2);
        b = videoFrame(:,:,3);
        f = g - r/2 - b/2 ;
        bwrot = f>0.03;
        bwrot = and(bwrot,BW1Rotor);
        
        rotorT(i) = sum(sum(bwrot));
        
        foreground = step(foregroundDetector,videoFrame);
        % Perform morphological filtering
        %cleanForeground = imopen(foreground, strel('Disk',1));
        cleanForeground = foreground ;
        cleanForeground = and(cleanForeground,BW1Ball);
        
        [area,cent,bbox] = step(blobAnalysisBall, cleanForeground);
        
        if ~isempty(area)
            [~,I] = max(area);
            ballT(i) = area(I);
        else
            ballT(i) = 0;
        end
        
        
        % Display output
        step(videoPlayer, foreground);
        
        
    end
    
    [pks1,tball] = findpeaks(ballT,1:i,'MinPeakDistance',20,'MinPeakHeight',60);
    [pks2,trotor] = findpeaks(rotorT,1:i,'MinPeakDistance',40,'MinPeakHeight',300);
    
     tball = tball - tball(1);
     tball = tball(2:end); 
     tball = tball*25/1000;  
     
     trotor = trotor - trotor(1);
     trotor = trotor(2:end); 
     trotor = trotor*25/1000;  
    
    ballTimes{iVid} = tball;
    rotorTimes{iVid} = trotor;
    
    
end


save RouletteData ballTimes rotorTimes;

%% release video reader and writer
release(videoPlayer);
release(videoReader);

delete(videoPlayer); % delete will cause the viewer to close

