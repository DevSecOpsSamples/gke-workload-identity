import os
from flask import Flask
from flask import request
from flask import json
from flask_wtf.csrf import CSRFProtect
from werkzeug.exceptions import HTTPException

from google.cloud import storage

app = Flask(__name__)
csrf = CSRFProtect()
csrf.init_app(app)

@app.route("/")
def ping_root():
    return ping()

@app.route("/<string:path1>")
def ping_path1(path1):
    return ping()

def ping():
    return {
        "host": request.host,
        "url": request.url,
        "method": request.method,
        "message": "bucket-api"
    }

@app.route("/bucket")
def bucket():
    bucket_name = os.getenv('GCS_BUCKET_NAME')
    if bucket_name == None:
        for k, v in os.environ.items():
            print(f'{k}={v}')
        raise ValueError('Invalid BUCKET_NAME enrironment variable')
    return write_read(bucket_name, 'put-test.txt')

def write_read(bucket_name, blob_name):
    response = ""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    with blob.open("w") as f:
        f.write("read/write test, bucket: " + bucket_name)

    with blob.open("r") as f:
        response = f.read()

    return {
        "bucket_name": bucket_name,
        "blob_name": blob_name,
        "response": response
    }

@app.errorhandler(HTTPException)
def handle_exception(e):
    response = e.get_response()
    response.data = json.dumps({
        "code": e.code,
        "name": e.name,
        "description": e.description,
        
    })
    response.content_type = "application/json"
    return response

if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0', port=8000)
