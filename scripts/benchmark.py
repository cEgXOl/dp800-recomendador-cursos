"""Paired SQL-only benchmark. Same catalog, vector and parameters; no cache clearing."""
from __future__ import annotations
from datetime import datetime,timezone
import json
import os
from pathlib import Path
import statistics
import sys
import time
ROOT=Path(__file__).resolve().parents[1]; sys.path.insert(0,str(ROOT))
from setup_database import DEFAULT_CONNECTION
os.environ.setdefault('COURSE_RECOMMENDER_SQL_CONNECTION_STRING',DEFAULT_CONNECTION)
import pyodbc
from app import connection_string,embed_query

def snapshot(connection,procedure):
    sql='''SELECT COALESCE(SUM(CONVERT(float,s.count_executions)),0),
    COALESCE(SUM(s.avg_duration*s.count_executions),0),
    COALESCE(SUM(s.avg_cpu_time*s.count_executions),0),
    COALESCE(SUM(s.avg_logical_io_reads*s.count_executions),0)
    FROM sys.query_store_query q JOIN sys.query_store_plan p ON p.query_id=q.query_id
    JOIN sys.query_store_runtime_stats s ON s.plan_id=p.plan_id
    WHERE q.object_id=OBJECT_ID(?) AND s.execution_type=0'''
    return list(connection.execute(sql,procedure).fetchone())

def main():
    vector=json.dumps(embed_query('Quiero aprender a analizar ventas con SQL'))
    names=['dbo.usp_RecommendCoursesBaseline','dbo.usp_RecommendCourses']
    timings={name:[] for name in names}; messages={name:[] for name in names}
    with pyodbc.connect(connection_string(),autocommit=True) as connection:
        counts=connection.execute('SELECT COUNT(*),SUM(CASE WHEN DescriptionEmbedding IS NULL THEN 1 ELSE 0 END) FROM dbo.Courses').fetchone()
        assert counts[1]==0
        def run(name,measure=False):
            cursor=connection.cursor()
            start=time.perf_counter()
            cursor.execute('EXEC '+name+' @QueryEmbeddingJson=?, @MaxDistance=0.70;',vector)
            rows=[tuple(row) for row in cursor.fetchall()]
            elapsed=(time.perf_counter()-start)*1000
            if measure:
                timings[name].append(elapsed)
                messages[name].extend(str(message) for message in cursor.messages)
            cursor.close()
            return rows
        for _ in range(3):
            expected=run(names[0]); assert expected==run(names[1])
        connection.execute('EXEC sys.sp_query_store_flush_db;')
        before={name:snapshot(connection,name) for name in names}
        connection.execute('SET STATISTICS IO ON; SET STATISTICS TIME ON;')
        for repeat in range(30):
            order=names if repeat%2==0 else names[::-1]
            results={name:run(name,True) for name in order}
            assert results[names[0]]==results[names[1]],'Diferencia de resultados'
        connection.execute('SET STATISTICS IO OFF; SET STATISTICS TIME OFF;')
        connection.execute('EXEC sys.sp_query_store_flush_db;')
        after={name:snapshot(connection,name) for name in names}
        plans=[]
        for name in names:
            rows=connection.execute('''SELECT q.query_id,p.plan_id,p.query_plan FROM sys.query_store_query q
            JOIN sys.query_store_plan p ON p.query_id=q.query_id WHERE q.object_id=OBJECT_ID(?)''',name).fetchall()
            for row in rows:
                plans.append({'procedure':name,'queryId':row[0],'planId':row[1],'xml':row[2]})
    summary={}
    for name in names:
        delta=[b-a for a,b in zip(before[name],after[name])]
        summary[name]={'calls':len(timings[name]),'medianRoundTripMs':round(statistics.median(timings[name]),3),
                       'meanRoundTripMs':round(statistics.mean(timings[name]),3),
                       'sqlDurationMsPerCall':round(delta[1]/1000/30,3),
                       'sqlCpuMsPerCall':round(delta[2]/1000/30,3),
                       'logicalReadsPerCall':round(delta[3]/30,3),
                       'capturedStatementExecutions':delta[0]}
    data={'timestamp':datetime.now(timezone.utc).isoformat(),'courses':counts[0],
          'method':'30 paired calls, 3 warm-ups, alternate order, same vector and filters; embeddings excluded. Query Store totals are deltas for each procedure object_id, summed across internal statements.',
          'summary':summary,'rawRoundTripMs':timings,'statisticsMessages':messages,'plans':plans}
    folder=ROOT/'docs'/'evidence';folder.mkdir(parents=True,exist_ok=True)
    (folder/'optimization.json').write_text(json.dumps(data,ensure_ascii=False,indent=2,default=str),encoding='utf-8')
    print(json.dumps(summary,indent=2),flush=True)

if __name__=='__main__': main()
