library(vitae)
library(rorcid)
library(lubridate)
library(readxl)
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
  arrange(desc(year))

mycvdata$pubsx$title <- as.character(mycvdata$pubsx$title)

mycvdata$pubsx$title <- ifelse(grepl("[.]$", mycvdata$pubsx$title), mycvdata$pubsx$title, paste0(mycvdata$pubsx$title, "."))

mycvdata$pubsx <- detailed_entries(mycvdata$pubsx,
    what = title,
    when = year,
    with = author,
    where = journal
  )


pres <- read_excel("Data.xlsx", sheet = "Short Presentations")



pres <- pres[order(strptime(pres$Start.Date, format = "%m/%d/%Y"), decreasing = TRUE),]
pres <- pres[order(pres$Start.Date),]
pres$where <- paste(pres$Sponsor, pres$Location)
mycvdata$presx <- detailed_entries(pres, what = Title,  when = Start.Date, where=where, with=Authors)

write_rds(mycvdata, "./mycvdata.rds")
