# Plano de Ação Nacional para Conservação dos Pequenos Felinos (PAN Pequenos Felinos)

Repositório dedicado à organização, análise, monitoramento e disseminação de dados e produtos relacionados ao **2º Ciclo do Plano de Ação Nacional para Conservação dos Pequenos Felinos** [(PAN Pequenos Felinos)](https://www.gov.br/icmbio/pt-br/assuntos/biodiversidade/pan/pan-pequenos-felinos), coordenado pelo **ICMBio**.


## 🎯 Objetivo do Repositório

Centralizar documentos, códigos, bases de dados georreferenciadas, análises e materiais de suporte técnico para implementação, monitoramento e avaliação do PAN Pequenos Felinos (vigência 2022–2027, Portaria ICMBio nº 493/2022).

## Espécies contempladas (2º ciclo)

| Nome científico          | Nome popular              | Categoria de ameaça (MMA 2022) |
|--------------------------|---------------------------|--------------------------------|
| Herpailurus yagouaroundi | jaguarundi/gato-mourisco  | VU (Vulnerável)                |
| Leopardus geoffroyi      | gato-do-mato-grande       | VU (Vulnerável)                |
| Leopardus guttulus       | gato-do-mato-do-sul       | VU (Vulnerável)                |
| Leopardus wiedii         | gato-maracajá             | VU (Vulnerável)                |
| Leopardus braccatus      | gato-palheiro             | EN (Ameaçado)                  |
| Leopardus tigrinus       | gato-do-mato              | EN (Ameaçado)                  |
| Leopardus munoai         | gato-dos-pampas           | CR (Criticamente Ameaçado)     |

## 📁 Estrutura do Repositório

``` bash
planoDeAcaoPequenosFelinos/
├──📄 README.md                  ← Você está aqui
├──📄 LICENSE                    ← Sugestão: CC-BY-4.0 ou CC-BY-SA-4.0
├──📄 CITATION.cff               ← Arquivo de citação recomendada (opcional)
│
├── /01_input/                   ← Bases de dados (ocorrências, shapefiles, etc.)
│   ├── /data_papers/                ← Registros brutos (Atlantic Series, Neotropical Series)
│   ├── /global/                     ← Registros burtos (SALVE, GBIF, SiBBr, etc.)
│   └── /geodata/                    ← Mapas e polígonos de referência
│
├── /02_script/                  ← Scripts de limpeza, triagem e integração
│   ├── data/
│   ├── funcoes/
│   ├── notebooks/
│   ├── 00_importDatasets.Rmd
│   ├── 01_prepareDatasets.Rmd
│
├── /mapas_e_visualizacoes/       ← Figuras, mapas finais, painéis
│
├── /produtos/                    ← Relatórios gerados, sumários executivos, infográficos
│
└── /referencias/                 ← Artigos científicos, teses, links úteis
```
## 🚀 Como contribuir

1. Faça um **fork** do repositório
2. Crie uma **branch** para sua feature (`git checkout -b feature/nova-analise`)
3. Commit suas mudanças (`git commit -m 'Adiciona script de modelagem MaxEnt'`)
4. Faça push para a branch (`git push origin feature/nova-analise`)
5. Abra um **Pull Request**

Toda contribuição é bem-vinda: dados limpos, códigos de análise (R, Python), revisão de documentos, criação de mapas, sugestões de indicadores de monitoramento, etc.

**Importante**: Respeite as restrições de sensibilidade de dados de ocorrência de espécies ameaçadas (generalize coordenadas quando necessário).

## 📜 Licença

[Creative Commons Atribuição 4.0 Internacional (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/deed.pt)

Você pode copiar, distribuir, exibir, executar, modificar e criar obras derivadas desde que dê crédito ao repositório e autores originais.

## 📫 Contato & Coordenação

- **Mantenedor principal**: Fernando Lima / @pardalismitis
- **Grupo de trabalho oficial**: PAN Pequenos Felinos – ICMBio / CENAP
- E-mail institucional sugerido: (se houver grupo de e-mail ou lista)

## Referências principais

- [Página oficial do PAN Pequenos Felinos – ICMBio](https://www.gov.br/icmbio/pt-br/assuntos/biodiversidade/pan/pan-pequenos-felinos)
- Portaria ICMBio nº 493, de 21 de junho de 2022
- Matriz de Planejamento do 2º Ciclo (disponível no site do ICMBio)

---

✨ *Ajude a conservar os pequenos felinos do Brasil — cada dado, mapa e análise contam!* 🐱🐾
