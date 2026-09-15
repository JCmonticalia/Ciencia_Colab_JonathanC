# Execute no RStudio: source("R/gerar_site.R", encoding="UTF-8")
source("R/comum.R", encoding="UTF-8")
if (!rmarkdown::pandoc_available()) {
  candidato <- "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
  if(file.exists(file.path(candidato,"pandoc.exe"))) Sys.setenv(RSTUDIO_PANDOC=candidato)
}
if(!rmarkdown::pandoc_available()) stop("Pandoc nao encontrado. Execute pelo RStudio ou configure RSTUDIO_PANDOC.")
arquivos <- c("index.Rmd",sort(list.files(raiz,pattern="^0[1-5]_.*\\.Rmd$")),"resultados.Rmd")
dir.create(caminho("docs"),showWarnings=FALSE)
for(arq in arquivos) {
  message("Gerando ",arq)
  rmarkdown::render(caminho(arq), output_dir=caminho("docs"),
                     envir=new.env(parent=globalenv()),encoding="UTF-8",quiet=TRUE)
}
dir.create(caminho("docs","tabelas"),showWarnings=FALSE)
publicar <- list.files(caminho("resultados"),pattern="^0[45]_.*\\.csv$",full.names=TRUE)
publicar <- publicar[!grepl("ocorrencias|coordenadas_invalidas",basename(publicar))]
file.copy(publicar,caminho("docs","tabelas"),overwrite=TRUE)
file.create(caminho("docs",".nojekyll"))
capture.output(sessionInfo(),file=caminho("data","sessao_R.txt"))
message("Site gerado em docs/.")
