import os
from flask import Flask
from flask import request
from flask import json
from flask_wtf.csrf import CSRFProtect
from werkzeug.exceptions import HTTPException

from google.cloud import storage
from google.cloud import pubsub_v1
from google.api_core import retry

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
        "message": "pubsub-api"
    }


@app.route("/bucket")
def bucket():
    bucket_name = os.getenv('GCS_BUCKET_NAME', '')
    if bucket_name == '':
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


@app.route("/pub")
def pub():
    publisher = pubsub_v1.PublisherClient()
    topic_name = 'projects/{project_id}/topics/{topic}'.format(
        project_id=os.getenv('GOOGLE_CLOUD_PROJECT'),
        topic='echo'
    )
    future = publisher.publish(topic_name, b'My first message!', spam='eggs')
    return {
        "topic_name": topic_name,
        "result": future.result()
    }


@app.route("/sub")
def sub():
    topic_name = 'projects/{project_id}/topics/{topic}'.format(
        project_id=os.getenv('GOOGLE_CLOUD_PROJECT'),
        topic='echo'
    )
    subscription_path = 'projects/{project_id}/subscriptions/{sub}'.format(
        project_id=os.getenv('GOOGLE_CLOUD_PROJECT'),
        sub='echo-read'
    )
    NUM_MESSAGES = 100

    subscriber = pubsub_v1.SubscriberClient()
    with subscriber:
        response = subscriber.pull(
            request={"subscription": subscription_path, "max_messages": NUM_MESSAGES},
            retry=retry.Retry(deadline=10),
        )
        if len(response.received_messages) == 0:
            return

        ack_ids = []
        for received_message in response.received_messages:
            print(f"Received: {received_message.message.data}.")
            ack_ids.append(received_message.ack_id)

        subscriber.acknowledge(request={"subscription": subscription_path, "ack_ids": ack_ids})
    return {
        "topic_name": topic_name,
        "subscription_path": subscription_path,
        "acknowledged": len(response.received_messages)
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

