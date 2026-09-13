<#
.SYNOPSIS
PS25 Script: PS104-Add-ETL-Jobs

.DESCRIPTION
INPUT: airflow/
PROCESSING: Nightly DAG to sync Postgres -> ClickHouse
OUTPUT: Data in DW by 3am. Incremental sync
HYPERLINK: https://airflow.apache.org
STACK: Airflow + Python + JDBC
COMPLIANCE: PS25 Data freshness < 24h

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 16
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS104: Adding ETL DAG ===" -ForegroundColor Cyan

$airflowDir = Join-Path $BasePath "airflow\dags"
New-Item -ItemType Directory -Force $airflowDir | Out-Null

$dag = Join-Path $airflowDir "etl_to_dw.py"
@"
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import psycopg2, clickhouse_connect

def sync_vouchers():
    pg = psycopg2.connect("host=postgres dbname=demobank user=postgres")
    ch = clickhouse_connect.get_client(host='clickhouse', username='atlas', password='atlas123')
    df = pd.read_sql("SELECT * FROM vouchers WHERE created_at > now() - interval '1 day'", pg)
    ch.insert_df('analytics.vouchers', df)

with DAG('etl_to_dw', schedule='0 3 * * *', start_date=datetime(2026,1,1), catchup=False) as dag:
    PythonOperator(task_id='sync_vouchers', python_callable=sync_vouchers)
"@ | Out-File $dag -Encoding utf8

Write-Host "PS104 Done: Place in airflow and run scheduler" -ForegroundColor Green
