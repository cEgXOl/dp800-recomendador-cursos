# Resultados de las pruebas funcionales

| N.º | Caso | Filtros | Resultado |
|---:|---|---|---|
| 1 | Analizar ventas con SQL y conocimientos básicos | Ninguno | Correcto. Los cursos de SQL y análisis de ventas aparecen primero. |
| 2 | Misma petición | Principiante | Correcto. Los resultados mostrados son de nivel principiante. |
| 3 | Misma petición | Avanzado | Correcto. Se muestran cursos avanzados relacionados con SQL. |
| 4 | Crear informes y paneles de datos | Máximo 120 minutos | Correcto. Los cursos mostrados respetan la duración máxima. |
| 5 | Consultar y transformar datos relacionales | Temática SQL/bases de datos | Correcto. Los cursos pertenecen a la temática seleccionada. |
| 6 | Aprender diseño de moda | Ninguno | Correcto tras añadir el umbral: no se muestran cursos sin afinidad suficiente. |
| 7 | Automatizar el análisis de datos | Principiante y máximo 180 minutos | Correcto. Los resultados respetan ambos filtros. |

## Observación sobre relevancia

La primera ejecución de la prueba 6 mostró cursos porque el recomendador siempre devolvía hasta diez resultados. Se añadió un límite inicial de distancia coseno de `0.70`; al repetir las pruebas, la consulta de diseño de moda quedó sin resultados y el usuario confirmó que las otras búsquedas seguían mostrando resultados correctos.

El valor `0.70` es un umbral empírico validado con el catálogo de prueba ampliado a 131 cursos. Conviene revisarlo si cambia el modelo o el contenido del catálogo.

## Repetición con el catálogo ampliado

Se repitieron los siete casos con 131 cursos y embeddings completos. Los recuentos fueron: búsqueda semántica, 10; principiante, 10; avanzado, 10; duración máxima, 4; temática SQL, 10; consulta sin afinidad, 0; filtros combinados, 10. Los filtros de nivel y duración se comprobaron en los resultados y la búsqueda sin afinidad siguió vacía.

Los 100 cursos añadidos son sintéticos y están identificados en `AdditionalAttributes` con `source=synthetic_scale_test`; sirven para la prueba de escala y no representan una oferta real de cursos.
