from neo4j import GraphDatabase
import sys
import os


def check_db_empty(uri, user, password):
    driver = GraphDatabase.driver(uri, auth=(user, password))
    with driver.session() as session:
        result = session.run("MATCH (n) RETURN COUNT(n) AS count")
        count = result.single()[0]
        return count == 0


def main():
    NEO4J_URI = os.getenv("NEO4J_URI", "bolt://neo4j:7687")
    NEO4J_USERNAME = os.getenv("NEO4J_USERNAME", "neo4j")
    NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

    if check_db_empty(NEO4J_URI, NEO4J_USERNAME, NEO4J_PASSWORD):
        print("Neo4j is empty.")
        sys.exit(0)
    else:
        print("Neo4j already contains data. Skipping ingest.py...")
        sys.exit(1)


if __name__ == "__main__":
    main()
