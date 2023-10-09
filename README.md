# proteomics-intern
bioinformatics internship in 57357 hospital in proteomic and metabolomics department 

**Overview**

This project focuses on proteomics analysis in the field of cancer research. It involves the comparison of protein expression levels between a control group (cancer) and a treatment group. The project includes preprocessing steps such as normalization, filtration, and imputation of the data. Statistical analysis and biological analysis are performed to gain insights into the differences between the two groups. The project also involves visualizing the data in various ways to facilitate data exploration and interpretation.

**Data**

The project utilizes proteomics data obtained from the control and treatment groups. The data includes measurements of protein expression levels for multiple samples in each group.

**Preprocessing**

Before conducting the analysis, the following preprocessing steps are performed on the data:

PQN Normalization: The protein expression levels are normalized to account for variations in sample preparation and instrument performance.
Filtration: The data is filtered to remove 50% NAs in each group
Imputation: Missing values in the dataset are imputed using median of each row to ensure a complete and reliable dataset.


**Statistical Analysis**

Statistical analysis is carried out to identify significant differences in protein expression between the control and treatment groups. This analysis helps in identifying proteins that are differentially expressed and may play a role in the observed effects of the treatment.

**Biological Analysis**

In addition to statistical analysis, biological analysis is performed to gain insights into the functional implications of the differentially expressed proteins. This analysis involves enriching the protein list with relevant biological annotations, such as gene ontology terms, pathways, or protein-protein interaction networks , i use gprofile to bring all this pathways.

**Visualization**

To aid in data exploration and interpretation, the project includes various visualization techniques. These visualizations include in my project:
box plot : Visualizing orgin data before preprocessing 
Heatmaps: Visualizing the expression patterns of different proteins across samples.
Volcano plots: Illustrating the statistical significance and fold change of differentially expressed proteins.
Pathway analysis plots: Showing the enrichment of differentially expressed proteins in specific biological pathways , i use three diffrents figure for this : ggplot point ,ggsankey digram ,Network digram.

**Dependencies**

The project utilizes various programming libraries and tools for data analysis and visualization. Some of the key dependencies include:

Programming language: R

Data analysis libraries: ggplot, reshape2 , dplyr

Visualization: ggsankey, networkD3
