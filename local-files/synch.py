#!/usr/bin/env python

import sys
import time
import ediarum

source_username=sys.argv[1]
source_password=sys.argv[2]
source_server=sys.argv[3]
source_resource=sys.argv[4]
target_username=sys.argv[5]
target_password=sys.argv[6]
target_server=sys.argv[7]
target_resource=sys.argv[8]

sys.stdout = open('synch.log', 'w')

print time.asctime( time.localtime(time.time()) )

target_connection = {
    'username':target_username,
    'password':target_password,
    'server':target_server
    }

source_connection = {
    'username':source_username,
    'password':source_password,
    'server':source_server
    }

def synch_collections(source_connection, source_collection, target_connection, target_collection):
    ediarum.delete_file(target_connection, target_collection)
    resources = ediarum.get_filenames_in_collection(source_connection, source_collection)
    for resource in resources:
        file = ediarum.get_file(source_connection, '{}/{}'.format(source_collection, resource))
        if file:
            ediarum.put_file(target_connection, '{}/{}'.format(target_collection, resource), file)

synch_collections(source_connection, source_resource,
                  target_connection, target_resource)
