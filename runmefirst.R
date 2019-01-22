library(vitae)
library(rorcid)
library(lubridate)
library(tidyverse)
orcid_auth()


edu <- rorcid::orcid_educations("0000-0002-3378-7386")

edux <- detailed_entries(edu$`0000-0002-3378-7386`$`education-summary`, what =`role-title`,
                 when=as.character(glue::glue("{`start-date.year.value`} - {`end-date.year.value`}")),
                 with = organization.name,
                 where = glue::glue("{`organization.address.city`}, {`organization.address.region`}")
)



mycvdata <- list(edux = edux)


emp <- orcid_employments("0000-0002-3378-7386")

# emp$`0000-0002-3378-7386`$`employment-summary`$`role-title` <- 
#   paste(emp$`0000-0002-3378-7386`$`employment-summary`$`role-title`, "\\hfill \\break")
# 

emp$`0000-0002-3378-7386`$`employment-summary`$`end-date.year.value`[is.na(emp$`0000-0002-3378-7386`$`employment-summary`$`end-date.year.value`)] <- "     Present"

empx <- detailed_entries(emp$`0000-0002-3378-7386`$`employment-summary`, what =`role-title`,
                         when=as.character(glue::glue("{`start-date.year.value`} - {`end-date.year.value`}")),
                         with = organization.name,
                         where = glue::glue("{`organization.address.city`}, {`organization.address.region`}"),
                         .protect = FALSE)

mycvdata$empx <- empx
pubs <- works(orcid_id("0000-0002-3378-7386"))

mycvdata$pubsx <- 
  scholar::get_publications("E-Zn20UAAAAJ", flush=TRUE) %>% 
  filter(!is.na(cid)) %>%
  filter(journal != "") %>%
  arrange(desc(year)) %>%
  mutate(title = ifelse(grepl("[.]$", title), title, paste0(title, "."))) %>%
  detailed_entries(
    what = title,
    when = year,
    with = author,
    where = journal
  )

pres <- read.csv(file = "./presies.csv", as.is=TRUE)
pres <- pres[order(strptime(pres$when, format = "%m/%d/%Y"), decreasing = TRUE),]


mycvdata$presx <- detailed_entries(pres, what = what, when = when, where=where, with=who)

write_rds(mycvdata, "./mycvdata.rds")
