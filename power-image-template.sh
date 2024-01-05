#!/bin/bash

if [ -f .env ]; then
  source .env
fi

# login validation
ibmcloud login --apikey $IBM_CLOUD_API_KEY

image_name='image-template-'$(date +%m-%d-%Y)

# Power Workspace target
service_list_output=$(ibmcloud pi service-list)

service_crn=$(echo "$service_list_output" | awk -v workspace="$IBM_POWER_WORKSPACE_NAME" '$0 ~ workspace {print $1}')

ibmcloud pi service-target "$service_crn"

# Power LPAR instance 
instances_list_output=$(ibmcloud pi instances)

instance_crn=$(echo "$instances_list_output" | awk -v workspace="$IBM_POWER_INSTANCE_NAME" '$0 ~ workspace {print $1}')

#Capture image in IBM COS

ibmcloud pi instance-capture "$instance_crn" --destination cloud-storage --access-key $COS_ACCESS_KEY --secret-key $COS_SECRET_KEY --region us-east --image-path power-vs-instance-bucket-images --name "$image_name" --job
sleep 5
ibmcloud logout
