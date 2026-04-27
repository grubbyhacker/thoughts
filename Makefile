.PHONY: pdf serve

pdf:
	@for dir in content/writing/*/; do \
		name=$$(basename $$dir); \
		mkdir -p static/writing/$$name; \
		sed '1,/^---$$/d' $$dir/index.md | pandoc \
			--from markdown \
			--to pdf \
			--pdf-engine=xelatex \
			--resource-path="$$dir:." \
			--variable mainfont="DejaVu Serif" \
			-o static/writing/$$name/$$name.pdf; \
		echo "Generated static/writing/$$name/$$name.pdf"; \
	done

serve:
	hugo server
