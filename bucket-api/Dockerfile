FROM python:3.9-alpine

VOLUME ./:app/

RUN apk add --no-cache --virtual .build-deps g++ python3-dev libffi-dev openssl-dev && \
    apk add --no-cache --update python3 && \
    pip3 install --upgrade pip setuptools

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
RUN pip install --upgrade google-cloud-storage

COPY . /app/

WORKDIR /app

EXPOSE 8000

CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000"]
