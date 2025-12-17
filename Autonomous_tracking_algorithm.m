% Umbilical artery autonomous tracking algorithm. 
% By measuring the inter-frame color difference in the duplex video, 
% the tracking algorithm identifies the centroid of the umbilical artery. 
% MeanColorThresh is the threshold to distinguish the color Doppler pixels with B-mode pixels; 
% Prtn is the thresshold to differentiate the pulsating artery and non-pulsating vein regions using the inter-frame color difference;
% SizeThLow and SizeThHigh are size thresholds to discard cases,
% where segmented area is too small or too large to be identified as umbilical artery; 
% stdThresh is the standard deviation threshold to discard cases during fast cord movements.
% Owned by Sheng Xu research group, University of California, San Diego.

clear all

vidObj = VideoReader('Sample.mp4'); % Load RGB video
VFR = vidObj.FrameRate % Obtain frame rate
IUmbArtSeg = read(vidObj);
Th = 16; % Size of the inspected frame window, change with desired window time length and framerate
clear vidObj

% Unit test for playing the video
SZSeg = size(IUmbArtSeg);
for tp = 1:SZSeg(4)
    imshow(IUmbArtSeg(:,:,:,tp))
    pause(1/VFR);
end

%% Identify the pulsating region
MeanColor = repmat(mean(IUmbArtSeg,3),[1 1 3 1]); % Mean intensity of RGB channel for each pixel in each frame
NImg = double(IUmbArtSeg) - MeanColor;
clear MeanColor
NColorImg = squeeze(sum(NImg.^2,3));
clear NImg

MeanColorThresh = 50; % Threshold to distinguish the color Doppler pixels with B-mode pixels
NColorImgLogic = NColorImg > MeanColorThresh;
clear NColorImg

% Unit test for segmenting the color Doppler pixels
for tp = 1:SZSeg(4)
    imshow(NColorImgLogic(:,:,tp))
    pause(1/VFR);
end

iuasDiff = squeeze(sum(abs(IUmbArtSeg(:,:,:,1:end-1)-IUmbArtSeg(:,:,:,2:end)),3));

%% Segment the umbilical artery
SE = ones(1,1,Th); % Structural element
ClrDiffSum = convn(iuasDiff,SE,'valid');
clear iuasDiff
SzClr = size(ClrDiffSum)
clear IUmbArt

Prtn = 16; % Threshold to differentiate the pulsating artery and non-pulsating vein regions using the inter-frame color difference
% The portion sets an adaptive threshold for vessel segmentation. For
% Verasonics operation, an emperical threshold of 4.875 color difference
% is used
CDResult = ClrDiffSum>max(ClrDiffSum,[],'all')*1/Prtn; 
CDResult = CDResult .* NColorImgLogic(:,:,1+Th/2:SzClr(3)+Th/2);

% Unit test for segmenting the umbilical arteries
for tp = 1:SzClr(3)
%     imshow(CDResult(:,:,tp))
    imshowpair(CDResult(:,:,tp),IUmbArtSeg(:,:,:,tp+Th/2),'montage') %
    pause(1/VFR);
end

clear NColorImgLogic
clear ClrDiffSum

% Use morphological operations to get more precise centroid and remove noises
SE = ones(8,8);
I = logical.empty;
for tp = 1:SzClr(3)
    I = cat(3,I,imerode(CDResult(:,:,tp),SE)); % imdilate(,SE)
end
clear CDResult

%% Recognize the primary region of the umbilical artery
tic
BlobVid = zeros(SzClr);
for tp = 1:SzClr(3)
    [L, num] = bwlabel(I(:,:,tp),8);
    thisBlob = zeros(SzClr(1),SzClr(2),num);
    for k = 1 : num
        thisBlob(:,:,k) = ismember(L, k);
    end
    Npixel = squeeze(sum(thisBlob,[1 2]));
    [mxP,ImxP] = max(Npixel);
    SizeThLow = 80; % Threshold to filter small regions that are noises
    SizeThHigh = 50000; % Threshold to filter regions that are caused by large movement
    % If the area of the primary region is smaller than the threshold, this frame is considered invalid
    if isempty(ImxP) ~= 1 && mxP > SizeThLow && mxP < SizeThHigh
        BlobVid(:,:,tp) = thisBlob(:,:,ImxP(1));
    end
end
toc

clear I

% Unit test for recognizing the primary region
for tp = 1:SzClr(3)
    imshowpair(BlobVid(:,:,tp),IUmbArtSeg(:,:,:,tp+Th/2),'montage')
    pause(2*1/VFR);
end
close all
IGfinal = IUmbArtSeg(:,:,:,1+Th/2:SzClr(3)+Th/2); % 

%% Identify the centroid
CntCords = zeros(2,SzClr(3));
for tp = 1:SzClr(3)
    [Xind,Yind] = find(BlobVid(:,:,tp));
    XMean = round(mean(Xind));
    YMean = round(mean(Yind));
    CntCords(:,tp) = [XMean YMean];
end

% Register sample gate when movement is minimized
for tp = 1+Th/2:SzClr(3)-Th/2
    CntCordsStd(:,tp-Th/2) = std(CntCords(:,tp-Th/2:tp+Th/2).');
end

stdThresh = 75; % Standard deviation threshold

Ct = 0; % Optional: a time counter to preent the sample gate being changed too frequently. Usually for testing purposes.
for tp = 1+Th/2 : SzClr(3)-Th/2
%% Register as sample gate
    if  CntCords(1,tp) > 4 && CntCords(2,tp) > 4
        if Ct > 0
            Ct = Ct-1;
            continue
        else
            if max(CntCordsStd(:,tp-Th/2)) <= stdThresh
                IGfinal(CntCords(1,tp)-3:CntCords(1,tp)+3,CntCords(2,tp)-3:CntCords(2,tp)+3,:,tp:tp+VFR-1) = repmat(reshape([0 255 0],[1 1 3]),[7,7,1,VFR]);
                Ct = VFR; % The minimal sampling gate change time is 1 second
            end
        end
    end
end

%% Display final results
% Make sure the host has enough calculation power on the CPU to ensure correct
% framerate for the display
for tp = 1:SzClr(3)
    image(IGfinal(:,:,:,tp))
    pause(1/VFR);

end


