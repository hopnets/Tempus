import csv
import numpy as np

file_name = 'dc_propagation_random_100G.csv'

first_line = False
m_array = []
with open(file_name, mode ='r')as file:
    csvFile = csv.reader(file)
    for lines in csvFile:
        if not first_line:
            first_line = True
            continue
        m_array.append(float(lines[0]))


print('min: {}, max: {}, mean: {}, p50: {}, p99: {}'.format(
    min(m_array), max(m_array), np.mean(m_array), np.percentile(m_array, 50), np.percentile(m_array, 99)
))