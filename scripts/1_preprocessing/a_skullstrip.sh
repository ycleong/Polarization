#!/bin/sh

# Skullstrip anatomical scans

# Set Parameters
subjID=("1004" "1005" "1006" "1007" "1008" "1009" "1011" "1012" "1014" "1015" "1016" "1017" "1018" "1019" "1020" "1021" "1022" "1023" "1024" "1026" "1027" "1028" "1029" "1030" "1031" "1032" "1033" "1034" "1035" "1036" "1037" "1038" "1039" "1040" "1041" "1042" "1043" "1044")

# bet doesn't seem to to work well with defaced data, the following subjects may require manual intervention if you use the defaced anatomicals
# subjID=("1008" "1009" "1014" "1020" "1026")

bid_dir='../../Polarization'
anat_dir='../../data/fmri/anat_brain'

for subjNo in "${subjID[@]}"
	do

	echo Running subject $subjNo
	subj_dir="$bid_dir/sub-$subjNo/anat/sub-${subjNo}_T1w.nii.gz"

	# Remove brain
	echo Running BET...
	bet $subj_dir "$anat_dir/sub-${subjNo}_T1w_brain.nii.gz" -f 0.15

done
