import os
import logging
import unittest
from unittest import mock
from test import support

import main


class RestAPIsTestCase(unittest.TestCase):

    def test_ping(self):
        response = main.app.test_client().get("/ping")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)

    def test_bucket_invalid_bucket_name(self):
        """ GCS_BUCKET_NAME is None """
        with self.assertRaises(ValueError):
            main.app.test_client().get("/bucket")

    @mock.patch.dict(os.environ, {"GCS_BUCKET_NAME": "PROJECT-ID-bucket-api"}, clear=True) 
    def test_bucket_invalid_bucket_name(self):
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 500, 'response : %s' % response.data)