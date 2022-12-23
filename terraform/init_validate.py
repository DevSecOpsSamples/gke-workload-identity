import subprocess
import os

steps = ["cluster", "workload-identity"]
for step in steps:
    pwd = "{}/{}".format(os.path.dirname(os.path.realpath(__file__)), step)
    cmd = 'cd {} && terraform init && terraform fmt -check && terraform validate -no-color'.format(pwd)
    print('==== {} ===='.format(cmd))
    proc = subprocess.Popen(cmd, shell=True)
    proc.wait()