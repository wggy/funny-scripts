# -*- coding: utf-8 -*-
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
import pymysql
from types import FunctionType

from airflow.models import Variable, DAG

from datetime import date, datetime, timedelta


DB_IP='10.1.10.81'
DB_PORT=9203
DB_USER='lingq'
DB_PASSWD='GwpiLLTnrA2t8P7'
DB='apache_airflow_83'

class MyPdbc(object):
    def __init__(self):
        self.conn = pymysql.connect(DB_IP, DB_USER, DB_PASSWD, DB, DB_PORT, charset='utf8',
                                     use_unicode=True, connect_timeout=60)
        self.cursor = self.conn.cursor()

    def execute(self,sql):
        self.cursor.execute(sql)
        rows = self.cursor.fetchall()
        index = self.cursor.description
        columns = []
        for i in range(len(index)):
            columns.append(index[i][0])
        return [dict(zip(columns, row)) for row in rows]

    def close(self):
        self.cursor.close()
        self.conn.close()


group_dag_name='dynamic_dag'
##
## The DAG for the application account processing job to run
##
dag = DAG(group_dag_name,
    default_args={
                    'owner': 'airflow',
                    'start_date': datetime(2017, 2, 19),
                    'depends_on_past': False,
                    'retries': 1,
                    'retry_delay': timedelta(minutes=5),
                },
    schedule_interval = '@daily' ## '*/5 * * * *' # 5 minutes for testing
)
# Without any operators, this dag file will not execute/trigger
op = DummyOperator(task_id='dummy', dag=dag)


def process_new_accounts():
    pdbc = MyPdbc()
    select_sql = "SELECT id,name,cron as schedule_interval,date_format(start_date,'%Y-%m-%d %H:%m:%s') as start_date,depends_on_past,owner,retries,retry_delay,dagrun_timeout from dynamic_dag where is_active=1"
    try:
        return pdbc.execute(select_sql)
    finally:
        pdbc.close()



# Note that this runs the query every time the airflow heartbeat triggers(!)
dags = process_new_accounts()

for dag in dags:
    # the child dag name
    dag_name=dag["name"]
    dag_args = {
        'owner': 'airflow',
        'start_date': datetime.strptime(dag["start_date"], "%Y-%m-%d %H:%M:%S"),
        'depends_on_past': bool(dag["depends_on_past"]),
        'retries': dag["retries"],
        'retry_delay': timedelta(minutes=dag["retry_delay"]),
        'dagrun_timeout': timedelta(minutes=dag["dagrun_timeout"])
    }

    # the DAG creation cannot be in a Sensor or other Operator
    _dag = DAG(
        dag_id="%s.%s"%(group_dag_name,dag["name"]),
        default_args=dag_args,
        schedule_interval=dag["schedule_interval"]  # defaults to timedelta(1) - '@once' runs it right away, one time
    )

    pdbc = MyPdbc()
    operator_sql = "select * from dynamic_dag_operator where dag_id={} order by id".format(dag["id"])
    operators = pdbc.execute(operator_sql)
    pdbc.close()
    for opt in operators:
        pdbc = MyPdbc()
        if opt["operator"]=="PythonOperator":
            python_sql = "select * from dynamic_dag_operator_python where operator_id={}".format(opt["id"])
            python_func_item = pdbc.execute(python_sql)[0]
            ## This hits the account export url, _internal/accounts/export?id={ACCOUNT_ID}&token={AUTH_TOKEN}
            dynamic_func_code = compile('''
def dynamic_step_func(ds,**kwargs):
%s
''' % python_func_item["code"], "<string>", "exec")
            dynamic_func = FunctionType(dynamic_func_code.co_consts[0], globals(), "dynamic_step_func")
            exec ("%s=PythonOperator(task_id='%s',provide_context=True,python_callable=dynamic_func,dag=_dag)"%(opt["name"],opt["name"])) in globals(),locals()
        if opt["down_stream"]:
            exec ("%s.set_downstream(%s)"%(opt["name"],opt["down_stream"])) in globals(),locals()
    print("Created account processing DAG {}".format(_dag.dag_id))
    # register the dynamically created DAG in the global namespace
    globals()[dag_name] = _dag
