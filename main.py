# -*- coding: utf-8 -*-
# __maintainer__ = marcelomarcon

import subprocess
from io import StringIO
from pathlib import Path

import yaml


def get_submodules_from_extra_addons_folder() -> str:
    base_path = Path("extra-addons")
    submodule_paths = [
        "/mnt/" + str(module) for module in base_path.glob("*") if module.is_dir()
    ]
    return ", ".join(submodule_paths)


def generate_new_configmap():
    with open("configmap.yaml", "r", encoding="utf-8") as f:
        config_data = yaml.safe_load(f)

    odoo_config = config_data.get('data', {}).get('odoo.conf', '')
    lines = odoo_config.split('\n')

    new_addons_path = get_submodules_from_extra_addons_folder()
    for i, line in enumerate(lines):
        if line.strip().startswith("addons_path ="):
            lines[i] = "addons_path = /usr/lib/python3/dist-packages/odoo/addons, " + new_addons_path

    config_data['data']['odoo.conf'] = '\n'.join(lines)

    patch_data = {
        "data": {
            "odoo.conf": config_data['data']['odoo.conf']
        }
    }

    yaml_str = StringIO()
    yaml.dump(patch_data, yaml_str)
    return yaml_str.getvalue()


print(generate_new_configmap())