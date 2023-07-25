import configparser
from io import StringIO
from pathlib import Path
from typing import Any, Dict

import yaml


def get_submodules_from_extra_addons_folder() -> str:
    BASE = Path('extra-addons')
    submodule_paths = ["/mnt/" + str(module)
                       for module in BASE.glob('*') if module.is_dir()]
    return ', '.join(submodule_paths)


def generate_new_configmap() -> Dict[str, Any]:
    with open('config_map.yaml', 'r') as f:
        data = yaml.safe_load(f)

    ini_str = data['data']['odoo.conf']
    ini_file = StringIO(ini_str)
    config = configparser.ConfigParser()
    config.read_file(ini_file)

    config.set('options', 'addons_path',
               get_submodules_from_extra_addons_folder())

    with StringIO() as ini_file:
        config.write(ini_file)
        ini_str_updated = ini_file.getvalue()

    data['data']['odoo.conf'] = ini_str_updated
    return data


def save_to_configmap_file(data: Dict[str, Any]) -> None:
    with open('config_map.yaml', 'w') as f:
        yaml.safe_dump(data, f)


if __name__ == '__main__':
    save_to_configmap_file(data=generate_new_configmap())
