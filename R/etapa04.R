calcular04 <- function() {
  z <- readRDS(caminho("data", "etapa04.rds"))
  a <- as.data.frame(z$anual)
  a <- a[order(a$bioma,a$year),]
  # O ano corrente e exibido, mas nao entra na regressao por ser incompleto.
  ultimo_completo <- as.integer(substr(z$data_execucao,1,4)) - 1L
  modelos <- lapply(split(a[a$year <= ultimo_completo,], a$bioma[a$year <= ultimo_completo]), function(d) {
    if(nrow(d)<3L || length(unique(d$year))<3L)
      return(data.frame(bioma=d$bioma[1],anos=nrow(d),inicio=min(d$year),fim=max(d$year),
                        inclinacao=NA_real_,p_valor=NA_real_,rho=NA_real_))
    m <- lm(riqueza ~ year, data=d)
    co <- summary(m)$coefficients
    data.frame(bioma=d$bioma[1],anos=nrow(d),inicio=min(d$year),fim=max(d$year),
               inclinacao=unname(co["year","Estimate"]),p_valor=unname(co["year","Pr(>|t|)"]),
               rho=if(sd(d$registros)>0 && sd(d$riqueza)>0) cor(d$registros,d$riqueza,method="spearman") else NA_real_)
  })
  tendencias <- do.call(rbind,modelos)
  tendencias$p_ajustado_BH <- p.adjust(tendencias$p_valor,method="BH")
  salvar_csv(a,"04_registros_riqueza_ano_bioma.csv")
  salvar_csv(z$bioma,"04_resumo_biomas.csv")
  salvar_csv(tendencias,"04_tendencias_descritivas.csv")
  z$anual <- a
  z$tendencias <- tendencias
  z$ultimo_completo <- ultimo_completo
  z
}
