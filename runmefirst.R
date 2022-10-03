library(vitae)
library(rorcid)
library(lubridate)
library(readxl)
library(tidyverse)
orcid_auth()


orcid_edu <- do.call("rbind",
                      rorcid::orcid_educations("0000-0002-3378-7386")$`0000-0002-3378-7386`$`affiliation-group`$summaries
)



edux <- orcid_edu %>%
  detailed_entries(
    what = `education-summary.role-title`,
    when = glue::glue("{`education-summary.start-date.year.value`} - {`education-summary.end-date.year.value`}"),
    with = `education-summary.organization.name`,
    where = glue::glue("{`education-summary.organization.address.city`}, {`education-summary.organization.address.region`}") 
  )






mycvdata <- list(edux = edux)


emp <- rorcid::orcid_employments("0000-0002-3378-7386")$`0000-0002-3378-7386`$`affiliation-group`$summaries %>%
  bind_rows()


# emp$`0000-0002-3378-7386`$`employment-summary`$`role-title` <- 
#   paste(emp$`0000-0002-3378-7386`$`employment-summary`$`role-title`, "\\hfill \\break")
# 

emp$`employment-summary.end-date.year.value`[is.na(emp$`employment-summary.end-date.year.value`)] <- "     Present"

empx <- emp %>%
  detailed_entries(
    what = `employment-summary.role-title`,
    when = glue::glue("{`employment-summary.start-date.year.value`} - {`employment-summary.end-date.year.value`}"),
    with = `employment-summary.organization.name`,
    where = glue::glue("{`employment-summary.organization.address.city`},{`employment-summary.organization.address.region`}")
  )



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
  ) %>%
  filter(where != "Geol Soc Am Abstr Program")




pres <- read_excel("Data.xlsx", sheet = "Short Presentations")



pres <- pres[order(strptime(pres$Start.Date, format = "%m/%d/%Y"), decreasing = TRUE),]
pres <- pres[order(pres$Start.Date, decreasing = TRUE),]
pres$where <- paste(pres$Sponsor, pres$Location)
mycvdata$presx <- detailed_entries(pres, what = Title,  where = where, when = Start.Date,  with=Authors)



govt <- read_excel("Data.xlsx", sheet = "Governmental Publications")

govt <- govt[order(strptime(govt$Start.Date, format = "%m/%d/%Y"), decreasing = TRUE),]
govt <- govt[order(govt$Start.Date, decreasing = TRUE),]
govt$where <- paste(govt$Sponsor, govt$Location)
mycvdata$govtx <- detailed_entries(govt, what = Title,  when = format(Start.Date, "%Y"), where=where, with=Authors)



write_rds(mycvdata, "./mycvdata.rds")
