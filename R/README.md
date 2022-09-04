# Readme <a href='https://osf.io/zcvbs/'><img src='worcs_icon.png' align="right" height="139" /></a>

See main repository README.md

## Where do I start?

You can load this project in RStudio by opening the file called 'R.Rproj'.

## Project structure

<!--  You can add rows to this table, using "|" to separate columns.         -->
File           | Description                | Usage         
-------------- | -------------------------- | --------------
README.md      | Description of project     | Human editable
R.Rproj        | Project file               | Loads project 
.worcs         | WORCS metadata YAML        | Read only     
codebook.md | Codebook of the cleaned data | Machine created
prepare_data.R | Script to process raw data | Human editable
bootnet.R 	   | LASSO penalized network modeling of the KT task | Human editable
dashboard.R | Script used to make first version of the dashboard (which was then customized) | Human editable
label_data.R | Script to store value labels of categorical variables | Human editable
lasso.R | Script to perform LASSO-regression predicting the KT task | Human editable
label_data.R | Script to store value labels of categorical variables | Human editable
lasso.R | Script to perform LASSO-regression predicting the KT task | Human editable
umap_hdbscan.R | Script to perform non-parametric clustering of the KT task | Human editable

<!--  You can consider adding the following to this file:                    -->
<!--  * A citation reference for your project                                -->
<!--  * Contact information for questions/comments                           -->
<!--  * How people can offer to contribute to the project                    -->
<!--  * A contributor code of conduct, https://www.contributor-covenant.org/ -->

# Reproducibility

This project uses the Workflow for Open Reproducible Code in Science (WORCS) to
ensure transparency and reproducibility. The workflow is designed to meet the
principles of Open Science throughout a research project. 

To learn how WORCS helps researchers meet the TOP-guidelines and FAIR principles,
read the preprint at https://osf.io/zcvbs/

## WORCS: Advice for authors

* To get started with `worcs`, see the [setup vignette](https://cjvanlissa.github.io/worcs/articles/setup.html)
* For detailed information about the steps of the WORCS workflow, see the [workflow vignette](https://cjvanlissa.github.io/worcs/articles/workflow.html)

## WORCS: Advice for readers

Please refer to the vignette on [reproducing a WORCS project]() for step by step advice.
<!-- If your project deviates from the steps outlined in the vignette on     -->
<!-- reproducing a WORCS project, please provide your own advice for         -->
<!-- readers here.                                                           -->

## Access to data

The data are available at https://DOI.org/10.17605/OSF.IO/UCQ8E

<!--Clarify here how users should contact you to gain access to the data, or to submit syntax for evaluation on the original data.-->