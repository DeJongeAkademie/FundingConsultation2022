import matplotlib.pyplot as plt
import pandas as pd
import os
import yaml
import numpy as np
import requests

QUANTITATIVE_DATA_URL_OSF = 'https://osf.io/f76rb//?action=download'
PATH_TO_QUANTITATIVE_DATA = '../data/dat.csv'
PATH_TO_QUALITATIVE_DATA = '../data/data_character_clean.csv'
PATH_TO_VARIABLE_LABELS = '../data/Variabelen_DJA_shortlabels.csv'
TEXT_FOLDER = 'text'

def get_quantitative_data():
    # download a fresh copy of the dataset from the OSF
    response = requests.get(QUANTITATIVE_DATA_URL_OSF)

    if response.status_code == 200:
        with open(PATH_TO_QUANTITATIVE_DATA, 'wb') as f:
            f.write(response.content)

    quantitative_data = pd.read_csv(PATH_TO_QUANTITATIVE_DATA)
    return quantitative_data


def get_qualitative_data():
    # because of potential identifiability, the textual data is not public.
    # Please contact the DJA Consultation team if you would wish to obtain access to the file referenced here.
    qualitative_data = pd.read_csv(PATH_TO_QUALITATIVE_DATA,  encoding='ISO-8859-1')
    return qualitative_data


def get_variable_labels():
    variable_labels = pd.read_csv(PATH_TO_VARIABLE_LABELS, encoding='ISO-8859-1')
    return variable_labels


def get_query_indexes():
    return yaml.safe_load(open('../data/value_labels.yml'))

def get_textual_indexes():
    return yaml.safe_load(open('../data/value_labels_dat.yml'))


def select_from_quantitative_data(quantitative_data, conditions):
    selection = quantitative_data

    for condition in conditions:
        condition_outcomes_to_select = conditions[condition]
        selection = selection.loc[selection[condition].isin(condition_outcomes_to_select)]

    return selection


def match_to_qualitative_responses(quantitative_data, qualitative_data):
    qualitative_selection = qualitative_data.loc[qualitative_data['id'].isin(quantitative_data['id'])]

    return qualitative_selection


def export_qualitative_responses(qualitative_data, column, file_name):
    if not os.path.exists(TEXT_FOLDER):
        os.mkdir(TEXT_FOLDER)

    TARGET_FILE_PATH = os.path.join(TEXT_FOLDER, '%s'% file_name)
    f = open(TARGET_FILE_PATH, 'w')
    f.close()

    for row_index, entry in qualitative_data.iterrows():

        if not pd.isna(entry[column]):
            entry_id = entry['id']

            f = open(TARGET_FILE_PATH, 'a')
            f.write('%s\n%s\n\n' % (entry_id, entry[column]))
            f.close()
