import boto.ec2
import time
import requests
from requests.auth import HTTPBasicAuth
import json
import time


MIN_TWEET_PROCESSING_RATE = 15000 / (2 * 60 * 60)
CHECKING_PERIOD = 60 * 10  # 10 minutes
MAX_RUNNING_AMAZON_VMS = 3
AWS_ACCESS_KEY_ID = 'AKIAIEIZ4QKG36OL7XTQ'
AWS_SECRET_ACCESS_KEY = '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'
DRY_RUN = True

conn = boto.ec2.connect_to_region(
    "eu-west-1",
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY)


def start_new_filter_VM():
    newinstance = conn.run_instances(
        image_id='ami-df7ebfa8',
        instance_type='t1.micro',
        key_name='Group10',
        dry_run=DRY_RUN)
    return newinstance


def shutdown_filter_VM(running_instances):
    conn.stop_instances(
        instance_ids=running_instances[0],
        dry_run=DRY_RUN)


def get_rabbitMQ_rates():
    rawResponse = requests.get(
        'http://flightcees.lab.uvalight.net:15672/api/queues/soa/soa10:TweetString:RAW',
        auth=HTTPBasicAuth('soa-cloud', 'PxKGpr5A')).text
    positiveResponse = requests.get(
        'http://flightcees.lab.uvalight.net:15672/api/queues/soa/soa10:TweetString:POSITIVE',
        auth=HTTPBasicAuth('soa-cloud', 'PxKGpr5A')).text
    negativeResponse = requests.get(
        'http://flightcees.lab.uvalight.net:15672/api/queues/soa/soa10:TweetString:NEGATIVE',
        auth=HTTPBasicAuth('soa-cloud', 'PxKGpr5A')).text

    rawObject = json.loads(rawResponse)
    positiveObject = json.loads(positiveResponse)
    negativeObject = json.loads(negativeResponse)

    injectRate = rawObject["message_stats"]["publish_details"]["rate"]
    collectRate = rawObject["message_stats"]["get_no_ack_details"]["rate"]
    readyMessagesAmount = rawObject["messages_ready"]

    positiveRate = positiveObject["message_stats"]["publish_details"]["rate"]
    negativeRate = negativeObject["message_stats"]["publish_details"]["rate"]

    return {'ready': readyMessagesAmount,
            'injectRate': injectRate,
            'collectRate': collectRate,
            'positiveRate': positiveRate,
            'negativeRate': negativeRate,
            'totalRate': negativeRate + positiveRate}


def print_info(rates):
    print "\t--" + (time.strftime("%H:%M:%S")) + "--"
    print " [Amazon]"
    print "#Running VM instances: " + str(len(reservations))
    print " [RabbitMQ]"
    print "Inject rate:\t\t" + str(rates["injectRate"]) + " [" + str(rates["ready"]) + " ready to be collected]"
    print "Incoming positive rate:\t" + str(rates["positiveRate"])
    print "Incoming negative rate:\t" + str(rates["negativeRate"])
    print "Total filter rate:\t" + str(rates["totalRate"])
    print "Collect rate:\t\t" + str(rates["collectRate"])
    print ""

st = time.time()
rate_array = []
while True:
    reservations = conn.get_all_reservations(
        filters={'tag:InstanceOwner': 'Group10', 'instance-state-code': 16})
    rates = get_rabbitMQ_rates()
    print_info(rates)
    rate_array.append(rates["totalRate"])
    print ["%0.2f" % i for i in rate_array]
    # Check every 10 minutes if minimum filter rate is satisfied by all filter
    # VMs
    if time.time() - st > CHECKING_PERIOD:
        average_rate = sum(rate_array) / len(rate_array)
        if average_rate < MIN_TWEET_PROCESSING_RATE and len(reservations) < MAX_RUNNING_AMAZON_VMS:
            start_new_filter_VM()
        elif average_rate > 2 * MIN_TWEET_PROCESSING_RATE and len(reservations) > 1:
            shutdown_filter_VM(reservations)
        rate_array = []
        st = time.time()

    time.sleep(5)
