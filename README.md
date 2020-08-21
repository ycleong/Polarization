---
output: html_document
---
### Conservative and liberal attitudes drive polarized neural responses to political content
This repository hosts analyses code for our manuscript <i> Conservative and liberal attitudes drive polarized neural responses to political content </i>. If you have any questions, or find any bugs (or broken links), please email me at ycleong@berkeley.edu. A preprint is available here: https://www.biorxiv.org/content/10.1101/2020.04.30.071084v1

<b> data </b>  
- fmri: [raw data will be made available on [OpenNeuro](https://openneuro.org/) upon publication]  
- [behav](data/behav/VideoRating.csv): participants' rating for each video  
- [semantic_categories](data/semantic_categories/liwc_data.csv): percentage of words in each of the 50 semantic categories for each segment  


<b> scripts </b>  
- [1_preprocessing](scripts/1_preprocessing): preprocessing scripts, rewritten to work with BIDS format data  
- [2_ISC](scripts/2_ISC): Calculate overall, within-group, between-group ISC  
- [3_semantic](scripts/3_semantic): semantic analyses    
- [4_ISFC](scripts/4_ISFC): ISFC analyses   
- [5_attitude_change](scripts/5_attitude_change): attitude change analyses    
- [9_help_scripts](scripts/9_help_scripts): helper functions  
- 9_NIFTI_tools: download from [here](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)  

[<b>Neurovault Collection</b>](https://neurovault.org/collections/PKFXOYLX/)