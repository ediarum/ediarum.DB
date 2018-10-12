# exist_system/

All files which should go to the system collection (`/db/system/config/`) in the database should be go here, i.e. `collection.xconf` for indexing or trigger purposes.

To enable the automatic uploading via *ANT*, one has to decomment the corresponding lines in `build.xml`. If the collection.xconf should lie in a subcollection it must be named with the path as part of the name (escape the slashes with underscore), e.g. `data_Register_Personen_collection.xconf` goes into the collection `/db/system/config/db/projects/NAME/data/Register/Personen/collection.xconf`.
