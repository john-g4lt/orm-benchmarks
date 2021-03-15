checkfiles = benchmarks/
black_opts = -l 100 -t py38
PASSWORD ?= "123456"

up:
	@poetry update

deps:
	@poetry install

style: deps
	isort -src $(checkfiles)
	black $(black_opts) $(checkfiles)

check: deps
	black --check $(black_opts) $(checkfiles) || (echo "Please run 'make style' to auto-fix style issues" && false)
	flake8 $(checkfiles)
	bandit -r $(checkfiles)

benchmark: deps
	sh benchmarks/benchmark_all.sh