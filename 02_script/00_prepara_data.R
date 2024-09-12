#' ---
#' title: prepare data - data papers - mammals sp
#' author: mauricio vancine
#' year: 2022-03-29
#' ---

# prepare r -------------------------------------------------------------

# packages
library(tidyverse)
library(data.table)
library(sf)
library(terra)
library(fasterize)
library(tmap)

# options
options(timeout = 1e6)
sf::sf_use_s2(FALSE)

# directories
dir.create("scripts")
dir.create("data")
dir.create("data/data_papers")
dir.create("data/geodata")

# prepare data papers ------------------------------------------------------------

#' here i prepare the data from mammals data papers. these data are not available

## atlantic camtrap ----

# download data
#download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.1998&file=ecy1998-sup-0001-DataS1.zip",
            #  "data/data_papers/atlantic_camtrap.zip", mode = "wb")

# unzip
#unzip(zipfile = "data/data_papers/atlantic_camtrap.zip", exdir = "data/data_papers")

# import sites
ca_si <- readr::read_csv("data/data_papers/ATLANTIC_CAMTRAPS_1-0_LOCATION.csv") %>% 
    dplyr::select(location_id, X, Y)
ca_si

# import sites names
ca_si_na <- readr::read_csv("data/data_papers/ATLANTIC_CAMTRAPS_1-0_SURVEY.csv") %>% 
    dplyr::left_join(., ca_si, by = "location_id") %>% 
    dplyr::select(location_id, survey_id, yearfinish,  X, Y)
ca_si_na

# import species names
ca_sp_na <- readr::read_csv("data/data_papers/ATLANTIC_CAMTRAPS_1-0_SPECIES.csv") %>% 
    dplyr::select(order:genus, species_name, species_code)
ca_sp_na

# import species
ca_sp <- readr::read_csv("data/data_papers/ATLANTIC_CAMTRAPS_1-0_RECORDS.csv") %>% 
    dplyr::select(survey_id, species_code, presence_absence) %>% 
    dplyr::filter(presence_absence == 1) %>% 
    dplyr::mutate(species_code = ifelse(species_code == "Potu_flav", "Poto_flav", species_code)) %>% 
    dplyr::left_join(., ca_sp_na, by = "species_code") %>% 
    dplyr::select(-c(presence_absence,  species_code))
ca_sp

# join data
ca_occ <- ca_sp %>% 
    dplyr::left_join(ca_si_na, by = "survey_id") %>% 
    dplyr::mutate(species = species_name,
                  longitude = as.numeric(X), 
                  latitude = as.numeric(Y), 
                  year = as.numeric(yearfinish),
                  source = "atlantic_camtrap") %>%
    dplyr::select(order:genus, species, longitude, latitude, year, source) %>% 
    tibble::rowid_to_column()
ca_occ

# export data
readr::write_csv(ca_occ, "data/atlantic_camtrap.csv")

## atlantic large mammals ----

# download data
#download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.2785&file=ecy2785-sup-0001-DataS1.zip",
 #             destfile = "data/data_papers/atlantic_large_mammals.zip", mode = "wb")

# unzip
#unzip(zipfile = "data/data_papers/atlantic_large_mammals.zip", exdir = "data/data_papers")

# import data
lm_occ <- readr::read_csv("data/data_papers/ATLANTIC_MAMMAL_MID_LARGE _assemblages_and_sites.csv") %>% 
    dplyr::mutate(genus = str_split(Actual_species_Name, " ", simplify = TRUE)[, 1],
                  species = Actual_species_Name,
                  longitude = as.numeric(Longitude), 
                  latitude = as.numeric(Latitude), 
                  year = as.numeric(Year_finish),
                  source = "atlantic_large_mammals") %>%
    dplyr::select(genus, species, longitude, latitude, year, source) %>% 
    tidyr::drop_na(longitude, latitude) %>% 
    dplyr::mutate(species = str_trim(species)) %>% 
    tibble::rowid_to_column() %>% 
    dplyr::left_join(., rbind(unique(ca_occ[, c(2, 3, 4)])), by = "genus") %>% 
    dplyr::relocate(order:family, .before = 2)
