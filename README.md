# Dynamic-Model-Score-Dashboard
Dynamic Model Score Dashboard is a web application that visualizes model data—such as name, score, and description—imported from an Excel file using dynamic charts and interactive accordion menus. This project was developed to facilitate easy data tracking and enhance user interaction.

Features

• Excel Integration:
The application reads model names, scores, and description texts from an Excel file. When a new model is added to the Excel file, the data is automatically updated.

• Dynamic Charts:
Bar charts are created using Chart.js and ChartJsCore. There is a collective chart that shows all model scores and individual horizontal bar charts for each model displayed within its own accordion panel.

• Interactive Accordion:
The application implements an accordion menu using jQuery UI Accordion. When a bar in the general chart is clicked, the corresponding model’s accordion panel opens. Each panel displays the chart on the left and the model’s description on the right.

• Responsive Design:
The layout is managed using Bootstrap’s grid system, ensuring that the chart and description sections within the accordion are displayed side by side and are appropriately sized.

Technologies Used

• ASP.NET WebForms
The core server-side framework is ASP.NET WebForms. Dynamic content is generated using .aspx and .cs files.

• ChartJsCore and Chart.js
Integrated via NuGet, ChartJsCore leverages Chart.js to build chart configurations. Chart.js provides modern, interactive charting capabilities for data visualization.

• ExcelDataReader
This library is used to read data from Excel files. The application extracts model names, scores, and descriptions using ExcelDataReader.

• Newtonsoft.Json
Chart configuration objects are converted to JSON format using Newtonsoft.Json. These JSON objects are then used by Chart.js on the client side.

• jQuery and jQuery UI
jQuery is used for DOM manipulation and to implement interactive features. jQuery UI Accordion provides user-friendly, interactive panel transitions.

• Bootstrap
The Bootstrap CSS framework is used for responsive design and layout adjustments. In particular, the accordion body layout is organized using Bootstrap’s grid system.

• Font Awesome
Font Awesome is integrated to include visual icons in the accordion headers, offering additional visual cues to users.

Installation and Running the Project

Clone the Repository
Use the following command to clone the repository:
git clone https://github.com/username/Dynamic-Model-Score-Dashboard.git

Install the Required NuGet Packages
Ensure that the following packages are installed via the Visual Studio Package Manager:

ChartJsCore
ExcelDataReader
Newtonsoft.Json
Prepare the Excel File
Place the "bar-data.xlsx" file in the project’s root directory. This file should contain at least three columns: Name, Score, and Description. When a new model is added to the file, its data (including the description) will automatically be incorporated into the application.

Run the Application
Build and run the project using Visual Studio. When opened in a browser, the application will display the general chart, interactive accordion panels for each model, and the corresponding description texts.

Project Structure

• Default.aspx
Contains the HTML, CSS, and JavaScript code defining the user interface, including the chart displays and accordion panels.

• Default.aspx.cs
Contains the server-side code responsible for reading data from the Excel file, generating chart configurations, and binding data to the repeater control.

• bar-data.xlsx
An Excel file that holds the model data. This file should include columns for Name, Score, and Description.

Conclusion

Dynamic Model Score Dashboard combines dynamic data visualization with an interactive user experience. It serves as a comprehensive example of integrating multiple technologies—ASP.NET WebForms, Chart.js, ExcelDataReader, jQuery UI, and Bootstrap—to create a modern, responsive web application.

Note: Due to GitHub's maximum file limit warning, only the necessary files have been uploaded. You only need to create an ASP.NET Web Forms project and add the corresponding files to your project folder. 
Also, please note that the project is built using ASP.NET Web Forms version 4.6.2.
