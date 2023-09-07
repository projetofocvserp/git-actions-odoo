# -*- coding: utf-8 -*-
# __maintainer__ = marcelomarcon

from pathlib import Path


def get_submodules_from_extra_addons_folder() -> str:
    base_path = Path(".")
    submodule_paths = [
        "/mnt/" + str(module) for module in base_path.glob("*") if module.is_dir()
    ]
    return ", ".join(submodule_paths)


def generate_new_configmap():
    with open("config_map.yaml", "r", encoding="utf-8") as f:
        lines = f.readlines()

    start_line = None
    end_line = None

    for i, line in enumerate(lines):
        if "odoo.conf: |+" in line:
            start_line = i
        elif start_line is not None and line.startswith("    "):
            end_line = i
        elif start_line is not None and not line.startswith("    "):
            break

    if start_line is not None and end_line is not None:
        new_addons_path: str = get_submodules_from_extra_addons_folder()
        for i in range(start_line + 1, end_line + 1):
            if lines[i].strip().startswith("addons_path ="):
                lines[i] = (
                    "    addons_path = /usr/lib/python3/dist-packages/odoo/addons, "
                    + new_addons_path
                    + "\n"
                )

    with open("modified_config_map.yaml", "w", encoding="utf-8") as f:
        f.writelines(lines)


def main():
    generate_new_configmap()


if __name__ == "__main__":
    main()