lm_occ

# export data
readr::write_csv(lm_occ, "data/atlantic_large_mammals.csv")

## neotropical carnivores ----

# download data
#download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.3128&file=ecy3128-sup-0001-DataS1.zip",
 #             destfile = "data/data_papers/neotropical_carnivores.zip", mode = "wb")

# unzip
#unzip(zipfile = "data/data_papers/neotropical_carnivores.zip", exdir = "data/data_papers")

sort(unique(neo_car_occ$TYPE_REC))

# import
neo_car_occ <- readr::read_csv("data/data_papers/NEOTROPICAL_CARNIVORES_DATASET_2020-04.csv") %>% 
    dplyr::mutate(family = FAMILY,
                  genus = GENUS,
                  species = SPECIES,
                  name = SPECIES, 
                  longitude = LONG_X, 
                  latitude = LAT_Y,
                  year = as.numeric(COL_END_YR),
                  source = "neotropical_carnivores") %>%
    dplyr::select(family, genus, species, longitude, latitude, year, source) %>% 
    dplyr::mutate(species = str_trim(species)) %>% 
    tibble::rowid_to_column() %>% 
    dplyr::left_join(., unique(rbind(ca_occ[, c(2, 4)], lm_occ[, c(2, 4)])), by = "genus") %>% 
    dplyr::relocate(order, .after = 1)
neo_car_occ

# export data
readr::write_csv(neo_car_occ, "data/neotropical_carnivores.csv")

# prepare geodata ------------------------------------------------------------------

#' here i prepare the geoespatial data. these data are not available

## UGRHI ----
download.file("https://datageo.ambiente.sp.gov.br/geoserver/datageo/LimiteUGRHI/wfs?version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=LimiteUGRHI",
              "data/geodata/LimiteUGRHI.zip", mode = "wb")
unzip(zipfile = "data/geodata/LimiteUGRHI.zip", exdir = "data/geodata")

ugrhi <- sf::st_read("data/geodata/LimiteUGRHIPolygon.shp", 
                     options = "ENCODING=WINDOWS-1252") %>% 
    sf::st_transform(4326) %>% 
    sf::st_make_valid()
ugrhi

## Inventario Florestal 2020 ----
download.file("http://datageo.ambiente.sp.gov.br/geoserver/datageo/InventarioFlorestal2020/wfs?version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=InventarioFlorestal2020",
              "data/geodata/InventarioFlorestal2020.zip", mode = "wb")
unzip(zipfile = "data/geodata/InventarioFlorestal2020.zip", exdir = "data/geodata")

inventario_florestal <- sf::st_read("data/geodata/InventarioFlorestal2020.shp",
                                    options = "ENCODING=WINDOWS-1252") %>% 
    sf::st_transform(4326) %>% 
    sf::st_make_valid() %>% 
    dplyr::mutate(FITOFISION = as.factor(FITOFISION)) %>% 
    dplyr::mutate(layer = as.numeric(FITOFISION))
inventario_florestal

inventario_florestal_code <- inventario_florestal %>% 
    sf::st_drop_geometry() %>% 
    dplyr::select(FITOFISION, layer) %>% 
    dplyr::distinct()
inventario_florestal_code

inventario_florestal_raster <- fasterize::fasterize(sf = inventario_florestal,
                                                    raster = fasterize::raster(inventario_florestal, res = 500/(3600*30)),
                                                    field = "FITOFISION") %>% 
    terra::rast() %>% 
    terra::as.polygons() %>% 
    sf::st_as_sf() %>% 
    dplyr::left_join(., inventario_florestal_code)
inventario_florestal_raster

