function extract_dti_map(app_file,apa_file)

%--------------------------------------------------------------------------
%  Extraction of FA MD maps from dual AP PA DWI acquisitions
%  bval and bvec is 
%  Adapted from the scripts of Arnaud Attyé.
%--------------------------------------------------------------------------

global mrtrix_path
disp('-------- MR convert nifti to mif ---------');
status = system([mrtrix_path 'mrconvert ' app_file ' dwi_APP.mif -fslgrad ' strrep(app_file, '.nii', '.bvecs') ' ' strrep(app_file, '.nii', '.bvals')]);
if status == 0
    warning('FAIL - mrconvert APP');
end

status = system([mrtrix_path 'mrconvert ' apa_file ' dwi_APA.mif -fslgrad ' strrep(apa_file, '.nii', '.bvecs') ' ' strrep(apa_file, '.nii', '.bvals')]);
if status ~= 0
    warning('FAIL - mrconvert APA');
end

% DWI denoising
disp('-------- DWI denoising ---------');
status = system([mrtrix_path 'dwidenoise dwi_APP.mif dwi_APP_denoised.mif -noise noiseAPP.mif']);
if status ~= 0
    warning('FAIL - dwidenoise APP');
end

status = system([mrtrix_path 'dwidenoise dwi_APA.mif dwi_APA_denoised.mif -noise noiseAPA.mif']);
if status ~= 0
    warning('FAIL - dwidenoise APA');
end

% Gibbs ringing artifacts removal
disp('-------- Gibbs ringing artifacts removal ---------');
status = system([mrtrix_path 'mrdegibbs dwi_APP_denoised.mif dwi_APPGibbs.mif']);
if status ~= 0
    warning('FAIL - mrdegibbs APP');
end

status = system([mrtrix_path 'mrdegibbs dwi_APA_denoised.mif dwi_APAGibbs.mif']);
if status ~= 0
    disp('DONE');
else
    warning('FAIL - mrdegibbs APA');
end

% DWI distorsion correction
disp('-------- DWI distorsion correction ---------');
system([mrtrix_path 'mrcat dwi_APPGibbs.mif dwi_APAGibbs.mif all_DWIs.mif -axis 3']);
if status ~= 0
    warning('FAIL - mrcat');
end

status = system([mrtrix_path 'dwipreproc all_DWIs.mif dwi_preproc.mif -pe_dir PA -rpe_all -eddy_options="--slm=linear" ']);
if status ~= 0
    warning('FAIL - dwipreproc');
end

% Mask estimation
disp('-------- Mask estimation ---------');
status = system([mrtrix_path 'dwi2mask dwi_preproc.mif mask_orig.mif']);
if status ~= 0
    warning('FAIL - dwi2mask');
end

% DWI upsampling
disp('-------- DWI bias correction and upsampling ---------');
status = system([mrtrix_path 'mrresize dwi_preproc.mif -vox 1 dwi_preproc_upsampled.mif']);
if status ~= 0
    warning('FAIL - upsampling');
end

status = system([mrtrix_path ' dwi2mask dwi_preproc_upsampled.mif mask_upsampled.mif']);
if status ~= 0
    warning('FAIL - mask upsampling');
end

% Tensor-derived parameter maps generation
disp('-------- Tensor-derived parameter maps generation ---------');
status = system([mrtrix_path 'dwi2tensor -mask mask_orig.mif dwi_preproc.mif dwi_tensor.mif']);
if status ~= 0
    warning('FAIL - dwi2tensor');
end

status = system([mrtrix_path 'tensor2metric -adc MD.nii -fa FA.nii -mask mask_orig.mif dwi_tensor.mif']);
if status ~= 0
    warning('FAIL - tensor2metric');
end
end