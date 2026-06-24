.PHONY: pdf serve

pdf:
	scripts/generate-pdfs.sh

serve:
	hugo server
