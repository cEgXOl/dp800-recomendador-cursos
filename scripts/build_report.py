"""Build the technical report from measured evidence (optional authoring dependency: reportlab)."""
from pathlib import Path
import json
from xml.sax.saxutils import escape
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, Image, Flowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from PIL import Image as PILImage

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'output'/'pdf';OUT.mkdir(parents=True,exist_ok=True)
EVIDENCE=ROOT/'docs'/'evidence'
validation=json.loads((EVIDENCE/'validation.json').read_text(encoding='utf-8'))
benchmark=json.loads((EVIDENCE/'optimization.json').read_text(encoding='utf-8'))
baseline=benchmark['summary']['dbo.usp_RecommendCoursesBaseline']
optimized=benchmark['summary']['dbo.usp_RecommendCourses']
for name,file in [('Arial','arial.ttf'),('Arial-Bold','arialbd.ttf')]:
    pdfmetrics.registerFont(TTFont(name,'C:/Windows/Fonts/'+file))
pdfmetrics.registerFontFamily('Arial',normal='Arial',bold='Arial-Bold')
NAVY=colors.HexColor('#15314d');TEAL=colors.HexColor('#137d78');LIGHT=colors.HexColor('#eef5f7')
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyLocal',fontName='Arial',fontSize=10.5,leading=15,spaceAfter=9,textColor=NAVY))
styles.add(ParagraphStyle(name='TitleLocal',fontName='Arial-Bold',fontSize=28,leading=33,spaceAfter=20,textColor=NAVY))
styles.add(ParagraphStyle(name='HeadingLocal',fontName='Arial-Bold',fontSize=19,leading=24,spaceAfter=14,textColor=NAVY))
styles.add(ParagraphStyle(name='SubLocal',fontName='Arial-Bold',fontSize=12,leading=16,spaceBefore=9,spaceAfter=7,textColor=TEAL))
styles.add(ParagraphStyle(name='SmallLocal',fontName='Arial',fontSize=8.5,leading=12,spaceAfter=6,textColor=NAVY))
story=[]
def p(text,style='BodyLocal'): return Paragraph(escape(str(text)).replace('\n','<br/>'),styles[style])
def add(text): story.append(p(text))
def heading(text): story.append(p(text,'HeadingLocal'))
def sub(text): story.append(p(text,'SubLocal'))
def page(): story.append(PageBreak())
def table(rows,widths=None):
    t=Table([[p(cell,'SmallLocal') for cell in row] for row in rows],colWidths=widths,repeatRows=1,hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),LIGHT),('VALIGN',(0,0),(-1,-1),'TOP'),
        ('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),7),
        ('BOTTOMPADDING',(0,0),(-1,-1),6),('LINEBELOW',(0,0),(-1,0),1,TEAL),
        ('LINEBELOW',(0,1),(-1,-1),0.3,colors.HexColor('#dbe4ec'))]))
    story.extend([t,Spacer(1,12)])
def image(name,maxheight=330):
    path=EVIDENCE/name
    with PILImage.open(path) as source: w,h=source.size
    scale=min(500/w,maxheight/h)
    story.extend([Image(str(path),width=w*scale,height=h*scale,hAlign='LEFT'),Spacer(1,8)])

class Architecture(Flowable):
    def __init__(self):
        super().__init__()
        self.width=500
        self.height=245
    def draw(self):
        c=self.canv
        def box(x,y,w,h,title,detail):
            c.setFillColor(LIGHT);c.setStrokeColor(TEAL);c.roundRect(x,y,w,h,5,fill=1,stroke=1)
            c.setFillColor(NAVY);c.setFont('Arial-Bold',11);c.drawCentredString(x+w/2,y+h-19,title)
            c.setFont('Arial',9);c.drawCentredString(x+w/2,y+13,detail)
        def arrow(x1,y1,x2,y2):
            c.setStrokeColor(TEAL);c.setLineWidth(1.2);c.line(x1,y1,x2,y2)
            if x1==x2:
                direction=1 if y2>y1 else -1;c.line(x2,y2,x2-4,y2-7*direction);c.line(x2,y2,x2+4,y2-7*direction)
            else:
                direction=1 if x2>x1 else -1;c.line(x2,y2,x2-7*direction,y2-4);c.line(x2,y2,x2-7*direction,y2+4)
        box(0,180,205,52,'Navegador local','Pregunta, filtros y respuesta')
        box(290,180,210,52,'Python','HTTP, recuperación y RAG')
        box(0,55,220,65,'SQL Server 2025','Catálogo · VECTOR · roles · TOP K')
        box(280,55,220,65,'Ollama local','embeddinggemma + qwen2.5:1.5b')
        arrow(205,206,290,206);arrow(395,180,395,120)
        c.line(290,193,250,193);c.line(250,193,250,140);c.line(250,140,110,140);arrow(110,140,110,120)
        c.setFont('Arial',9);c.setFillColor(NAVY);c.drawString(6,29,'Carga inicial: Python genera embeddings con Ollama y los guarda en SQL Server.')
        c.drawString(6,13,'Consulta: SQL devuelve fuentes; Python envía ese contexto al LLM local.')

