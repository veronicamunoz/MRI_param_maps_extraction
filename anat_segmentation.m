function anat_segmentation(Path,file,nproc)
%   Segmentation script
%   PARAMS
%       Path: Where is the subject folder ?
%       nproc: The number of simultaneus processes. It is recommended not
%       to excede half of the computer cores available.
%   
%   !! Some paths may be susceptible to change depending on your MATLAB
%   installation. It is typically found in the /local folder.
%
global spm_path
Subj_dir = dir([Path '/*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, file);
    seg_file = fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'Anat', 'mri', 'y_T1_3D.nii');
    if (exist(folder_path, 'file')~=0) && (exist(seg_file, 'file')==0)
        liste_anat{end+1}=folder_path;
    end
end

clear matlabbatch
spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.estwrite.data = liste_anat';
matlabbatch{1}.spm.tools.cat.estwrite.nproc = nproc;
matlabbatch{1}.spm.tools.cat.estwrite.opts.tpm = {[spm_path '/tpm/TPM.nii']};
matlabbatch{1}.spm.tools.cat.estwrite.opts.affreg = 'mni';
matlabbatch{1}.spm.tools.cat.estwrite.opts.biasstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.APP = 1070;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.LASstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.gcutstr = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.darteltpm = {[spm_path '/toolbox/cat12/templates_1.50mm/Template_1_IXI555_MNI152.nii']};
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.shootingtpm = {[spm_path '/toolbox/cat12/templates_1.50mm/Template_0_IXI555_MNI152_GS.nii']};
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regstr = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.vox = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.restypes.fixed = [1 0.1];
matlabbatch{1}.spm.tools.cat.estwrite.output.surface = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.noROI = struct([]);
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.native = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.dartel = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.native = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.dartel = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.bias.warped = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.warps = [1 1];
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

end
