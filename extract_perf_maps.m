function extract_perf_maps(perf_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Code adapted from the Susceptibility Module provided in MP3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = niftiread(perf_file);
if size(N,4) == 1
    error([perf_file ' is not a 4d image']);
end

N = double(N);
info = niftiinfo(perf_file);
[path, ~, ~] = fileparts(perf_file);

J = spm_jsonread(strrep(perf_file, '.nii', '.json'));

%% Remove Background
% Method by Jean-Albert Lotterie (CHU Toulouse)
MeanVol = mean(N,4);
% m1 mean on the 8 voxels on the 8 corners of the volume. Those voxels
% belongs to the background. It's the first zone.
Mask1 = false(size(MeanVol));
Mask1(1,1,1) = 1;
Mask1(end,1,1) = 1;
Mask1(1,end,1) = 1;
Mask1(end,end,1) = 1;
Mask1(1,1,end) = 1;
Mask1(end,1,end) = 1;
Mask1(1,end,end) = 1;
Mask1(end,end,end) = 1;
m1 = mean(MeanVol(Mask1(:)));
%The second zone is the complementary of the first one. Its mean is m2.
Mask2 = ~Mask1;
m2 = mean(MeanVol(Mask2(:)));

ArithmMean = mean([m1,m2]);
OldArithmMean = 0;

while floor(ArithmMean) == OldArithmMean
    Mask1 = MeanVol<ArithmMean;
    m1 = mean(MeanVol(Mask1(:)));
    Mask2 = ~Mask1;
    m2 = mean(MeanVol(Mask2(:)));
    OldArithmMean = floor(ArithmMean);
    ArithmMean = mean([m1,m2]);
end

Mask = MeanVol >= ArithmMean;
ExcluededVoxels = ~Mask;
B = repmat(ExcluededVoxels, [1, 1, 1, size(N,4)]);
N(B) = NaN;
    
%% Processing
meansignal = mean(squeeze(N),4);
volume_mask = meansignal>max(N(:))*0.01;
[aif,scores] = extraction_aif_volume(squeeze(N),volume_mask);

if sum(cell2mat(scores(:,5))) > 10
    error('No computation because the AIF is not good enough');
else
    [~,~,~,TMAX,TTP,T0, CBV,CBF,MTT,~,~,~,~] = deconvolution_perfusion_gui(aif,squeeze(N),J.RepetitionTime.value(1)*10^(-3),J.EchoTime.value*10^(-3));
    %maps = {'CBV','CBF','MTT','TMAX','TTP','T0'};

    CBV(ExcluededVoxels) = NaN;
    CBF(ExcluededVoxels) = NaN;
    MTT(ExcluededVoxels) = NaN;
    TMAX(ExcluededVoxels) = NaN;
    TTP(ExcluededVoxels) = NaN;
    T0(ExcluededVoxels) = NaN;
    mapsVar = {CBV, CBF, MTT, TMAX, TTP, T0};
    output_files = {'CBV', 'CBF', 'MTT', 'TMAX', 'TTP', 'T0'};
    output_files = fullfile(path,strcat(output_files,'.nii'));
end

%% Reshape to the input scan size
%FilteredImages = reshape(FilteredImages, Size);

for i=1:length(mapsVar)
    info2 = info;
    info2.Filename = output_files{i};
    info2.Filemoddate = char(datetime('now'));
    info2.Datatype = class(mapsVar{i});
    info2.PixelDimensions = info.PixelDimensions(1:length(size(mapsVar{i})));
    info2.ImageSize = size(mapsVar{i});
    info2.MultiplicativeScaling = 1;
    niftiwrite(mapsVar{i}, output_files{i}, info2)
end
end