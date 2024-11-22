from flask import Flask, request, jsonify, send_file, send_from_directory, abort
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash
from ssh import *
from code_generator import *
from run_script import *

IP_ADDRESS = ""

app = Flask(__name__)
auth = HTTPBasicAuth()

@app.route('/')
@auth.login_required
def index():
    return '<h1>Hello, World!</h1>'


#Handles requests for the simulations
@app.route('/lbm-sim', methods=['GET'])
def video():
    #gets all the parameters
    density = request.args.get('density')
    speed = request.args.get('speed')
    length = request.args.get('length')
    viscosity = request.args.get('viscosity')
    time = request.args.get('time')
    freq = request.args.get('freq')
    print("Parameters received:", density, speed, length, viscosity, time, freq)

    #runs script, code in run_script.py
    run_script(density, speed, length, viscosity, time, freq)
    mp4_filename = "outputs/lbm_sim.mp4"

    #sends results back to user
    return send_file(mp4_filename, mimetype='video/mp4', as_attachment=True)



# @app.route('/polaris', methods=['POST'])
# def data():
#     data = request.json
#     username = data.get('user')
#     password = data.get('password')
#     directory = data.get('directory')
    
#     if verify_password(username, password):
#         # Process the data 
#         command = data.get('command', [])
#         outputs, directories = ssh_and_run_command(command, directory)
        
#         response = {
#             'data_received': command,
#             'output': outputs,
#             'directory': directories
#         }
#         print(response)
#         return jsonify(response)
#     else:
#         return jsonify({'error': 'Unauthorized'}), 401



# @app.route('/code', methods=['POST'])
# def code():
#     data = request.json
#     username = data.get('user')
#     password = data.get('password')
    
#     if verify_password(username, password):
#         command = data.get('command')
#         #output = generate_code(command)
#         run_script(command)
#         output = "test"
#         response = {
#             'data_received': command,
#             'output': output,

#         }
#         print(response)
#         return jsonify(response)
#     else:
#         return jsonify({'error': 'Unauthorized'}), 401





if __name__ == '__main__':
    app.run(host=IP_ADDRESS, port=5000, debug=True)
    
    #app.run(debug=True)


