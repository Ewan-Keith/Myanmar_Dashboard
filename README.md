# Myanmar_Dashboard

#### R shiny code used to produce an interactive data application for exploring Myanmar's State and Region budgets.

### Directly required R packages

1. `shiny` - Handles interactivity and web page construction - [link](http://shiny.rstudio.com/)
2. `dplyr` - Used to re-arrange and reshape budget data for use - [link](https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html)
3. `Rcharts` - Produces interactive D3 plots from within R - [link](http://rcharts.io/)
4. `DT` - Produces interactive Jquery DataTables - [link](https://rstudio.github.io/DT/)
5. `ggplot2` - Creates publication quality, non-interactive charts - [link](http://ggplot2.org/)
6. `ggthemes` - Ready made themes for ggplot2 - [link](https://cran.r-project.org/web/packages/ggthemes/vignettes/ggthemes.html)
7. `tidyr` - Used to add missing entries with budget values of 0 - [link](https://cran.r-project.org/web/packages/tidyr/index.html)

Code is written so that each tab is independent of the others allowing for easy lifting of individual tabs.
