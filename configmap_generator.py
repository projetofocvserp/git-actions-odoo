import yaml
from io import StringIO
import configparser

with open('config_map.yaml', 'r') as f:
    data = yaml.safe_load(f)

ini_str = data['data']['odoo.conf']
ini_file = StringIO(ini_str)
config = configparser.ConfigParser()
config.read_file(ini_file)

config.set('options', 'addons_path',
           '/usr/lib/python3/dist-packages/odoo/addons, /mnt/extra-addons/sessions, /mnt/extra-addons/server-tools')

with StringIO() as ini_file:
    config.write(ini_file)
    ini_str_updated = ini_file.getvalue()

data['data']['odoo.conf'] = ini_str_updated


def save_to_configmap_file() -> None:
    with open('config_map.yaml', 'w') as f:
        yaml.safe_dump(data, f)


if __name__ == '__main__':
    save_to_configmap_file()
