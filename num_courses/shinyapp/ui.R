library(httr)
library(shiny)

agency_list = map(content(GET("http://django.gateway.staging.cit.io/groups/")), 1)
agency_list = sort(unlist(agency_list))


shinyUI(fluidPage(theme = "bootstrap.css",
                  img(src = "logo_citio.png"),

  headerPanel("Nombre de courses réalisées"),
  
  sidebarPanel(
    textInput("login", "Identifiant", "eglantine@cit.io"),
    passwordInput("password", "Mot de passe",""),
    selectInput("group", "Réseau", 
                choices=agency_list),
    selectInput("env", "Environnement", 
                choices=c("staging", "production")),

    actionButton("doLogin", "Se connecter"),
    
    dateInput("start_date", "Du ", value = Sys.Date() - 7),
    dateInput("end_date", "Au ", value = Sys.Date()),
    selectInput("aggregation_level", "Agrégation", 
                choices=c("jour" = "date",
                          "ligne" = "aggregation_level_id", 
                          "créneau horaire" = "time" ))
  ),
  
  mainPanel(
    tabsetPanel(type = "tabs", 
                tabPanel("Données brutes", tableOutput("raw_data")),
                tabPanel("Visualisation", tableOutput("bar_plot"))
                )
    )
  )
)
