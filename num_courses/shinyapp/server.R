library(shiny)
library(httr)
library(purrr)

source("../../auth.R", chdir = T)

function(input, output) {

  observeEvent(input$doLogin,{
    session_id = getSessionId(input$login, input$password, input$group, input$env)
    print(session_id)
  })
  
  output$raw_data = renderTable({
    if(!is.null(session_id)){
      
    
    api_base_url = buildBaseUrl(input$group, input$env)
    agency_id = getAgencyId(api_base_url, session_id)
    lines_referential = getReferentialSection(api_base_url,session_id,"lines")
    num_courses = getKPIdata(api_base_url,"num_courses",agency_id,start_date = input$start_date,end_date = input$end_date)
    
    num_courses
    }
    
  })
  
  output$bar_plot = renderTable({
    plot_data =
    num_courses %>%
    group_by(input$aggregation_level) %>%
    summarise(num_normal_courses=sum(num_normal_courses))
    
    as.data.frame(plot_data)
  })
}