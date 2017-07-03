
gh-pages:
	git checkout gh-pages
	find ./* -not -path '*/\.*' -prune -exec rm -r "{}" \;
	git checkout develop docs Makefile src README.rst
	git reset HEAD
	(cd docs && make html)
	mv -fv docs/_build/html/* ./
	rm -rf docs Makefile src README.rst
	touch .nojekyll
	git add -A
	git commit -m "Generated gh-pages for `git log develop -1 --pretty=short --abbrev-commit`" && git push origin gh-pages ; git checkout develop
