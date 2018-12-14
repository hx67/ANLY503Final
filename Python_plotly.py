# -*- coding: utf-8 -*-
"""
Created on Mon Dec 10 23:26:31 2018

@author: hongx
"""

import numpy as np
import pandas as pd
import plotly
import plotly.plotly as py
import plotly.graph_objs as go
from plotly.offline import download_plotlyjs, init_notebook_mode, plot, iplot
init_notebook_mode(connected=True) 

plotly.tools.set_credentials_file(
    username='hx67', api_key='sbazuFCeil4v1wHCr42h')

input_file = "./Data/globalterrorismdb_0718dist.csv"

df = pd.read_csv(
    input_file, header = 0,usecols=['iyear', 'imonth', 'iday', 
                                    'extended', 'country', 'country_txt',
                                    'region', 'latitude', 'longitude',
                                    'success', 'suicide','attacktype1',
                                    'attacktype1_txt', 'targtype1', 
                                    'targtype1_txt', 'natlty1','natlty1_txt',
                                    'weaptype1', 'weaptype1_txt' ,'nkill',
                                    'multiple', 'individual', 'claimed',
                                    'nkill','nkillter', 'nwound', 'nwoundte'])

df = df.drop([ 'region', 'claimed', 'nkillter', 'nwound','nwoundte'], axis=1) 

terror_peryear = np.asarray(df.groupby('iyear').iyear.count())
successes_peryear = np.asarray(df.groupby('iyear').success.sum())
killed_peryear = np.asarray(df.groupby('iyear').nkill.sum())


terror_years = np.arange(1970, 2018)
terror_years = np.delete(terror_years, [23])

trace1 = go.Bar(x = terror_years, y = terror_peryear, 
                name = 'Number of Terrorist Attacks', 
                width = dict(color = 'rgb(118,238,198)', width = 3))

trace2 = go.Scatter(x = terror_years, y = successes_peryear,
                    name = 'Number of Succesful Terrorist Attacks', 
                    line = dict(color = ('rgb(205, 12, 24)'), width = 5,))

layout = go.Layout(
    title = 'Terrorist Attacks by Year (1970-2017)', 
    xaxis = dict(title = 'Year'), yaxis = dict(title = 'Number of Attacks'),
    legend=dict(orientation="h"), barmode = 'group')

figure = dict(data = [trace1,trace2], layout = layout)

plot(figure)

rate_peryear = successes_peryear/terror_peryear

df_rate = pd.DataFrame({"Year":terror_years.tolist(),
                        "Success_Rate": rate_peryear.tolist(),
                        "People_Killed":killed_peryear})

df_rate.to_csv("./Data/rate.csv", encoding='utf-8')



