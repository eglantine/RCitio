library(shiny)
library(httr)
library(purrr)
library(ggplot2)


function(input, output) {
  
  source("../../auth.R", chdir = T)
  
  global_values <- reactiveValues()
  
  observeEvent(input$doLogin,{
    session_id = getSessionId(input$login, input$password, input$group, input$env)
    print(paste0("Login successful with session_id ",session_id))
    global_values$session_id = session_id
  },ignoreInit = TRUE)
  
  num_courses = reactive({
    api_base_url = buildBaseUrl(input$group, input$env)
    agency_id = getAgencyId(api_base_url, global_values$session_id)
    lines_referential = getReferentialSection(api_base_url,global_values$session_id,"lines")
    num_courses = getKPIdata(api_base_url,"num_courses",agency_id,start_date = input$start_date,end_date = input$end_date, session_id=global_values$session_id)
    
    num_courses = merge(x = num_courses, 
                        y = lines_referential,
                        by.x = "aggregation_level_id", 
                        by.y = "id")
    # print(head(num_courses))
    
    return(num_courses)
    
  })
  
  output$raw_data = renderTable({
    num_courses()
  })
  
  plot_data = reactive({
    plot_data =
      num_courses() %>%
      group_by_(input$aggregation_level) %>%
      summarise(num_normal_courses=sum(num_normal_courses))
    return(plot_data)
  })
  
  output$data_table = renderTable({
    plot_data()
  })
  
  output$bar_plot = renderPlot({
    print(head(input$aggregation_level))
    
    ggplot(plot_data(), 
           aes_string(x=input$aggregation_level,
               y = "num_normal_courses")) +
      geom_bar(stat="identity", fill = "#838BA1") +
      ylab("Nombre de courses réalisées") +
      xlab(element_blank()) + 
      geom_text(aes(label=num_normal_courses), position = position_stack(vjust = 0.5),color = "white") +
      theme_minimal()
  })
  
  output$downloadRawData <- downloadHandler(
    filename = function() {
      paste0("num_courses - ",input$group," - ", input$start_date," - ", input$end_date, ".csv")
    },
    content = function(file) {
      write.csv2(num_courses, file, row.names = FALSE)
    }
  )
  
}