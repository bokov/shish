if(file.exists('projlib.R')) source('projlib.R');

# fn for detecting enter key
entkey <- '
$(document).on("keyup", function(ee) {
  if(ee.keyCode == 13){
    Shiny.onInputChange("userinput", [$("#command")[0].value,new Date()]);
    $("#command").val("");
  }
})';

# Define UI for application that draws a histogram
ui <- fluidPage(
  HTML("<a href='__logout__'>Log Out</a>"),
  tags$head(tags$link(rel="shortcut icon", href="favicon.ico"))
  ,tags$script(entkey)
  ,includeCSS('app.css')
  #,useShinyjs()
  #,useShinyalert()
  ,fluidRow(h3('SHIny SHell (debugging tool)')
            ,'Do not run unattended, do not share link with the public.')
  ,mainPanel(
         div(id='console','Welcome to SHInySHell')
         ,textAreaInput('command',label='',width = '100%',resize = 'both'
                       ,placeholder = 'Your R commands here...')
         ,hr()
         ,actionButton('debug','Debug')
      )
   )

# Define server logic required to draw a histogram
server <- function(input, output, session=getDefaultReactiveDomain()) {
  rv <- reactiveValues(history=c());
  observeEvent(input$userinput,{
    if(is.null(rv$servenv)) rv$servenv <- environment();
    rv$history <- c(rv$history,inp<-input$userinput[1]);
    message('\n*** updated history ***\n');
    insertUI('#console','beforeEnd',ui=pre(inp,class='coninp'),immediate = T);
    message('\n*** updated input ***\n');
    out <- try(capture.output(eval(parse(text=inp),envir = rv$servenv)));
    if(is(out,'try-error')){
      outclass <- 'conerr';
      out <- attr(out,'condition')$message;
    } else {
      out <- paste0(out,collapse='\n');
      outclass <- 'conrslt';
    }
    insertUI('#console','beforeEnd',ui=pre(out,class=outclass),immediate = T);
    message('\n*** updated output ***\n');
    });
  
  observeEvent(input$debug,{browser()});
}

# Run the application 
shinyApp(ui = ui, server = server)

