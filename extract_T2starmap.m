function extract_T2starmap(t2_file,thresh,lim)

N = niftiread(t2_file);
N = abs(N); % rajouté pour des images avec presque que des valeurs negatives 
info = niftiinfo(t2_file);

%% load input JSON file
J = spm_jsonread(strrep(t2_file, '.nii', '.json'));

% define the threshold and variables
echotime = J.EchoTime.value;
firstecho = sum(echotime < lim(1)) + 1;

first_echotime=echotime(firstecho);

% Get information from the JSON data
%if isfield(J, 'SpinEchoTime')
if isfield(J, 'MethodDiffusion')
    if strcmp(J.MethodDiffusion.value, 'User:eb_MGEFIDSE')    
        lastecho = sum(echotime<J.SpinEchoTime.value/2);
    else 
        lastecho = length(echotime);
    end
else
    lastecho = length(echotime);
end

last_echotime= echotime(lastecho);
% update the last_echotime if the user add a specific value
if last_echotime > lim(2)
    lastecho = sum(echotime < lim(2));
end
echotimes_used = echotime(firstecho:lastecho);

% reshape the data to a vector matric (speed the fitting process)
%data_to_fit = reshape(double(data.img), [size(data.img,1)*size(data.img, 2)*size(data.img,3) numel(EchoTime)]);
data_to_fit = reshape(double(N), [size(N,1)*size(N, 2)*size(N,3) numel(echotime)]);
maxim=max(data_to_fit(:)) * thresh/100;

%% create empty structures
T2map_tmp = NaN(size(data_to_fit,1),1);

parfor voxel_nbr=1:size(data_to_fit,1)
    tempydata=data_to_fit(voxel_nbr,:);
    if tempydata(1)>maxim
        % fit initializing
        t2s=(first_echotime-last_echotime)/log(tempydata(lastecho)/tempydata(firstecho));
        if t2s<=0 || isnan(t2s)
            t2s=30;
        end
        t2s=30;
        % apply the fit
        %[aaa, bbb,  ~]=levenbergmarquardt('AB_t2s',echotime_used, tempydata(firstecho:lastecho)',[t2s max(tempydata(firstecho:lastecho))*1.5]);
        [aaa, ~,  ~]=levenbergmarquardt('AB_t2s',echotimes_used, tempydata(firstecho:lastecho)',[t2s max(tempydata(firstecho:lastecho))*1.5]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        if aaa(1)>0 & imag(aaa)==0 %#ok<AND2>
            T2map_tmp(voxel_nbr)=aaa(1);
           % fit_err(voxel_nbr)=bbb(1);
        %else
            %wrongpix(voxel_nbr)=2; % the fit does not work
        end
   % else % else below the fit threshold
    %    wrongpix(voxel_nbr)=1;
    end
end

% reshape matrix
OutputImages=reshape(T2map_tmp,[size(N,1) size(N, 2) size(N,3)]);
OutputImages(OutputImages < 0) = NaN;
OutputImages(OutputImages > 300) = NaN;
OutputImages(isnan(OutputImages)) = NaN;

% save the new files (.nii & .json)
% update the header before saving the new .nii
info2 = info;
info2.Filename = fullfile(path,'T2star_map.nii');
info2.Filemoddate = char(datetime('now'));
info2.Datatype = class(OutputImages);
info2.PixelDimensions = info.PixelDimensions(1:length(size(OutputImages)));
info2.ImageSize = size(OutputImages);

% save the new .nii file
niftiwrite(OutputImages, fullfile(path,'T2star_map.nii'), info2);
end
