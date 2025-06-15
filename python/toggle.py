import boto3
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Tag key and value to filter EC2 instances
TAG_KEY = 'Environment'
TAG_VALUE = 'Dev'

def lambda_handler(event, context):
    logger.info("Lambda function started.")
    logger.info(f"Looking for EC2 instances with tag {TAG_KEY}={TAG_VALUE}")

    ec2 = boto3.client('ec2')

    try:
        # Describe instances with the specified tag
        response = ec2.describe_instances(
            Filters=[
                {'Name': f'tag:{TAG_KEY}', 'Values': [TAG_VALUE]},
                {'Name': 'instance-state-name', 'Values': ['running', 'stopped']}
            ]
        )

        instances_to_start = []
        instances_to_stop = []

        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                state = instance['State']['Name']
                logger.info(f"Found instance {instance_id} in state: {state}")

                if state == 'running':
                    instances_to_stop.append(instance_id)
                elif state == 'stopped':
                    instances_to_start.append(instance_id)

        if instances_to_stop:
            logger.info(f"Stopping instances: {instances_to_stop}")
            ec2.stop_instances(InstanceIds=instances_to_stop)
        else:
            logger.info("No instances to stop.")

        if instances_to_start:
            logger.info(f"Starting instances: {instances_to_start}")
            ec2.start_instances(InstanceIds=instances_to_start)
        else:
            logger.info("No instances to start.")

        logger.info("Lambda execution completed successfully.")

        return {
            'statusCode': 200,
            'body': f"Toggled instances. Started: {instances_to_start}, Stopped: {instances_to_stop}"
        }

    except Exception as e:
        logger.error(f"Error toggling EC2 instances: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