## Limite Municipal ----
download.file("https://datageo.ambiente.sp.gov.br/geoserver/datageo/LimiteMunicipal/wfs?version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=LimiteMunicipal",
              "data/geodata/LimiteMunicipal.zip", mode = "wb")
unzip(zipfile = "data/geodata/LimiteMunicipal.zip", exdir = "data/geodata")

limite_municipal <- sf::st_read("data/geodata/LimiteMunicipalPolygon.shp",
                                options = "ENCODING=WINDOWS-1252") %>% 
    sf::st_transform(4326) %>% 
    sf::st_make_valid()
limite_municipal

## ucs ----
download.file("http://mapas.mma.gov.br/ms_tmp/ucsei.shp",
              "data/geodata/ucsei.shp", mode = "wb")

download.file("http://mapas.mma.gov.br/ms_tmp/ucsei.shx",
              "data/geodata/ucsei.shx", mode = "wb")

download.file("http://mapas.mma.gov.br/ms_tmp/ucsei.dbf",
              "data/geodata/ucsei.dbf", mode = "wb")

uc_pi <- sf::st_read("data/geodata/ucsei.shp",
                     options = "ENCODING=WINDOWS-1252")
sf::st_crs(uc_pi) <- 4326
uc_pi

uc_pi <- sf::st_intersection(uc_pi, ugrhi)
uc_pi
plot(uc_pi$geometry)

# export
sf::st_write(ugrhi, "data/ugrhi.shp", delete_dsn = TRUE)
sf::st_write(inventario_florestal_raster, "data/inventario_florestal.shp", delete_dsn = TRUE)
sf::st_write(limite_municipal, "data/limite_municipal.shp", delete_dsn = TRUE)
sf::st_write(uc_pi, "data/uc_pi.shp", delete_dsn = TRUE)

# import data papers -------------------------------------------------------

# large mammals
at_lar <- readr::read_csv("data/atlantic_large_mammals.csv")
at_lar

# camtrap
at_cam <- readr::read_csv("data/atlantic_camtrap.csv")
at_cam

# neotropical carnivores
neo_car <- readr::read_csv("data/neotropical_carnivores.csv")
neo_car

# bind
occ <- dplyr::bind_rows(
  at_cam,
  at_lar,
  neo_car
  ) %>%
  dplyr::select(-1) %>% 
    dplyr::distinct(species, longitude, latitude, .keep_all = TRUE)
occ

# vetor
occ_v <- occ %>% 
    tidyr::drop_na(longitude, latitude) %>% 
    dplyr::mutate(lon = longitude,
                  lat = latitude) %>% 
    dplyr::filter(lon > -180 & lon < 180) %>% 
    dplyr::filter(lat > -90 & lat < 90) %>% 
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
occ_v

plot(occ_v$geometry, pch = 20)

# import geodata ----------------------------------------------------------

# ugrhi
ugrhi <- sf::st_read("data/geodata/ugrhi.shp")
ugrhi

# inventario_florestal
inventario_florestal <- sf::st_read("data/geodata/inventario_florestal.shp")
inventario_florestal

# limite_municipal
limite_municipal <- sf::st_read("data/geodata/limite_municipal.shp")
limite_municipal

# uc_pi
uc_pi <- sf::st_read("data/geodata/uc_pi.shp")
uc_pi

# filters -----------------------------------------------------------------

# crop sp
occ_v_sp <- occ_v[ugrhi, ] %>% 
    tibble::rowid_to_column()
occ_v_sp

mamiferos <- occ_v
mamiferos <- mamiferos %>%
  dplyr::filter(
    family == "Felidae"
  )

mamiferos <- mamiferos[!grepl("sp.", mamiferos$species),]

