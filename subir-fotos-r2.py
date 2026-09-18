import json
import mimetypes
import pathlib
import sys

# Lee claves de r2-config.json (al lado de este script). No se sube a git.
BASE = pathlib.Path(__file__).resolve().parent
CFG_PATH = BASE / "r2-config.json"
SRC = BASE / "nuevas-fotos"

if not CFG_PATH.exists():
    print("Falta r2-config.json. Copia r2-config.ejemplo.json a r2-config.json y completa tus claves.")
    sys.exit(1)
cfg = json.loads(CFG_PATH.read_text(encoding="utf-8"))
ACCOUNT = cfg["account_id"]
KEY = cfg["access_key_id"]
SECRET = cfg["secret_access_key"]
BUCKET = cfg.get("bucket", "fotos")
PUBLIC_URL = cfg.get("public_url", "").rstrip("/")
FORZAR = "--forzar" in sys.argv

import boto3
from botocore.config import Config

ENDPOINT = f"https://{ACCOUNT}.r2.cloudflarestorage.com"
s3 = boto3.client(
    "s3", endpoint_url=ENDPOINT, aws_access_key_id=KEY,
    aws_secret_access_key=SECRET, region_name="auto",
    config=Config(signature_version="s3v4", connect_timeout=10, read_timeout=60, retries={"max_attempts": 3}),
)

if not SRC.exists():
    SRC.mkdir(parents=True, exist_ok=True)
    print(f"Carpeta creada: {SRC}. Pon tus fotos adentro replicando la ruta, ej: nuevas-fotos/productos/Limpieza/foto.jpg")
    sys.exit(0)

locales = {f.relative_to(SRC).as_posix(): f for f in SRC.rglob("*") if f.is_file()}
if not locales:
    print("No hay archivos en nuevas-fotos. Copia ahi tus fotos y corre de nuevo.")
    sys.exit(0)
print(f"Archivos locales: {len(locales)}")

remotas = set()
token = None
while True:
    kw = {"Bucket": BUCKET, "MaxKeys": 1000}
    if token:
        kw["ContinuationToken"] = token
    r = s3.list_objects_v2(**kw)
    for o in r.get("Contents", []):
        remotas.add(o["Key"])
    if not r.get("IsTruncated"):
        break
    token = r.get("NextContinuationToken")

ok = omit = fail = 0
for i, key in enumerate(sorted(locales), 1):
    f = locales[key]
    if key in remotas and not FORZAR:
        omit += 1
        continue
    ctype, _ = mimetypes.guess_type(f.name)
    if not ctype:
        ctype = "image/jpeg"
    try:
        s3.upload_file(str(f), BUCKET, key, ExtraArgs={"ContentType": ctype})
        ok += 1
        print(f"SUBIDA {i}/{len(locales)} {key}")
        if PUBLIC_URL:
            print(f"  URL: {PUBLIC_URL}/{key}")
    except Exception as e:
        fail += 1
        print(f"FALLO {key}: {e}")
print(f"LISTO subidas={ok} omitidas(ya estaban)={omit} fallos={fail}")
print("Siguiente: agrega la tarjeta del producto en index.html con esa URL, corre generate-share-pages.ps1, commit y push.")
