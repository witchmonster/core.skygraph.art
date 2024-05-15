.PHONY: all csv-import

csv-import:
	@./csv_import.sh

csv-import-dump:
	@./csv_import.sh -o

csv-import-monthly:
	@./csv_import.sh -m