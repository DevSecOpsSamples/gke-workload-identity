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

    @mock.patch.dict(os.environ, {"GCS_BUCKET_NAME": "project-id-bucket-api"}, clear=True)
    def test_env(self):
        self.assertEqual(os.environ.get("GCS_BUCKET_NAME"), "project-id-bucket-api")

    @mock.patch.dict(os.environ, {}, clear=True)
    def test_bucket_invalid_bucket_name(self):
        with self.assertRaises(ValueError):
            main.bucket

    def test_buckets(self):
        response = main.app.test_client().get("/buckets")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)

    def test_bucket(self):
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)
