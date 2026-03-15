from datetime import datetime
from airflow.models import Variable
from airflow.decorators import dag, task
from airflow.providers.mysql.hooks.mysql import MySqlHook
import pendulum
import json

@dag(
    start_date=pendulum.datetime(2024, 1, 1),
    schedule="@hourly",
    catchup=False
)
def support_call_dag():

    @task
    def new_calls():
        last_loaded = Variable.get("last_loaded_call_time", default_var='1970-01-01 00:00:00')
        print(f"Checking for new support calls since {last_loaded}...")

        mysql_hook = MySqlHook(mysql_conn_id='mysql_db_conn')

        call_i = "SELECT call_id FROM calls WHERE call_time > %s"
        lc = mysql_hook.get_records(call_i, parameters=(last_loaded,))
        new_call_ids = [row[0] for row in lc]

        print(f"Found {len(new_call_ids)} new calls: {new_call_ids}")
        return new_call_ids

    @task
    def process_calls(call_ids: list) -> list:
        results = []
        directory_path = '/usr/local/airflow/data'
        required_fields = {'call_id', 'duration_sec', 'short_description'}  

        for call_id in call_ids:
            file_path = f"{directory_path}/call_{call_id}.json"
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    call_data = json.load(f)

                    missing = required_fields - call_data.keys()
                    if missing:
                        print(f"Call {call_id} is missing required fields: {missing}. Skipping.")
                        continue

                    results.append(call_data)
                    print(f"Processed call {call_id} from {file_path}")
            except FileNotFoundError:
                print(f"File for call {call_id} not found at {file_path}. Skipping.")
            except json.JSONDecodeError:
                print(f"Error decoding JSON for call {call_id} in file {file_path}. Skipping.")

        print(f"Successfully validated {len(results)} / {len(call_ids)} calls.")
        return results

    @task
    def tr_and_ld_db(processed_calls: list) -> None:
        import duckdb

        if not processed_calls:
            print("No calls to load into the database.")
            return

        print(f"Loading {len(processed_calls)} processed calls into the database...")

        mysql_hook = MySqlHook(mysql_conn_id='mysql_db_conn')
        call_ids = [c['call_id'] for c in processed_calls]
        placeholders = ','.join(['%s'] * len(call_ids))

        query = f"""
            SELECT c.call_id, c.employee_id, e.full_name, e.team,
                   c.call_time, c.phone, c.direction, c.status
            FROM calls c
            JOIN employees e ON c.employee_id = e.employee_id
            WHERE c.call_id IN ({placeholders})
        """
        rows = mysql_hook.get_records(query, parameters=call_ids)
        mysql_data = {row[0]: row for row in rows}
        print(f"Fetched MySQL data for {len(mysql_data)} calls.")

        db_path = '/usr/local/airflow/include/support_call_enriched.db'  
        duckdb_con = duckdb.connect(db_path)

        duckdb_con.execute("""
            CREATE TABLE IF NOT EXISTS support_call_enriched (
                call_id          INTEGER PRIMARY KEY,
                employee_id      INTEGER,
                full_name        VARCHAR,
                team             VARCHAR,
                call_time        TIMESTAMP,
                phone            VARCHAR,
                direction        VARCHAR,
                status           VARCHAR,
                duration_sec     INTEGER,
                short_description VARCHAR
            )
        """)

        inserted = 0
        skipped = 0
        for call in processed_calls:
            cid = call['call_id']
            mysql_row = mysql_data.get(cid)

            if not mysql_row:
                print(f"No MySQL record found for call {cid}. Skipping.")
                skipped += 1
                continue

            duckdb_con.execute("""
                INSERT OR REPLACE INTO support_call_enriched
                    (call_id, employee_id, full_name, team,
                     call_time, phone, direction, status,
                     duration_sec, short_description)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                mysql_row[0],           
                mysql_row[1],           
                mysql_row[2],          
                mysql_row[3],          
                mysql_row[4],          
                mysql_row[5],           
                mysql_row[6],          
                mysql_row[7],           
                call['duration_sec'],
                call['short_description']
            ))
            inserted += 1
            print(f"Inserted/Updated call {cid} into the database.")

        print(f"Done: {inserted} inserted, {skipped} skipped.")

        result = duckdb_con.execute("SELECT * FROM support_call_enriched").fetchall()
        print(f"Current rows in support_call_enriched: {result}")
        duckdb_con.close()

        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        Variable.set("last_loaded_call_time", current_time)
        print(f"Updated last_loaded_call_time to {current_time}")

    new_call_ids = new_calls()
    processed_calls = process_calls(new_call_ids)
    tr_and_ld_db(processed_calls)

support_call_dag()
