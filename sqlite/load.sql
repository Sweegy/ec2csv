
.read sqlite/schema.sql

.mode csv
.import sample/instance.csv instance
.import sample/volume.csv volume
.import sample/snapshot.csv snapshot
.import sample/instance_tag.csv instance_tag
.import sample/volume_tag.csv volume_tag
.import sample/snapshot_tag.csv snapshot_tag
.import sample/attachment.csv attachment
.import sample/sg_membership.csv sg_membership

