from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from .models import Page
from onwebed.core import CoreSingleton

# Create your views here.

def index(request):
	return render(request, "pages/index.html")


def list(request):
	context = {
		'pages': Page.objects.all()
	}

	return render(request, "pages/list.html", context)


def create(request):
	if request.method == "POST":
		title = request.POST['title']
		name = request.POST['name']

		Page.objects.create(title = title, name = name)

		messages.success(request, 'Page created successfully!')

		return redirect("pages:list")

	return render(request, "pages/create.html")


def edit(request, page_id):
	page = get_object_or_404(Page, pk = page_id)

	if request.method == "POST":
		page.content = request.POST["content"]
		page.name = request.POST["name"]
		page.title = request.POST["title"]
		page.html_content = CoreSingleton.getInstance().unescape(request.POST["template_content"])
		page.save()

		# expire all page caches
		Page.objects.all().update(is_cached = False)

		# write the template file
		CoreSingleton.getInstance().cache_page(page.name, page.html_content)
		
		# messages.success(request, 'Page saved successfully!')

	context = {
		'page': page
	}

	return render(request, "pages/edit.html", context)


def delete(request, page_id):
	if request.method == "POST":
		page = get_object_or_404(Page, pk = page_id)
		page.delete()

		messages.success(request, 'Page deleted successfully!')
		return redirect("pages:list")

	context = {
		'page': get_object_or_404(Page, pk = page_id)
	}

	return render(request, "pages/delete.html", context)


def detail(request, page_id):
	page = get_object_or_404(Page, pk = page_id)

	context = {
		'page': page
	}

	if not page.is_cached:
		CoreSingleton.getInstance().cache_page(page.name, page.html_content)

	return render(request, "pages/cached/" + page.name + ".html", context)


def detail_by_name(request, page_name):
	page = get_object_or_404(Page, name = page_name)

	context = {
		'page': page,
		'pages': Page.objects.all()
	}

	if not page.is_cached:
		CoreSingleton.getInstance().cache_page(page.name, page.html_content)

	return render(request, "pages/cached/" + page.name + ".html", context)