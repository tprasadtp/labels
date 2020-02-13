import logging
import os
import re
import shlex
import subprocess
import typing

from labels.github import Repository

REMOTE_REGEX = re.compile(
    r"^(https|git)(:\/\/|@)github\.com[\/:](?P<owner>[^\/:]+)\/(?P<name>.*?)(\.git)?$"
)


def load_repository_info(remote_name: str = "origin") -> typing.Optional[Repository]:
    """Load repository information from the local working tree.

    HTTPS url format -> 'https://github.com/owner/name.git'
    SSH   url format -> 'git@github.com:owner/name.git'
    """
    logger = logging.getLogger("labels")

    if os.environ.get("GITHUB_ACTIONS", "false") == "true":
        logging.info("Running in GitHub Actions")
        _gh_repo = os.environ.get("GITHUB_REPOSITORY", None)

        _repo = None
        _owner = None

        if _gh_repo is not None:
            if len(_gh_repo.split("/")) == 2:
                _repo = _gh_repo.split("/")[1]
                _owner = _gh_repo.split("/")[0]
            if _repo is not None and _owner is not None:
                logging.info("Determined Repository is {_repo}, and owner is {_owner}")
                return Repository(owner=_owner, name=_repo)
            else:
                logging.debug("Error! malformed GITHUB_REPOSITORY env variable.")

        return None

    else:
        logger.debug(f"Load repository information for '{remote_name}'.")

        proc = subprocess.run(
            shlex.split(f"git remote get-url {remote_name}"),
            stdout=subprocess.PIPE,
            encoding="utf-8",
        )

        if proc.returncode != 0:
            logger.debug(f"Error running git remote get-url.")
            return None

        remote_url = proc.stdout.strip()
        match = REMOTE_REGEX.match(remote_url)

        if match is None:
            logger.debug(f"No match for remote URL: {remote_url}.")
            return None

        return Repository(owner=match.group("owner"), name=match.group("name"))
