cl-nebula-www

This is the HTTP frontend for Nebula. It requires nebula[1], and the
nebula setup must be complete (namely, database setup and creating the
credentials file). For more information about Nebula, see [2].

[1] https://github.com/kisom/nebula
[2] https://kyleisom.net/blog/2015/04/07/nebula/

Endpoints
=========

The examples here assume a file server running on localhost.

Upload new blob
---------------

   POST /entry

   This takes a "file" parameter; right now this is due to a
   limitation in my understanding of how Clojure's web libraries work.
   Eventually, this will be the request body and not a form.

   $ cat file.txt
   *** Hello, world.
   $ curl --data-binary @file.txt localhost:3000/entry

   The endpoint will return the UUID of the file entry if the blob was
   uploaded successfully. This UUID is the only way for the user to
   access the file.

Retrieve a blob
---------------

  GET /entry/:uuid

  This retrieves the blob referenced by UUID, if such an entry
  exists. For example, if the upload returned the UUID
  2181203d-7c99-4cf3-8461-f0702565819b,

  $ curl localhost:3000/entry/2181203d-7c99-4cf3-8461-f0702565819b
  *** Hello, world

  would return the contents of the file.

  Files are currently returned as application/octet-stream right
  now. Some thought needs to be given to MIME-type handling (or
  whether that's something the file server needs to worry about.

Update a blob
-------------

   POST /entry/:uuid

   This uploads a new blob, signifying that it is a modified version
   of the entry referenced by the UUID. This will upload the new blob
   and set its parent to UUID.

   $ cat file.txt
   *** Hello, world!
   $ curl -X POST --data-binary @file.txt \
         localhost:3000/entry/32805045-857e-451f-bf8a-f32199376a3f
   32805045-857e-451f-bf8a-f32199376a3f

   On success, it will return the UUID for the child entry.

Proxy an entry
--------------

   GET /entry/:uuid/proxy

   This creates a proxied file entry: it can be shared to other
   users. When access by those users should then be restricted, this
   proxy entry can be deleted without removing the owner's access to
   the file.

   $ curl localhost:3000/entry/32805045-857e-451f-bf8a-f32199376a3f/proxy
   9b894ab7-0a16-44be-851f-74e6524ca575

   On success, it returns the UUID for the proxy entry.

Delete an entry
---------------

   DELETE /entry/:uuid

   This removes the UUID referenced by UUID. Garbage collection is done to
   remove any stale references or orphaned proxy entries.

   $ curl -X DELETE localhost:3000/entry/9b894ab7-0a16-44be-851f-74e6524ca575
   OK

Retrieve entry information
--------------------------

   GET /entry/:uuid/info

   This retrieves information about an entry as a JSON-encoded dictionary.

   $ curl localhost:3000/entry/9b894ab7-0a16-44be-851f-74e6524ca575/info
   {
       "children": null,
       "id": "9b894ab7-0a16-44be-851f-74e6524ca575",
       "metadata": {
	   "created": 1426799481
       },
       "parent": null
   }

Retrieve entry lineage
----------------------

   GET /entry/:uuid/lineage

   A lineage is the set of entries representing a succession of parent
   entries. The first entry is the UUID requested; what follows is a list
   of parents.

   Consider the following sequence:
   + A file is uploaded and assigned the ID 53ca9f30-4de6-4661-9e5a-
     e57bc78a873a
   + The file is changed and POSTed to
     /entry/53ca9f30-4de6-4661-9e5a-e57bc78a873a, returning the UUID
     9cb205d0-e7e5-4b14-9307-5ab70841786d
   + The file is changed again, and POSTed to
     /entry/9cb205d0-e7e5-4b14-9307-5ab70841786d returning the UUID
     6c7328cd-a7f1-4b90-8b08-d3d59b40df8f

   The following example demonstrates returning the file's lineage:

   $ curl localhost:3000/entry/6c7328cd-a7f1-4b90-8b08-d3d59b40df8f/lineage
   ["6c7328cd-a7f1-4b90-8b08-d3d59b40df8f"
   ,"9cb205d0-e7e5-4b14-9307-5ab70841786d"
   ,"53ca9f30-4de6-4661-9e5a-e57bc78a873a"]




