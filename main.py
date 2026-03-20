import click
from api_client import APIClient

@click.group()
def cli():
    """A CLI app that executes a rest api which performs a query with multiple arguments."""
    pass

@cli.command()
@click.option('--base-url', default='https://api.example.com', help='Base URL of the REST API.')
@click.option('--endpoint', default='endpoint', help='API endpoint to query.')
@click.option('--param', multiple=True, help='Query parameters in key=value format.')
def query(base_url, endpoint, param):
    """Execute a query with multiple arguments."""
    query_params = {}
    for p in param:
        if '=' not in p:
            raise click.ClickException(f"Invalid parameter format: '{p}'. Use key=value.")
        key, value = p.split('=', 1)
        query_params[key] = value
    
    click.echo(f"Querying {base_url}/{endpoint} with arguments: {query_params}")
    
    client = APIClient(base_url)
    try:
        response = client.get(endpoint, params=query_params)
        click.echo(f"API Response [{response.status_code}]: {response.text}")
    except Exception as e:
        raise click.ClickException(f"API Request failed: {str(e)}")

if __name__ == '__main__':
    cli()
