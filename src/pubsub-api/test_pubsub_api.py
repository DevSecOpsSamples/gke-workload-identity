import os
import unittest
from unittest import mock

import pubsub_api_main as main


class PubSubAPITestCase(unittest.TestCase):

    def test_root(self):
        response = main.app.test_client().get("/")
        self.assertEqual(response.status_code, 200)

    def test_ping(self):
        response = main.app.test_client().get("/ping")
        self.assertEqual(response.status_code, 200)

    @mock.patch.dict(os.environ, {}, clear=True)
    def test_bucket_invalid_bucket_name(self):
        with self.assertRaises(ValueError):
            main.bucket()

    @mock.patch.dict(os.environ, {"GCS_BUCKET_NAME": "invalid-bucket-api"}, clear=True)
    def test_invalid_bucket_name(self):
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 500, 'response : %s' % response.data)

    def test_bucket(self):
        """
        configurations in pytest.ini
        env =
            D:GOOGLE_APPLICATION_CREDENTIALS=.sa
            D:GCS_BUCKET_NAME={PROJECT_ID}-bucket-api
        """
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)