mamiferos <- mamiferos[!grepl("Panthera onca", mamiferos$species),]
mamiferos <- mamiferos[!grepl("Puma concolor", mamiferos$species),]
mamiferos <- mamiferos[!grepl("Felis catus", mamiferos$species),]
mamiferos <- mamiferos[!grepl("Lynx rufus", mamiferos$species),]
mamiferos <- mamiferos[!grepl("Leopardus guigna", mamiferos$species),]
mamiferos <- mamiferos[!grepl("Leopardus jacobita", mamiferos$species),]
mamiferos$species <- gsub("Puma yagouaroundi","Herpailurus yagouaroundi",
                          mamiferos$species)

sort(unique(mamiferos$species))
plot(mamiferos$geometry, pch = 20)

download.file("http://www.dpi.inpe.br/amb_data/Shapefiles/UF_EstadosBR_LLWGS84.zip",
              "data/geodata/brasil.zip", mode = "wb")

unzip(zipfile = "data/geodata/brasil.zip", exdir = "data/geodata")

brasil <- sf::st_read("data/geodata/vetor_EstadosBR_LLWGS84/EstadosBR_IBGE_LLWGS84.shp")

gatosBrasil <- mamiferos[brasil, ] %>% 
  tibble::rowid_to_column()

plot(gatosBrasil$geometry, pch = 20)

gatosBrasil$genus <- word(gatosBrasil$species,1)

unique(sort(gatosBrasil$species))

unique(sort(gatosBrasil$genus))

unique(sort(gatosBrasil$family))

unique(sort(gatosBrasil$order))

gatosBrasil <- gatosBrasil %>%
  filter(year>1999)

# map
tm_shape(ugrhi) +
    tm_polygons() +
    tm_shape(occ_v_sp) +
    tm_dots() +
    tm_graticules(lines = FALSE) +
    tm_compass(position = c("left", "bottom")) +
    tm_scale_bar(text.size = .7, position = c("left", "bottom"))

# selection
patterns <- c("sp.", 
              "Callithrix penicillata x Callithrix aurita",
              "Callithrix jacchus X Callithrix aurita",
              "Callithrix jacchus X Callithrix penicillata",
              "Monodelphis americana/scalops",
              "Unidentified rodent")

occ_v_sp_filter <- occ_v_sp %>% 
    dplyr::filter(!grepl(paste(patterns, collapse = "|"), species)) %>% 
    dplyr::mutate(species = case_when(species == "Puma yagouaroundi" ~ "Herpailurus yagouaroundi",
                                      species == "marmosops paulensis" ~ "Marmosops paulensis",
                                      species == "Dasypus septemcinctus septemcinctus" ~ "Dasypus septemcinctus",
                                      species == "Leopardus tigrinus" ~ "Leopardus guttulus",
                                      TRUE ~ species)) %>% 
    dplyr::mutate(genus = case_when(genus == "marmosops" ~ "Marmosops",
                                    genus == "Herpailurus" ~ "Puma",
                                    TRUE ~ genus)) %>% 
    dplyr::mutate(family = case_when(family == "Felídeos" ~ "Felidae",
                                     TRUE ~ family)) %>% 
    dplyr::mutate(order = ifelse(species == "Myrmecophaga tridactyla", "Pilosa", order)) %>% 
    dplyr::mutate(order = ifelse(species == "Tamandua tetradactyla", "Pilosa", order))

occ_v_sp_filter %>% 
    sf::st_drop_geometry() %>% 
    dplyr::count(order) %>% 
    as.data.frame()

occ_v_sp_filter %>% 
    sf::st_drop_geometry() %>% 
    dplyr::count(family) %>% 
    as.data.frame()

occ_v_sp_filter %>% 
    sf::st_drop_geometry() %>% 
    dplyr::count(genus) %>% 
    as.data.frame()

# export
sf::st_write(occ_v_sp_filter, "data/geodata/occ_v_sp.gpkg", delete_dsn = TRUE)

occ_v_sp_filter %>% 
    sf::st_drop_geometry() %>% 
    readr::write_csv("data/data_papers/occ_v_sp.csv")

# end ---------------------------------------------------------------------