import os
import logging
import unittest
from unittest import mock

import main


class RestAPIsTestCase(unittest.TestCase):

    def test_root(self):
        response = main.app.test_client().get("/")
        self.assertEqual(response.status_code, 200)

    def test_ping(self):
        response = main.app.test_client().get("/ping")
        self.assertEqual(response.status_code, 200)

    def test_bucket_invalid_bucket_name(self):
        with self.assertRaises(ValueError):
            main.app.test_client().get("/bucket")

    @mock.patch.dict(os.environ, {"GCS_BUCKET_NAME": "project-id-372417-bucket-api", "GOOGLE_CLOUD_PROJECT":"project-id-372417"}, clear=True) 
    def test_bucket_invalid_bucket_name(self):
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 500, 'response : %s' % response.data)

    @mock.patch.dict(os.environ, {"GCS_BUCKET_NAME": "project-id-372417-bucket-api"}, clear=True)
    def test_env(self):
        self.assertEqual(os.environ.get("GCS_BUCKET_NAME"), "project-id-372417-bucket-api")