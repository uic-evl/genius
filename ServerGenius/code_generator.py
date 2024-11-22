import subprocess
import json

def generate_code(command):
    command = "Resond with only code: make python code that takes in input and tells the user if its odd or even"
    command_string = "curl https://arcade.evl.uic.edu/codellama/generate -X POST -H 'Content-Type: application/json' -d '{\"inputs\":\"<s>[INST] " + command + " [/INST]\", \"parameters\": {\"max_new_tokens\": 200}}'"
    process = subprocess.Popen(command_string, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()


    print("Command String:", command_string)
    print("Standard Output:", stdout.decode('utf-8'))
    print("Standard Error:", stderr.decode('utf-8'))

    parsed_json = json.loads(stdout.decode('utf-8'))
    output = parsed_json['generated_text']    

    return output