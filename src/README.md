# Python Unittest

```bash
├── gradlew
├── gradlew.bat
├── pytest.ini
├── requirements.txt
├── src
│   ├── README.md
│   ├── all-commands.sh
│   ├── bucket-api
│   │   ├── Dockerfile
│   │   ├── README.md
│   │   ├── bucket-api-template.yaml
│   │   ├── deploy.sh
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── tests
│   │   │   └── test_bucket_api.py
│   │   ├── upload-test.txt
│   ├── pubsub-api
│   │   ├── Dockerfile
│   │   ├── deploy.sh
│   │   ├── pubsub-api-template.yaml
│   │   ├── pubsub_api_main.py
│   │   ├── requirements.txt
│   │   └── test_pubsub_api.py
```

```bash
PROJECT_ID="<your-project-id>"
pytest
# or gradle test

gladle clean
```

[src/pytest.ini](../pytest.ini)

`GOOGLE_APPLICATION_CREDENTIALS`, `GCS_BUCKET_NAME`, and `GOOGLE_CLOUD_PROJECT` environment variables are used with default('D:') option in pytest.
So if you want to test in src/bucket-api or src/pubsub-api path, `.sa` file should be created in each foler.

```ini
[pytest]
log_cli=True
log_cli_level=DEBUG
; --html=report.html options is 'pip install pytest-html'
addopts=--failed-first --cov=src/bucket-api --cov=src/pubsub-api --junit-xml=build/test-result.xml --html=build/test-report.html --cov-report=xml:build/test-coverage.xml 
junit_family=legacy
; --cov-branch 
; norecursedirs=.pyenv-python
env =
    D:GOOGLE_APPLICATION_CREDENTIALS=.sa
    D:GCS_BUCKET_NAME={PROJECT_ID}-bucket-api
    D:GOOGLE_CLOUD_PROJECT={PROJECT_ID}
```
