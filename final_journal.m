function T = final_journal(n)

slice_loc = 'combined\\';
slice_grey = imread(strcat(slice_loc, 'Input_DCM_', int2str(n), '.png'));       % ORIGINAL LOW-RES DICOM SLICES

tic;
num_iter = 15;
delta_t = 1/7;
kappa = 3;
option = 2;
slice_grey = uint8(anisodiff2D(slice_grey, num_iter, delta_t, kappa, option));

% Boundary detection of brain (skull-outer)
BW1 = slice_grey > (graythresh(slice_grey) * 255);
BW2 = imfill(BW1,'holes');

% BW3 = bwmorph(BW2,'remove');    % outline of brain (skull-outer)
BW4 = ~BW2;

% Distance transform (normalized)
Dp = bwdist(BW4,'cityblock');
Dpn = norm01(Dp);

slice_grey(BW4) = 255;
% MSER
regions = detectMSERFeatures(slice_grey, 'ThresholdDelta', 0.8);

% Extract statistics from MSER regions
R = size(regions);
R = R(:,1);     % number of regions extracted

C = double(R);
N = double(R);

% Invert intensities so that grey has higher value
afterInversion = norm01(255 - double(slice_grey));      slice_grey(BW4) = 0;      % revert to original color

afterConversion = norm01(Dpn.*afterInversion);

Pr = cell(1, R);     % cell array to store "R" lists of pixels' linear indices

for i = 1: 1: R
    a = regions(i).PixelList;
    rowSub = a(:,2);
    colSub = a(:,1);
    
    linearInd = sub2ind(size(slice_grey), rowSub, colSub);
    Pr{i} = linearInd;
    
    N(i) = numel(rowSub);
    C(i) = sum(afterConversion(linearInd)) / N(i);
end

[x,fval] = ga(@(x)ventriclefitnessfcn(x,C),R,[],[],[],[],[],[],[],gaoptimset('PopulationType','bitstring'));

% Determine region of interest for WMI detection
BW5 = zeros(size(BW4));
for i = 1: 1: R
    if x(i) == 1
        BW5(Pr{i}) = 1;     % ventricles
    end
end

Df = bwdist(BW5,'cityblock');

BW6 = abs(Df - Dp) <= 1;    % ROI boundary (outer)
BW7 = logical(imfill(BW6,'holes').*(~BW5));

% Detect outliers assuming normal distribution

V = double(slice_grey(BW7));    % Intensities of pixels within ROI
med_V = median(V);
cri_V = 2 * mad(V,1) / 0.6745;

BW8 = logical(BW2 - BW5);  % brain with ventricle removed

X1 = slice_grey.*uint8(BW8);

BW9  = logical(X1 > med_V + cri_V);   % potential candidates for white matter injury

% Calculate potential WMI regions' properties
[L,num_R] = bwlabel(BW9);
Rc = zeros(1, num_R);
Rd = zeros(1, num_R);
for i = 1:num_R
    LI = logical(L == i);
    Rc(i) = sum(LI(:));
    Rd(i) = min(Dp(LI(:)));
end

% Filter list of potential WMI regions by size
S_Rc = sort(Rc(Rc < prctile(Rc, 95)));
idx = kmeans(S_Rc', 2, 'Start', [S_Rc(1),S_Rc(end)]');
firstIndex = find(idx==2, 1);       % first "big" region
Th_Rc = S_Rc(firstIndex);

% Filter list of potential WMI regions by distance from ventricles
S_Rd = sort(Rd(Rd > prctile(Rc, 5)));
idx = kmeans(S_Rd', 2, 'Start', [S_Rd(1),S_Rd(end)]');
firstIndex = find(idx==2, 1);       % first "far" region
Th_Rd = S_Rd(firstIndex);

toc

% Visualization / Evaluation (depending on which statements are commented)
% T = slice_grey;
T = zeros(size(slice_grey));
for i = 1:num_R
    if Rc(i) < Th_Rc && Rd(i) > Th_Rd
%         T = T + uint8(L == i).*255;
        T = T + (L == i);
    end
end

% imwrite(T, strcat('WMI_',int2str(n),'_AD_15.png'));
% imwrite(slice_grey + uint8(BW5).*255, strcat('ventricles_',int2str(n),'_AD_15.png'));