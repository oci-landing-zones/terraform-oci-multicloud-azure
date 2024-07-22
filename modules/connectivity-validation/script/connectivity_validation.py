import logging
import subprocess

import argparse

logging.basicConfig(filename="connectivity_validation.log", level=logging.INFO, format="%(levelname)s:%(message)s")


def validate_connectivity(db_admin_password, long_connection_string):
    try:
        dbsession = subprocess.Popen([f"sqlplus sys/{db_admin_password}@'{long_connection_string} as sysdba'"],
                                     shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        query = '''SELECT name FROM v$database;
                       exit'''
        logging.info(f"Checking connectivity. Running SQL query: {query}")
        dbsession.stdin.write(query.encode('utf-8'))
        query_result, err = dbsession.communicate(timeout=15)
        if err:
            logging.error(f"Failed to connect to db: {err.strip()}")
            raise Exception(err.strip())
    except subprocess.CalledProcessError as e:
        logging.error("Failed to connect to db.")
        logging.error(e.output)
        logging.error("Connectivity validation Failed!")
    except subprocess.TimeoutExpired as e:
        logging.error("Failed to connect to db. hint: please check your connection string.")
        logging.error(e.output)
        logging.error("Connectivity validation Failed!")
    else:
        db_name = long_connection_string.split("SERVICE_NAME=")[1].split("_")[0]
        validate_db_name(query_result, db_name)
    finally:
        return


def validate_db_name(query_result, db_name):
    query_result = query_result.decode("utf-8").split("SQL>")
    logging.info(query_result[0].lstrip().rstrip())
    query_returned_db_name = query_result[1].strip().splitlines()[2]
    if query_returned_db_name == db_name:
        logging.info(
            f"SQL query returned db name is {query_returned_db_name} that matches with given database name {db_name}. Connectivity validation Passed!")
    else:
        logging.info(
            f"SQL query returned db name is {query_returned_db_name} that DOESN'T match with given database "
            f"name {db_name}. Connectivity validation Failed!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-p', '--db_admin_password',
                        help='db_admin_password',
                        required=True)
    parser.add_argument('-s', '--cdb_long_connection_string',
                        help='cdb_long_connection_string',
                        required=True)
    parser.add_argument('-c', '--pdb_long_connection_string',
                        help='pdb_long_connection_string',
                        required=True)
    args = parser.parse_args()
    validate_connectivity(db_admin_password=args.db_admin_password,
                          long_connection_string=args.cdb_long_connection_string)
    validate_connectivity(db_admin_password=args.db_admin_password,
                          long_connection_string=args.pdb_long_connection_string)
