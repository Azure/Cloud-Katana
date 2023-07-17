import json

def ConfirmCKTSimulation(path=None, json_strings=None):
    """
    A Python function to read attack simulations from a JSON file or string and validate its schema.
    Translation of the PowerShell function Confirm-CKTSimulation.
    """
    if path:
        with open(path, 'r') as file:
            simu_strings = file.read()
    elif json_strings:
        simu_strings = json_strings
    else:
        raise ValueError("Either 'path' or 'json_strings' must be provided.")

    try:
        simu_ps_object = json.loads(simu_strings)
    except Exception as e:
        raise ValueError(f"Error while parsing JSON: {e}")

    simu_properties = simu_ps_object.keys()

    def confirm_step(atomic, default_params, default_vars):
        current_step = atomic['number']
        atomic_properties = atomic.keys()
        print(f"  [>] Validating step {atomic['name']} schema..")

        if 'execution' not in atomic_properties:
            raise ValueError(f"[Step {current_step}] The 'execution' attribute is required.")

        execution = atomic['execution']
        if not isinstance(execution, dict):
            raise ValueError(f"[Step {current_step}] The 'execution' must be a dictionary.")

        if 'platform' not in execution:
            raise ValueError(f"[Step {current_step}] The attribute 'platform' is required in execution.")
        else:
            valid_platforms = ['Azure', 'WindowsHybridWorker']
            platform = execution['platform']
            if platform not in valid_platforms:
                raise ValueError(f"[Step {current_step}] The platform {platform} is not a valid platform input. Valid platform set: {', '.join(valid_platforms)}")

        if 'supportingFileUris' in atomic_properties:
            supporting_file_uris = atomic['supportingFileUris']
            if not isinstance(supporting_file_uris, list):
                raise ValueError(f"[Step {current_step}] The 'supportingFileUris' attribute must be a list.")

        execution_types = ['ScriptModule', 'ScriptFile']
        execution_type = execution['type']
        if execution_type not in execution_types:
            raise ValueError("Execution type must be of type 'ScriptModule' or 'ScriptFile'.")

        if execution_type == 'ScriptModule':
            if 'module' not in execution:
                raise ValueError("[Step {current_step}] The 'module' attribute is required in ScriptModule execution.")

            module = execution['module']
            module_properties = module.keys()
            if 'name' not in module_properties:
                raise ValueError("[Step {current_step}] The 'name' attribute is required in ScriptModule 'module'.")
            if 'version' not in module_properties:
                raise ValueError("[Step {current_step}] The 'version' attribute is required in ScriptModule 'module'.")
            if 'function' not in module_properties:
                raise ValueError("[Step {current_step}] The 'function' attribute is required in ScriptModule 'module'.")

        if execution_type == 'ScriptFile':
            if 'scriptUri' not in execution:
                raise ValueError("[Step {current_step}] The 'scriptUri' attribute is required in ScriptFile execution.")

        if default_params:
            exec_param_properties = execution['parameters'].keys()
            for param in exec_param_properties:
                current_param_value = execution['parameters'][param]['defaultValue']
                if '*parameters(*)*' in current_param_value:
                    match = re.search(r'parameters\((?P<refName>[a-zA-Z]{1,})\)', current_param_value)
                    if match:
                        param_name = match.group('refName').lower()
                        if param_name not in default_params.keys():
                            raise ValueError(f"[Step {current_step}] references parameter {param_name}, but it is not defined in template. Current parameter set: {', '.join(default_params.keys())}")

        if default_vars:
            for param in exec_param_properties:
                current_param_value = execution['parameters'][param]['defaultValue']
                if '*variables(*)*' in current_param_value:
                    match = re.search(r'variables\((?P<refName>[a-zA-Z]{1,})\)', current_param_value)
                    if match:
                        var_name = match.group('refName').lower()
                        if var_name not in default_vars.keys():
                            raise ValueError(f"[Step {current_step}] references variable {var_name}, but it is not defined in template. Current variables set: {', '.join(default_vars.keys())}")

    print("[*] Starting campaign schema validation..")
    if 'steps' not in simu_properties:
        raise ValueError("[Campaign] The 'steps' attribute is required.")

    if 'parameters' in simu_properties:
        simu_param_properties = simu_ps_object['parameters'].keys()
        default_params = {key.lower(): simu_ps_object['parameters'][key] for key in simu_param_properties}
    else:
        default_params = None

    if 'variables' in simu_properties:
        simu_var_properties = simu_ps_object['variables'].keys()
        default_vars = {key.lower(): simu_ps_object['variables'][key] for key in simu_var_properties}
    else:
        default_vars = None

    if default_vars:
        print("[*] Validating global variables referencing global parameters..")
        for key in simu_var_properties:
            current_var_value = simu_ps_object['variables'][key]
            if '*parameters(*)*' in current_var_value:
                match = re.search(r'parameters\((?P<refName>[a-zA-Z]{1,})\)', current_var_value)
                if match:
                    param_name = match.group('refName').lower()
                    if param_name not in default_params.keys():
                        raise ValueError(f"[Variable {key}] references parameter {param_name}, but it is not defined in template. Current parameter set: {', '.join(default_params.keys())}")

    if not isinstance(simu_ps_object['steps'], list):
        raise ValueError("[Campaign] The 'steps' attribute must be a list.")

    print("[*] Validating the schema of each step..")
    for step in simu_ps_object['steps']:
        if 'number' not in step:
            raise ValueError("[Step] The 'number' attribute is required when defining campaign steps.")
        confirm_step(step, default_params, default_vars)

    return simu_ps_object

