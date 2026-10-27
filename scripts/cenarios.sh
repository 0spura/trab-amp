#!/usr/bin/env bash
# Executa os cenários de falha do OpenTelemetry Demo via feature flags (flagd)
# e registra o intervalo (UTC) de cada um em cenarios.log.
set -euo pipefail
cd "$(dirname "$0")/.."
F=otel-demo/src/flagd/demo.flagd.json
LOG=cenarios.log
DUR=${DUR:-240}

setflag() { # flag variante
  jq --arg f "$1" --arg v "$2" '.flags[$f].defaultVariant=$v' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
}
# productCatalogFailure: o targeting do demo devolve "off" nos dois ramos; força "on" para o produto OLJCESPC7Z
catalog_on() {
  jq '.flags.productCatalogFailure.targeting.if[2]="on"' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
}
catalog_off() {
  jq '.flags.productCatalogFailure.targeting.if[2]="off"' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
}
now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
run() { # nome  comando_on  comando_off
  local s=$(now); echo "== $1 inicio $s" | tee -a $LOG
  eval "$2"; sleep "$DUR"; eval "$3"
  echo "== $1 fim $(now)" | tee -a $LOG
  sleep 60  # respiro entre cenários
}

: > $LOG
echo "== baseline inicio $(now)" | tee -a $LOG; sleep "$DUR"; echo "== baseline fim $(now)" | tee -a $LOG; sleep 30
run "pagamento_falha_50"   'setflag paymentFailure 50%'    'setflag paymentFailure off'
run "imagens_lentas_5s"    'setflag imageSlowLoad 5sec'    'setflag imageSlowLoad off'
run "catalogo_falha"       'catalog_on'                    'catalog_off'
run "cpu_alta_ad"          'setflag adHighCpu on'          'setflag adHighCpu off'
run "vazamento_memoria_email" 'setflag emailMemoryLeak 10000x' 'setflag emailMemoryLeak off'
echo "== FIM $(now)" | tee -a $LOG
