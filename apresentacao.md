# Roteiro da apresentação (8 a 9 min)

Ambiente de demo ao vivo: SigNoz em http://localhost:8080 (`test@gmail.com`) e loja em http://localhost:8081. Prints de reserva em `evidencias/`.

| Tempo | Conteúdo | Mostrar |
|---|---|---|
| 0:00–0:45 | Problema: "uma aplicação bem testada ainda falha em produção". Objetivo da atividade | Slide curto |
| 0:45–1:45 | Stack: OpenTelemetry (coleta) → SigNoz (APM). App: OpenTelemetry Demo, 17 serviços. Falhas injetadas por feature flags | Diagrama mermaid do relatório |
| 1:45–2:30 | Baseline e método RED (Rate, Errors, Duration) | `01-services-lista.png` |
| 2:30–4:00 | **Cenário pagamento 50%**: `frontend` em 0% de erro, `payment` e `checkout` em 61%. Abrir o trace e ler a mensagem | `05-service-payment.png`, `09-trace-pagamento-falha.png` |
| 4:00–5:00 | **Imagens lentas**: HTTP 200 com p95 de 5 s. A armadilha do EventStream do flagd | `11-trace-lento-5s.png` |
| 5:00–6:00 | **Catálogo**: erro em cascata 70% → 26% → 14%, service map | `04-service-product-catalog.png`, `08-service-map.png` |
| 6:00–7:15 | **CPU do `ad`** e **vazamento do `email`**: lentidão que contamina dependentes; memória 33 → 72 MB | `06-service-ad.png`, `07-service-email.png` |
| 7:15–8:30 | Conclusões: métrica avisa, trace localiza, log explica. Limitações (carga baixa, host único). Recomendações | Tabela da seção 7 |
| 8:30–9:00 | Perguntas | |

## Demo ao vivo (opcional, 1 min)

Ligue a falha de pagamento e mostre o erro surgindo no SigNoz em poucos minutos:

```bash
cd otel-demo
jq '.flags.paymentFailure.defaultVariant="50%"' src/flagd/demo.flagd.json > /tmp/f.json && mv /tmp/f.json src/flagd/demo.flagd.json
# para desligar: troque "50%" por "off"
```

Em seguida, SigNoz → Services → `payment` (intervalo Last 15 min).

## Perguntas prováveis

- **Por que SigNoz e não Prometheus/Grafana/Jaeger?** Uma UI única para métricas, traces e logs, com o service map pronto. A stack separada exige integrar três ferramentas.
- **Qual a diferença entre APM e monitorar CPU/memória?** O erro de pagamento deixou o front-end em 0% de erro e as imagens lentas respondiam HTTP 200. Só a visão por requisição mostrou o problema.
- **O que faltou?** Regras de alerta (MTTD por alerta) e mais carga/repetições.
