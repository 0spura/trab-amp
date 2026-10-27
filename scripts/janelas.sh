#!/usr/bin/env bash
# Tabela por cenário: spans de entrada (kind=2 server) por serviço
q() { docker exec signoz-telemetrystore-clickhouse-0-0 clickhouse-client --format PrettyCompact -q "$1"; }
while read -r _ nome tipo ts; do
  [[ $tipo == inicio ]] && { n=$nome; ini=$ts; continue; }
  [[ $tipo == fim && $n == $nome ]] || continue
  echo "### $nome  ($ini -> $ts)"
  q "select resource_string_service\$\$name as servico, count() as reqs, countIf(has_error) as erros, round(100*countIf(has_error)/count(),2) as pct_erro, round(quantile(0.5)(duration_nano)/1e6,1) as p50_ms, round(quantile(0.95)(duration_nano)/1e6,1) as p95_ms, round(max(duration_nano)/1e6,1) as max_ms from signoz_traces.distributed_signoz_index_v3 where kind=2 and timestamp between toDateTime64('${ini%Z}'||'',9,'UTC') - 0 and toDateTime64('${ts%Z}',9,'UTC') and servico in ('frontend','checkout','payment','product-catalog','ad','email','cart','frontend-proxy') group by servico order by servico" 2>&1 | sed 's/T/ /g'
done < <(grep '^==' cenarios.log | sed 's/^== //' | awk '{print "x",$1,$2,$3}')
