import os
import unittest
from unittest import mock

import pubsub_api_main as main


class PubSubAPITestCase(unittest.TestCase):

    def test_ping(self):
        response = main.app.test_client().get("/ping")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)

    @mock.patch.dict(os.environ, {}, clear=True)
    def test_bucket_invalid_bucket_name(self):
        with self.assertRaises(ValueError):
            main.bucket()

    def test_bucket(self):
        response = main.app.test_client().get("/bucket")
        self.assertEqual(response.status_code, 200, 'response : %s' % response.data)