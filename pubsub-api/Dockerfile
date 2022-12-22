FROM python:3.8-slim

COPY . .

RUN pip install -r requirements.txt \
    && pip install --upgrade google-cloud-storage \
    && pip install --upgrade google-cloud-pubsub

EXPOSE 8000

CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:8000"]