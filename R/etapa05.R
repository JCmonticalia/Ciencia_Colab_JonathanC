calcular05 <- function() {
  p <- caminho("data","kg_1991_2020_30s.tif")
  f <- caminho("data","kg_2071_2099_ssp585_30s.tif")
  if (!all(file.exists(c(p,f)))) stop("Faltam os dois rasters globais em data/.")
  atual <- terra::rast(p); futuro <- terra::rast(f)
  terra::compareGeom(atual,futuro,stopOnError=TRUE)
  stopifnot(terra::nlyr(atual)==1L,terra::nlyr(futuro)==1L,
            all(abs(terra::res(atual)-1/120)<1e-7))
  linhas <- readLines(caminho("data","legend.txt"),warn=FALSE,encoding="UTF-8")
  pat <- "^\\s*([0-9]+):\\s+([A-Za-z]+)\\s+.*$"
  linhas <- linhas[grepl(pat,linhas,perl=TRUE)]
  legenda <- data.frame(codigo=as.integer(sub(pat,"\\1",linhas,perl=TRUE)),
                        simbolo=sub(pat,"\\2",linhas,perl=TRUE))
  stopifnot(nrow(legenda)==30L,setequal(legenda$codigo,1:30),!anyDuplicated(legenda$codigo))
  d <- as.data.frame(readRDS(caminho("data","ocorrencias_alvo_etapa03.rds")))
  exigidas <- c("gbifID","species","bioma","decimalLongitude","decimalLatitude")
  if(!all(exigidas %in% names(d))) stop("Colunas ausentes: ",paste(setdiff(exigidas,names(d)),collapse=", "))
  if(anyNA(d$bioma) || any(d$bioma != "Mata Atlântica")) stop("A entrada contem registros de outro bioma.")
  # Compatibilidade explicita com o nome historico usado no documento anterior.
  d$nome_original <- d$species
  d$species[d$species=="Caesalpinia echinata"] <- "Paubrasilia echinata"
  alvos <- c("Araucaria angustifolia","Cariniana legalis","Cattleya labiata",
              "Dicksonia sellowiana","Euterpe edulis","Paubrasilia echinata")
  if (any(!d$species %in% alvos)) stop("Especie fora da lista de estudo.")
  n_origem <- nrow(d)
  coordenadas_validas <- with(d,is.finite(decimalLongitude)&is.finite(decimalLatitude)&
                                abs(decimalLongitude)<=180&abs(decimalLatitude)<=90)
  auditoria <- d[!coordenadas_validas, c("gbifID","species")]
  salvar_csv(auditoria,"05_coordenadas_invalidas.csv")
  d <- d[coordenadas_validas,]
  if(!nrow(d)) stop("Nenhum registro com coordenadas validas.")
  pontos <- sf::st_as_sf(d,coords=c("decimalLongitude","decimalLatitude"),crs=4326,remove=FALSE)
  pontos <- sf::st_transform(pontos,terra::crs(atual))
  xy <- sf::st_coordinates(pontos)
  # Matriz de coordenadas: extract devolve a camada, sem a coluna ID de SpatVector.
  d$kg_atual <- as.integer(terra::extract(atual,xy)[[1]])
  d$kg_futuro <- as.integer(terra::extract(futuro,xy)[[1]])
  d$kg_atual[!d$kg_atual %in% 1:30] <- NA_integer_
  d$kg_futuro[!d$kg_futuro %in% 1:30] <- NA_integer_
  d$celula <- terra::cellFromXY(atual,xy)
  d$classe_atual <- legenda$simbolo[match(d$kg_atual,legenda$codigo)]
  d$classe_futura <- legenda$simbolo[match(d$kg_futuro,legenda$codigo)]
  d$situacao <- ifelse(is.na(d$kg_atual)|is.na(d$kg_futuro),"Sem informação climática",
                        ifelse(d$kg_atual==d$kg_futuro,"Classe mantida","Classe alterada"))
  resumir <- function(x) {
    r <- lapply(alvos,function(s) {
      a <- x[x$species==s,,drop=FALSE]
      validos <- sum(a$situacao!="Sem informação climática")
      muda <- sum(a$situacao=="Classe alterada")
      data.frame(species=s,total=nrow(a),validos=validos,sem_clima=nrow(a)-validos,
                  mantidos=sum(a$situacao=="Classe mantida"),alterados=muda,
                  percentual=if(validos>0)100*muda/validos else NA_real_)
    })
    do.call(rbind,r)
  }
  resumo <- resumir(d)
  # Uma observacao por especie e celula, apenas onde ha clima nos dois periodos.
  validos <- d[d$situacao!="Sem informação climática",]
  celulas <- validos[!duplicated(validos[c("species","celula")]),]
  resumo_celulas <- resumir(celulas)
  if("coordinateUncertaintyInMeters" %in% names(d)) {
    u <- suppressWarnings(as.numeric(d$coordinateUncertaintyInMeters))
    precisos <- resumir(d[!is.na(u)&u>=0&u<=1000,])
    incerteza <- data.frame(species=alvos,
      sem_incerteza=vapply(alvos,function(s)sum(d$species==s & is.na(u)),integer(1)),
      acima_1km=vapply(alvos,function(s)sum(d$species==s & !is.na(u) & u>1000),integer(1)))
  } else { precisos <- NULL; incerteza <- NULL }
  transicoes <- as.data.frame(dplyr::count(validos,species,classe_atual,classe_futura,name="registros"))
  transicoes$percentual <- 100*transicoes$registros/resumo$validos[match(transicoes$species,resumo$species)]
  transicoes <- transicoes[order(transicoes$species,-transicoes$registros),]
  sensibilidade <- merge(resumo[c("species","validos","percentual")],
                         resumo_celulas[c("species","validos","percentual")],by="species",suffixes=c("_registros","_celulas"))
  sensibilidade$diferenca_pp <- sensibilidade$percentual_celulas-sensibilidade$percentual_registros
  salvar_csv(resumo,"05_resumo_especies.csv")
  salvar_csv(transicoes,"05_transicoes_climaticas.csv")
  salvar_csv(sensibilidade,"05_sensibilidade_celulas.csv")
  if(!is.null(precisos)) salvar_csv(precisos,"05_sensibilidade_incerteza_1km.csv")
  if(!is.null(incerteza)) salvar_csv(incerteza,"05_incerteza_coordenadas.csv")
  salvar_csv(d,"05_ocorrencias_com_clima.csv")
  espacial <- sf::st_as_sf(d,coords=c("decimalLongitude","decimalLatitude"),crs=4326,remove=FALSE)
  sf::st_write(espacial,caminho("resultados","05_ocorrencias_clima.gpkg"),layer="ocorrencias",delete_layer=TRUE,quiet=TRUE)
  list(dados=d,resumo=resumo,celulas=celulas,sensibilidade=sensibilidade,
        precisos=precisos,incerteza=incerteza,transicoes=transicoes,legenda=legenda,
        n_origem=n_origem,n_invalidas=nrow(auditoria),atual=atual,futuro=futuro)
}

