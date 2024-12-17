pacman::p_load(reactablefmtr)

# t = ind_data |>
#   filter(UOM == "Persons", Sex == "Both sexes") |>
#   group_by(Industry, Characteristic, REF_DATE) |>
#   summarise(VALUE = sum(VALUE)) |>
#   arrange(Industry, Characteristic, REF_DATE)
# 
# t_outer = t |>
#   pivot_wider(names_from = Characteristic, values_from = VALUE) |>
#   group_by(Industry) |>
#   summarise(across(3:last_col(), ~list(.))) |>
#   select(Industry, Employment)  # only one sparkline is enough, dammit. It would be nice to be able to print the years in the tooltips as well but I can't figure that out.
# 
# 
# ind_data |>
#   filter(UOM == "Persons", Sex == "Both sexes") |>
#   group_by(Industry, Characteristic, REF_DATE) |>
#   summarise(VALUE = sum(VALUE))

last_year = max(ind_data$REF_DATE)

t_employment = ind_data |>
  filter(UOM == "Persons", Sex == "Both sexes", Characteristic == "Employment") |>
  group_by(Industry, REF_DATE) |>
  summarise(VALUE = sum(VALUE)) |>
  arrange(Industry, REF_DATE) |>
  summarise(across(c(VALUE), ~list(.))) |>
  rename(Employment = VALUE)
  
t_percent_female = ind_data |>
  filter(UOM == "Persons", Sex != "Both sexes", Characteristic == "Employment", REF_DATE == last_year) |>
  group_by(Industry, Sex) |>
  summarise(VALUE = sum(VALUE)) |>
  pivot_wider(names_from = Sex, values_from = VALUE) |>
  adorn_totals(where = 'col') |>
  mutate(Percent_female = Females / Total) |>
  as_tibble() |>
  select(Industry, Percent_female)
  


t_outer = t_employment |>
  inner_join(t_percent_female)


t_soc2 = suppressWarnings( # this is because the sparkline thingy makes a weird warning
  reactable(
    t_outer,
    compact = T, onClick = 'expand', highlight = T, rowStyle = list(cursor = "pointer"), searchable = T, defaultPageSize = 20,
    columns = list(
      Employment = colDef(cell = react_sparkline(t_outer, show_area = T, highlight_points = highlight_points(first = "green", last = "purple"), labels = c("first", "last"))),
      Percent_female = colDef(cell = data_bars(t_outer, text_position = "outside-base", number_fmt = scales::percent))
    ),
    details = function(index, value) {
      
      the_industry = t_outer[[index, 'Industry']]
      
      g_tibble = ind_data |>
        filter(Characteristic == 'Unemployment rate', Sex == "Both sexes", Age == "25 to 54 years") |> 
        select(Industry, REF_DATE, VALUE) |>
        mutate(VALUE = VALUE / 100)
      
      g = g_tibble |>
        ggplot(aes(x=REF_DATE, y=VALUE, color=Industry, group=Industry, alpha=.2)) +
        geom_line() +
        geom_point() +
        geom_line(data = filter(g, Industry == the_industry), color='black', size=2, alpha=1) +
        geom_point(data = filter(g, Industry == the_industry), color='black', size=3, alpha = 1) +
        ggthemes::theme_clean() +
        labs(y="Unemployment Rate", x = "Year") +
        theme(legend.position = 'none') +
        theme(axis.text.x = element_text(angle = 45)) + 
        scale_y_continuous(labels = scales::percent) +
        ggtitle(paste0(the_industry, " Unemployment Rate Time Series"))
      
      
      div(
        h4(paste0(the_industry, " (", last_year, ")" )),
        
        # this div is the table of employment % by age breakdown
        div(
          class = 'card', # does this work?
          ind_data |>
            filter(REF_DATE == last_year) |> 
            filter(UOM == "Persons", Sex == "Both sexes", Characteristic == "Employment") |>
            filter(Industry == the_industry) |>
            select(Age, VALUE) |>
            rename(Employment = VALUE) |>
            replace_na(list(Employment = 0)) |>
            adorn_percentages(denominator = 'col') |>
            as_tibble() |>
            reactable(bordered = T, fullWidth = F, width = 300, columns = list(Employment = colDef(format = colFormat(percent = T, digits = 1))))
        ),
        
        # this div is a time series plot of unemployment rate for the select industry
        br(),
        br(),
        div(htmltools::plotTag(g, alt='plot', width = 600))
      )
    }
  )
)

t_soc2



# Note: the printing of "NA" in percent_female is very annoying. See https://stackoverflow.com/questions/79096431/how-to-ignore-na-when-using-icon-sets-in-reactablefmtr-package -- that didn't work. I also tried writing a function for the cell (ie if is.na(value) then "" else data_bars...) Finally, I tried setting the na argument to "". Nope.








