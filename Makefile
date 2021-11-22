.PHONY: setup build-pre-processing upload-pre-processing dbt-sync

-include .env

setup:
	@cp .env-dist .env

build-pre-processing:
	python -m ingenii_data_engineering pre_processing_package pre_process

upload-pre-processing:
	az storage blob upload --account-name $(UTILITIES_STORAGE_ACCOUNT_NAME) --account-key $(UTILITIES_STORAGE_ACCOUNT_KEY) -f dist/pre_process-1.0.0-py3-none-any.whl -c utilities -n pre_process/pre_process-1.0.0-py3-none-any.whl

create-data-factory-objects:
	python -m azure_data_factory_generator pipeline_generation pipeline_generation

dbt-sync:
	az storage blob sync --account-name $(UTILITIES_STORAGE_ACCOUNT_NAME) --account-key $(UTILITIES_STORAGE_ACCOUNT_KEY) -c dbt -s dbt
