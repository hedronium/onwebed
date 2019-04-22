from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from pages.models import Page
import re

class CoreSingleton:
    instance = None

    @staticmethod
    def getInstance():
        if (CoreSingleton.instance == None):
            CoreSingleton.instance = CoreSingleton();

        return CoreSingleton.instance;


    def unescape(self, string):
        return \
            string \
                .encode("utf-8") \
                .decode('unicode_escape')

    def write_template_file(self, page_name, page_content):
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


    def page_name(self, page_tag):
        return page_tag[10:-3].strip()


    def fill_name(self, fill_tag):
        return fill_tag[10:-2].strip()


    def hole_name(self, hole_tag):
        return hole_tag[10:-2].strip()


    def process_content(self, content):
        # page inclusions

        page_tags = re.findall("<page id=\"[^\"]+\"\/>", content)

        page_names = []
        for page_tag in page_tags:
            page_names.append(self.page_name(page_tag))

        pages = Page.objects.filter(name__in = page_names)

        for page in pages:
            content = \
                re.sub("<page id=\"" + page.name + "\"/>"
                    , self.process_content(page.html_content)
                    , content)

        
        # fills

        fill_tags = re.findall("<fill id=\"[^\"]+\">", content)

        fills = []
        for fill_tag in fill_tags:
            pos = content.find("<fill id=\"" + self.fill_name(fill_tag) + "\">")
            length = len("<fill id=\"" + self.fill_name(fill_tag) + "\">")
            
            pos2 = content.find("</fill>", pos + length)

            fills.append({
                'name': self.fill_name(fill_tag),
                'content': content[(pos + length):pos2]
            })

            content = content[:pos] + content[(pos2 + len("</fill>")):]

        # holes

        hole_tags = re.findall("<hole id=\"[^\"]+\">", content)

        for hole_tag in hole_tags:
            pos = content.find("<hole id=\"" + self.hole_name(hole_tag) + "\">")
            length = len("<hole id=\"" + self.hole_name(hole_tag) + "\">")
            
            pos2 = content.find("</hole>", pos + length)

            for fill in fills:
                if self.hole_name(hole_tag) == fill['name']:
                    content = content[:pos] + fill['content'] + content[(pos2 + len("</hole>")):]

        return content


    def remove_holes(self, content):
        hole_tags = re.findall("<hole id=\"[^\"]+\">", content)

        for hole_tag in hole_tags:
            pos = content.find("<hole id=\"" + self.hole_name(hole_tag) + "\">")
            length = len("<hole id=\"" + self.hole_name(hole_tag) + "\">")
            
            pos2 = content.find("</hole>", pos + length)

            content = content[:pos] + content[(pos + length):pos2] + content[(pos2 + len("</hole>")):]

        return content


    def cache_page(self, page_name, content):
        self.write_template_file(
            page_name,
            self.remove_holes(
                self.process_content(
                    content)))
        Page.objects.filter(name = page_name).update(is_cached = True)