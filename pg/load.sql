
\i pg/schema.sql

\copy instance from sample/instance.csv csv
\copy volume from sample/volume.csv csv
\copy snapshot from sample/snapshot.csv csv
\copy instance_tag from sample/instance_tag.csv csv
\copy volume_tag from sample/volume_tag.csv csv
\copy snapshot_tag from sample/snapshot_tag.csv csv
\copy attachment from sample/attachment.csv csv
\copy sg_membership from sample/sg_membership.csv csv

