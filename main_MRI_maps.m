%--------------------------------------------------------------------------
%
%                  MULTIPARAMETRIC MRI MAP EXTRACTION
%                           (Grenoble, FR, 2021)
%               by Veronica Munoz Ramirez & Michel Dojat
%
% The code assumes that the Path folder contains one folder per subject
% with an anatomical image and raw multiparametric images in subfolders or
% by themselves.
% Ex: Path --> Subject 1 --> T1
%                            FLAIR
%                            pCASL
%                            PERF
%                            Relax
% 
%--------------------------------------------------------------------------

global spm_path
spm_path = '/usr/local/MATLAB/spm12';
addpath(spm_path);
global mrtrix_path
mrtrix_path = '/home/veronica/mrtrix3/bin/';

Path = '/media/veronica/DATAPART2/SignaPark/Test/';

%% ORGANIZE NIFTIS AFTER IMPORT WITH MRI_CONV
organize_niftis(Path);

%% PARAMETRIC MAPS EXTRACTION

Subj_dir = dir([Path '/*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));

for s = 1 : size(Subj_dir,1)
    if (exist(fullfile(Path,Subj_dir(s,1).name), 'dir')~=0)
        disp(Subj_dir(s,1).name);
        cd(fullfile(Path,Subj_dir(s,1).name))
        % PERFUSION
        %
        dce_perf_file = fullfile(Path, Subj_dir(s,1).name,'Perfusion','PERFUSION.nii');
        if exist(dce_perf_file, 'file')~=0
            extract_perf_maps(dce_perf_file);
        end
        
        % DIFFUSION
        %
        apa_file = fullfile(Path, Subj_dir(s,1).name,'Diffusion','Cerveau_APA_7x0.nii');
        app_file = fullfile(Path, Subj_dir(s,1).name,'Diffusion','Cerveau_APP_7x0.nii');
        if (exist(apa_file, 'file')~=0) && (exist(app_file, 'file')~=0)
            extract_dti_map(app_file,apa_file);
        end
        
        % RELAXOMETRY T1 VFA
        %
        FA = {'5','15','20','35'};
        t1_files = fullfile(Path, Subj_dir(s,1).name,'Relaxometry',strcat('DCEFA',FA,'.nii'));
        thresh = 5;
        if exist(t1_files{1}, 'file')~=0
            extract_T1map_VFA(t1_files, thresh);
        end
        
        % RELAXOMETRY T2
        %
        t2_file = fullfile(Path, Subj_dir(s,1).name,'Relaxometry','T2etoile_4echo.nii');
        limits = [0,Inf];
        thresh = 5;
        if exist(t2_file, 'file')~=0
            extract_T2starmap(t2_file, thresh, limits);
        end
    end
end
cd(Path)

disp('Click ENTER if you want to continue with segmentation.');
pause();

%% SEGMENTATION
% Brain segmentation using SPM/CAT12 functions
anat_file = 'Anat/T1_3D.nii'; 
anat_segmentation(Path,anat_file,2); % 1st : Path to files, 2th: How many simultaneous processes ? 
disp('We need to wait until all segmentations have finished.');
disp('Click ENTER when the process is finished.');
pause();

%% QUALITY CONTROL
% Display of all subjects from the population for quality control in one
% image
file_to_control='Anat/mri/wmT1_3D.nii';
slice = 125; % Slice to display
cat12quality_control(Path,file_to_control,slice);

