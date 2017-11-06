#!/usr/bin/python

import httplib
import sys
import base64
from lxml import etree
from string import rfind

def sendHTTP(session,request,resource,length,content):
    server = session['server']
    con = httplib.HTTPConnection(server)
    con.putrequest(request, '/exist/rest/%s' % resource)
    con.putheader('User-Agent', 'Python http auth')
    con.putheader('Content-Type', 'application/xml')
    con.putheader('Content-Length', `length`)

    username = session['username']
    password = session['password']
    # base64 encode the username and password
    auth = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')

    con.putheader('Authorization', 'Basic %s' % auth)
    con.endheaders()
    con.send(content)

    r = con.getresponse()

    if not(r.status in (200,201)):
        print 'An error occurred: %s %s' % (r.status, r.reason)
        return 0
    else:
        print "Ok."
        return r

def delete_file(session, resource):
    print "deleting %s ..." % resource,
    sendHTTP(session,'DELETE',resource,0,'')

def put_file(session, resource, content):
    print "storing %s ..." % resource,
    clen = len(content)
    sendHTTP(session,'PUT',resource,clen,content)

def get_file(session, resource):
    print "getting %s ..." % resource,
    response = sendHTTP(session, 'GET', resource, 0, '')
    if response:
        data = response.read()
        return data
    else:
        return 0

def get_filenames_in_collection(session, collection, current_collection=''):
    filenames = []
    if current_collection:
        print "read %s/%s ... " % (collection, current_collection),
        response = sendHTTP(session, 'GET', '{}/{}'.format(collection,current_collection), 0, '')
    else:
        print "read %s ... " % collection,
        response = sendHTTP(session, 'GET', '{}'.format(collection), 0, '')
    if response:
        data = response.read()
        root = etree.fromstring(data)
        child_resources = root.xpath('/exist:result/exist:collection/exist:resource',namespaces={'exist': 'http://exist.sourceforge.net/NS/exist'})
        for child_resource in child_resources:
            if current_collection:
                resource_name = '{}/{}'.format(current_collection,child_resource.attrib['name'])
            else:
                resource_name = '{}'.format(child_resource.attrib['name'])
            filenames += [resource_name]
        child_collections = root.xpath('/exist:result/exist:collection/exist:collection',namespaces={'exist': 'http://exist.sourceforge.net/NS/exist'})
        for child_collection in child_collections:
            if current_collection:
                child_collection_name = '{}/{}'.format(current_collection,child_collection.attrib['name'])
            else:
                child_collection_name = '{}'.format(child_collection.attrib['name'])
            filenames += get_filenames_in_collection(session,collection,child_collection_name)
    return filenames
