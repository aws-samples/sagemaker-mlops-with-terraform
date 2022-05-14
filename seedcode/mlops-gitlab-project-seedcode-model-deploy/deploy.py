import argparse
import json
import logging
import os

import boto3
from botocore.exceptions import ClientError
from time import gmtime, strftime

logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler())

def read_parameters(param_file):
    '''  '''
    logging.info("Reading param_file")
    logging.info(param_file)
    with open(param_file) as f:
        params = json.load(f)

    parameters = params['Parameters']
    tags = params['Tags']

    taglist = []
    for key in tags.keys():
        t = {
                'Key' : key,
                'Value' : tags[key]
            }
        taglist.append(t)

    return parameters, taglist

def main():
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--region")
    parser.add_argument("--param-file")
    parser.add_argument("--project-id")
    args, _ = parser.parse_known_args()

    sm_client = boto3.client('sagemaker', region_name=args.region)
    parameters, tags = read_parameters(args.param_file)
    print(parameters)
    
    try:
        stage_name = parameters["StageName"]
        model_package_arn = parameters["ModelPackageName"]
        role_arn = parameters["ModelExecutionRoleArn"]
        ep_instance_count = parameters["EndpointInstanceCount"]
        ep_instance_type = parameters["EndpointInstanceType"]

        #Use boto3 to create model
        model_name = 'DEMO-modelname-' + \
            strftime("%Y-%m-%d-%H%M%S", gmtime())
        container_list = [{"ModelPackageName": model_package_arn}]
        create_model_response = sm_client.create_model(
            ModelName=model_name,
            ExecutionRoleArn=role_arn,
            Containers=container_list
        )
        
        #Create endpoint config
        endpoint_config_name = stage_name+'-Endpoint-Config-' + \
            strftime("%Y-%m-%d-%H%M%S", gmtime())
        create_endpoint_config_response = sm_client.create_endpoint_config(
            EndpointConfigName=endpoint_config_name,
            ProductionVariants=[{
                'InstanceType': ep_instance_type,
                'InitialVariantWeight': 1,
                'InitialInstanceCount': int(ep_instance_count),
                'ModelName': model_name,
                'VariantName': 'AllTraffic'}])
        
        #Ceate endpoint
        endpoint_name = stage_name+'-Endpoint-' + \
            strftime("%Y-%m-%d-%H%M%S", gmtime())
        print("EndpointName={}".format(endpoint_name))
        
        create_endpoint_response = sm_client.create_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=endpoint_config_name)
        print(create_endpoint_response['EndpointArn'])
                    
    except Exception as e:
        print(e)
        print("[ERROR]create_endpoint:", e)
        raise(e)

if __name__ == '__main__':
    main()
