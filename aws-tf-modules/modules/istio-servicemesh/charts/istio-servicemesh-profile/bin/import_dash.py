#!/usr/bin/env python3
"""
Import Correct versions of Dashboards into Codebase
"""

__author__ = "Steve Randall"
__version__ = "1.0.0"
__license__ = "Commerical"

import argparse
from os.path import join
from os import remove
import re
from collections import OrderedDict
import requests
import yaml

DASH_LIST = [
    {
        'id': '7645',  # Istio Control Plane Dashboard
        'filename': 'pilot-dashboard.yaml',
        'configmap': 'istio-control-plane-dashboard'
    },
    {
        'id': '7639',  # Istio Mesh Dashboard
        'filename': 'istio-mesh-dashboard.yaml',
        'configmap': 'istio-mesh-dashboard'
    },
    {
        'id': '11829',  # Istio Performance Dashboard
        'filename': 'istio-performance-dashboard.yaml',
        'configmap': 'istio-performance-dashboard'
    },
    {
        'id': '7636',  # Istio Service Dashboard
        'filename': 'istio-service-dashboard.yaml',
        'configmap': 'istio-service-dashboard'
    },
    {
        'id': '7630',  # Istio Workload Dashboard
        'filename': 'istio-workload-dashboard.yaml',
        'configmap': 'istio-workload-dashboard'
    },
    {
        'id': '7642',  # Istio Mixer Dashboard
        'filename': 'mixer-dashboard.yaml',
        'configmap': 'mixer-dashboard'
    },
    {
        'id': '13277',  # Istio Wasm Extension Dashboard
        'filename': 'istio-wasm-dashboard.yaml',
        'configmap': 'istio-wasm-dashboard'
    }
]

HEADER = OrderedDict(
    {
        'apiVersion': 'v1',
        'kind': 'ConfigMap',
        'metadata':
            {
                'name': 'istio-control-plane-dashboard',
                'labels': {
                    'grafana_dashboard': "true"
                },
                'annotations': {},
                'namespace': 'monitoring'
            }
    }
)


class quoted(str):
    pass


def quoted_presenter(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')


yaml.add_representer(quoted, quoted_presenter)


class literal(str):
    pass


def literal_presenter(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')


yaml.add_representer(literal, literal_presenter)


def ordered_dict_presenter(dumper, data):
    return dumper.represent_dict(data.items())


yaml.add_representer(OrderedDict, ordered_dict_presenter)


def istio_ver_to_dash(dashid, istio_version):
    """Use the Grafana Website's API to grab the correct download link"""
    try:
        response = requests.get(f"https://grafana.com/api/dashboards/{ dashid }/revisions")
        if response.status_code == 200:
            for item in response.json()['items']:
                if item['description'].endswith(istio_version):
                    link = next((item for item in item['links'] if item['rel'] == 'download'), None)
                    return f"https://grafana.com/api{link['href']}"
        else:
            return None
    except requests.exceptions.RequestException as e:
        # catastrophic error. bail.
        raise SystemExit(e)


def download_dash(url):
    """Download the Dashboard json from the grafana site"""
    try:
        response = requests.get(url)
        return response.text
    except requests.exceptions.RequestException as e:
        # catastrophic error. bail.
        raise SystemExit(e)


def main(args):
    """ Let's get this party started """
    for dash in DASH_LIST:
        downloadlink = istio_ver_to_dash(dash['id'], args.version)
        # hacky workaround to avoid Go interpolation of our large dashboard JSONs
        file_filename = join(args.files, dash['filename'])
        template_filename = join(args.templates, dash['filename'])
        if downloadlink:
            dashjson = download_dash(downloadlink)
            # Grafana ConfigMap import doesn't support interpolation [yet]
            dashjson = re.sub('\${DS_PROMETHEUS}', 'Prometheus', dashjson)
            # Build our record
            record = HEADER
            record['metadata']['name'] = dash['configmap']
            record['metadata']['annotations']['source'] = downloadlink
            record['data'] = {}
            record['data'][f"{dash['configmap']}.json"] = literal(dashjson)
            # write it as YAML - Grafana dashboards use lots of {{}} which Helm doesn't like - so we import as literals
            print(f"Creating file {file_filename}")
            file = open(file_filename, 'w')
            file.write(yaml.dump(record))
            file.close
            print(f"Creating file {template_filename}")
            file = open(template_filename, 'w')
            # file.write(yaml.dump(record))
            file_parts = file_filename.rsplit('/', 3)
            file_ref =  "/".join((file_parts[-2], file_parts[-1]))
            file.write(f'{"{{"} (.Files.Get \"{file_ref}\") {"}}"}')
            file.close

        else:
            print (f"Version {args.version} does not have '{dash['configmap']}' dashboard, deleting {file_filename} & {template_filename}")
            try:
                remove(file_filename)
                remove(template_filename)
            except OSError:
                pass



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--templates", action="store", default="../templates", help="Location of templates folder")
    parser.add_argument("-f", "--files", action="store", default="../files", help="Location of files folder")
    parser.add_argument(
        "-v", "--version", action="store", default="1.7.5",
        help="Version of Istio Files to Download (default: 1.7.5)"
    )
    args = parser.parse_args()
    main(args)
