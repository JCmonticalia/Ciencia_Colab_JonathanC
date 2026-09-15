# Proveniência e decisões analíticas

## Origem dos arquivos

Reconstrução realizada em 15/09/2026 a partir dos cinco R Markdown de `projeto_github_pages_Rmd` e dos arquivos já existentes em sua pasta `resultados`.

| Entrada | Uso |
|:--|:--|
| `Br_01_control_depuracion.csv` | Resumo auditável da etapa 1 |
| `Br_01_clean2.csv` | Resumo da etapa 2 e recuperação de `species`, incerteza espacial e licença pelo `gbifID` |
| `Br_01_analisis.csv` | Totais da etapa 3, agregação temporal da etapa 4 e seleção de ocorrências da Mata Atlântica |
| `koppen_data/1991_2020/koppen_geiger_0p00833333.tif` | Clima de referência |
| `koppen_data/2071_2099/ssp585/koppen_geiger_0p00833333.tif` | Clima futuro |
| `koppen_data/legend.txt` | Correspondência entre códigos e classes |

Os rasters foram lidos do conjunto já presente em `Ferramentas_Ciencia_Colab`. Não foi atribuída uma versão de descarga por inferência do nome: a identificação exata da versão do ZIP local não estava documentada. O site oficial distribui atualmente V3 e solicita a citação de Beck et al. (2023). O artigo descreve V2. Os hashes dos arquivos utilizados constam em `data/manifesto_sha256.csv`.

Limites dos biomas: `biomes_2025.parquet`, distribuição oficial do `geobr`, release `v2.0.0`, obtida em 15/09/2026:

https://github.com/ipea/geobr_prep_data/releases/download/v2.0.0/biomes_2025.parquet

As geometrias completas foram conservadas em RDS. A simplificação cartográfica é aplicada apenas durante o desenho dos mapas.

## Universo das análises

- Matriz da etapa 3: 2.944.266 registros.
- Registros classificados como Mata Atlântica nessa matriz: 1.412.049.
- Etapa 4: apenas `HUMAN_OBSERVATION` e `PRESERVED_SPECIMEN`, com ano inteiro positivo, não posterior ao ano da execução e bioma informado.
- Riqueza: identificadores `speciesKey` distintos; valores ausentes não contam.
- Etapa 5: seis espécies da lista original, recuperadas pelo `gbifID`, entre os registros atribuídos à Mata Atlântica; 8.417 registros antes da extração climática.
- Os nomes aceitos são os recebidos da matriz limpa. A única correspondência nominal explicitamente prevista é `Caesalpinia echinata` → `Paubrasilia echinata`, confirmada no POWO.

O recorte não foi feito por uma caixa geográfica nem por um suposto arquivo GeoPackage anterior. A atribuição do bioma segue a matriz efetivamente produzida na etapa 3. Isso preserva a origem sequencial, inclusive suas limitações.

## Dados compactos

`data/etapa04.rds` contém agregações exatas da matriz, não uma amostra. `data/ocorrencias_alvo_etapa03.rds` contém os registros das espécies de estudo com os campos necessários. O mapa ilustrativo da etapa 2 utiliza uma amostra de 30 mil registros, semente 123, claramente identificada na legenda.

Os TIFF globais foram copiados integralmente, sem recorte, interpolação ou mudança de resolução. A extração usa a célula que contém a coordenada. Cada espécie é analisada por registros e, adicionalmente, por células únicas. Registros sem classe válida em um dos períodos permanecem documentados e não compõem o denominador de alteração.

## Alcance da execução

As etapas 4 e 5 são recalculadas na geração do site. As etapas 1–3 exibem os procedimentos e os resumos dos arquivos anteriores. Não foi executada novamente a depuração integral da base bruta de vários gigabytes.

As correções do código das etapas 2 e 3 não foram aplicadas retroativamente às matrizes herdadas. O modo de reprocessamento completo está documentado no README e pode alterar os resultados após uma nova execução.

Não foi possível calcular a relação com áreas protegidas porque a sequência não fornece `dentro_ap` nem um arquivo de limites de proteção. Não foram mantidos percentuais ou conclusões sem resultados verificáveis.

## Verificações concluídas

- As sete páginas HTML foram geradas em R 4.4.1.
- Os códigos climáticos de todos os 8.417 registros foram comparados com os dois TIFF globais de origem e coincidiram.
- Os totais por espécie, denominadores e registros sem informação foram conferidos.
- A sintaxe dos blocos R dos cinco documentos e de todos os scripts foi verificada.
- Os links e recursos locais das páginas foram verificados; nenhum arquivo do pacote ultrapassa 100 MB.
- Os gráficos da etapa 5 foram inspecionados após a geração.
- A etapa 5 foi gerada novamente a partir do ZIP extraído em outra pasta, sem `config.local.R` e sem acesso às matrizes originais pelo código do documento.

## Atribuição das fontes

Mapas climáticos: CC BY 4.0; Beck et al. (2023), https://doi.org/10.1038/s41597-023-02549-6.

Ocorrências: matrizes GBIF fornecidas pelo autor. Os campos `gbifID`, `datasetKey` e `license` foram preservados no recorte disponibilizado. O DOI da descarga e a consulta original devem ser acrescentados pelo autor quando disponíveis; não foram inventados.

Taxonomia do pau-brasil: Royal Botanic Gardens, Kew. (2026). *Paubrasilia echinata*. Plants of the World Online. https://powo.science.kew.org/taxon/urn:lsid:ipni.org:names:77158012-1. Sem DOI.

Vieses de documentação: Meyer, C., Weigelt, P., & Kreft, H. (2016). Multidimensional biases, gaps and uncertainties in global plant occurrence information. *Ecology Letters, 19*(8), 992–1006. https://doi.org/10.1111/ele.12624.


