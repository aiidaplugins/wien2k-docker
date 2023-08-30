from pathlib import Path

Path(QueryBuilder().append(CalcJobNode).first()[0].get_remote_workdir()).rename('/home/aiida/testrun')
