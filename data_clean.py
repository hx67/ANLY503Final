# -*- coding: utf-8 -*-
"""
Created on Thu Nov 29 20:13:50 2018

@author: hongx
"""

import pandas as pd
import re

gtdb = pd.read_csv(
    './Data/globalterrorismdb_0718dist.csv', encoding = "ISO-8859-1")

replace_list = [' & Caribbean', 'Middle East & North ', 'Australasia & ',
                'East ', 'Southeast ', 'Sub-Saharan ', 'Western ', 'Eastern ']

changed_region = list(
    map(lambda x: re.sub(
        r'|'.join(map(re.escape, replace_list)), '', x), gtdb['region_txt']))

changed_region = list(
    map(lambda x: x.replace(
        "Central America", "North America"), changed_region))
changed_region = list(
    map(lambda x: x.replace("South Asia", "Asia"), changed_region))
changed_region = list(
    map(lambda x: x.replace("Central Asia", "Asia"), changed_region))

gtdb["General_region"] = changed_region
gtdb.to_csv('./Data/globalterrorismdb_0718dist.csv')