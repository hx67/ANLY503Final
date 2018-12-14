import pandas as pd
import numpy as np

import matplotlib.pyplot as plt
import seaborn as sns
import plotly.plotly as py
from plotly import graph_objs as go
import os
plotly.tools.set_credentials_file(username='hx67', api_key='g7uTjz7ggl9FaNKuvI6B')

input_path = './Data/globalterrorismdb_0718dist.csv'

data = pd.read_csv(input_path, encoding = 'ISO-8859-1', low_memory = False)
data.head()

uniques = data.nunique()
missing = data.isnull().sum()
trace = go.Scatter(
    x = uniques.index,
    y = uniques.values / data.shape[0] * 100,
    mode = 'markers',
    name = 'Unique %',
    marker = dict(
        #size = uniques.values / data.shape[0] * 100,
        sizemode = 'area',
        color = np.random.randn(len(uniques))
    )
)

trace1 = go.Scatter(
    x = missing.index,
    y = missing.values / data.shape[0] * 100,
    mode = 'markers',
    name = 'Missing %',
    marker = dict(
        #size = missing.values / data.shape[0] * 100,
        sizemode = 'area',
        color = np.random.randn(len(missing)),
        opacity = 0.5
    )
)

layout = go.Layout(
    title = 'Distinct Feature Information',
    xaxis = dict(
        title = 'Feature Names'
    ),
    yaxis = dict(
        title = 'Percentage of Values'
    )
)

fig = go.Figure(data = [trace, trace1], layout = layout)
py.plot(fig, filename='heatmap')
