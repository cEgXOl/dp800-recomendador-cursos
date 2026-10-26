"""Integration checks against real local SQL Server and Ollama; saves evidence."""
from __future__ import annotations
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from setup_database import DEFAULT_CONNECTION, execute_file
os.environ.setdefault('COURSE_RECOMMENDER_SQL_CONNECTION_STRING',DEFAULT_CONNECTION)
import pyodbc
from app import recommend,get_categories,embed_query,connection_string,database_connection
from rag import generate_answer

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--skip-rag',action='store_true')
    parser.add_argument('--output',default='validation.json')
    args=parser.parse_args()
    suite=unittest.defaultTestLoader.discover(str(ROOT/'tests'))
    if not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful():
        raise SystemExit(1)
    evidence={'timestamp':datetime.now(timezone.utc).isoformat(),'cases':[],'rag':[]}
    sql_id=next(c['id'] for c in get_categories() if c['name']=='SQL')
    query='Quiero aprender a analizar ventas con SQL y tengo conocimientos básicos'
    cases=[('semantic',{'query':query}),('beginner',{'query':query,'level':'Beginner'}),
           ('advanced',{'query':query,'level':'Advanced'}),
           ('duration',{'query':'Quiero crear informes y paneles de datos','maxDuration':120}),
           ('category',{'query':'Quiero consultar y transformar datos relacionales','categoryId':sql_id}),
           ('none',{'query':'Quiero aprender diseño de moda'}),
           ('combined',{'query':'Quiero automatizar análisis de datos','level':'Beginner','maxDuration':180}),
           ('paraphrase',{'query':'Necesito convertir cifras comerciales en un tablero interactivo con gráficos'})]
    for name,payload in cases:
        rows=recommend(payload)
        assert len(rows)<=10,(name,'TOP K')
        assert all(r['cosineDistance']<=0.7001 for r in rows),(name,'distance')
        assert [r['cosineDistance'] for r in rows]==sorted(r['cosineDistance'] for r in rows),(name,'ranking')
        if name=='none': assert not rows,'La consulta negativa no se abstiene'
        else: assert rows,(name,'No hay resultados')
        if 'level' in payload: assert all(r['level']==payload['level'] for r in rows),name
        if 'maxDuration' in payload: assert all(r['durationMinutes']<=payload['maxDuration'] for r in rows),name
        if 'categoryId' in payload: assert all(payload['categoryId'] in r['categoryIds'] for r in rows),name
        evidence['cases'].append({'name':name,'request':payload,'results':rows})
        print(name,len(rows),'OK',flush=True)
    with pyodbc.connect(connection_string(),autocommit=True) as connection:
        evidence['security']=execute_file(connection,ROOT/'sql'/'09_security_tests.sql')
        count=connection.execute('SELECT COUNT(*),SUM(CASE WHEN DescriptionEmbedding IS NULL THEN 1 ELSE 0 END) FROM dbo.Courses').fetchone()
        assert count[0]>=131 and count[1]==0,tuple(count)
        evidence['catalog']={'courses':count[0],'pendingEmbeddings':count[1]}
    with database_connection() as connection:
        assert connection.execute('SELECT USER_NAME()').fetchone()[0]=='CourseReaderDemo'
    if not args.skip_rag:
        for question in (query,'Qué precio tienen los cursos para analizar ventas con SQL?', 'Quiero aprender diseño de moda'):
            result=generate_answer(question,recommend({'query':question}))
            assert set(result['citations']) <= {r['id'] for r in result['sources']}
            if not result['sources']: assert not result['generated']
            if question==query: assert result['generated'] and result['citations']
            if question.startswith('Qué precio'):
                assert not result['generated'] and 'precios' in result['answer']
            evidence['rag'].append(result)
            print('RAG',question[:40],result['answer'],flush=True)
    folder=ROOT/'docs'/'evidence'; folder.mkdir(exist_ok=True,parents=True)
    (folder/Path(args.output).name).write_text(json.dumps(evidence,ensure_ascii=False,indent=2,default=str),encoding='utf-8')
    print('Validacion completa',flush=True)

if __name__=='__main__': main()
