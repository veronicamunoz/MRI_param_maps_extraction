function extract_T1map_VFA(t1_files, thresh)

NbAngles = size(t1_files,2);

for angles=1:NbAngles
    fid=fopen(t1_files{angles} ,'r');
    if fid>0
        fclose(fid);
        %tmp =  niftiread(files_in.In1{angles});
        input(angles).nifti_header = spm_vol(t1_files{angles});
        data_to_process(:,:,:,angles) = read_volume(input(angles).nifti_header, input(1).nifti_header, 0, 'Axial');
        input(angles).json = spm_jsonread(strrep(t1_files{angles}, '.nii', '.json'));
        flip_angles(angles) = input(angles).json.FlipAngle.value;
        TR(angles) = input(angles).json.RepetitionTime.value;
    else
        warning_text = sprintf('##$ Can not calculate the T1 map because there is\n##$ something wrong with the data \n##$ Could not open the files');
        msgbox(warning_text, 'T10 map warning') ;
        return
    end
end

% Order the data (from the smallest to hightest flip angle)
[~,flip_angles_index] = sort(flip_angles);
flip_angles = flip_angles(flip_angles_index);
TR = TR(flip_angles_index);
data_to_process =  data_to_process(:,:,:,flip_angles_index);

%% calculate T1map
data_in_vector = reshape(data_to_process, [size(data_to_process,1)*size(data_to_process,2)*size(data_to_process,3), size(data_to_process,4)]);
maxim=max(data_in_vector) * thresh / 100;
fit_result = NaN([size(data_in_vector,1), 2]);
erreur = zeros([size(data_in_vector,1), 1]);

parfor i=1:size(data_in_vector,1)
    vector_to_process = data_in_vector(i,:);
    if  max(vector_to_process(:))>= maxim
        x = vector_to_process ./ tan(flip_angles/180*pi)/ mean(vector_to_process);
        y = vector_to_process ./ sin(flip_angles/180*pi)/ mean(vector_to_process);
        X = [ones(length(x'),1) x'];
        p = X\y';
        % Calculate R2 --> in order to estimate the fit quality
        yfit = p(2)*x + p(1);
        yresid = y - yfit;
        SSresid = sum(yresid.^2);
        SStotal = (length(y)-1) * var(y);
        rsq = 1 - SSresid/SStotal;
        
        fit_result(i,1) = p(2); % slope of the curve
        erreur(i) = rsq*100;    % R2*100
    end
end

fit_result(:,2) = erreur;
fit_result=reshape(fit_result,[size(data_to_process,1),size(data_to_process,2),size(data_to_process,3), 2]);
fit_result(fit_result(:,:,:,1)<0.) = nan;
T1map = -mean(TR)./ log(fit_result(:,:,:,1)); % en ms

% transform the T1map matrix in order to match to the nii hearder of the
% first input (rotation/translation)
T1map = write_volume(T1map, input(1).nifti_header, 'Axial');
[path, ~, ~] = fileparts(t1_files{1});

%% save the new files (.nii & .json)
% first load the header of the first input
nii_header = niftiinfo(t1_files{1});
% update the header before saving the new .nii
nii_header.Filename = fullfile(path,'T1_map.nii');
nii_header.Filemoddate = char(datetime('now'));
nii_header.Datatype = class(T1map);
nii_header.ImageSize = size(T1map);
%nii_header.Description = [nii_header.Description, ' Modified by the Module T1map_MultiAngles'];
% save the new .nii file
niftiwrite(T1map, fullfile(path,'T1_map.nii') , nii_header)
end