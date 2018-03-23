## Set up cluster

### Set up keys for ssh

```bash
bin/gen-key.sh
```
### Run download.sh

```bash
bin/download.sh
```

### Run vagrant up

```bash
vagrant up
```

### Add keys to your auth known_hosts

```
ssh-keyscan node0 node1 node2  bastion > ~/.ssh/known_hosts
```

### Ensure they are up

```
ansible all  -m ping
node2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node0 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
bastion | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

```

### Add keys to nodes

```
ansible-playbook playbooks/keyscan.yml
```

## Installing Spark
http://apache.spinellicreations.com/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz

###  Untar it

```
tar xvzf spark.tgz
```

### Install it

To install spark we do this.

```
mkdir -p /opt/
mv spark-2.3.0-bin-hadoop2.7/ /opt/spark
ls /opt/spark/
```

See [spark standalone set up for more details](https://spark.apache.org/docs/latest/spark-standalone.html).



Next we want to edit the  `/opt/spark/conf/spark-env.sh` (see spark-env.sh.template)

```
SPARK_LOCAL_IP=192.168.50.6
SPARK_PUBLIC_DNS=node2
SPARK_MASTER_HOST=node2
```


#### Run the master

Then we can run the master.

```bash

/opt/spark/sbin/start-master.sh

```



### tail the log of the spark master

We can also tail the log of the master.
```
tail -f  /var/spark/logs/spark-root-org.apache.spark.deploy.master.Master-1-localhost.localdomain.out

```

### Output
```
org.apache.spark.deploy.master.Master --host localhost --port 7077 --webui-port 8080

```
### Go to browser

We can see that the master is running.
At this point spark is running.

Go to http://192.168.50.6:8080/


Then See URLs on this page as follows:

```
URL: spark://localhost:7077
REST URL: spark://localhost:6066 (cluster mode)
```

## Log into another node

Install Spark here.

Connect a worker to the master.

```bash
/opt/spark/sbin/start-slave.sh spark://192.168.50.6:7077
```

## Slaves file

```

cat slaves
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# A Spark Worker will be started on each of the machines listed below.
node1


```

To visualize the DAGS and see job / worker/ application metrics, we will want the [spark job history server](https://jaceklaskowski.gitbooks.io/mastering-apache-spark/content/spark-history-server.html).


### Running a job

To see metrics, we will want to run some jobs.

Run SparkPi example with enable log true (for history server).

```bash

 /opt/spark/bin/spark-submit --class org.apache.spark.examples.SparkPi \
 --master spark://node0:7077 \
 --conf spark.eventLog.enabled=true \
 /opt/spark/examples/jars/spark-examples_2.11-2.3.0.jar
```

Run SparkPageRank example with enable log true (for history server).

```bash

/opt/spark/bin/spark-submit \
  --class org.apache.spark.examples.SparkPageRank \
  --master spark://node0:7077 \
  --conf spark.eventLog.enabled=true \
  /opt/spark/examples/jars/spark-examples_2.11-2.3.0.jar \
  /opt/spark/data/mllib/pagerank_data.txt 20
```

With the Spark Job History server we can track metrics like:


Should be easy to track time for serialization

* Scheduler Delay
* Task Deserialization Time
* Result Serialization Time
* Getting Result Time
* Peak Execution Memory

This will tell us where any bottlenecks occur.

### Spark metrics

Spark has an internal metrics system based on [Yammer metrics (now Code Hale Metrics or DropWizard metrics)](http://metrics.dropwizard.io/4.0.0/).

Spark allows metrics to be sent from various sources to one more sinks.

The instance which provide sources are:
* "master"
* "worker"
* "executor"
* "driver"
* "applications"

A wildcard `"*"` denotes all sources inherits the property config.

Within an instance, a "source" specifies a grouped source of related metrics.

Spark Internal sources to track internal state are as follows:
* MasterSource
* WorkerSource
* DAGSchedulerSource
* ApplicationSource
* CacheMetrics
* CodegenMetrics
* possibly more

System sources:
* JvmSource (for JVM metrics)


Sinks are where metrics and KPIs get delivered to (StatsD, JMX, file).

To specify metrics use `"spark.metrics.conf=${SPARK_HOME}/conf/metrics.properties"`
If you put the metrics file in ${SPARK_HOME}/conf it gets loaded automatically.

`MetricsServlet sink` is added by default as a sink in the master, worker and driver. Just send HTTP requests to the "/metrics/json" to get a snapshot of metrics.

Use "/metrics/master/json" and "/metrics/applications/json" endpoints to the master node.

### Curling master for metrics for master

Since MetricsServlet is built-in and on by default you can curl it to see metrics.


#### Curling Spark for metrics
```bash

curl http://node0:8080/metrics/master/json/ | jq
"
  "version": "3.1.3",
  "gauges": {
    "master.aliveWorkers": {
      "value": 3
    },
    "master.apps": {
      "value": 0
    },
    "master.waitingApps": {
      "value": 0
    },
    "master.workers": {
      "value": 3
    }
    "
```

### Curling master for applications

```bash
curl http://node0:8080/metrics/applications/json/ | jq
"
{
  "version": "3.1.3",
  "gauges": {
    "application.Spark Pi.1521748826010.cores": {
      "value": 12
    },
    "application.Spark Pi.1521748826010.runtime_ms": {
      "value": 3700
    },
    "application.Spark Pi.1521748826010.status": {
      "value": "FINISHED"
    },
    "application.Spark Pi.1521748914505.cores": {
      "value": 12
    },
"
```

#### Curling worker for metrics

The default path is `/metrics/json` for all instances except the master which was shown earlier. (Recall Master has `/metrics/applications/json` for apps and `/metrics/master/json`
for master).


```bash
$ curl  http://node1:8081/metrics/json/ | jq
...
"
{
  "version": "3.1.3",
  "gauges": {
    "worker.coresFree": {
      "value": 4
    },
    "worker.coresUsed": {
      "value": 0
    },
    "worker.executors": {
      "value": 0
    },
    "worker.memFree_MB": {
      "value": 1844
    },
    "worker.memUsed_MB": {
      "value": 0
    }
  },
  "counters": {
    "HiveExternalCatalog.fileCacheHits": {
      "count": 0
    },
"    
```

### List of available sinks in metrics.properties

The built-in sinks are as follows:

* ConsoleSink
* CSVSink
* GangliaSink
* JmxSink
* GraphiteSink
* StatsdSink

You can configure more sinks as follows:

#### Spark metrics sink setup
```bash
# org.apache.spark.metrics.sink.ConsoleSink
#   Name:   Default:   Description:
#   period  10         Poll period
#   unit    seconds    Unit of the poll period

# org.apache.spark.metrics.sink.CSVSink
#   Name:     Default:   Description:
#   period    10         Poll period
#   unit      seconds    Unit of the poll period
#   directory /tmp       Where to store CSV files

# org.apache.spark.metrics.sink.GangliaSink
#   Name:     Default:   Description:
#   host      NONE       Hostname or multicast group of the Ganglia server,
#                        must be set
#   port      NONE       Port of the Ganglia server(s), must be set
#   period    10         Poll period
#   unit      seconds    Unit of the poll period
#   ttl       1          TTL of messages sent by Ganglia
#   dmax      0          Lifetime in seconds of metrics (0 never expired)
#   mode      multicast  Ganglia network mode ('unicast' or 'multicast')

# org.apache.spark.metrics.sink.JmxSink

# org.apache.spark.metrics.sink.MetricsServlet
#   Name:     Default:   Description:
#   path      VARIES*    Path prefix from the web server root
#   sample    false      Whether to show entire set of samples for histograms
#                        ('false' or 'true')
#

# org.apache.spark.metrics.sink.GraphiteSink
#   Name:     Default:      Description:
#   host      NONE          Hostname of the Graphite server, must be set
#   port      NONE          Port of the Graphite server, must be set
#   period    10            Poll period
#   unit      seconds       Unit of the poll period
#   prefix    EMPTY STRING  Prefix to prepend to every metric's name
#   protocol  tcp           Protocol ("tcp" or "udp") to use

# org.apache.spark.metrics.sink.StatsdSink
#   Name:     Default:      Description:
#   host      127.0.0.1     Hostname or IP of StatsD server
#   port      8125          Port of StatsD server
#   period    10            Poll period
#   unit      seconds       Units of poll period
#   prefix    EMPTY STRING  Prefix to prepend to metric name
```


### Examples spark stats metrics config

To enable Enable `JmxSink` for all instances use this config.

```bash
*.sink.jmx.class=org.apache.spark.metrics.sink.JmxSink
```

To enable `ConsoleSink` for all instances by class name use

```bash
*.sink.console.class=org.apache.spark.metrics.sink.ConsoleSink
```


To enable StatsdSink for all instances by class name

```bash
*.sink.statsd.class=org.apache.spark.metrics.sink.StatsdSink
*.sink.statsd.prefix=spark
```

You can also set poll period for various sinks.

Here we set the polling period for ConsoleSink.

```bash
# Polling period for the ConsoleSink
*.sink.console.period=10
# Unit of the polling period for the ConsoleSink
*.sink.console.unit=seconds
```

Here we set the polling period for ConsoleSink but only for master.

```bash
# Polling period for the ConsoleSink specific for the master instance
master.sink.console.period=15
# Unit of the polling period for the ConsoleSink specific for the master
# instance
master.sink.console.unit=seconds
```

To enable JvmSource for master, worker and driver we would do the following:

```bash
# Enable JvmSource for instance master, worker, driver and executor
master.source.jvm.class=org.apache.spark.metrics.source.JvmSource
worker.source.jvm.class=org.apache.spark.metrics.source.JvmSource
driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource
executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource
```

### Sample metrics config metrics.properties

We plan on using InfluxDB and Telegraf to capture metrics.
Let's set up an example and since we have not installed Telegraf or InfluxDB yet,
let's use the console to capture metrics.

```bash

*.sink.statsd.class=org.apache.spark.metrics.sink.StatsdSink
*.sink.statsd.prefix=spark
*.sink.statsd.port=8125
*.sink.statsd.unit=seconds
*.sink.statsd.period=3
*.sink.statsd.host=node1

*.sink.console.class=org.apache.spark.metrics.sink.ConsoleSink
*.sink.console.period=3
*.sink.console.seconds=seconds

master.source.jvm.class=org.apache.spark.metrics.source.JvmSource
worker.source.jvm.class=org.apache.spark.metrics.source.JvmSource
driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource
executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource
```

#### Sample console metrics output log

Here is a sample spark metrics output from using the above config.

```bash

tail -f /opt/spark/logs/spark-spark-org.apache.spark.deploy.master.Master-1-node0.out \

-- Gauges ----------------------------------------------------------------------
jvm.PS-MarkSweep.count
             value = 2
jvm.PS-MarkSweep.time
             value = 62
jvm.heap.usage
             value = 0.09392405577507208
jvm.heap.used
             value = 89671968
...

-- Counters --------------------------------------------------------------------
HiveExternalCatalog.fileCacheHits
             count = 0
HiveExternalCatalog.filesDiscovered
             count = 0
...
-- Histograms ------------------------------------------------------------------
CodeGenerator.compilationTime
             count = 0
               min = 0
               max = 0
              mean = 0.00
            stddev = 0.00
            median = 0.00
              75% <= 0.00
             value = -3.9609096E7
jvm.pools.Code-Cache.init
             value = 2555904
              95% <= 0.00
              98% <= 0.00
              99% <= 0.00
            99.9% <= 0.00
...
master.aliveWorkers
             value = 3
master.apps
             value = 0
master.waitingApps
             value = 0
master.workers
             value = 3

-- Counters --------------------------------------------------------------------
HiveExternalCatalog.fileCacheHits
             count = 0
...
```

## InfluxDB and friends

Chronograf
http://node2:8888/sources/new?redirectPath=/
