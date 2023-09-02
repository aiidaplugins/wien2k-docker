from pathlib import Path

cj_path = Path(QueryBuilder().append(CalcJobNode).first()[0].get_remote_workdir())

case_path = cj_path / 'case'
case_path.rename('/home/aiida/aiida_run/case')

stderr_path = cj_path / '_scheduler-stderr.txt'
stderr_path.rename('/home/aiida/aiida_run/case/stderr.log')
