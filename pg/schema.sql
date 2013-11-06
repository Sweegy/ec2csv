
CREATE TABLE IF NOT EXISTS instance
( instance      text PRIMARY KEY,
  launch_time   timestamptz,
  az            text,
  ssh_key       text,
  root_device   text,
  ami           text,
  aki           text,
  type          text,
  arch          text,
  state         text );

CREATE TABLE IF NOT EXISTS volume
( volume        text PRIMARY KEY,
  create_time   timestamptz,
  size          integer,
  az            text,
  snapshot      text,
  state         text );

CREATE TABLE IF NOT EXISTS snapshot
( snapshot      text PRIMARY KEY,
  start_time    timestamptz,
  size          integer,
  volume        text,
  state         text,
  progress      text,
  description   text,
  owner         text );

CREATE TABLE IF NOT EXISTS instance_tag
( instance      text REFERENCES instance,
  tag           text,
  value         text );

CREATE TABLE IF NOT EXISTS volume_tag
( volume        text REFERENCES volume,
  tag           text,
  value         text );

CREATE TABLE IF NOT EXISTS snapshot_tag
( snapshot      text REFERENCES snapshot,
  tag           text,
  value         text );

CREATE TABLE IF NOT EXISTS attachment
( device        text,
  instance      text REFERENCES instance,
  volume        text REFERENCES volume,
  attach_time   timestamptz,
  state         text,
  remove_on_termination boolean );

CREATE TABLE IF NOT EXISTS sg_membership
( instance      text REFERENCES instance,
  sg            text,
  name          text );

CREATE TABLE IF NOT EXISTS net
( instance      text REFERENCES instance,
  pub_ip        inet,
  priv_ip       inet,
  pub_dns       text,
  priv_dns      text );

