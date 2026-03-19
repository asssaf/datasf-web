import click
from click.testing import CliRunner
import sys
import os

# Add the root directory to sys.path to allow importing from the app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import cli

def test_cli_help():
    runner = CliRunner()
    result = runner.invoke(cli, ['--help'])
    assert result.exit_code == 0
    assert 'Show this message and exit.' in result.output

def test_cli_query_with_args():
    runner = CliRunner()
    # Test with multiple query arguments
    result = runner.invoke(cli, ['query', '--param', 'key1=value1', '--param', 'key2=value2'])
    assert result.exit_code == 0
    assert 'Querying with arguments: {\'key1\': \'value1\', \'key2\': \'value2\'}' in result.output

def test_cli_query_invalid_arg_format():
    runner = CliRunner()
    # Test with invalid parameter format
    result = runner.invoke(cli, ['query', '--param', 'invalid_format'])
    assert result.exit_code != 0
    assert 'Error: Invalid parameter format' in result.output
