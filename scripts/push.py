#! /usr/bin/env python3

#
# This script sends a push notification using Firebase Admin SDK.
# Modify it to suit your needs.
#
# # Prerequisites
# 
# * Install the Firebase Admin SDK and the dotenv
# 
#     pip3 install --user firebase-admin python-dotenv
#
# Usage:
# * Environment variables are auto-loaded from the '.env.default' file
#   * FIREBASE_CONFIG - Private key file generated using Firebase Console's Service Accounts
#   (see https://firebase.google.com/docs/admin/setup)
#   
# * Arguments:
#   * -t, --token FCM_TOKEN - FCM token of the device
#   * -c, --config CONFIG_PATH - override the FIREBASE_CONFIG environment variable
# 
# # Documentation
# * Firebase Admin SDK: https://firebase.google.com/docs/reference/admin/python/firebase_admin.messaging
# * APNS headers: https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1
# * Payload keys: https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW1
# * Mutable notifications: https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/ModifyingNotifications.html

import os
from dotenv import load_dotenv
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, messaging
import argparse

# Command line arguments parsing
parser = argparse.ArgumentParser()
parser.add_argument('-t', '--token', help='Push token of a device', required=True)
parser.add_argument('-c', '--config', help='Firebase private key file path', required=False)
args = parser.parse_args()

# Environment variables loading from config
load_dotenv(dotenv_path=Path('.') / '.env.default')

# Initialize firebase SDK
firebase_private_key_file_path=args.config or os.getenv('FIREBASE_CONFIG')
device_fcm_token=args.token
app_credentials = credentials.Certificate(firebase_private_key_file_path)
default_app = firebase_admin.initialize_app(app_credentials)

message = messaging.Message(
    apns=messaging.APNSConfig(
        headers={'apns-priority': '10'}, # 10 - immediate send
        payload=messaging.APNSPayload(
            aps=messaging.Aps(
                alert=messaging.ApsAlert(
                    title_loc_key='sign_transaction_request_title',
                ),
                mutable_content=True,
                badge=1,
                sound='default'
            )
        )
    ),
    data={'type': 'sendTransaction'},
    token=device_fcm_token
)

message_id = messaging.send(message, app=default_app)
print('Message id:', message_id)