story.append(Spacer(1,55));story.append(p('Recomendador de cursos\npor intereses','TitleLocal'))
story.append(p('SQL Server 2025 y RAG local','HeadingLocal'))
add('Mini proyecto DP-800 | Nivel 3 avanzado | 26 de octubre de 2026')
story.append(Spacer(1,30))
sub('Objetivo y caso de uso')
add('Convertir una necesidad de aprendizaje expresada en español en cursos relevantes, respetando nivel, duración y temática. El sistema explica sus recomendaciones usando únicamente los cursos recuperados del catálogo.')
add('Ejemplo: «Quiero aprender a analizar ventas con SQL y tengo conocimientos básicos». La aplicación compara embeddings, aplica filtros SQL y presenta una orientación con referencias verificables.')
sub('Alcance')
add('131 cursos ficticios, diez categorías y dos modelos locales. Se incluyen diseño relacional, programación T-SQL, seguridad, optimización medida, búsqueda semántica y RAG. No se utilizan servicios de inferencia de pago.')
add('El catálogo y la respuesta son una demostración académica; no representan una oferta real de cursos.')
page()

heading('Arquitectura y ejecución local')
story.append(Architecture());story.append(Spacer(1,8))
sub('Responsabilidad de cada componente')
add('El navegador envía la petición a Python. embeddinggemma transforma el texto en un vector. El procedimiento SQL calcula distancias y devuelve cursos. Python forma el contexto para qwen2.5:1.5b, que genera motivos de recomendación. Los datos estructurados y las citas se completan desde SQL, no se redactan libremente.')
table([['Componente','Tecnología / función'],['Datos','SQL Server 2025 local; tablas, vistas, procedimientos, JSON y VECTOR(768)'],['Búsqueda','Ollama embeddinggemma y distancia coseno en T-SQL'],['Generación','Ollama qwen2.5:1.5b; salida JSON estructurada'],['Interfaz','Python estándar, pyodbc, HTML/CSS/JavaScript'],['Herramientas','Windows 11, SSMS 22, VS Code, Git y repositorio GitHub privado']],[112,388])
add('Los modelos se descargan una vez. La ejecución consume recursos locales y genera/procesa tokens, pero no hay facturación por API. Cambiar el modelo de embeddings exige regenerar todo el espacio vectorial.')
page()

heading('Modelo de datos y programación SQL')
table([['Objeto','Contenido y relación'],['dbo.Courses','CourseId PK; título, descripción, nivel, duración, atributos JSON, embedding, modelo y fecha.'],['dbo.Categories','CategoryId PK y nombre UNIQUE. Diez temáticas.'],['dbo.CourseCategories','PK compuesta y dos FK: relación muchos a muchos entre cursos y categorías.'],['dbo.vCourseCatalog / vCategories','Vistas de lectura que no exponen el vector al lector.'],['dbo.usp_RecommendCourses','Validación de parámetros, conversión de vector, filtros, CTE TOP K y agregado de categorías.']],[164,336])
sub('Integridad e índices')
add('CHECK limita nivel y duración positiva; ISJSON valida los atributos adicionales. PK y UNIQUE crean los índices básicos. Las FK impiden enlaces a cursos o categorías inexistentes. La carga usa comprobaciones de existencia para evitar duplicados al repetirse.')
sub('T-SQL avanzado')
add('Se usan CTE para separar puntuación y selección, EXISTS correlacionado para filtrar temática, STRING_AGG para categorías, JSON_VALUE para atributos y ROW_NUMBER para la ampliación sintética. El procedimiento admite hasta diez resultados y comprueba los parámetros antes de consultar.')
sub('Datos de prueba')
add('El catálogo inicial tenía 31 cursos. Se añadieron 100 ejemplos sintéticos marcados con source=synthetic_scale_test. Los 131 registros tienen embeddings. Los datos adicionales no representan una oferta comercial real.')
page()

