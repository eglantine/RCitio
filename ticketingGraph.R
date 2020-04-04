lines = getResponseFromRoute(api_url,sessionId,"/rest/lines")
referential_lines = do.call(rbind.data.frame, c(lines, stringsAsFactors = F))

ticketing_raw_data = getResponseFromRoute(api_url,sessionId,"/kpis/ticketing/agency/17/line?aggregated_by_time=false&included_date_perimeters=2020-03-26_2020-04-02_1111111&excluded_date_perimeters=&ticket_type_id=all")
ticketing_data = do.call(rbind.data.frame, c(ticketing_raw_data$data, stringsAsFactors = F))
ticketing_data = merge(x = ticketing_data, 
                       y = referential_lines,
                       by.x = "aggregation_level_id", 
                       by.y = "id")

lines_colours = unique(ticketing_data$colour)
names(lines_colours) = unique(ticketing_data$name)

ticketing_per_line = 
  ticketing_data %>%
  group_by(name, colour) %>%
  summarise(direction_in = sum(direction_in))

plot= 
  ggplot(ticketing_per_line, 
         aes(x= reorder(name, direction_in), 
             y=direction_in, 
             fill=name,
             label=direction_in)) + 
  geom_bar(stat="identity") +
  ggtitle (paste0("Nombre de validations par ligne (",
                  group,
                  ", du ",
                  min(ticketing_data$date),
                  " au ",
                  max(ticketing_data$date),
                  ")")) +
  ylab("Nombre de validations") +
  xlab(element_blank()) +
  scale_fill_manual(values=lines_colours)+ 
  theme_minimal()+
  theme(legend.position = "none")+
#  geom_text(aes(label=direction_in), position = position_stack(vjust = 0.95),color = "white") +
  coord_flip()
