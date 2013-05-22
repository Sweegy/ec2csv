
CREATE SCHEMA ec2;
SET search_path TO ec2, "$user", public, pg_temp;

CREATE TABLE instance
( instance      text PRIMARY KEY,
  t             timestamptz NOT NULL DEFAULT now(),
  az            text NOT NULL,
  ssh_key       text NOT NULL,
  root          text NOT NULL,
  ami           text NOT NULL,
  aki           text NOT NULL,
  type          text NOT NULL,
  arch          text NOT NULL,
  pub_ip        inet NOT NULL,
  priv_ip       inet NOT NULL,
  state         text NOT NULL );

CREATE TABLE volume
( volume        text PRIMARY KEY,
  t             timestamptz NOT NULL DEFAULT now(),
  size          integer NOT NULL,
  az            text NOT NULL,
  snapshot      text NOT NULL,
  state         text NOT NULL );

CREATE TABLE snapshot
( snapshot      text PRIMARY KEY,
  t             timestamptz NOT NULL DEFAULT now(),
  size          integer NOT NULL,
  volume        text NOT NULL,
  state         text NOT NULL,
  progress      text NOT NULL,
  description   text NOT NULL,
  owner         text NOT NULL );

CREATE TABLE instance_tag
( instance      text NOT NULL REFERENCES instance(instance),
  tag           text NOT NULL,
  value         text NOT NULL );

CREATE TABLE volume_tag
( volume        text NOT NULL REFERENCES volume(volume),
  tag           text NOT NULL,
  value         text NOT NULL );

CREATE TABLE snapshot_tag
( snapshot      text NOT NULL REFERENCES snapshot(snapshot),
  tag           text NOT NULL,
  value         text NOT NULL );

CREATE TABLE attachment
( dev           text NOT NULL,
  instance      text NOT NULL REFERENCES instance(instance),
  volume        text NOT NULL REFERENCES volume(volume),
  t             timestamptz NOT NULL DEFAULT now(),
  state         text NOT NULL,
  term_del      boolean NOT NULL );

CREATE TABLE sg_membership
( instance      text NOT NULL REFERENCES instance(instance),
  sg            text NOT NULL,
  name          text NOT NULL );

