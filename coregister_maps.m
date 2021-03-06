function coregister_maps(anat, param_files, atlas, atlas_def_field)
if exist(anat,'file')~=0 
    im_mni = '/home/veronica/Donnees/Atlas/Neuromorphometrics/labels_Neuromorphometrics.nii';
    
    % Reslice to 1.5 x 1.5 x 1.5 voxel size
    if ( exist('atlas','var')==1 && exist('atlas_def_field','var')==1)
        if ( exist(atlas,'file')~=0 && exist(atlas_def_field,'file')~=0 )
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.util.defs.comp{1}.def = {atlas_def_field};
            matlabbatch{1}.spm.util.defs.comp{2}.def = {strrep(anat, 'T1_3D','mri/iy_T1_3D')};
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {atlas};
            matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {fileparts(anat)}; %takes the first output argument, which is path
            matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
            matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'def';
            matlabbatch{2}.spm.spatial.coreg.write.ref = {im_mni};
            matlabbatch{2}.spm.spatial.coreg.write.source(1) = cfg_dep('Deformations: Warped Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','warped'));
            matlabbatch{2}.spm.spatial.coreg.write.roptions.interp = 0;
            matlabbatch{2}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
            matlabbatch{2}.spm.spatial.coreg.write.roptions.mask = 0;
            matlabbatch{2}.spm.spatial.coreg.write.roptions.prefix = 'co_';
            matlabbatch{3}.spm.spatial.coreg.write.ref = {im_mni};
            matlabbatch{3}.spm.spatial.coreg.write.source = {anat};
            matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 4;
            matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
            matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
            matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'co_';
            spm('defaults', 'FMRI');
            spm_jobman('run', matlabbatch);
            clear matlabbatch
        end
    else
        clear matlabbatch
        spm_jobman('initcfg');
        matlabbatch{1}.spm.spatial.coreg.write.ref = {im_mni};
        matlabbatch{1}.spm.spatial.coreg.write.source = {anat};
        matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'co_';
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch);
    end

    % Coregister
    if exist(strrep(anat, 'T1_3D','co_T1_3D'), 'file')~=0
        for i = 1:size(param_files,2)
            if exist(param_files{i}, 'file')~=0
                clear matlabbatch
                spm_jobman('initcfg');
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strrep(anat, 'T1_3D','co_T1_3D')};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = param_files(i);
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'co_';
                spm('defaults', 'FMRI');
                spm_jobman('run', matlabbatch);
                clear matlabbatch
            end
        end
    end
    
end
end