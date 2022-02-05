# Data Warehouse Demo
This project contains my final capstone submission for the Post-Baccalaureate Certificate in SQL Server Development from the University of Washington Continuum College, September 2021.

## Build Notes
The method used to build the "Independent Book Sellers" data warehouse is to first open the Visual Studio Solution **data_warehouse_demo_solution.sln.**

From Visual Studio, inside of the project's **Scripts** folder, you will find SQL scripts that are numbered from 00 to 03, and 03 through to 07. **02**_metadata_worksheet is found in the **Documents** folder. The 02_metadata_worksheet is used to define the extract, transform, and load process that takes place between 01_source_database and 03_destination_database. Open each of the scripts in the order of their ascending number, review the code, and execute each script against the SQL Server instance **localhost.**

There are 2 additional scripts that are used to create SQL Server Agent Jobs. These scripts are named **etl_sysjob** and **maintenance_sysjob.** The PowerShell script **New-SSISProxyUser** must be run before executing **etl_sysjob**.

Additional information regarding the overall structure of the data warehouse, including details on reports and jobs, can be found in **Documents\admin_manual.**

## Prerequisites
**Download data_warehouse_demo to the C drive of a Windows system, C:\data_warehouse_demo.**

Visual Studio 2019 Community Edition -- https://visualstudio.microsoft.com/downloads/

SQL Server 2019 Developer Edition* -- https://www.microsoft.com/en-us/sql-server/sql-server-downloads

Visual Studio Extension: SQL Server Integration Service Projects -- https://marketplace.visualstudio.com/items?itemName=SSIS.SqlServerIntegrationServicesProjects

Visual Studio Extension: Microsoft Reporting Services Projects -- https://marketplace.visualstudio.com/items?itemName=ProBITools.MicrosoftReportProjectsforVisualStudio

PowerShell

Microsoft Office

*The SQL Server instance name used for this project is **localhost.**