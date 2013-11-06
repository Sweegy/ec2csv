#!/usr/bin/env python
import sys
import os
import json
import csv

from awscli.clidriver import CLIDriver

def forked(f):
    def _(*args, **kwargs):
        pid = os.fork()
        if pid is 0:
            f(*args, **kwargs)
            sys.exit()
        else:
            return pid
    return _

def ec2_via_awscli(args):
    d = CLIDriver()
    stat = d.main(['--output', 'json', 'ec2'] + args)
    sys.stdout.flush()
    sys.stderr.flush()
    return stat

def ec2(cli_args, output_file):
    def __(f):
        def _(*args, **kwargs):
            tmp = output_file + '.tmp'
            out(tmp)
            stat = ec2_via_awscli(cli_args)
            if stat is not 0:
                formatted_cli = ' '.join(['aws', 'ec2'] + cli_args)
                print >>sys.stderr, formatted_cli, '~>', stat
                print >>sys.stderr, open(tmp).read().rstrip()
                os.remove(tmp)
                sys.exit(stat)
            os.rename(tmp, output_file)
            f(*args, **kwargs)
        return _
    return __

@forked
@ec2(['describe-instances'], 'instance.json')
def instances():
    instances = []
    tags = []
    security_groups = []
    nets = []
    with open('instance.json') as h:
        for res in json.load(h)['Reservations']:
            for inst in res['Instances']:
                info = ( inst.get('InstanceId'),
                         inst.get('LaunchTime'),
                         inst.get('Placement', {}).get('AvailabilityZone'),
                         inst.get('KeyName'),
                         inst.get('RootDeviceName'),
                         inst.get('ImageId'),
                         inst.get('KernelId'),
                         inst.get('InstanceType'),
                         inst.get('Architecture'),
                         inst.get('State', {}).get('Name') )
                instances.append(info)
                net = ( inst.get('PublicIpAddress'),
                        inst.get('PrivateIpAddress'),
                        inst.get('PublicDnsName'),
                        inst.get('PrivateDnsName') )
                if any(net):
                    nets.append((inst.get('InstanceId'),) + net)
                for tag in inst.get('Tags', []):
                    info = ( inst.get('InstanceId'),
                             tag.get('Key'),
                             tag.get('Value') )
                    tags.append(info)
                for sg in inst.get('SecurityGroups', []):
                    info = ( inst.get('InstanceId'),
                             sg.get('GroupId'),
                             sg.get('GroupName') )
                    security_groups.append(info)
    with open('instance.csv', 'wb') as h:
        csv.writer(h).writerows(instances)
    with open('instance_tag.csv', 'wb') as h:
        csv.writer(h).writerows(tags)
    with open('sg_membership.csv', 'wb') as h:
        csv.writer(h).writerows(security_groups)
    with open('net.csv', 'wb') as h:
        csv.writer(h).writerows(nets)

@forked
@ec2(['describe-volumes'], 'volume.json')
def volumes():
    volumes = []
    attachments = []
    tags = []
    with open('volume.json') as h:
        for vol in json.load(h)['Volumes']:
            volumes.append(( vol.get('VolumeId'),
                             vol.get('CreateTime'),
                             vol.get('Size'),
                             vol.get('AvailabilityZone'),
                             vol.get('SnapshotId'),
                             vol.get('State') ))
            for att in vol.get('Attachments', []):
                attachments.append(( att.get('Device'),
                                     att.get('InstanceId'),
                                     att.get('VolumeId'),
                                     att.get('AttachTime'),
                                     att.get('State'),
                                     att.get('DeleteOnTermination') ))
            for tag in vol.get('Tags', []):
                tags.append(( vol.get('SnapshotId'),
                              tag.get('Key'),
                              tag.get('Value') ))
    with open('volume.csv', 'wb') as h:
        csv.writer(h).writerows(volumes)
    with open('attachment.csv', 'wb') as h:
        csv.writer(h).writerows(attachments)
    with open('volume_tag.csv', 'wb') as h:
        csv.writer(h).writerows(tags)

@forked
@ec2(['describe-snapshots', '--owner-ids', 'self'], 'snapshot.json')
def snapshots():
    snapshots = []
    tags = []
    with open('snapshot.json') as h:
        for snap in json.load(h)['Snapshots']:
            snapshots.append(( snap.get('SnapshotId'),
                               snap.get('StartTime'),
                               snap.get('VolumeSize'),
                               snap.get('VolumeId'),
                               snap.get('State'),
                               snap.get('Progress'),
                               snap.get('Description'),
                               snap.get('OwnerId') ))
            for tag in snap.get('Tags', []):
                tags.append(( snap.get('SnapshotId'),
                              tag.get('Key'),
                              tag.get('Value') ))
    with open('snapshot.csv', 'wb') as h:
        csv.writer(h).writerows(snapshots)
    with open('snapshot_tag.csv', 'wb') as h:
        csv.writer(h).writerows(tags)

def main():
    for pid in [ instances(), volumes(), snapshots() ]:
        os.waitpid(pid, 0)

def out(f):
    fd = os.open(f, os.O_RDWR | os.O_TRUNC | os.O_CREAT)
    os.dup2(fd, 1)

if __name__ == '__main__':
    main()

