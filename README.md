# rancher-logs-collector

rancher-logs-collector is a tool to collect logs for a Rancher 1.6 environment.

## How to use

Step 1: Download and setup Rancher CLI. Make sure this path is added in $PATH.

Step 2: Setup API Keys in Rancher Server.

Step 3: Execute: `rancher config` to specify the URL, Access Key and Secret Key.

Step 4: Collect logs: `./rancher_logs_collector.sh`.
