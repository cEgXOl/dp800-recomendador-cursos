"""Reproduce the project in a separate local database; existing databases are never dropped."""
import os
from pathlib import Path
import subprocess
import sys
from setup_database import connection_string

ROOT=Path(__file__).resolve().parents[1]
environment=os.environ.copy()
environment['COURSE_RECOMMENDER_SQL_CONNECTION_STRING']=connection_string('CourseRecommender_Repro')
environment['PYTHONIOENCODING']='utf-8'
commands=[['scripts/setup_database.py','--database','CourseRecommender_Repro','--security-tests'],
          ['scripts/generate_embeddings.py'],
          ['scripts/validate_project.py','--skip-rag','--output','reproduction-validation.json']]
for command in commands:
    subprocess.run([sys.executable,'-u',*command],cwd=ROOT,env=environment,check=True)
print('Reproduccion completa en CourseRecommender_Repro. No se ha borrado ninguna base.')
