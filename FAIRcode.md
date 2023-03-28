# FAIR code  

To speed up the data analysis and avoid wasting valuable research time, we ask contributors to share the analysis code as much as possible. You can use these resources, or add a link to the code you have written to this list with minimal and clear description.

# Existing reusable syntax

* The file `R/pca_analyses.Rmd` contains reproducible code for reducing the 11 research funding items to 3 orthogonal dimensions, which roughly correspond to funding choices that benefit ECR, those that benefit senior scholars, and those that benefit consortia. Subsequently, we examined correlations of these three components with all other variables in the dataset, and used LASSO-penalized regression to identify the most important predictors per component. The code can be reproduced by knitting the Rmd file.



# Reproducibility

This project aspires to follow the Workflow for Open Reproducible Code in Science (WORCS) to
ensure transparency and reproducibility. The [workflow](https://psyarxiv.com/k4wde/) is designed by 
[Van Lissa et al](10.31234/osf.io/k4wde)  to meet the principles of Open Science throughout a research project. 

To learn how WORCS helps researchers meet the TOP-guidelines and FAIR principles,
[read the preprint](https://osf.io/zcvbs/).
