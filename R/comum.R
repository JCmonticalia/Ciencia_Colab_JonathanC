# No Windows, mantenha UTF-8 para comparar nomes de biomas vindos de CSV e GeoParquet.
if (.Platform$OS.type == "windows") suppressWarnings(Sys.setlocale("LC_CTYPE", "Portuguese_Brazil.utf8"))
encontrar_raiz <- function(inicio = getwd()) {
  p <- normalizePath(inicio, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(p, "_site.yml"))) return(p)
    acima <- dirname(p)
    if (identical(acima, p)) stop("Abra o projeto .Rproj ou execute a partir da pasta do projeto.")
    p <- acima
  }
}
raiz <- encontrar_raiz()
caminho <- function(...) file.path(raiz, ...)
config <- list(dados_originais = "", resultados_originais = "")
if (file.exists(caminho("config.local.R"))) source(caminho("config.local.R"), local = TRUE)
entrada <- function(nome) {
  candidatos <- c(caminho(nome), file.path(config$dados_originais, nome),
                  file.path(config$resultados_originais, basename(nome)))
  candidatos <- candidatos[file.exists(candidatos)]
  if (!length(candidatos)) stop("Entrada ausente: ", nome, ". Configure config.local.R.")
  normalizePath(candidatos[1], winslash = "/", mustWork = TRUE)
}
dir.create(caminho("resultados"), showWarnings = FALSE)
fmt <- function(x, casas=0) format(round(x, casas), big.mark=".", decimal.mark=",", nsmall=casas, trim=TRUE, scientific=FALSE)
tab <- function(x, digits=2, ...) knitr::kable(as.data.frame(x), row.names=FALSE, digits=digits, ...)
salvar_csv <- function(x, nome) data.table::fwrite(x, caminho("resultados", nome), na="")
tema <- function() ggplot2::theme_classic(base_size=12) +
  ggplot2::theme(plot.title=ggplot2::element_text(face="bold"),
                 strip.background=ggplot2::element_blank(),
                 strip.text=ggplot2::element_text(face="bold"),
                 legend.position="bottom")
knitr::opts_chunk$set(echo=TRUE, message=FALSE, warning=FALSE, error=FALSE,
                     fig.width=9, fig.height=5.5, dpi=150)

