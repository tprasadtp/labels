#!/usr/bin/python3

"""
Sync requirements.txt with setup.py
---
Expects setup.py/pyproject.toml and requirements.txt to be already present.
Also expects `install_requires=[***]` to be present in the setup.py.
also Expects pyproject.toml contains requires=[***]
Otherwise script won't update it.
"""

from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from typing import List

import fileinput
import logging
import re


log = logging.getLogger()
log.setLevel(logging.INFO)
# create console handler and set level to debug
ch = logging.StreamHandler()
ch.setFormatter(logging.Formatter('[ %(levelname)-6s ] '
                                  '%(lineno)3d  %(message)s'))
log.addHandler(ch)

SETUP_PATTERN = r'install_requires=\[*.*\]'
PYPROJECT_PATTERN = r'requires\s*=\s*\[*.*\]'


def requirements_list() -> List[str]:
    """
    Get a list of deps from requirements.txt
    Also remove comments and filter empty lines
    returns: List of requiremets
    rtype: List
    """
    log.info("Reading requirements.txt")
    with open('requirements.txt') as f:
        lines = f.read().splitlines()
        lc = []
        for l in lines:
            _line = l.partition('#')[0].strip().rstrip()
            if _line:
                log.debug(f"Requirement: {_line}")
                lc.append(_line)
        return lc


def sync_setup(file: str,
               pattern: str,
               prefix: str,
               backup: bool = False) -> None:
    """
    Sync setup.py/pyproject.toml with requirements.txt
    """
    log.info(f"Inplace replace {file}")

    with fileinput.input(files=(file),
                         inplace=True,
                         mode='rU',
                         backup=backup) as s:
        sync_string = requirements_list()
        log.debug("Searching for pattern")

        for line in s:
            if 'requires = ["flit"]' in line:
                log.info("Skip flit tool deps")
            else:
                line = re.sub(pattern,
                              f"{prefix}{sync_string}",
                              line.rstrip())
            log.debug(f":::Write: {line}:::")
            print(line.rstrip())
    log.info(f"Replacement successful with {sync_string}")


if __name__ == "__main__":
    parser = ArgumentParser(description=__doc__.partition('---')[0],
                            epilog=__doc__.partition('---')[2],
                            add_help=True,
                            formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("-v", "--verbose",
                        default=False,
                        action="store_true",
                        help="Verbose Logging")
    parser.add_argument("-b", "--backup",
                        default=False,
                        action="store_true",
                        help="Backup before sync")
    parser.add_argument("--flit",
                        help="Use Flit instead",
                        action="store_true",
                        default=False)
    args = parser.parse_args()
    if args.verbose:
        log.setLevel(logging.DEBUG)

    if args.flit:
        sync_setup(file="pyproject.toml",
                   pattern=PYPROJECT_PATTERN,
                   prefix="requires = ",
                   backup=args.backup)
    else:
        sync_setup(file="setup.py",
                   pattern=SETUP_PATTERN,
                   prefix="install_requires=",
                   backup=args.backup)