heading('Embeddings y búsqueda semántica')
add('El texto de documento combina Title, Description y las listas skills y prerequisites de AdditionalAttributes. Se utiliza el formato «title: ... | text: ...». La consulta usa «task: search result | query: ...». Ambos se generan con embeddinggemma, 768 dimensiones, y el vector se almacena en SQL Server.')
add('La distancia coseno compara la orientación de los vectores: 1 - producto escalar / producto de normas. Una distancia menor indica mayor afinidad. El ranking es una búsqueda exacta con filtros relacionales; no se necesita un índice aproximado para este catálogo.')
add('El umbral 0,70 se eligió de forma empírica y se verificó con casos positivos y una consulta fuera de temática. No es una garantía universal de relevancia y debe reevaluarse con más ejemplos.')
labels={'semantic':'Búsqueda semántica','beginner':'Principiante','advanced':'Avanzado','duration':'Duración máxima','category':'Temática SQL','none':'Sin afinidad','combined':'Filtros combinados','paraphrase':'Paráfrasis'}
table([['Prueba real','Resultados'],*[[labels[case['name']],str(len(case['results']))] for case in validation['cases']]],[330,170])
sub('Paráfrasis')
paraphrase=next(c for c in validation['cases'] if c['name']=='paraphrase')
add(paraphrase['request']['query'])
add('Primeros cursos recuperados: '+ '; '.join(r['title'] for r in paraphrase['results'][:2])+'.')
page()

heading('RAG: contexto, generación y fuentes')
add('RAG añade recuperación de datos antes de la generación. El LLM recibe la pregunta y los cuatro cursos mejor clasificados, no el catálogo completo. Devuelve identificadores y motivos breves; Python valida las fuentes y muestra título, nivel y duración desde los datos recuperados.')
image('rag-answer.png',300)
story.append(p('Captura de una ejecución real de la interfaz local. El detalle desplegable permite examinar el contexto enviado al modelo.','SmallLocal'))
sub('Abstención y límites')
add('Sin cursos pertinentes no se invoca al modelo. Si se pregunta por precios, se informa de que el esquema no tiene esa información. Las fuentes se validan contra los cursos recuperados. La explicación libre todavía puede contener interpretaciones incorrectas: las citas no constituyen una prueba completa de veracidad.')
add('Se probaron salida con identificadores desconocidos, referencias inconsistentes, datos cuantitativos no permitidos en el motivo y ausencia de fuentes. Las respuestas y el contexto reales se conservan en validation.json y ui-rag.json.')
page()

heading('Seguridad y permisos diferenciados')
add('La demostración combina usuarios/roles de base de datos y permisos explícitos GRANT/DENY. CourseReaderDemo y CourseEditorDemo se crean WITHOUT LOGIN: no hace falta guardar contraseñas. Se verifican los permisos con EXECUTE AS USER y REVERT.')
table([['Operación','Lector','Editor'],['Consultar vista del catálogo','Permitido','Permitido'],['Ejecutar recomendación','Permitido','No concedido'],['Leer directamente Courses y sus vectores','Denegado','Permitido'],['Actualizar Courses','Denegado','Permitido'],['Borrar Courses','Denegado','Denegado']],[250,125,125])
sub('Evidencia de funcionamiento')
add('La prueba de seguridad confirma lectura de la vista, error 229 al acceder a la tabla base como lector, error 229 al modificarla y error 229 al borrar como editor. La actualización de prueba del editor se ejecuta dentro de una transacción que termina en ROLLBACK.')
sub('Identidad efectiva de la aplicación')
add('Python usa la identidad lectora para cada consulta y revierte antes de devolver la conexión al pool. La cadena de propiedad permite ejecutar el procedimiento sin conceder lectura directa de la tabla. Los valores de usuario se enlazan como parámetros, no se concatenan en SQL.')
add('La cuenta de Windows de la demostración necesita permisos de instalación e impersonación. Para un servicio real debe usarse un login dedicado asociado al rol lector y retirar esos permisos administrativos. Las credenciales no se almacenan en el repositorio.')
page()

