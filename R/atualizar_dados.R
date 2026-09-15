# Execute depois das etapas 1–3 para atualizar os dados portateis.
source("R/comum.R",encoding="UTF-8")
library(data.table)
d <- fread(entrada("resultados/Br_01_analisis.csv"),
           colClasses=c(gbifID="character",speciesKey="character"))
requeridas <- c("gbifID","speciesKey","bioma","year","basisOfRecord","decimalLongitude","decimalLatitude")
stopifnot(all(requeridas %in% names(d)))
saveRDS(d[,.(registros=.N,especies=uniqueN(speciesKey[!is.na(speciesKey)])),by=bioma],caminho("data","resumo03.rds"))
saveRDS(d[,.(registros=.N),by=year],caminho("data","anos03.rds"))
ano_execucao <- as.integer(format(Sys.Date(),"%Y"))
dt <- d[basisOfRecord %chin% c("HUMAN_OBSERVATION","PRESERVED_SPECIMEN") &
          !is.na(year)&!is.na(bioma)&year==floor(year)&year>0&year<=ano_execucao]
a <- dt[,.(registros=.N,riqueza=uniqueN(speciesKey[!is.na(speciesKey)&speciesKey!=""])),by=.(bioma,year)]
b <- dt[,.(registros=.N,riqueza=uniqueN(speciesKey[!is.na(speciesKey)&speciesKey!=""])),by=bioma]
saveRDS(list(anual=a,bioma=b,tipo=dt[,. (registros=.N),by=.(year,basisOfRecord)],
             n_entrada=nrow(d),n_temporal=nrow(dt),sem_ano=sum(is.na(d$year)),
             data_execucao=as.character(Sys.Date())),caminho("data","etapa04.rds"))
ma <- d[bioma=="Mata Atlântica"]
rm(d,dt);gc()
cab <- names(fread(entrada("resultados/Br_01_clean2.csv"),nrows=0))
cols <- intersect(c("gbifID","species","coordinateUncertaintyInMeters","license"),cab)
stopifnot(all(c("gbifID","species") %in% cols))
tax <- fread(entrada("resultados/Br_01_clean2.csv"),select=cols,colClasses=c(gbifID="character"))
alvos <- c("Araucaria angustifolia","Euterpe edulis","Cariniana legalis","Cattleya labiata",
            "Dicksonia sellowiana","Caesalpinia echinata","Paubrasilia echinata")
tax <- tax[species %chin% alvos]
if(anyDuplicated(tax$gbifID)) {
  stopifnot(!nrow(tax[,.(n=uniqueN(species)),by=gbifID][n>1]))
  tax <- unique(tax,by="gbifID")
}
# A coluna da base limpa e a referencia para a correspondencia taxonomica.
ma[, (intersect(setdiff(cols,"gbifID"),names(ma))) := NULL]
alvo <- merge(ma,tax,by="gbifID",all=FALSE,sort=FALSE)
if(!nrow(alvo)) stop("Nenhuma das especies de estudo foi encontrada na Mata Atlantica.")
saveRDS(alvo,caminho("data","ocorrencias_alvo_etapa03.rds"))
rm(ma,tax);gc()
controle <- fread(entrada("resultados/Br_01_control_depuracion.csv"),select="motivo_eliminacao")
saveRDS(controle[,.(registros=.N),by=motivo_eliminacao],caminho("data","resumo01.rds"))
rm(controle);gc()
limpa <- fread(entrada("resultados/Br_01_clean2.csv"),
               select=c("basisOfRecord","speciesKey","decimalLongitude","decimalLatitude"),
               colClasses=c(speciesKey="character"))
set.seed(123)
saveRDS(list(n=nrow(limpa),tipos=limpa[,.N,by=basisOfRecord],
             n_especies=uniqueN(limpa$speciesKey[!is.na(limpa$speciesKey)]),
             amostra=limpa[sample.int(.N,min(.N,30000)),.(decimalLongitude,decimalLatitude)]),
        caminho("data","resumo02.rds"))
message("Dados portateis atualizados. Gere novamente o site para atualizar textos e tabelas.")
