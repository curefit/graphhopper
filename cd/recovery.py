import os
import subprocess

helm_path = os.getcwd()
values_array = []

def run_os_command(command):
    output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    jsonS = output.communicate()[0]
    print(jsonS)

# for root, dirs, files in os.walk("/Users/romil.punetha/Curefit/prod/"):
#     for file in files:
#         if file.startswith("values-prod") and file.endswith(".yaml"):
#             values_array.append(os.path.join(root, file))

values_array = ["/Users/romil.punetha/Curefit/prod/cult-api/values-prod.yaml"]

for file_path in values_array:
    folder_path = file_path.split("values")[0]
    name = file_path.split("/")[5]
    print(name)
    print(folder_path)
    os.chdir(folder_path)
    cmd = "git stash && git checkout . && git checkout master && git reset --hard origin/master"
    run_os_command(cmd)
    cmd = "echo 'appName: '" + name + " >> " + file_path
    run_os_command(cmd)
    cmd = "echo 'appEnv: prod' >> " + file_path
    run_os_command(cmd)
    os.chdir(helm_path)
    cmd = "helm template . -f " + file_path + " > " + name + ".yaml"
    run_os_command(cmd)