def ConvertCKTSimulation(simulation):
    """
    A Python function to create the Simulation Object to send to Cloud Katana.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    """
    simu_object = {
        'id': simulation['id'],
        'name': simulation['name'],
        'metadata': simulation['metadata'],
        'steps': []
    }
    simu_props = simulation.keys()
    simu_steps = simulation['steps']

    def set_simu_references(simulation, simu_steps, reference_name):
        for step in simu_steps:
            print(f"  [>] Processing {step['name']} step..")
            if 'parameters' in step['execution']:
                step_parameters = step['execution']['parameters']
                for key in step_parameters.keys():
                    current_param_value = step_parameters[key]['defaultValue']
                    if f"{reference_name}(" in current_param_value:
                        param_name = current_param_value.split(f"{reference_name}(")[1].split(')')[0]
                        if reference_name == 'parameters':
                            param_value = simulation[reference_name][param_name]['defaultValue']
                        else:
                            param_value = simulation[reference_name][param_name]
                        new_param_value = current_param_value.replace(f"{reference_name}({param_name})", param_value)
                        step_parameters[key]['defaultValue'] = new_param_value
        return simu_steps

    if 'parameters' in simu_props:
        # Processing Parameters File
        if 'ParametersFile' in simu_props:
            print("[*] Resolving global parameters from parameters file..")
            with open(simulation['ParametersFile'], 'r') as file:
                json_object = json.load(file)
            for param in simulation['parameters'].keys():
                simulation['parameters'][param]['defaultValue'] = json_object['parameters'][param]['value']

        # Checking if Parameters have a default value set
        print("[*] Checking if Parameters have a default value set..")
        for param in simulation['parameters'].keys():
            if 'defaultValue' not in simulation['parameters'][param]:
                raise ValueError(f"[Parameter {param}] does not have a value set.")

        if 'variables' in simu_props:
            print("[*] Resolving global parameters in global variables")
            for key in simulation['variables'].keys():
                print(f"  [>] Processing {key} variable..")
                current_var_value = simulation['variables'][key]
                if 'parameters(' in current_var_value:
                    current_var_value = current_var_value.replace('parameters(', '').replace(')', '')
                    param_name = current_var_value
                    param_value = simulation['parameters'][param_name]['defaultValue']
                    new_param_value = current_var_value.replace(f"parameters({param_name})", param_value)
                    simulation['variables'][key] = new_param_value

        # Processing Simulation Steps
        print("[*] Resolving global parameters in step parameters")
        simu_steps = set_simu_references(simulation, simu_steps, 'parameters')

    if 'variables' in simu_props:
        # Processing Variables
        print("[*] Resolving global variables in step parameters")
        simu_steps = set_simu_references(simulation, simu_steps, 'variables')

    # Set new steps
    print("[*] Setting new steps..")
    simu_object['steps'] = simu_steps

    return simu_object