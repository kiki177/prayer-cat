"""Build-time model download. Runtime downloads are implemented natively in the app."""
import hashlib,json,pathlib,subprocess,sys
root=pathlib.Path(__file__).resolve().parent.parent
model=json.loads((root/'Models.json').read_text())[0]
target=pathlib.Path(sys.argv[1] if len(sys.argv)>1 else root/'build/models'/model['filename']).resolve()
target.parent.mkdir(parents=True,exist_ok=True)
part=target.with_suffix('.download')
subprocess.run(['curl','--fail','--location','--proto','=https','--proto-redir','=https','--retry','3','--max-time','3600',model['url'],'-o',str(part)],check=True)
with part.open('rb') as stream: digest=hashlib.file_digest(stream,'sha256').hexdigest()
if part.stat().st_size!=model['size'] or digest!=model['sha256']:
    raise SystemExit('Model verification failed; refusing to package it')
part.replace(target)
print(target)
