library(vitae)
library(rorcid)
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
  detailed_entries(
    what = title,
    when = year,
    with = author,
    where = journal
  )

write_rds(mycvdata, "./mycvdata.rds")
