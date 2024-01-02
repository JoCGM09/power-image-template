#!/bin/bash

if [ -f .env ]; then
  source .env
fi

# login validation
ibmcloud login --apikey $IBM_CLOUD_API_KEY

image_name='test-cli-'$(date +%m-%d-%Y)

# CSM-Power-test Workspace target
service_list_output=$(ibmcloud pi service-list)

service_crn=$(echo "$service_list_output" | awk '/CSM-Power-test/ {print $1}')

ibmcloud pi service-target "$service_crn"

# lpar-bkp-ibmi instance 
instances_list_output=$(ibmcloud pi instances)

instance_crn=$(echo "$instances_list_output" | awk '/lpar-bkp-ibmi/ {print $1}')

#image_list_output=$(ibmcloud pi images) 

# Check if test-cli image exists
#if echo "$image_list_output" | grep -q 'test-cli'; then 
#	image_crn=$(echo "$image_list_output" | awk '/test-cli/ {print $1}') 
#	echo "Eliminando la imagen existente..." 
#	ibmcloud pi image-delete "$image_crn" 
#	sleep 15
#else
#    echo "No se encontró la imagen 'test-cli', continuando."
#fi 
# Capture te image

ibmcloud pi instance-capture "$instance_crn" --destination cloud-storage --access-key $COS_ACCESS_KEY --secret-key $COS_SECRET_KEY --region us-east --image-path power-vs-instance-bucket-images --name "$image_name" --job
sleep 5
ibmcloud logout
