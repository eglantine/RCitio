library(httr)
library(jsonlite)

source("credentials.conf")

group = "lorient"
env = "staging"

####################################

credentials = paste("Basic", base64_enc(paste0(login,":",password)))

gateway_url = paste0(
  "https://",
  group,
  ".",
  "gateway",
  ".",
  ifelse(env=="staging","staging",""),
  ".cit.io"
)

api_url = paste0(
  "https://",
  group,
  ".",
  "api",
  ".",
  ifelse(env=="staging","staging",""),
  ".cit.io"
)

login_route = paste0(gateway_url,"/api/login")
auth_route = paste0(gateway_url,"/api/authenticate")

getSessionId = function(login_route, auth_route, credentials){
  login_response = GET(login_route, add_headers(Authorization = credentials))
  auth_response = GET(auth_route)
  return(
    auth_response$cookies$value[auth_response$cookies$name=="sessionid"]
    )
}

getResponseFromRoute = function(api_url,sessionId, queriedRoute){
  route_url = paste0(api_url, queriedRoute)
  response = GET(route_url,set_cookies(sessionid = sessionId))
  return(
    content(response)
    )
}

######################

sessionId = getSessionId(login_route, auth_route, credentials)

lines = getResponseFromRoute(api_url,sessionId,"/rest/lines")
