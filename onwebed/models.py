from django.db import models

# Create your models here.

class SiteAttribute(models.Model):
	key = models.CharField(max_length = 80, unique = True)
	value = models.CharField(max_length = 100)