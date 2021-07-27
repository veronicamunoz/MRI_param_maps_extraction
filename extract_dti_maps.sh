#!/bin/bash

File_folder=$1
cd $File_folder/Diffusion
app_file=$2
apa_file=$3

if [ ! -f FA.nii ]; then 
	if [ ! -f dwi_APP.mif ]; then
		echo "-------- MR convert nifti to mif ---------"
		mrconvert $app_file.nii dwi_APP.mif -fslgrad $app_file.bvecs $app_file.bvals
		mrconvert $apa_file.nii dwi_APP.mif -fslgrad $apa_file.bvecs $apa_file.bvals
	fi

	if [ ! -f dwi_APP_denoised.mif ]; then
		echo "-------- DWI denoising ---------"
		dwidenoise dwi_APP.mif dwi_APP_denoised.mif -noise noiseAPP.mif
		dwidenoise dwi_APA.mif dwi_APA_denoised.mif -noise noiseAPA.mif
	fi

	if [ ! -f dwi_APPGibbs.mif ]; then
		echo "-------- Gibbs ringing artifacts removal ---------"
		mrdegibbs dwi_APP_denoised.mif dwi_APPGibbs.mif
		mrdegibbs dwi_APA_denoised.mif dwi_APAGibbs.mif
	fi

	if [ ! -f all_DWIs.mif ]; then
		echo "-------- DWI distorsion correction ---------"
		mrcat dwi_APPGibbs.mif dwi_APAGibbs.mif all_DWIs.mif -axis 3
		dwifslpreproc all_DWIs.mif dwi_preproc.mif -pe_dir PA -rpe_all -eddy_options="--slm=linear"
	fi


	echo "-------- Mask estimation ---------"
	dwi2mask dwi_preproc.mif mask_orig.mif

	echo "-------- DWI bias correction and upsampling ---------"
	mrresize dwi_preproc.mif -vox 1 dwi_preproc_upsampled.mif
	dwi2mask dwi_preproc_upsampled.mif mask_upsampled.mif

	echo "-------- Tensor-derived parameter maps generation ---------"
	dwi2tensor -mask mask_orig.mif dwi_preproc.mif dwi_tensor.mif
	tensor2metric -adc MD.nii -fa FA.nii -mask mask_orig.mif dwi_tensor.mif

fi









