import os
import logging
import unittest
from unittest import mock
from test import support

import main


class RestAPIsTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        logging.basicConfig(level=logging.DEBUG)

    def test_ping(self):
        response = main.app.test_client().get("/ping")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)

    def test_bucket_invalid_bucket_name(self):
        with self.assertRaises(ValueError) as e:
            main.app.test_client().get("/bucket")

    @mock.patch.dict(os.environ, {"GCS_BUCKET_NAME": "PROJECT-ID-bucket-api"}, clear=True) 
    def test_bucket_invalid_bucket_name(self):
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 500, 'response : %s' % response.data)

    def test_credential(self):
        print('GOOGLE_APPLICATION_CREDENTIALS: {}'.format(os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')))