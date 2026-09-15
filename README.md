# Flora, biomas e mudança climática

Projeto de Jonathan David Castillo, reconstruído em português a partir dos cinco documentos R Markdown e das matrizes fornecidas.

## Publicar no GitHub Pages

As páginas já estão geradas em `docs/`; a publicação não precisa executar R.

1. Extraia o arquivo ZIP e coloque **o conteúdo da pasta do projeto** na raiz do seu repositório.
2. Envie os arquivos para a branch principal.
3. Em **Settings → Pages → Build and deployment**, selecione **Deploy from a branch**, a branch principal e **/docs**.
4. Salve. O endereço será informado pelo GitHub.

Instruções oficiais: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site

O arquivo `docs/.nojekyll` evita processamento pelo Jekyll. Os links são relativos, portanto funcionam também em repositórios de projeto. O fundo do mapa interativo depende de internet.

## Abrir e gerar novamente

Abra `Flora_Biomas_Clima.Rproj` no RStudio. Caso faltem bibliotecas:

```r
source("R/instalar_pacotes.R", encoding = "UTF-8")
```

Para recriar as páginas:

```r
source("R/gerar_site.R", encoding = "UTF-8")
```

Esse modo usa os dados compactos incluídos. Recalcula as etapas 4 e 5 e apresenta os resumos da execução anterior nas etapas 1–3. Nenhuma página depende de objetos que tenham permanecido no Environment.

Para gerar apenas a etapa 5:

```r
rmarkdown::render("05_mudanca_climatica_mata_atlantica.Rmd", output_dir = "docs", encoding = "UTF-8")
```

Os blocos de preparação da etapa 5 estão em `R/etapa05.R`, e seu código completo também aparece na página. Esse arquivo lê as ocorrências regionais, verifica os rasters, extrai as classes e salva os resultados.

## Refazer a sequência completa

As matrizes brutas e intermediárias somam vários gigabytes e não acompanham o pacote. A cópia de trabalho possui `config.local.R` apontando para os arquivos existentes neste computador; esse arquivo está ignorado pelo Git e não acompanha o ZIP. Em outro computador, copie `config.exemplo.R` como `config.local.R` e ajuste as duas pastas.

Depois execute, na ordem:

```r
etapas <- c("01_depuracao_BR_01.Rmd", "02_limpeza_complementar_BR_01.Rmd",
            "03_analise_exploratoria.Rmd")
for (arq in etapas) {
  rmarkdown::render(arq, params = list(reprocessar = TRUE),
                    output_dir = "docs", encoding = "UTF-8",
                    envir = new.env(parent = globalenv()))
}
source("R/atualizar_dados.R", encoding = "UTF-8")
source("R/gerar_site.R", encoding = "UTF-8")
```

Os resultados novos são escritos nesta pasta do projeto. A leitura prioriza arquivos da nova pasta e usa a configuração externa apenas quando a entrada ainda não existe. Para garantir uma sequência inteiramente nova, execute as três etapas completas antes de atualizar os dados compactos.

## Conteúdo

- `01_...Rmd` a `05_...Rmd`: documentos e interpretação.
- `R/`: carga, análise, atualização e geração do site.
- `data/`: resumos, ocorrências das seis espécies, limites dos biomas, dois rasters globais e legenda.
- `docs/`: site pronto para publicação, com tabelas sintéticas.
- `resultados/`: tabelas analíticas e ocorrências com clima, incluindo GeoPackage.
- `PROVENIENCIA.md`: origem dos dados, decisões e alcance da validação.

## Alterações metodológicas explícitas

Na etapa 2, os códigos de problemas passam a ser comparados como termos completos, evitando exclusões por fragmentos de palavras. A lista original de códigos foi preservada e ainda exige revisão em relação à codificação da descarga GBIF. Na etapa 3, `species` e incerteza espacial são preservadas; associações espaciais ambíguas permanecem sem bioma em vez de multiplicarem linhas.

Essas mudanças não foram aplicadas retrospectivamente às matrizes existentes. Os resultados publicados nas etapas 4 e 5 usam os produtos anteriores, com a recuperação taxonômica descrita. Uma nova depuração pode produzir números diferentes.

Não há análise de áreas protegidas: a sequência fornecida não contém a classificação `dentro_ap` nem a camada territorial necessária. O documento explicita essa ausência.

