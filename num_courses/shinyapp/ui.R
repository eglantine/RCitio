library(httr)
library(purrr)
library(shiny)

agency_list = map(content(GET("http://django.gateway.staging.cit.io/groups/")), 1)
agency_list = sort(unlist(agency_list))


shinyUI(fluidPage(theme = "bootstrap.css",
                  img(src = "logo_citio.png",style="display: block; margin-left: auto; margin-right: auto;"),

  headerPanel("Nombre de courses réalisées"),
  
  sidebarPanel(
    textInput("login", "Identifiant", "eglantine@cit.io"),
    passwordInput("password", "Mot de passe",""),
    selectInput("group", "Réseau",
                choices=agency_list,selected = "casablanca"),
    selectInput("env", "Environnement", 
                choices=c("staging", "production")),

    actionButton("doLogin", "Se connecter"),
    
    dateInput("start_date", "Du ", value = Sys.Date() - 7),
    dateInput("end_date", "Au ", value = Sys.Date()),
    selectInput("aggregation_level", "Agrégation", 
                choices=c("jour" = "date",
                          "ligne" = "name", 
                          "créneau horaire" = "time" )),
    
    downloadButton("downloadRawData", "Télécharger les données brutes")
    
  ),
  
  mainPanel(
    tabsetPanel(type = "tabs", 
                tabPanel("Données brutes", tableOutput("raw_data")),
                tabPanel("Tableau", tableOutput("data_table")),
                tabPanel("Visualisation", plotOutput("bar_plot"))
                )
    )
  )
)
