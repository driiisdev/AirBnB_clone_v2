#!/usr/bin/python3
"""
 that distributes an archive to your web servers,
 using the function do_deploy

 run:
 fab -f 2-do_deploy_web_static.py do_deploy:archive_path=
 versions/web_static_20170315003959.tgz -i my_ssh_private_key -u
 ubuntu
"""
from fabric.api import env, put, run
from os.path import exists

env.hosts = ["100.26.122.130", "35.153.93.220"]
env.user = "ubuntu"


def do_deploy(archive_path):
    """distributes an archive to the web servers"""
    if exists(archive_path) is False:
        return False
    try:
        file_n = archive_path.split("/")[-1]
        no_ext = file_n.split(".")[0]
        path = "/data/web_static/releases/"
        put(archive_path, '/tmp/')
        run('mkdir -p {}{}/'.format(path, no_ext))
        run('tar -xzf /tmp/{} -C {}{}/'.format(file_n, path, no_ext))
        run('rm /tmp/{}'.format(file_n))
        run('mv {0}{1}/web_static/* {0}{1}/'.format(path, no_ext))
        run('rm -rf {}{}/web_static'.format(path, no_ext))
        run('rm -rf /data/web_static/current')
        run('ln -s {}{}/ /data/web_static/current'.format(path, no_ext))
        return True
    except:
        