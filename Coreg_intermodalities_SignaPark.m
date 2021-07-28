File_path = '/media/veronica/DATAPART2/SignaPark/Patients/';

Subj_dir = dir([File_path '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
C3Dcommand='/home/veronica/Downloads/Programs/c3d/bin/c3d ';

for i = 1 : size(Subj_dir,1)
    disp(Subj_dir(i,1).name);
    anat_path=fullfile(File_path, Subj_dir(i,1).name, 'T1_3D.nii');
    
%     % Reslice T1 image to correspond to PD25 atlas
    if (Subj_dir(i,1).isdir==1 && exist(anat_path, 'file') ~= 0)
%         clear matlabbatch
%         spm_jobman('initcfg');
%         matlabbatch{1}.spm.spatial.coreg.write.ref = {'/home/veronica/Donnees/mni_PD25/PD25-fusion-template-1mm.nii,1'};
%         matlabbatch{1}.spm.spatial.coreg.write.source = {anat_path};
%         matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
%         matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
%         matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
%         matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
%         spm('defaults', 'FMRI');
%         spm_jobman('run', matlabbatch);
%         clear matlabbatch
%         disp('---Carte anatomique rehachée');
%         
%         system([FSLcommand 'bet ' strrep(anat_path, 'Anat', 'rAnat') ' ' strrep(anat_path, 'Anat', 'ssrAnat') ' -m ']);
%         
% % %         system([C3Dcommand anat_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(anat_path,'Anat','c3d_Anat')]);
% %     end
%     
    anat_path=fullfile(File_path, Subj_dir(i,1).name, 'rAnat.nii');
    ssanat_path=fullfile(File_path, Subj_dir(i,1).name, 'ssrAnat.nii');
%     
%     if ( Subj_dir(i,1).isdir==1 && exist(anat_path, 'file') ~= 0 && exist(ssanat_path,'file') ~= 0 )
%         
%         % Perfusion - Susceptibility images
        rcbf_path=fullfile(File_path, Subj_dir(i,1).name, 'rCBF.nii');
        rcbv_path=fullfile(File_path, Subj_dir(i,1).name, 'rCBV.nii');
        mtt_path=fullfile(File_path, Subj_dir(i,1).name, 'MTT.nii');
        
        if (exist(rcbf_path, 'file') ~= 0 && exist(rcbv_path, 'file') ~= 0 && exist(mtt_path, 'file') ~= 0 )
%             system([C3Dcommand rcbf_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(rcbf_path,'rCBF','c3d_rCBF')]);
%             system([C3Dcommand rcbv_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(rcbv_path,'rCBV','c3d_rCBV')]);
%             system([C3Dcommand mtt_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(mtt_path,'MTT','c3d_MTT')]);
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {ssanat_path};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {rcbf_path};%{strrep(rcbf_path,'rCBF','c3d_rCBF')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {
                rcbv_path
                mtt_path
%                 strrep(rcbv_path,'rCBV','c3d_rCBV')
%                 strrep(mtt_path,'MTT','c3d_MTT')
                };
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
            disp('---Cartes de perfusion (DSC) coregistrées');
        end
%         
%         % Diffusion
        fa_path=fullfile(File_path, Subj_dir(i,1).name, 'FA.nii');
        md_path=fullfile(File_path, Subj_dir(i,1).name, 'MD.nii');
        
        if (exist(fa_path, 'file') ~= 0 && exist(md_path, 'file') ~= 0 )
%             system([C3Dcommand fa_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(fa_path,'FA','c3d_FA')]);
%             system([C3Dcommand md_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(md_path,'MD','c3d_MD')]);
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {anat_path};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {fa_path};%{strrep(fa_path,'FA','c3d_FA')};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {md_path};%{strrep(md_path,'MD','c3d_MD')};
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
%         
%         % Perfusion - pCASL
        cbf_path=fullfile(File_path, Subj_dir(i,1).name, 'pCBF.nii');
        
        if exist(cbf_path, 'file') ~= 0
%             system([C3Dcommand cbf_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(cbf_path,'pCBF','c3d_pCBF')]);
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {anat_path};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {cbf_path};%{strrep(cbf_path,'pCBF','c3d_pCBF')};
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
            disp('---Carte de perfusion - pCASL coregistrée');
        end
%         
        % T1 relaxometry map
        t1_path=fullfile(File_path, Subj_dir(i,1).name, 'T1map.nii');
        
        if exist(t1_path, 'file') ~= 0
%             system([C3Dcommand t1_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(t1_path,'T1map','c3d_T1map')]);
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {anat_path};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {t1_path};%{strrep(t1_path,'T1map','c3d_T1map')};
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
            disp('---Carte de relaxometrie T1 coregistrée');
        end
        
%         % T2* relaxometry map
        t2_path=fullfile(File_path, Subj_dir(i,1).name, 'T2starmap.nii');
        
        if exist(t2_path, 'file') ~= 0
%             system([C3Dcommand t2_path ' -resample-mm 1.5x1.5x1.5mm -o ' strrep(t2_path,'T2star','c3d_T2star')]);
            clear matlabbatch
            spm_jobman('initcfg');
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {anat_path};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {t2_path};%{strrep(t2_path,'T2star','c3d_T2star')};
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
            disp('---Carte de relaxometrie T2* coregistrée');
        end
           
     end
end