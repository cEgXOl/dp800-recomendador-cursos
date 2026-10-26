# Optimización controlada

Fecha: 26 de octubre de 2026. Datos completos en `evidence/optimization.json`.

## Método

Se comparan `dbo.usp_RecommendCoursesBaseline` y `dbo.usp_RecommendCourses` sobre los mismos 131 cursos, con todos sus vectores, el mismo embedding de consulta y los mismos filtros. Tres calentamientos preceden a treinta llamadas pareadas; el orden se alterna. Cada par debe devolver filas completas idénticas, incluido el orden. No se limpian las cachés ni se fuerza un plan.

La medición ODBC cubre la llamada y lectura del resultado. Las métricas del motor se toman como deltas de los totales de Query Store por `object_id`, antes/después de las llamadas medidas. Se suman las sentencias internas y se divide por treinta llamadas: su número de ejecuciones no equivale al número de peticiones. El embedding se calcula una sola vez fuera de la zona medida. Se excluyen el navegador y la generación del LLM.

## Cambio y resultado

La consulta inicial agrega categorías antes del TOP. La final sitúa TOP K en una CTE anterior al OUTER APPLY. Los nombres de categorías solo se agregan para el conjunto seleccionado. No se cambia el catálogo ni se añade un índice para fabricar una mejora.

| Por llamada | Inicial | CTE TOP K |
|---|---:|---:|
| Duración SQL media | 1,475 ms | 1,164 ms |
| CPU SQL media | 1,256 ms | 0,899 ms |
| Lecturas lógicas | 1.145 | 331 |
| Mediana ODBC | 2,641 ms | 2,616 ms |

La reducción observada de lecturas es aproximadamente del 71 %. La diferencia de mediana ODBC es pequeña y puede estar dentro del ruido de una prueba local con pocos datos. No se extrapola a catálogos grandes o distintos equipos.

## Operadores y costes estimados

Los planes finales guardados en el JSON son el 11 para la referencia y el 12 para la sentencia principal optimizada. El mismo archivo conserva planes anteriores de la propuesta temporal; no deben confundirse con el plan final.

- Referencia: Top -> Sort -> Nested Loops -> candidatos y agregado. El agregado se encuentra antes del límite del ranking.
- Final: Nested Loops -> Top -> Sort -> candidatos, con el agregado como rama de los cursos ya seleccionados.
- Ambos siguen leyendo `Courses` con Clustered Index Scan; es razonable para comparar vectores exactos en este catálogo. Los accesos de categorías usan sus índices existentes.
- Coste estimado de subárbol de Sort: 0,168912 inicial y 0,0956443 final; del agregado: 0,0730998 y 0,0241802. Son unidades relativas del optimizador, no milisegundos, y los subárboles no deben sumarse como si fueran costes independientes.

La primera propuesta (`evidence/optimization-materialized-trial.json`) usaba una tabla temporal: bajaban las lecturas, pero aumentaban duración y CPU. Se descartó a favor de la CTE. Esa experiencia se conserva para explicar por qué se mide el código sugerido por IA.
