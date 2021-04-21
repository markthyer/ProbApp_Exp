##########################
## Javascript Code object
JScode <-

  "$(function() {

setTimeout(function(){

var vals = [0];

var powStart = 7;

var powStop = 0;

for (i = powStart; i >= powStop; i--) {

var val = Math.pow(10, -i);

val = parseFloat(val.toFixed(8));

vals.push(val);

}

$('#offset').data('ionRangeSlider').update({'values':vals})

}, 5)})"

##########################
## Installing packages
x="moments" %in% rownames(installed.packages())
if(!x) {install.packages("moments")}
library("moments")

x="shiny" %in% rownames(installed.packages())
if(!x) {install.packages("shiny")}
library("shiny")

x="shinythemes" %in% rownames(installed.packages())
if(!x) {install.packages("shinythemes")}
library("shinythemes")

####NOTE #####
#ON THIS SIDE OF THE APP (UI) WITHIN THE SHINYUI FUCTION LINES INSIDE FUNCTIONS (AND FUNCTIONS THEMSELVES) ARE SEPARATED USING COMMAS

##########################
## Defining the UI
shinyUI(


  ##########################
  ## Front 'About' page
  navbarPage("Interactive Probabilistic Predictions",theme = shinytheme("united"),
             #FIRST TAB PANEL
             tabPanel("About",
                      helpText(h2("Interactive Probabilistic Predictions")),
                      helpText("This web-app produces probabilistic hydrological predictions using the LS-MoM method introduced in McInerney et al (2018)."),
                      helpText("The web-app assumes the user has already calibrated their hydrological model using their preferred software and an acceptable objective function (see below). This is referred to as 'Stage 1' of the calibration.") ,
                      helpText("The user should upload the observed and calibrated streamflow time series and the associated dates of measurement (daily timestep), and specify the Box Cox transformation parameters (lambda and A*) and the preferred mean structure. If the mean structure is either 'zero' or 'constant', we recommend that the Box-Cox transformation parameters match the values that were used in the hydrological objective function."),
                      helpText("The web-app will then estimate the residual error model parameters (referred to as 'Stage 2') and generate probabilistic predictions in the form of streamflow time series and associated 50% and 90% prediction limits. A selection of metrics and diagnostics from Evin et al (2014) and McInerney et al (2017) will be provided."),
                      #helpText(h3("Objective functions")),
                      #helpText("The web-app assumes a least-squares objective function, e.g. the sum-of-squared-errors (SSE) or equivalent Nash-Sutcliffe efficiency (NSE), computed from Box-Cox transformed flows (McInerney et al, 2017)."),
                      #helpText("These include widely used objective functions such as the NSE (lambda=1, A*=0), the NSE on square-root transformed flows (lambda=0.5, A*=0) and the NSE on log-transformed flows (lambda=0, A*=0). "),
                      helpText(h3("Demonstration data")),
                      helpText("By default, loading up the web-app for the first time will display probabilistic streamflow predictions for the Yackandandah Creek catchment (Australia), obtained from the GR4J rainfall-runoff model and pre-calibrated to the NSE objective function in one version, and the NSE-BC02 objective function in the other."),
                      helpText(h3("Uploading your own data")),
                      helpText("To upload your own data, create a CSV file with three columns corresponding to the daily timestep in format (DD/MM/YYYY), observed data and simulated data."),
                      #helpText(HTML("Download the demo data file to see the required format: <a href='http://www.algorithmik.org.au/dat/demoData.csv'> demo data file </a>.")),

                      helpText(h3("Further information")),
                      helpText(HTML("Further information on the importance probabilistic predictions in hydrology, and methods for   generating these predictions, can be found on the
                                    <a href='http://waterdecisions.org/reducing-hydrological-uncertainty/'> Intelligent Water Decisions Blog </a> and
                                    <a href='https://www.youtube.com/watch?v=mvuYlyF6S4s'> this talk</a> at the 2016 DEWNR NRM Science Conference. ")),


                      helpText(h3("Contact us")),
                      helpText(HTML("Contact <a href='mailto:jason.hunter@adelaide.edu.au'> Jason Hunter </a>
                                    for further details on how to use the web-app, the methods used for generating probabilistic predictions, and the diagnostics and performance metrics. ")),
                      helpText(HTML(" ")),
                      helpText(h3("References")),
                      helpText(HTML("Evin, G., Thyer, M., Kavetski, D., McInerney, D., & Kuczera, G. (2014). Comparison of joint versus postprocessor approaches for hydrological uncertainty estimation accounting for error autocorrelation and heteroscedasticity. Water Resources Research, 50(3), 2350-2375,
                                    <a href='https://doi.org/10.1002/2013WR014185'> DOI: 10.1002/2013WR014185</a>.")),
                      helpText(HTML("McInerney, D., Thyer, M., Kavetski, D., Bennett, B., Gibbs, M. & Kuczera, G. (2018). A simplified approach to produce probabilistic hydrological model predictions. Environmental Modelling and Software,
                                    <a href='https://doi.org/10.1016/j.envsoft.2018.07.001'> DOI: 10.1016/j.envsoft.2018.07.001</a>. ")),
                      helpText(HTML("McInerney, D., Thyer, M., Kavetski, D., Lerat, J., & Kuczera, G. (2017). Improving probabilistic prediction of daily streamflow by identifying Pareto optimal approaches for modeling heteroscedastic residual errors. Water Resources Research, 53(3), 2199-2239,
                                    <a href='https://doi.org/10.1002/2016WR019168'> DOI: 10.1002/2016WR019168</a>.")),
                      helpText(HTML("Hunter, J., Thyer, M., McInerney, D., Kavetski, D. (2020). Achieving high-quality probabilistic predictions from hydrological models calibrated with a wide range of objective functions. Journal of Hydrology, (submitted)."))


             ),

             ##########################
             ## 'Simulation' panel
             tabPanel("Simulation", icon=icon("area-chart","fa-1.9x"),  #adding an icon to the tab

            verticalLayout(

              wellPanel(

                # HEADINGS
                fluidRow(
                  column(4,helpText(h3("Input Data"))),
                  conditionalPanel(condition = "input.dataSel == 'Use demo data'",
                                   column(5,selectInput(inputId="model",label="demo data select",
                                                        choices =c("Yackandandah Creek (NSE)",
                                                                   "Yackandandah Creek (NSE-BC02)"),
                                                        selected="Yackandandah Creek (NSE)")))
                ),
                br(),

                # INPUT DATA
                fluidRow(
                  column(5,radioButtons(inputId="dataSel",label="",choices=c("Use demo data","Load my own data"),selected="Use demo data",inline = TRUE))
                  ),
                fluidRow(

                  conditionalPanel(condition = "input.dataSel == 'Load my own data'",
                                   column(3,
                                          fileInput('file1',label="",accept=c('text/csv','text/comma-separated-values/plain','.csv')),
                                          downloadLink('file2',label="data file example - use 'Open in Browser' at top of interface for easy viewing"), # downloads demo data from package
                                          textInput(inputId="lab.date",label="header of dates",value="date"),
                                          textInput(inputId="lab.obs",label="header of observed data",value="obs"),
                                          textInput(inputId="lab.pred",label="header of predicted data",value="pred"),
                                          textInput(inputId="lab.unit",label="input units (e.g. mm/d, m3/s, ML/d)"),value="mm/d")
                                   )
                )
              ), # end of well panel


# MODEL PARAMETERS
              wellPanel(
                fluidRow(
                  column(7,helpText(h3("Residual Model Parameters")))
                ),

                fluidRow(
                  column(3,sliderInput("lambda","Transformation power parameter (Lambda)",min=0, max=1,value=0.2,step=0.1),
                         tags$head(tags$script(HTML(JScode))),
                         sliderInput("offset", "Transformation offset parameter [Dimensionless] (A*)",min = 0,max = 1e-0,value = 0.0001)),
                  column(2,selectInput(inputId="mean",label="mean structure",choices=c("linear","constant","zero"),selected="zero")),
                  column(5,div(tableOutput("report"),style="font-size:120%"))
                )

              ),

# WARNING MESSAGES

              wellPanel(
                fluidRow(
                  column(7,helpText(h3("Data integrity checks")))
                 ),
                  fluidRow(
                    column(7,textOutput(outputId="error1")),
                    column(7,textOutput(outputId="error2"))
                    #column(7,textOutput(outputId="error3")),
                    #column(7,textOutput(outputId="error5")),
                    #column(7,textOutput(outputId="error6"))
                  )
              ),

# TIME SERIES PLOT
              wellPanel(

                fluidRow(
                  column(4,checkboxInput(inputId="plotTS",label="Plot timeseries",value=TRUE)) #tick box to hide plot & plotting options
                ),
                fluidRow(
                  conditionalPanel(condition = "input.plotTS == true",
                                   plotOutput("TS"),  #outputting a graphic beneath (option to turn off)
                                   column(8,sliderInput("datRange","X range",min=0, max=1000,value=c(50,450),step=1)),
                                   column(4,sliderInput("yRange","Y range",min=0, max=30,value=c(0,30),step=1.0,round=TRUE))
                            )
                    )
              ),

# PREDICTIVE PERFORMANCE EVALUATION PLOTS
              wellPanel(
                fluidRow(
                  column(4,checkboxInput(inputId="plotEval",label="Plot predictive performance evaluation",value=TRUE)) #tick box to hide plot & plotting options
                ),

                conditionalPanel(condition = "input.plotEval==true",

                  fluidRow(
                    column(6,helpText("Performance metric plot type")),
                    column(6,helpText("Performance benchmarking"))
                  ),

                  fluidRow(
                    column(6,selectInput("perfPlot",NULL,choices =c("Predictive QQ plot"),selected="Predictive QQ plot")),
                    column(6,selectInput("boxPlot",NULL,choices = c("Reliability","Sharpness","Bias"),selected="Reliability"))

                  ),

                  fluidRow(
                    column(6,plotOutput("perf")),  #far-left
                    column(6,plotOutput("box"))   #centre-right
                  ),


                  fluidRow(
                    column(5,helpText("")),
                    column(2,helpText(h4(HTML("</P> <P ALIGN=CENTER>Metric Summary</P> "))))
                  ),

                  fluidRow(
                    column(5,helpText("")),
                    column(2,div(tableOutput("metrics"),style="font-size:120%")) #right
                  )
                ) # end tick-box condition
              ), #end well panel

# RESIDUAL DIAGNOSTICS PLOTS
              wellPanel(
                fluidRow(
                  column(4,checkboxInput(inputId="plotResid",label="Plot residual diagnostics",value=TRUE)) #tick box to hide plot & plotting options
                ),
                conditionalPanel(condition = "input.plotResid==true",

                  fluidRow(
                    column(3,helpText("Residual plot type"))
                  ),
                  fluidRow(
                    column(4,selectInput("resPlot",NULL,
                                         choices =c("Standardised residuals v predictions",
                                                    "Standardised residuals v cummulative probability of predictions",
                                                    "Probability density of standardised residuals",
                                                    "Standardised residuals v transformed predictions"),
                                                    #"Autocorrelation plot of the residual innovations",
                                                    #"Partial-autocorrelation plot of the residual innovations"),
                                         selected="Standardised residuals v predictions"))
                  ),
                  fluidRow(
                    plotOutput("resid")) #centre-left
                )
              ), #end well panel

# OUTPUT DATA
              wellPanel(
                fluidRow(
                  column(4,helpText(h3("Output Data")))
                ),
                br(),
                fluidRow(
                  helpText("Note: Interface must be opened in browser for downloads to be available - see option 'Open in Browser' at the top of the interface window."),
                  column(4,downloadButton("dlReps","Download replicates.csv")),
                  column(4,downloadButton("dlPL","Download probability limits.csv")),
                  column(4,downloadButton("dlSummary","Download summary .pdf"))
                ),
                br()
              ) # end of wellPanel

            ) #end of vertical layout

     )  #end of tab panel 2

   ) #end of navbar layout
) #end of shinyui