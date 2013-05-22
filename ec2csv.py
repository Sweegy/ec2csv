#!/usr/bin/env python
import sys
import os
import json
import csv

from awscli.clidriver import CLIDriver

def _forked(f):
    def _(*args, **kwargs):
        pid = os.fork()
        if pid is 0:
            f(*args, **kwargs)
            sys.exit()
        else:
            return pid
    return _

@_forked
def instances():
    out('instance.json')
    ec2(['describe-instances'])
    instances = []
    tags = []
    security_groups = []
    with open('instance.json') as h:
        for res in json.load(h)['Reservations']:
            for inst in res['Instances']:
                instances.append(( inst['InstanceId'],
                                   inst['LaunchTime'],
                                   inst['Placement']['AvailabilityZone'],
                                   inst['KeyName'],
                                   inst['RootDeviceName'],
                                   inst['ImageId'],
                                   inst['KernelId'],
                                   inst['InstanceType'],
                                   inst['Architecture'],
                                   inst['PublicIpAddress'],
                                   inst['PrivateIpAddress'],
                                   inst['State']['Name'] ))
                for tag in inst.get('Tags', []):
                    tags.append(( inst['InstanceId'],
                                  tag['Key'],
                                  tag['Value'] ))
                for sg in inst.get('SecurityGroups', []):
                    security_groups.append(( inst['InstanceId'],
                                             sg['GroupId'],
                                             sg['GroupName'] ))
    with open('instance.csv', 'wb') as h:
        csv.writer(h).writerows(instances)
    with open('instance_tag.csv', 'wb') as h:
        csv.writer(h).writerows(tags)
    with open('sg_membership.csv', 'wb') as h:
        csv.writer(h).writerows(security_groups)

@_forked
def volumes():
    out('volume.json')
    ec2(['describe-volumes'])
    volumes = []
    attachments = []
    tags = []
    with open('volume.json') as h:
        for vol in json.load(h)['Volumes']:
            volumes.append(( vol['VolumeId'],
                             vol['CreateTime'],
                             vol['AvailabilityZone'],
                             vol['Size'],
                             vol['SnapshotId'],
                             vol['State'] ))
            for att in vol.get('Attachments', []):
                attachments.append(( att['AttachTime'],
                                     att['Device'],
                                     att['InstanceId'],
                                     att['VolumeId'],
                                     att['State'],
                                     att['DeleteOnTermination'] ))
            for tag in vol.get('Tags', []):
                tags.append(( vol['SnapshotId'],
                              tag['Key'],
                              tag['Value'] ))
    with open('volume.csv', 'wb') as h:
        csv.writer(h).writerows(volumes)
    with open('attachment.csv', 'wb') as h:
        csv.writer(h).writerows(attachments)
    with open('volume_tag.csv', 'wb') as h:
        csv.writer(h).writerows(tags)

@_forked
def snapshots(path='snapshot.json'):
    out(path)
    ec2(['describe-snapshots', '--owner-ids', 'self'])
    snapshots = []
    tags = []
    with open(path) as h:
        for snap in json.load(h)['Snapshots']:
            snapshots.append(( snap['SnapshotId'],
                               snap['VolumeSize'],
                               snap['StartTime'],
                               snap['VolumeId'],
                               snap['State'],
                               snap['Progress'],
                               snap['Description'],
                               snap['OwnerId'] ))
            for tag in snap.get('Tags', []):
                tags.append(( snap['SnapshotId'],
                              tag['Key'],
                              tag['Value'] ))
    with open('snapshot.csv', 'wb') as h:
        csv.writer(h).writerows(snapshots)
    with open('snapshot_tag.csv', 'wb') as h:
        csv.writer(h).writerows(tags)

def main():
    for pid in [ instances(), volumes(), snapshots() ]:
        os.waitpid(pid, 0)

def ec2(args):
    d = CLIDriver()
    d.create_main_parser()
    d._parse_args(['ec2'] + args)
    d._call(d.operation_parser.args)
    sys.stdout.flush

def out(f):
    fd = os.open(f, os.O_RDWR | os.O_CREAT)
    os.dup2(fd, 1)

if __name__ == '__main__':
    main()

