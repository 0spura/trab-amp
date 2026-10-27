# APM de uma aplicação com SigNoz e OpenTelemetry

Trabalho prático de monitoramento de desempenho. O projeto monitora o OpenTelemetry Demo (loja virtual de microsserviços) com SigNoz e injeta cenários de falha via feature flags.

- [Relatório](relatorio.md)
- [Roteiro da apresentação](apresentacao.md)
- [Capturas da plataforma e traces](evidencias/)
- [Scripts dos cenários e extração de métricas](scripts/)
- [Log temporal dos cenários](cenarios.log)
- [Configurações de integração](config/)

## Requisitos

- Docker Desktop / Docker Engine + Docker Compose v2; recomendado pelo menos 8 GB de RAM.
- `foundryctl` para instalar o SigNoz conforme o [guia oficial](https://signoz.io/docs/install/docker/).
- Git, `jq` e `curl`.

## Obter a aplicação

O OpenTelemetry Demo é um projeto de terceiros e não é copiado para este repositório. Clone-o separadamente:

```bash
git clone --depth 1 https://github.com/open-telemetry/opentelemetry-demo.git otel-demo
```

Copie `config/otelcol-config-extras.yml` para `otel-demo/src/otel-collector/otelcol-config-extras.yml`, e `config/otel-demo.override.yaml` para a raiz (ao lado de `otel-demo/`). Ajuste `ENVOY_PORT=8081` no `otel-demo/.env` para evitar conflito com a UI do SigNoz em 8080.

## Subir o SigNoz e o demo

```bash
export PATH="$HOME/.local/bin:$PATH"
foundryctl cast -f config/signoz-casting.yaml
```

Se a porta padrão OTLP (4317/4318) estiver ocupada, inicie o compose do SigNoz com o override publicado:

```bash
docker compose -p signoz \
  -f signoz/pours/deployment/compose.yaml \
  -f config/signoz-compose.override.yaml up -d
```

> O comando acima pressupõe que o Foundry já gerou `signoz/pours/deployment/compose.yaml` no diretório do projeto. Em uma instalação limpa, rode `foundryctl forge -f config/signoz-casting.yaml` a partir de `signoz/`.

Suba a aplicação, no diretório `otel-demo/`:

```bash
docker compose -f compose.yaml -f ../config/otel-demo.override.yaml up -d
```

A loja fica em http://localhost:8081 e o SigNoz em http://localhost:8080. Crie a conta inicial do SigNoz na UI; não use credenciais pessoais em arquivos versionados.

## Reproduzir cenários

A partir da raiz deste repositório:

```bash
scripts/cenarios.sh   # aproximadamente 30 minutos
scripts/janelas.sh
```

O script de cenários espera que `otel-demo/` exista e que `flagd` esteja rodando. Ele alterna as flags e salva os intervalos em `cenarios.log`. Os scripts consultam o container ClickHouse `signoz-telemetrystore-clickhouse-0-0`.

## Resultados e limites

Veja os valores observados, metodologia, limitações do experimento e referências em [relatorio.md](relatorio.md). Os resultados são de uma execução local de baixa carga; não são benchmark nem garantia de produção. As capturas de tela são evidência dessa execução.

## Licenças

Os textos e scripts deste repositório são para o trabalho acadêmico. O OpenTelemetry Demo e SigNoz são projetos de terceiros, cada um com sua licença; consulte os repositórios oficiais antes de redistribuir esses projetos.
