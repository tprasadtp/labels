import pytest

from labels import utils


@pytest.mark.usefixtures("unset_env_github_actions")
@pytest.mark.parametrize(
    "remote_url",
    [
        "git@github.com:pytest-dev/pytest.git\n",
        "https://github.com/pytest-dev/pytest.git\n",
        "git@github.com/pytest-dev/pytest\n",
        "https://github.com/pytest-dev/pytest\n",
    ],
    ids=["ssh", "https", "ssh_no_git", "https_no_git"],
)
def test_load_repository_info(mock_repo_info):
    """Test that load_repository_info() works for both SSH and HTTPS URLs."""

    repo = utils.load_repository_info()
    assert repo.owner == "pytest-dev"
    assert repo.name == "pytest"
    assert mock_repo_info.called


@pytest.mark.usefixtures("unset_env_github_actions")
def test_load_repository_info_error(mock_repo_info_error):
    """Test that load_repository_info() handles errors."""

    repo = utils.load_repository_info()
    assert repo is None
    assert mock_repo_info_error.called


@pytest.mark.usefixtures("unset_env_github_actions")
def test_load_repository_bad_url(mock_repo_info_bad_url):
    """Test that load_repository_info() handles bad URLs."""

    repo = utils.load_repository_info()
    assert repo is None
    assert mock_repo_info_bad_url.called


@pytest.mark.usefixtures("set_env_github_actions")
def test_load_repository_info_from_env_valid(monkeypatch):
    """Test when GITHUB_ACTIONS is true and a valid repo is set"""
    monkeypatch.setenv("GITHUB_REPOSITORY", "pytest-dev/pytest")
    repo = utils.load_repository_info()
    assert repo.owner == "pytest-dev"
    assert repo.name == "pytest"


@pytest.mark.usefixtures("set_env_github_actions")
@pytest.mark.parametrize(
    "github_repository_env",
    ["", "pytest-dev", "pytest/pytest/pytest"],
    ids=["empty-env", "too_short", "too_long"],
)
def test_load_repository_info_from_env_invalid(monkeypatch, github_repository_env):
    """Test when GITHUB_ACTIONS is true and a valid repo is set"""
    monkeypatch.setenv("GITHUB_REPOSITORY", github_repository_env)
    repo = utils.load_repository_info()
    assert repo is None


@pytest.mark.usefixtures("unset_env_github_actions")
@pytest.mark.parametrize(
    "github_repository_env", ["", "pytest-dev"], ids=["empty-env", "valid-env"],
)
@pytest.mark.parametrize(
    "remote_url",
    [
        "git@github.com:pytest-dev/pytest.git\n",
        "https://github.com/pytest-dev/pytest.git\n",
        "git@github.com/pytest-dev/pytest\n",
        "https://github.com/pytest-dev/pytest\n",
    ],
    ids=["ssh", "https", "ssh_no_git", "https_no_git"],
)
def test_load_repository_info_from_env_disabled(
    monkeypatch, github_repository_env, mock_repo_info
):
    """Test when GITHUB_ACTIONS is true and a valid repo is set"""
    monkeypatch.setenv("GITHUB_REPOSITORY", github_repository_env)
    repo = utils.load_repository_info()
    assert repo.owner == "pytest-dev"
    assert repo.name == "pytest"
    assert mock_repo_info.called
