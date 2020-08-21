#!/bin/bash
# Transform data to 3mm so that it's easier to work with

# Subject Numbers
#subjNo=("1004" "1005" "1006" "1007" "1008" "1009" "1011" "1012" "1014" "1015" "1016" "1017" "1018" "1019" "1020" "1021" "1022" "1023" "1024")
#subjNo=("1026" "1027" "1028" "1029" "1030" "1031" "1032" "1033" "1034" "1035" "1036" "1037" "1038" "1039" "1040" "1041" "1042" "1043" "1044")

design="preproc"
REF_2MM="../../data/fmri/masks/standard/MNI152_T1_2mm_brain.nii.gz"
REF_3MM="../../data/fmri/masks/standard/2mmTo3mm.nii"
REF_MAT_2MM_TO_3MM="../../data/fmri/masks/standard/2mmTo3mm.mat"

for subjID in "${subjNo[@]}"
	do
    echo Running Subj $subjID
		mkdir "../../data/fmri/glm/transformed_data/$subjID"

    for r in 1 2 3 4
        do
					echo run $r

					FUNC_VOL="../../data/fmri/glm/$design/$subjID/run${r}.feat/filtered_func_data.nii.gz"
					REF_MAT_F2S="../../data/fmri/glm/$design/$subjID/run${r}.feat/reg/example_func2standard.mat"
					REF_MAT_F_TO_3MM="../../data/fmri/glm/$design/$subjID/run${r}.feat/reg/example_func2standard_3mm.mat"
					VOL_3MM="../../data/fmri/glm/transformed_data/$subjID/run${r}.nii.gz"

					# combine transforms: convert_xfm -omat AtoC.mat -concat BtoC.mat AtoB.mat
					convert_xfm -omat $REF_MAT_F_TO_3MM -concat $REF_MAT_2MM_TO_3MM $REF_MAT_F2S

					# transform filtered_func_data to trans_filtered_func_data_3mm
					flirt -in $FUNC_VOL -ref $REF_3MM -out $VOL_3MM -init $REF_MAT_F_TO_3MM -applyxfm
    done
done
