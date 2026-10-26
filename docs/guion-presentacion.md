# Guion de presentación: 5–8 minutos

1. Título y objetivo (30 s). Explicar la recomendación de cursos con SQL Server 2025 y RAG local, nivel 3.
2. Caso de uso (40 s). Una petición natural y filtros de nivel, temática y tiempo. Catálogo ficticio, 131 cursos.
3. Arquitectura (60 s). Python consulta Ollama para el embedding, SQL Server devuelve fuentes y el LLM redacta sobre ese contexto. Todo se ejecuta en local.
4. Modelo y seguridad (60 s). Tres tablas, claves, JSON y VECTOR. Mostrar vista/procedimiento y lector/editor con accesos diferentes.
5. Funcionalidades DP-800 y RAG (60 s). Diferenciar embeddings de generación. Mostrar pregunta, fuentes, contexto y respuesta; explicar limitaciones de citas y abstención.
6. Demostración (90 s). Abrir interfaz, buscar ventas con SQL, limitar a principiante y pedir explicación. Abrir contexto; repetir con diseño de moda o precios para mostrar abstención.
7. Resultados (60 s). Enseñar antes/después con mismo catálogo y treinta pares. Menos lecturas; señalar que la mediana ODBC apenas cambia. Mostrar seguridad y reproducción verificada.
8. Conclusiones (40 s). Aprendizajes: datos, permisos y evidencias importan tanto como el LLM. Futuro: evaluación más amplia y cuenta de servicio dedicada.

Antes de la sesión: iniciar Ollama y SQL Server, arrancar `app.py`, comprobar los dos modelos. Conservar las capturas y JSON como alternativa si la demostración en vivo no está disponible. El profesor necesita una invitación al repositorio privado.
