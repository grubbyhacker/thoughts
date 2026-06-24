.PHONY: pdf serve

pdf:
	@set -e; \
	for dir in content/writing/*/; do \
		name=$$(basename $$dir); \
		mkdir -p static/writing/$$name; \
		awk 'NR == 1 && $$0 == "---" { in_frontmatter = 1; next } in_frontmatter && $$0 == "---" { in_frontmatter = 0; next } !in_frontmatter { print }' $$dir/index.md | pandoc \
			--from markdown \
			--to pdf \
			--pdf-engine=xelatex \
			--resource-path="$$dir:." \
			--variable mainfont="texgyretermes-regular.otf" \
			-o static/writing/$$name/$$name.pdf; \
		echo "Generated static/writing/$$name/$$name.pdf"; \
	done

serve:
	hugo server
