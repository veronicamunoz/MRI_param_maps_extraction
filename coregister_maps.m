function coregister_maps(anat, param_files)
if exist(anat,'file')~=0
    % Reslice to 1.5 x 1.5 x 1.5 cm
    
    
    % Coregister 
    for i = size(param_files,2)
        if exist(param_files{i}, 'file')~=0
            %             system([C3Dcommand fa_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(fa_path,'FA','c3d_FA')]);
            %             system([C3Dcommand md_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(md_path,'MD','c3d_MD')]);
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {anat};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = param_files{i};%{strrep(fa_path,'FA','c3d_FA')};
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
            disp('---Cartes de diffusion coregistrées');
        end
    end
end
end