"""PubData2XL Views."""
import io
import os
import uuid
import datetime
import urllib.request as urllib
from xml.etree import ElementTree

from django.urls import reverse
from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.conf import settings

#from Bio import Medline
import pandas as pd

from .forms import GetPMIDsForm
from .helpers import get_xml, get_initialize_form #get_all_data, 

N = 300
TESTING = False
APP_PATH = os.path.dirname(os.path.abspath(__file__)) # Gets path of the _init_.py file
xslt_file = os.path.join(APP_PATH, "PubMed_XML_to_Pandas_Transformer.xsl")
MEDLINE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed"
MEDLINE_URL = MEDLINE_URL + "&api_key=" + settings.NCBI_API_KEY
MEDLINE_URL = MEDLINE_URL + "&rettype=medline"
MEDLINE_URL = MEDLINE_URL + "&retmode=xml&id="
CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
DECLARATION_AND_DOCTYPE = '''<?xml version="1.0" ?>
<!DOCTYPE PubmedArticleSet PUBLIC "-//NLM//DTD PubMedArticle, 1st January 2025//EN" "https://dtd.nlm.nih.gov/ncbi/pubmed/out/pubmed_250101.dtd">
'''

def redirect_view(request, pmid):
    response = redirect(reverse("pubdata2xl:download_excel") + pmid)
    return response

def news(request, pmid):
    """."""
    context = {'time': datetime.datetime.now().strftime ("%B %d, %Y")} #October 10, 2020
    template = "pubdata2xl/news.html"
    context["page_h1_title"] = "PubData2XL"
    context['form'] = get_initialize_form(pmid, news=True)
    return render(request, template, context)

def download_excel(request, pmid):
    """."""
    context = {"page_h1_title": "PubData2XL", "download_button_text": "Download Excel File"}
    template = 'pubdata2xl/index.html'
    if request.method == "GET":
        context['form'] = get_initialize_form(pmid)
    elif request.method == "POST":
        if GetPMIDsForm(request.POST).is_valid():
            pmids = request.POST.get("pmids").strip().split('\r\n')
            pmids = [x for x in pmids if x] #remove empty strings.
            pubmed_data = pd.DataFrame()
            batches = [pmids[i * N:(i + 1) * N] for i in range((len(pmids) + N - 1) // N )]
            for batch in batches:
                batch_url = MEDLINE_URL + ",".join(batch)
                print(batch_url)
                temp_df = pd.read_xml(batch_url, xpath="/Citation", stylesheet=xslt_file, dtype=str)
                pubmed_data = pd.concat([pubmed_data, temp_df], ignore_index=True)
            output = io.BytesIO()
            writer = pd.ExcelWriter(output, engine='xlsxwriter')
            pubmed_data = pubmed_data.apply(lambda x: x.str.replace("{--","<").str.replace("--}",">"))
            pubmed_data.to_excel(writer, sheet_name='PubData2XL', index=False, header=True)
            writer.close()
            response = HttpResponse(output.getvalue(), content_type=CONTENT_TYPE)
            response['Content-Disposition'] = "attachment; filename=" + str(uuid.uuid1()) + ".xlsx"
            return response
        else:
            context['form'] = GetPMIDsForm(request.POST)
            return render(request, 'pubdata2xl/index.html', context)
    return render(request, template, context)


    
def download_xml(request, pmid):
    """."""
    context = {"page_h1_title": "PubData2XML", "download_button_text": "Download XML File"}
    template = 'pubdata2xl/xml.html'
    if request.method == "GET":
        context['form'] = get_initialize_form(pmid)
    elif request.method == "POST":
        if GetPMIDsForm(request.POST).is_valid():
            pmids = request.POST.get("pmids").strip().split('\r\n')
            pmids = [x for x in pmids if x] #remove empty strings.
            data = None
            for batch in [pmids[i * N:(i + 1) * N] for i in range((len(pmids) + N - 1) // N )]:
                batch_url = MEDLINE_URL + ",".join(batch)
                tree = get_xml(batch_url)
                root = tree.getroot()
                if data is None:
                    data = root
                else:
                    data.extend(root)
            doc = ElementTree.tostring(data).decode('utf-8')
            response = HttpResponse(f"{DECLARATION_AND_DOCTYPE}{doc}", content_type="application/xml")
            response['Content-Disposition'] = "attachment; filename=" + str(uuid.uuid1()) + ".xml"
            return response
        else:
            context['form'] = GetPMIDsForm(request.POST)
            return render(request, template, context)
    return render(request, template, context)