heading('Optimización: comparación controlada')
add('La consulta inicial agregaba categorías de los candidatos antes de limitar el ranking. La versión final limita TOP K dentro de una CTE antes del agregado. Así reduce accesos a las tablas de categorías. Se comparan los mismos datos, vector, filtros y columnas de salida.')
rows=[['Métrica por llamada','Inicial','CTE TOP K']]
for label,key in [('Duración SQL media (ms)','sqlDurationMsPerCall'),('CPU SQL media (ms)','sqlCpuMsPerCall'),('Lecturas lógicas','logicalReadsPerCall'),('Mediana cliente ODBC (ms)','medianRoundTripMs')]:
    rows.append([label,str(baseline[key]),str(optimized[key])])
table(rows,[260,120,120])
add('Método: tres calentamientos y treinta llamadas pareadas, alternando el orden, sin limpiar cachés. Se comprueba igualdad de las filas completas. La generación de embeddings queda fuera de la medición. Query Store se filtra por object_id y se toman deltas antes/después, sumando las sentencias internas por llamada.')
add('Las lecturas se reducen aproximadamente un 71 %. La mediana observada en el cliente cambia muy poco: el ruido y el coste de ODBC dominan a esta escala. La mejora de CPU y de lecturas no permite extrapolar latencia para otros equipos o catálogos.')
sub('Propuesta descartada')
add('Una primera variante con tabla temporal reducía lecturas, pero aumentaba la duración y la CPU. La CTE evita ese coste. Ambas mediciones se conservan como evidencia de evaluación y corrección del código asistido por IA.')
page()

heading('Verificación, problemas y conclusiones')
add('Se ejecutaron cuatro pruebas unitarias y ocho escenarios de recuperación, además de los casos RAG positivo, sin datos y sin cursos pertinentes. Se verificó la identidad lectora y se reprodujo la instalación en CourseRecommender_Repro, con 131 embeddings y pruebas satisfactorias.')
table([['Problema encontrado','Resolución'],['ODBC ntext y VECTOR','Conversión explícita de JSON a nvarchar(max) y después a VECTOR(768).'],['Alias SQL reservado y diagnósticos en Query Store','Alias corregido e identificación por object_id del procedimiento.'],['Citas y duración inventada por el LLM pequeño','Salida estructurada con IDs y motivos; datos cuantitativos y referencias compuestos por la aplicación desde SQL.'],['Mejora de lecturas sin mejora de tiempo','Medir la propuesta, conservar la evidencia y sustituir tabla temporal por CTE.']],[230,270])
sub('Conclusiones')
add('El valor de la IA depende de la calidad de los datos, la recuperación y la validación. SQL Server conserva la integridad y los permisos; el modelo local redacta la orientación a partir del contexto. Las pruebas y métricas permiten explicar tanto el funcionamiento como sus límites.')
add('Mejoras futuras: evaluación semántica con más consultas etiquetadas, verificación de afirmaciones generadas, cuenta de servicio dedicada y pruebas de carga con mayor concurrencia. El proyecto es una demostración académica, no una plataforma productiva.')
sub('Referencias y reproducción')
story.append(p('Código, scripts y evidencias: repositorio GitHub privado del proyecto (acceso por invitación). README contiene instalación y comandos. Fuentes oficiales: https://ollama.com/library/qwen2.5:1.5b · https://ollama.com/library/embeddinggemma · https://docs.ollama.com/api/chat · https://docs.ollama.com/capabilities/structured-outputs','SmallLocal'))

def footer(canvas,doc):
    canvas.saveState();canvas.setStrokeColor(TEAL);canvas.line(45,43,A4[0]-45,43)
    canvas.setFont('Arial',8);canvas.setFillColor(NAVY)
    canvas.drawString(45,29,'DP-800 · Recomendador de cursos · SQL Server 2025 y RAG local')
    canvas.drawRightString(A4[0]-45,29,str(doc.page));canvas.restoreState()

SimpleDocTemplate(str(OUT/'informe-dp800.pdf'),pagesize=A4,rightMargin=45,leftMargin=45,
    topMargin=45,bottomMargin=57,title='Recomendador de cursos con SQL Server 2025 y RAG local',
    author='Proyecto DP-800').build(story,onFirstPage=footer,onLaterPages=footer)
print(OUT/'informe-dp800.pdf')
