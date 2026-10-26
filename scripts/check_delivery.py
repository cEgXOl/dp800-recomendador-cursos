"""Offline integrity checks for the handoff; no SQL Server or LLM calls."""
import ast
import json
from pathlib import Path
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[1]
files=subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0')
secret=re.compile(r'gh[pousr]_[A-Za-z0-9]{25,}|github_pat_[A-Za-z0-9_]{25,}')
for name in filter(None,set(files)):
    path=ROOT/name
    if path.suffix in {'.py','.sql','.md','.json','.txt','.ps1','.html','.mjs','.cjs'}:
        source=path.read_text(encoding='utf-8-sig')
        assert not secret.search(source),'Posible token en '+name
        if path.suffix=='.py': ast.parse(source,filename=name)
with zipfile.ZipFile(ROOT/'presentation'/'dp800-project.pptx') as package:
    names=package.namelist()
    slides=[n for n in names if re.fullmatch(r'ppt/slides/slide\d+\.xml',n)]
    assert len(slides)==8
    media=[n for n in names if n.startswith('ppt/media/')]
    assert len(media)>=3 and all(package.getinfo(n).file_size>100 for n in media),'Imagen vacía'
assert (ROOT/'output'/'pdf'/'informe-dp800.pdf').read_bytes().startswith(b'%PDF-')
for name in ('validation.json','reproduction-validation.json'):
    evidence=json.loads((ROOT/'docs'/'evidence'/name).read_text(encoding='utf-8'))
    assert evidence['catalog']=={'courses':131,'pendingEmbeddings':0}
    assert len(evidence['cases'])==8
record=json.loads((ROOT/'docs'/'evidence'/'validation.json').read_text(encoding='utf-8'))
assert len(record['rag'])==3 and record['rag'][0]['generated']
assert not record['rag'][1]['generated'] and not record['rag'][2]['generated']
http=json.loads((ROOT/'docs'/'evidence'/'http-validation.json').read_text(encoding='utf-8'))
assert http['search'] and http['rag'] and not http['browserErrors']
print('Entrega: sintaxis, evidencias, PDF y PPTX con imagenes incrustadas OK.')
