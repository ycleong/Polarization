#!/bin/sh

# Skullstrip anatomical scans

# Set Parameters
subjID=("1004" "1005" "1006" "1007" "1008" "1009" "1011" "1012" "1014" "1015" "1016" "1017" "1018" "1019" "1020" "1021" "1022" "1023" "1024" "1026" "1027" "1028" "1029" "1030" "1031" "1032" "1033" "1034" "1035" "1036" "1037" "1038" "1039" "1040" "1041" "1042" "1043" "1044")

# The following subjects may require manual intervention (7/2/2021) edit:
# "1008": -R -f 0.68 -g 0 -c 123 130 102
# "1009": -R -f 0.37 -g 0 -c 125.0 135 99
# "1014": -f 0.18 -g 0 -c 126 127 97
# "1020": -S -f 0.20 -g 0 -c 125 136 105
# "1024": -f 0.2 -g 0 -c 126 134 98
# "1026": -R -f 0.30 -g 0.1 -c 126 134 101

bid_dir='../../../Polarization'
anat_dir='../../data/fmri/anat_brain'

for subjNo in "${subjID[@]}"
	do

	echo Running subject $subjNo
	subj_dir="$bid_dir/sub-$subjNo/anat/sub-${subjNo}_T1w.nii.gz"

	# Remove brain
	echo Running BET...
	bet $subj_dir "$anat_dir/sub-${subjNo}_T1w_brain.nii.gz" -f 0.15

done
