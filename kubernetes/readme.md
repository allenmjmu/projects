# Kubernetes

This folder contains samples of different kubernetes yaml files

## K8S Folder/PgBouncer-gcp

This is a sample configmap, deployment, and service yaml to install PgBouncer as a microservice in a kubernetes cluster.
PgBouncer is a pooler for PostgreSQL database connections. This allows multiple users to connect and write to the database at once. Much like a load balancer.

This deployment also contains a Google Cloud SQL Auth Proxy sidecar container. This is necessary when the database on GCP is marked "public." GCP will not allow the kubernetes cluster to communicate with the database unless using the proxy. In this case, the proxy acts as a secure tunnel to the database. See here for more information:

<https://cloud.google.com/sql/docs/postgres/connect-kubernetes-engine>

## sample-server-gcp

This is a sample confimap, deployment, ingress, and service yaml to install a backend server as a microservice in a kubernetes cluster.

## References

<https://github.com/pgbouncer/pgbouncer>

<http://www.pgbouncer.org>
