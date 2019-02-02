from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from pages.models import Page
import re


def unescape(string):
	return \
		string \
			.encode("utf-8") \
			.decode('unicode_escape')

def write_template_file(page_name, page_content):
	path = \
		"pages/templates/pages/cached/" \
			+ page_name \
			+ ".html"
			
	if default_storage.exists(path):
		default_storage.delete(path)

	default_storage.save(
		path
		, ContentFile(page_content)
	)


def page_name(page_tag):
	return page_tag[10:-3].strip()


def fill_name(fill_tag):
	return fill_tag[10:-2].strip()


def hole_name(hole_tag):
	return hole_tag[10:-2].strip()


def process_content(content):
	# page inclusions

	page_tags = re.findall("<page id=\"[^\"]+\"\/>", content)

	page_names = []
	for page_tag in page_tags:
		page_names.append(page_name(page_tag))

	pages = Page.objects.filter(name__in = page_names)

	for page in pages:
		content = \
			re.sub("<page id=\"" + page.name + "\"/>"
				, process_content(page.html_content)
				, content)

	
	# fills

	fill_tags = re.findall("<fill id=\"[^\"]+\">", content)

	fills = []
	# fill_names, fill_contents = [], []
	for fill_tag in fill_tags:
		pos = content.find("<fill id=\"" + fill_name(fill_tag) + "\">")
		length = len("<fill id=\"" + fill_name(fill_tag) + "\">")
		
		pos2 = content.find("</fill>", pos + length)

		fills.append({
			'name': fill_name(fill_tag),
			'content': content[(pos + length):pos2]
		})

		content = content[:pos] + content[(pos2 + len("</fill>")):]

	# holes

	hole_tags = re.findall("<hole id=\"[^\"]+\">", content)

	for hole_tag in hole_tags:
		pos = content.find("<hole id=\"" + hole_name(hole_tag) + "\">")
		length = len("<hole id=\"" + hole_name(hole_tag) + "\">")
		
		pos2 = content.find("</hole>", pos + length)

		for fill in fills:
			if hole_name(hole_tag) == fill['name']:
				content = content[:pos] + fill['content'] + content[(pos2 + len("</hole>")):]

	return content


def remove_holes(content):
	hole_tags = re.findall("<hole id=\"[^\"]+\">", content)

	for hole_tag in hole_tags:
		pos = content.find("<hole id=\"" + hole_name(hole_tag) + "\">")
		length = len("<hole id=\"" + hole_name(hole_tag) + "\">")
		
		pos2 = content.find("</hole>", pos + length)

		content = content[:pos] + content[(pos + length):pos2] + content[(pos2 + len("</hole>")):]

	return content


def cache_page(page_name, content):
	write_template_file(page_name, remove_holes(process_content(content)))
	Page.objects.filter(name = page_name).update(is_cached = True)