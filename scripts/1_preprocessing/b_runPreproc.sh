#!/bin/bash
#export FSLPARALLEL=slurm

# Subj Numbers
subjNo=("1004" "1005" "1006" "1007" "1008" "1009" "1011" "1012" "1014" "1015" "1016" "1017" "1018" "1019" "1020" "1021" "1022" "1023" "1024" "1026" "1027" "1028" "1029" "1030" "1031" "1032" "1033" "1034" "1035" "1036" "1037" "1038" "1039" "1040" "1041" "1042" "1043" "1044")

design="preproc"
bids_dir="Users/ycleong/Desktop/Polarization"
analysis_dir="Users/ycleong/Desktop/PolarizationAttn"

mkdir 'fsfs/'$design

for subjID in "${subjNo[@]}"
	do

		for r in 1 2 3 4
		    do

        thisFile="/$bids_dir/sub-$subjID/func/sub-${subjID}_task-run${r}_bold.nii.gz"
        nvols=$(fslnvols $thisFile)

        \cp templates/preproc.fsf fsfs/$design/subj${subjID}_task_run${r}.fsf

        sed -i -e 's/ChangeMyRun/'$r'/g' fsfs/$design/subj${subjID}_task_run${r}.fsf  #Swap "ChangeMyRun" with run number
        sed -i -e 's/ChangeMySubj/'$subjID'/' fsfs/$design/subj${subjID}_task_run${r}.fsf  #Swap "ChangeMyRun" with run number
				sed -i -e 's/ChangeMySubj/'$subjID'/' fsfs/$design/subj${subjID}_task_run${r}.fsf  #Swap "ChangeMyRun" with run number
        sed -i -e 's/ChangeMyVolumes/'$nvols'/' fsfs/$design/subj${subjID}_task_run${r}.fsf  #Swap "ChangeMyRun" with run number
        sed -i -e 's/ChangeMyDesign/'$design'/' fsfs/$design/subj${subjID}_task_run${r}.fsf  #Swap "ChangeMyRun" with run number

				sed -i -e 's@ChangeMyAnalysisDir@'${analysis_dir}'@' fsfs/$design/subj${subjID}_task_run${r}.fsf
				sed -i -e 's@ChangeMyBidsDir@'${bids_dir}'@' fsfs/$design/subj${subjID}_task_run${r}.fsf

        \rm fsfs/$design/*-e #Remove excess schmutz

        echo Running Subj $subjID run $r
        feat fsfs/$design/subj${subjID}_task_run${r}.fsf
				done
	
	# uncomment below to remove the original data after running the model (to save disk space)
	#for r in 1 2 3 4
	#do
	#	\rm /$bids_dir/sub-$subjID/func/sub-${subjID}_task-run${r}_bold.nii.gz
	#done
done
