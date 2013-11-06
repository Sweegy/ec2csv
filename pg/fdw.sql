
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER csv FOREIGN DATA WRAPPER file_fdw;

\set dir `pwd -P`/sample

CREATE FOREIGN TABLE IF NOT EXISTS instance
( instance      text,
  launch_time   timestamptz,
  az            text,
  ssh_key       text,
  root_device   text,
  ami           text,
  aki           text,
  type          text,
  arch          text,
  state         text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/instance.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS volume
( volume        text,
  create_time   timestamptz,
  size          integer,
  az            text,
  snapshot      text,
  state         text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/volume.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS snapshot
( snapshot      text,
  start_time    timestamptz,
  size          integer,
  volume        text,
  state         text,
  progress      text,
  description   text,
  owner         text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/snapshot.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS instance_tag
( instance      text,
  tag           text,
  value         text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/instance_tag.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS volume_tag
( volume        text,
  tag           text,
  value         text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/volume_tag.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS snapshot_tag
( snapshot      text,
  tag           text,
  value         text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/snapshot_tag.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS attachment
( device        text,
  instance      text,
  volume        text,
  attach_time   timestamptz,
  state         text,
  remove_on_termination boolean )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/attachment.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS sg_membership
( instance      text,
  sg            text,
  name          text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/sg_membership.csv' );

CREATE FOREIGN TABLE IF NOT EXISTS net
( instance      text,
  pub_ip        inet,
  priv_ip       inet,
  pub_dns       text,
  priv_dns      text )
SERVER csv
OPTIONS ( format 'csv', filename :'dir' -- Newline is mandatory here :)
                                 '/net.csv' );

