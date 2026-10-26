"""Create/update the local database without dropping existing data. SQL batches use GO."""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import re
import pyodbc

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONNECTION = 'Driver={ODBC Driver 18 for SQL Server};Server=localhost\\SQLEXPRESS;Database=CourseRecommender;Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;'

def connection_string(database: str | None = None) -> str:
    value = os.getenv('COURSE_RECOMMENDER_SQL_CONNECTION_STRING', DEFAULT_CONNECTION)
    if database:
        value = re.sub(r'(?i)(Database|Initial Catalog)=[^;]*', 'Database='+database, value)
    return value

def batches(source: str) -> list[str]:
    return [part.strip() for part in re.split(r'^\s*GO\s*$', source, flags=re.M|re.I) if part.strip()]

def execute_file(connection, path: Path) -> list[dict]:
    output = []
    for batch in batches(path.read_text(encoding='utf-8-sig')):
        cursor = connection.cursor()
        try:
            cursor.execute(batch)
            while True:
                if cursor.description:
                    columns = [col[0] for col in cursor.description]
                    output.append({'columns': columns, 'rows': [list(row) for row in cursor.fetchall()]})
                if not cursor.nextset():
                    break
        finally:
            cursor.close()
    return output

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--database',default='CourseRecommender')
    parser.add_argument('--security-tests',action='store_true')
    args=parser.parse_args()
    if not re.fullmatch(r'[A-Za-z][A-Za-z0-9_]{0,100}',args.database):
        parser.error('Nombre de base no valido')
    with pyodbc.connect(connection_string('master'),autocommit=True,timeout=10) as connection:
        if connection.cursor().execute('SELECT DB_ID(?)',args.database).fetchone()[0] is None:
            connection.execute('CREATE DATABASE ['+args.database+']')
    names=['01_schema.sql','02_seed_catalog.sql','03_add_embedding_storage.sql','06_expand_catalog_scale_test.sql','07_programmability.sql','08_security.sql','10_benchmark_baseline.sql']
    if args.security_tests:
        names.append('09_security_tests.sql')
    records=[]
    with pyodbc.connect(connection_string(args.database),autocommit=True,timeout=10) as connection:
        for name in names:
            path=ROOT/'sql'/name
            if path.exists():
                data=execute_file(connection,path)
                records.append({'file':name,'results':data})
                print(name, 'OK', flush=True)
    folder=ROOT/'docs'/'evidence'
    folder.mkdir(parents=True,exist_ok=True)
    (folder/('setup-'+args.database+'.json')).write_text(json.dumps(records,ensure_ascii=False,indent=2,default=str),encoding='utf-8')

if __name__=='__main__':
    main()
