# Context
The database (eg. mysql/mongo) may run inside the mojaloop cluster or may run as managed database (e.g. AWS RDS). In both cases, we want to gather database metrics for operational visibility

# Problem
How do we show the same metrics to ops team when the database is running as managed instance (e.g. AWS RDS). 

# Solution

In case of self managed database, the exporter runs as a side car container with the database container in the same k8s pod. When the database runs as external managed service (eg. AWS RDS), we deploy a standalone exporter instance. This exporter instance pulls the metrics data from the database and converts them to prometheus format. 

![diagram](./database-metrics-architecture.svg) 