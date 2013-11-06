
CREATE EXTENSION IF NOT EXISTS hstore;

CREATE OR REPLACE VIEW instance_expanded AS
WITH
  fancy_tag AS
  ( SELECT instance, hstore(array_agg(tag), array_agg(value)) AS tags
      FROM instance_tag GROUP BY instance ),
  fancy_net AS
  ( SELECT instance,
           hstore(net) - text('instance') -
           hstore('pub_ip=>NULL,priv_ip=>NULL,pub_dns=>NULL,priv_dns=>NULL')
           AS net
      FROM net )
SELECT instance.*, COALESCE(tags, hstore('')) AS tags,
                   COALESCE(net, hstore('')) AS net
  FROM instance LEFT JOIN fancy_tag USING (instance)
                LEFT JOIN fancy_net USING (instance);

CREATE OR REPLACE VIEW volume_expanded AS
WITH
  fancy_tag AS
  ( SELECT volume, hstore(array_agg(tag), array_agg(value)) AS tags
      FROM volume_tag GROUP BY volume )
SELECT volume.*, instance, device,
                 COALESCE(root_device = device, FALSE) AS root,
                 COALESCE(tags, hstore('')) AS tags
  FROM volume LEFT JOIN fancy_tag USING (volume)
              LEFT JOIN attachment USING (volume)
              LEFT JOIN instance USING (instance);

CREATE OR REPLACE VIEW snapshot_expanded AS
WITH
  fancy_tag AS
  ( SELECT snapshot, hstore(array_agg(tag), array_agg(value)) AS tags
      FROM snapshot_tag GROUP BY snapshot )
SELECT snapshot.*, COALESCE(tags, hstore('')) AS tags
  FROM snapshot LEFT JOIN fancy_tag USING (snapshot);

CREATE OR REPLACE VIEW tags AS
SELECT instance AS entity, hstore(array_agg(tag), array_agg(value)) AS tags
  FROM instance_tag GROUP BY instance
 UNION
SELECT volume AS entity, hstore(array_agg(tag), array_agg(value)) AS tags
  FROM volume_tag GROUP BY volume
 UNION
SELECT snapshot AS entity, hstore(array_agg(tag), array_agg(value)) AS tags
  FROM snapshot_tag GROUP BY snapshot;
