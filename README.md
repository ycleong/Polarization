---
output: html_document
---
### Conservative and liberal attitudes drive polarized neural responses to political content
This repository hosts analyses code for our manuscript <i> Conservative and liberal attitudes drive polarized neural responses to political content </i>. If you have any questions, or find any bugs (or broken links), please email me at ycleong@berkeley.edu. A preprint is available here: https://ycleong.github.io/files/papers/LeongPNAS2020.pdf

<b> data </b>  
- fmri: raw data are available on [OpenNeuro](https://openneuro.org/datasets/ds003095/versions/1.0.0)  
- [behav](data/behav/VideoRating.csv): participants' rating for each video  
- [semantic_categories](data/semantic_categories/liwc_data.csv): percentage of words in each of the 50 semantic categories for each segment  
- [MTurkRatings](data/MTurkRatings/OnlinePretest.csv): MTurk ratings on the 6 issues


<b> scripts </b>  
- [1_preprocessing](scripts/1_preprocessing): preprocessing scripts, rewritten to work with BIDS format data  
- [2_ISC](scripts/2_ISC): Calculate overall, within-group, between-group ISC  
- [3_semantic](scripts/3_semantic): semantic analyses    
- [4_ISFC](scripts/4_ISFC): ISFC analyses   
- [5_attitude_change](scripts/5_attitude_change): attitude change analyses    
- [6_MTurkRatings](scripts/MTurkRatings): MTurk ratings on the 6 issues
- [7_RSA](scripts/7_RSA): representational similarity analyses  
- [9_help_scripts](scripts/9_help_scripts): helper functions  
- 9_NIFTI_tools: download from [here](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)  

[<b>Neurovault Collection</b>](https://neurovault.org/collections/PKFXOYLX/)
