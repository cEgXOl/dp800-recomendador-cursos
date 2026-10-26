// Optional authoring script for the Codex bundled Artifact Tool runtime.
import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const root=process.cwd();
const modules=process.env.RUNTIME_NODE_MODULES;
const skill=process.env.PRESENTATION_SKILL_DIR;
if(!modules||!skill) throw Error('Set RUNTIME_NODE_MODULES and PRESENTATION_SKILL_DIR for optional authoring.');
const {Presentation,PresentationFile}=await import(pathToFileURL(path.join(modules,'@oai/artifact-tool/dist/artifact_tool.mjs')).href);
const {finalizePresentation}=await import(pathToFileURL(path.join(skill,'container_tools/artifact_tool_utils.mjs')).href);
const build=path.join(root,'tmp','slides');await fs.mkdir(build,{recursive:true});
const output=path.join(root,'presentation');await fs.mkdir(output,{recursive:true});
const evidence=path.join(root,'docs','evidence');
const metrics=JSON.parse(await fs.readFile(path.join(evidence,'optimization.json'),'utf8')).summary;
const a=metrics['dbo.usp_RecommendCoursesBaseline'], b=metrics['dbo.usp_RecommendCourses'];
const deck=Presentation.create({slideSize:{width:1280,height:720}});
deck.theme.defaultFont='Arial';
const ink='#15314D', teal='#137D78', muted='#567086', light='#EEF5F7';
function text(slide,value,x,y,w,h,size=27,color=ink,bold=false,name='text'){
 const shape=slide.shapes.add({geometry:'textbox',name,position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
 shape.text=value;shape.text.style={typeface:'Arial',fontSize:size,color,bold};shape.text.insets=0;return shape;
}
function slide(title,notes){const s=deck.slides.add();s.background.fill='#FFFFFF';text(s,title,72,46,1136,70,44,ink,true,'title');s.speakerNotes.text=notes;return s;}
function table(s,values,x,y,w,h,widths){const t=s.tables.add({rows:values.length,columns:values[0].length,left:x,top:y,width:w,height:h,columnWidths:widths,values});
 for(let r=0;r<values.length;r++)for(let c=0;c<values[0].length;c++){const cell=t.getCell(r,c);cell.fill=r===0?light:'#FFFFFF';cell.text.style={typeface:'Arial',fontSize:24,color:ink,bold:r===0};}
 return t;
}
function box(s,title,detail,x,y,w,h){s.shapes.add({geometry:'rect',position:{left:x,top:y,width:w,height:h},fill:light,line:{fill:teal,width:1.5}});text(s,title,x+15,y+17,w-30,45,29,ink,true);text(s,detail,x+15,y+68,w-30,h-75,24,ink);}

// 1
let s=deck.slides.add();s.background.fill=ink;
text(s,'Recomendador de cursos\npor intereses',80,155,1090,190,64,'#FFFFFF',true,'title');
text(s,'SQL Server 2025 + RAG local',84,390,1090,65,34,'#A6E4DD');
text(s,'DP-800 · Nivel 3 avanzado',84,563,1000,50,27,'#FFFFFF');
s.speakerNotes.text='30 segundos. Objetivo: convertir una necesidad de aprendizaje en cursos y una explicación basada en el catálogo. Todo se ejecuta localmente. El catálogo contiene ejemplos ficticios. Fuentes: README.md y docs/evidence/validation.json.';

// 2
s=slide('Una necesidad de aprendizaje, varios filtros','40 segundos. Explicar que la petición no necesita un título exacto. Mostrar búsqueda, nivel, duración y temática. Captura real de la interfaz local en docs/evidence/search.png.');
text(s,'«Quiero analizar ventas\ncon SQL y tengo\nconocimientos básicos»',72,170,505,200,34,ink,true);
text(s,'131 cursos de prueba\n10 categorías\nRanking por afinidad semántica',72,435,500,150,28,muted);
s.images.add({blob:new Uint8Array(await fs.readFile(path.join(evidence,'search.png'))),contentType:'image/png',alt:'Búsqueda real con filtro principiante',fit:'contain',position:{left:620,top:150,width:590,height:510}});

// 3
s=slide('Arquitectura local','60 segundos. Python orquesta ambos modelos; SQL Server no llama directamente a Ollama. embeddinggemma devuelve vectores, SQL devuelve cursos y qwen2.5 genera motivos sobre ese contexto. Fuentes: app.py, rag.py, scripts/generate_embeddings.py; https://docs.ollama.com/api/chat y https://ollama.com/library/qwen2.5:1.5b.');
box(s,'Navegador','Pregunta y filtros',72,190,270,155);
box(s,'Python','HTTP y RAG',505,190,270,155);
box(s,'SQL Server 2025','VECTOR y procedimiento',938,190,270,155);
text(s,'↔',385,229,70,70,48,teal);text(s,'↔',815,229,70,70,48,teal);
box(s,'Ollama','embeddinggemma · 768D\nqwen2.5:1.5b · generación',390,470,500,150);
text(s,'↕',612,365,70,80,48,teal);
text(s,'Carga inicial: Python guarda los embeddings en SQL Server',72,655,1136,40,24,muted);

// 4
s=slide('Modelo relacional y permisos','60 segundos. Tres tablas y relación muchos a muchos. PK/FK/CHECK/UNIQUE e índices de restricciones. Explicar dos mecanismos: roles/usuarios y permisos GRANT/DENY. EXECUTE AS permite demostrar la diferencia. La app se impersona como lector y revierte; producción usaría cuenta dedicada. Fuentes: sql/01_schema.sql, sql/07_programmability.sql, sql/08_security.sql y evidencia setup-CourseRecommender.json.');
table(s,[['Tabla','Contenido'],['Courses','Título, descripción, nivel, duración, JSON y VECTOR'],['Categories','Temáticas del catálogo'],['CourseCategories','Relación muchos a muchos con PK y dos FK']],72,160,1136,290,[280,856]);
text(s,'Lector: vista y recomendación; tabla base y escritura denegadas',72,500,1136,55,27,teal,true);
text(s,'Editor: consulta y actualización; borrado denegado',72,570,1136,55,27,ink);

// 5
s=slide('Búsqueda semántica y RAG','60 segundos. Diferenciar modelo de embeddings y LLM. Coseno compara orientación; menor distancia es mejor. TOP K y filtros se ejecutan en SQL. El LLM redacta motivos, y la app muestra los campos factuales y referencias desde SQL. Citas conocidas no garantizan que toda explicación sea verdadera. Fuentes: rag.py y https://docs.ollama.com/capabilities/structured-outputs.');
text(s,'La búsqueda devuelve\ncursos ordenados',72,175,500,100,34,ink,true);
text(s,'RAG utiliza esos cursos\ncomo contexto y genera\nun motivo de recomendación',72,330,510,155,30,ink);
text(s,'Sin fuentes: abstención\nSin precios: informa de su ausencia',72,535,510,100,26,teal);
s.images.add({blob:new Uint8Array(await fs.readFile(path.join(evidence,'rag-answer.png'))),contentType:'image/png',alt:'Respuesta RAG real con cursos y fuentes',fit:'contain',position:{left:625,top:150,width:585,height:490}});

// 6
s=slide('Demostración: pregunta, contexto y respuesta','90 segundos. Abrir la aplicación. Buscar ventas SQL y aplicar Principiante. Pulsar Recomendar y explicar con IA local. Abrir el contexto y mostrar CourseId. Repetir con diseño de moda y con una pregunta de precios. La captura muestra contexto real de la interfaz. Fuentes: docs/evidence/ui-rag.json y rag-context.png.');
s.images.add({blob:new Uint8Array(await fs.readFile(path.join(evidence,'rag-context.png'))),contentType:'image/png',alt:'Fuentes recuperadas y contexto visible',fit:'contain',position:{left:72,top:145,width:700,height:520}});
text(s,'1. Escribir la necesidad\n\n2. Aplicar los filtros\n\n3. Pedir la explicación\n\n4. Revisar las fuentes',825,195,390,380,28,ink);

// 7
s=slide('Resultados medidos','60 segundos. Misma base con 131 cursos, mismo vector, filtros y treinta pares alternados después de tres calentamientos. Igualdad completa de resultados. Query Store usa deltas por object_id, sumando sentencias internas por llamada. No incluye Ollama. La mediana ODBC apenas cambia y no debe exagerarse. Fuentes: docs/evidence/optimization.json y optimization-materialized-trial.json.');
table(s,[['Métrica por llamada','Inicial','CTE TOP K'],['Duración SQL (ms)',String(a.sqlDurationMsPerCall),String(b.sqlDurationMsPerCall)],['CPU SQL (ms)',String(a.sqlCpuMsPerCall),String(b.sqlCpuMsPerCall)],['Lecturas lógicas',String(a.logicalReadsPerCall),String(b.logicalReadsPerCall)],['Mediana ODBC (ms)',String(a.medianRoundTripMs),String(b.medianRoundTripMs)]],72,160,1136,330,[570,283,283]);
text(s,'≈71 % menos lecturas; diferencia de latencia cliente pequeña',72,525,1136,55,29,teal,true);
text(s,'4 pruebas unitarias · 8 casos de recuperación · seguridad y reproducción verificadas',72,608,1136,62,25,ink);

// 8
s=slide('Conclusiones y límites','40 segundos. Concluir con datos y permisos como base de la solución. El catálogo es ficticio, la evaluación de relevancia es pequeña y el LLM puede equivocarse. No afirmar escalabilidad a miles de cursos. Entregables: README, scripts, PDF, PPTX, JSON y capturas, repositorio privado con invitación al profesor. Fuentes: README.md, docs/asistencia-ia.md y docs/evidence/reproduction-validation.json.');
text(s,'SQL conserva datos, integridad y permisos',72,170,1136,60,34,ink,true);
text(s,'Los modelos locales permiten buscar y explicar\ncon un contexto que se puede inspeccionar',72,270,1136,100,31,ink);
text(s,'La evaluación detectó errores reales y permitió corregirlos:\ncitas, duraciones, tipos ODBC y propuestas de optimización',72,420,1136,115,28,teal);
text(s,'Catálogo ficticio · LLM falible · Cuenta de servicio dedicada pendiente para producción',72,600,1136,70,24,muted);

for(const [index,current] of deck.slides.items.entries()){
  const png=await deck.export({slide:current,format:'png',scale:1});
  await fs.writeFile(path.join(build,`slide-${index+1}.png`),new Uint8Array(await png.arrayBuffer()));
}
const candidate=path.join(build,'candidate.pptx');await (await PresentationFile.exportPptx(deck)).save(candidate);
const final=path.join(output,'dp800-project.pptx');
const result=await finalizePresentation({workspaceDir:root,candidatePath:candidate,finalPath:final,
 pythonExecutable:process.env.RUNTIME_PYTHON,
 integrityValidatorPath:path.join(skill,'container_tools/inspect_presentation_package_integrity.py'),
 layoutValidatorPath:path.join(skill,'container_tools/inspect_presentation_layout_geometry.py'),
 layoutArgs:['--expected-slide-size-emu','12192000,6858000','--validate-bullet-geometry','--validate-heading-fit','--require-native-table-slide','4','--require-native-table-slide','7'],
 explicitTotalSlideCount:8,requiredNativeTableOwnerSlides:[4,7],requiredNativeChartOwnerSlides:[],
 fontPolicy:{basis:'design',families:['Arial']},verifyArtifactToolImport:true,
 receiptPath:path.join(build,`validation-${Date.now()}.json`)});
console.log(JSON.stringify(result));
