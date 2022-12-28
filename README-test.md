# Testing on your desktop with the IAM key

```bash
cd bucket-api
gcloud iam service-accounts keys create --iam-account "bucket-api-sa@${PROJECT_ID}.iam.gserviceaccount.com" .sa
```

```bash
cat .sa
```

```json
{
  "type": "service_account",
  "project_id": "sample-project",
  "private_key_id": "638eb4113abe670b12e556610ae69f20133c6a43",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDTXRd8n5g+CxH/\nvbPFi/fWsasXBBsYWLbugMVBeH799Acgjur7RVFJ2brUMsmGqP1c13rlRviM9JHv\nt2q0aMrYmBqp1mvhs+ZVtX3T5c5nIMoQA4h0aDjaVkOryOwcLLr7Y0ljNaPUnfZQ\n5Ld2M/4UMg7nyAg7OwpB+BZx7EVsSjweRwbBiKdeYYdNZhrZ9DBbmVSRYzSDOGPo\nSPEYMb5Ep3I2JQ+jGodPbD7leIsgEZ24z6u/rme3qSRti9camUw9bSMrznDrFIbt\nCA8oOD9wQeWTvOsMyMo2akzdL8OGrNPOZ4lS+8d8WX4xhkrJ6Tld2irkhZnlmZbo\n0Cu5t1G3AgMBAAECggEABvhRFSB+2Ojs4TCZyYq/Plq3Ms1FXCJXd0+oHEEY0E9o\nSW1nwqfQsZfsU8wQSOWwuTY34hta3exraurIVNuxzhOx/rtzQkr4Q7JLochjFpPb\nu0x1Mara2Rmy0JWRx69n7nCh6RN0lscrahPTbaKdnyqJbaDzOIokC/SI6kfUKukh\nDShwZG+5CcUAUvolz2TkfLk17Tk5S11g97No7ERJPxkUqOH3CvQlN2O5/oMVYy/6\nzFf9L/RXGhkZneXeF8GkMlE44tSicst+LXy+ZmIhDOgiEGNXWGSA2/SufHHyqI14\n82Hx2CGGF8xBKdLsK23Vh7Ar9lQduf0jCW/paHuQHQKBgQD9rGqAPjoKou6bZiC2\nKQP16YugcmhPohA+GN3eVq01fnJbAA/SpepAca2LMfhiegLogMC/58K55Vz8xwug\nuXx1+5RWfHaTOJRC/Y8sv0EfWU8+MVnrBhfu8fM/gejLajn7SE4Y86nkDVwEjZqA\nBDUScnO6wYxX/d5Ts1fnSF8HbQKBgQDVTVbN1lmNc9amLPwieFozL7IPrKdSf6sA\nJulUxf6FaXpbJjcLzO+AZDejWI7MwUxJRMIUf/HzTWg0AmdWi3jNfxj1ROO/XIyq\nt4MBgk+ogWqw9Pc346VvcG01JGu8r7YqxKffl5n2EmBy0eQX4k9fLsvvjd6eTpsP\nQf4ZjhLTMwKBgQCVmC/WINwpmZwMmFWCFv327xsgK1fIXlIlzJRKoeLTQRY/A/JQ\nzvctudwV0gogSMOeSQ9iHFKBPflwOBFrXvc+vHXl6tAiUaNdPhpI0SCeVBSfIIte\nReGnT5ebRAj8rFA1F5a2sDrn+djh9n++Lrz9e/EzmSAiY9vQkFquUcd4oQKBgFBs\nVpxJg35n/LivIWnFwwyloRdz26qpZEosYbGK7YpT2MRhRkP2wx6/qpK2IzFkeGTv\nvdWI4CsCNpXVii0BbUzd7QUdMlnGhWsgwg5hmbNJCHcsBcJW3NuFokd1MgH0plS9\nzSXqvSwghakFJmEy/QZAWLg734IE1UYNdccg4EwtAoGAX6TmcKdDSLR/ZLv/oNAl\nlxekvAWynoYJG0HOIoNQAgKWClk2Gy8Jbe1k40LQXH42YpYZCa77xvuc7J9Vafn9\n4D/WKtfDfhfU++rJjoB3ovqxpj8wANliNEHBGrbr+QnOoHPps9GXrfoHpbpi6U//\nD91JvhalLtm12apw1iCDanM=\n-----END PRIVATE KEY-----\n",
  "client_email": "bucket-api@sample-project.iam.gserviceaccount.com",
  "client_id": "23322106513898897843",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/bucket-api-sa%40sample-project.iam.gserviceaccount.com"
}
```

```bash
pip install -r requirements.txt
pip install --upgrade google-cloud-storage
```

```bash
export GCS_BUCKET_NAME="${PROJECT_ID}-bucket-api"
echo "GCS_BUCKET_NAME: ${GCS_BUCKET_NAME}"
export GOOGLE_APPLICATION_CREDENTIALS=".sa"
cat ${GOOGLE_APPLICATION_CREDENTIALS}
pytest

python3 app.py
```

```bash
 * Serving Flask app 'app' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
 * Running on http://10.243.176.154:8000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 142-743-318
```