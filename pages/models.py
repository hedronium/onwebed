from django.db import models

# Create your models here.

class Page(models.Model):
	title = models.CharField(max_length = 100)
	name = models.CharField(max_length = 80, unique = True)
	content = models.TextField()
	html_content = models.TextField()
	is_cached = models.BooleanField(default = False)
	updated_at = models.DateTimeField(auto_now = True)
	created_at = models.DateTimeField(auto_now_add = True)