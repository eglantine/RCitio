library(httr)
library(jsonlite)

####################################

getSessionId = function(login, password, group, env){
  if(is.null(login)||is.null(password)){
    stop("Please provide login and password")
  } else { 
    
    credentials = paste("Basic", base64_enc(paste0(login,":",password)))
    
    gateway_url = paste0(
      "https://",
      group,
      ".gateway.",
      ifelse(env=="staging","staging.",""),
      "cit.io"
    )
    
    login_route = paste0(gateway_url,"/api/login")
    
    auth_route = paste0(gateway_url,"/api/authenticate")
    
    GET(login_route, add_headers(Authorization = credentials))
    
    auth_response = GET(auth_route)
    
    return(
      auth_response$cookies$value[auth_response$cookies$name=="sessionid"]
    )
  }
}

buildBaseUrl = function(group, env) {
  api_base_url = paste0(
    "https://",
    group,
    ".api.",
    ifelse(env=="staging","staging.",""),
    "cit.io"
  )
  
  return(api_base_url)
}

getResponseFromRoute = function(route_url, session_id){
  response = GET(route_url,set_cookies(sessionid = session_id))
  return(
    content(response)
  )
}

getAgencyId = function(api_base_url, session_id){
  agency_route = paste0(api_base_url, "/rest/agency")
  response = getResponseFromRoute(agency_route,session_id)
  
  if(is.null(response$id)){
    stop("Agence non disponible")
  } else { 
    return(response$id)}
}


getReferentialSection = function(api_base_url,session_id, referential_section){
  referential_route = paste0(api_base_url,"/rest/", referential_section)
  response = getResponseFromRoute(referential_route, session_id)
  referential_table = do.call(rbind.data.frame, c(response, stringsAsFactors = F))
  return(referential_table)
}

getKPIdata = function(api_base_url, kpi, agency_id, spatial_aggregation_level = "line", aggregated_by_time = FALSE,aggregated_by_day = FALSE, start_date = Sys.Date() - 7, end_date = Sys.Date(), days_of_the_week =  1111111, session_id){
  
  kpi_base_url = paste(api_base_url,
                       "kpis",
                       kpi,
                       "agency",
                       agency_id,
                       spatial_aggregation_level,
                       sep = "/")
  
  query_parameters = paste(paste0("aggregated_by_time=", tolower(aggregated_by_time)),
                           paste0("aggregated_by_day=", tolower(aggregated_by_day)),
                           paste0("included_date_perimeters=",
                                  paste(start_date,
                                        end_date,
                                        days_of_the_week,
                                        sep = "_")
                           ),
                           sep="&")
  
  kpi_route = paste(kpi_base_url,query_parameters, sep = "?")
  
  response = getResponseFromRoute(kpi_route, session_id)
  
  kpi_data_table = do.call(rbind.data.frame, c(response$data, stringsAsFactors = F))
  
  return(kpi_data_table)
  
}

######################

# Samples
#
# session_id = getSessionId(login, password, group = "lorient", env = "staging")
# 
# api_base_url = buildBaseUrl(group = "lorient", env = "staging")
# 
# agency_id = getAgencyId(api_base_url, session_id)
# 
# lines_referential = getReferentialSection(api_base_url,session_id,"lines")
# 
# num_courses = getKPIdata(api_base_url,"num_courses",agency_id, session_id = session_id)
