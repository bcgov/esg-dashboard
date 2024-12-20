[![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

# esg-dashboard

Experimental dashboard project to explore non-shiny dashboarding options. Some possibilities include quarto documents, quarto dashboards, flexdashboards, incorporating widgets (plotly, leaflet, reactable), and incorporating interactivity with observable or crosstalk.

### Usage

There are four core folders that are required to run the dashboard:

-   01_data - contains any data for the dashboards
-   02_images - contains the bc gov logo and other images in future
-   03_styles - contains fonts, font styling in fonts.scss, and other styling in styles.css
-   04_scripts - contains scripts for functions, tables, and plots to be used in the dashboards
-   05_dashboards - contains the qmd files for the dashboards

### Data Sources

1.  Natural Resources Canada. [Industrial Sector - Secondary Energy Use and GHG Emissions by Industry](https://oee.nrcan.gc.ca/corporate/statistics/neud/dpa/showTable.cfm?type=CP&sector=agg&juris=bct&year=2021&rn=2&page=0)
2.  Natural Resources Canada. [Agriculture Sector - Secondary Energy Use and GHG Emissions by End-Use and Energy Source -- Excluding Electricity-Related Emissions](https://oee.nrcan.gc.ca/corporate/statistics/neud/dpa/showTable.cfm?type=CP&sector=agr&juris=bct&year=2021&rn=1&page=0)
3. Statistics Canada. [Table 14-10-0023-01 Labour force characteristics by industry, annual (x 1,000)](https://doi.org/10.25318/1410002301-eng)
4. Statistics Canada. [Table 38-10-0138-01 Waste materials diverted, by type and by source](https://doi.org/10.25318/3810013801-eng)
5. Statistics Canada. [Table 38-10-0032-01 Disposal of waste, by source](https://doi.org/10.25318/3810003201-eng)
6. Statistics Canada. [Table 14-10-0023-01 Labour force characteristics by industry, annual (x 1,000)](https://doi.org/10.25318/1410002301-eng)
7. Statistics Canada. [Table 14-10-0023-01 Labour force characteristics by industry, annual (x 1,000)](https://doi.org/10.25318/1410002301-eng)
8. Statistics Canada. [Table 33-10-0501-01 Representation of women and men on boards of directors and in officer positions, by firm attributes](https://doi.org/10.25318/3310050101-eng)
9. Statistics Canada. [Table 13-10-0757-01 Industry of employment for persons with and without disabilities aged 25 to 64 years, by sex](https://doi.org/10.25318/1310075701-eng)
10. Statistics Canada. [Table 14-10-0069-01 Union coverage by industry, monthly, unadjusted for seasonality (x 1,000)](https://doi.org/10.25318/1410006901-eng)
11. Statistics Canada. [Table 14-10-0063-01 Employee wages by industry, monthly, unadjusted for seasonality](https://doi.org/10.25318/1410006301-eng)
12. Statistics Canada. [Table 14-10-0076-01 Employees working overtime (weekly) by industry, annual](https://doi.org/10.25318/1410007601-eng)

For sources 1 and 2, download the data tables then open and save as csv (original format .xls). For the remainder of the sources, use the cansim package to access them directly. 

### Project Status

Experimental

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/esg-dashboard/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

    Copyright 2024 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------

*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.*
