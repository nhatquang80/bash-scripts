#!/bin/bash

echo "Start deleting... adtran_data.adtran_crawler_execution_monitoring_log"

sudo -u postgres -H -- psql -d adtran -c "DELETE FROM adtran_data.adtran_crawler_execution_monitoring_log WHERE created_date < now() - interval '2 days'"

echo "Finish deleting"
