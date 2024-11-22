# 
#
#
import subprocess


def run_command(command):
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    output = stdout.decode('utf-8')
    error_output = stderr.decode('utf-8')


    print("Command String:", command)
    print("Standard Output:", output)
    print("Standard Error:", error_output)

    return output, error_output


def ssh_and_run_command(commands, directory):
    outputs = []
    for command in commands:
        command_string = f'ssh polaris -t "cd {directory}; {command}"'
        command_output, error = run_command(command_string)

        output = ""
        if command_output != "":
            output += command_output
        if error != "" and "connection to polaris.alcf.anl.gov" not in error:
     
     
            output += error 

        outputs.append(output)

        if "cd" in command and "No such file or directory" not in error:
            directory = update_directory(command, directory)
    
    return outputs, directory


def update_directory(command, directories):
    directory = directories.split("/")
    parts = command.split()
    
    if parts[0] != "cd":
        return directories

    if len(parts) == 1:
        return ""

    if parts[1] == "..":
        print(directory)
        if directory:
            directory.pop()
            directory.pop()
            print(directory)
    
    elif parts[1].startswith("/"):
        directory.clear()
        directory.append(parts[1])

    else:
        # Handle relative paths
        dirs = parts[1].split('/')
        for d in dirs:
            if d == "..":
                if directory: 
                    if directory[len(directory)-1] == "":
                        directory.pop()
                    directory.pop()
            elif d == ".":
                continue
            else:
                directory.append(d)
    new_directories = ""
    for dir in directory:
        if dir != "":
            new_directories += dir + "/"
    
    print(directory)
    return new_directories

# def ssh_and_run_command(hostname, commands):
#     # Create an SSH client
#     ssh = paramiko.SSHClient()

#     # Automatically add the server's host key (not recommended for production)
#     ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

#     try:
#         # Connect to the server
#         ssh.connect(hostname)

#         # Run the command
#         outputs = []
#         for command in commands:
#             stdin, stdout, stderr = ssh.exec_command(command)

#             # Read the output
#             output = stdout.read().decode()
#             error = stderr.read().decode()

#             # Print the output and error (if any)
#             #print(f"Output:\n{output}")

            
#             if error:
#                 print(f"Error:\n{error}")
#                 outputs.append(error)
#             else:
#                 outputs.append(output)


#         return outputs
        
#     except Exception as e:
#         print(f"An error occurred: {e}")

#     finally:
#         # Close the connection
#         ssh.close()